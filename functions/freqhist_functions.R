# 'get.info.from.nc
# 'create.hist.prec.freq
# 'read.hist.prec.freq.header
# 'read.hist.prec.freq
# 'read.hist.prec.freq.next

get.info.from.nc<-function(nc,filetype) {
    if (filetype==1) {
      dx<-nc$dim$easting$vals[2]-nc$dim$easting$vals[1]
      ex.xmin<-min(nc$dim$easting$vals)-dx/2
      ex.xmax<-max(nc$dim$easting$vals)+dx/2
      dy<-nc$dim$northing$vals[2]-nc$dim$northing$vals[1]
      ex.ymin<-min(nc$dim$northing$vals)-dy/2
      ex.ymax<-max(nc$dim$northing$vals)+dy/2
      nx<-nc$dim$easting$len
      ny<-nc$dim$northing$len
      aux<-att.get.ncdf(nc,"layer","projection")
      projstr<-aux$value
    } else if (filetype==2) {
      dx<-nc$dim$X$vals[2]-nc$dim$X$vals[1]
      ex.xmin<-min(nc$dim$X$vals)-dx/2
      ex.xmax<-max(nc$dim$X$vals)+dx/2
      dy<-nc$dim$Y$vals[2]-nc$dim$Y$vals[1]
      ex.ymin<-min(nc$dim$Y$vals)-dy/2
      ex.ymax<-max(nc$dim$Y$vals)+dy/2
      nx<-nc$dim$X$len
      ny<-nc$dim$Y$len
      aux<-att.get.ncdf(nc,"UTM_Zone_33","proj4")
      projstr<-aux$value
    }
    return(list(dx=dx,dy=dy,
                nx=nx,ny=ny,
                ex.xmin=ex.xmin,ex.xmax=ex.xmax,
                ex.ymin=ex.ymin,ex.ymax=ex.ymax,
                projstr=projstr))
} # end function get.info.from.nc

create.hist.prec.freq<-function(date.begin,date.end,
                                input.path,input.filename,
                                input.filetype, hist.file,
                                hist.breaks,
                                lower.bound=NULL,
                                filter.scale=1,
                                mask.file=NULL,
                                mask.filetype=NULL)
# filetypes:
# 1: NORA10
# 2: seNorge2
# ---
# breaks[1] must be strictly > min value expected in data; 
# breaks[last] must be strictly < min value expected in data;
# breaks[n] a vector giving the breakpoints between histogram cells
{
#..............................................................................
  require(ncdf)
  require(raster)
  # set Time-related variables
  start.string<-paste(date.begin,sep="")
  end.string<-paste(date.end,sep="")
  start.string.day<-paste(substr(start.string,1,10),".01",sep="")
  end.string.day  <-paste(substr(end.string,1,10),".24",sep="")
  start <- strptime(start.string,"%Y.%m.%d","UTC")
  end <- strptime(end.string,"%Y.%m.%d","UTC")
  timeseq<-as.POSIXlt(seq(as.POSIXlt(start),as.POSIXlt(end),by="1 hour"),"UTC")
  nhour<-length(timeseq)
  start.day <- strptime(start.string.day,"%Y.%m.%d.%H","UTC")
  end.day <- strptime(end.string.day,"%Y.%m.%d.%H","UTC")
  dayseq<-as.POSIXlt(seq(as.POSIXlt(start.day),as.POSIXlt(end.day),by="1 day"),"UTC")
  nday<-length(dayseq)
  yyyy.v<-dayseq$year+1900
  mm.v<-dayseq$mon+1
  dd.v<-dayseq$mday
  yyyymm.v<-paste(yyyy.v,formatC(mm.v,width=2,flag="0"),sep="")
  yyyymmdd.v<-paste(yyyy.v,formatC(mm.v,width=2,flag="0"),
                           formatC(dd.v,width=2,flag="0"),sep="")
  #..............................................................................
  # read (common) grid parameters
  flag.filefound<-F
  for (d in 1:nday) {
    file<-paste(input.path,"/",yyyymm.v[d],"/",input.filename,yyyymmdd.v[d],"_",yyyymmdd.v[d],".nc",sep="")
    if (file.exists(file)) {
      flag.filefound<-T
      break
    }
  }
  #check
  if (!flag.filefound) return(F)
  # read mask file
  mask.flag<-F
  if (!is.null(mask.file) & file.exists(mask.file)) {
    mask.flag<-T
    nc <- open.ncdf(mask.file)
    nc.info<-get.info.from.nc(nc,mask.filetype)
    close.ncdf(nc)
# Define raster variable "r"
    r.mask <-raster(ncol=nc.info$nx, nrow=nc.info$ny,
                    xmn=nc.info$ex.xmin, xmx=nc.info$ex.xmax,
                    ymn=nc.info$ex.ymin, ymx=nc.info$ex.ymax,
                    crs=nc.info$projstr)
    r.mask[]<-NA
    data<-get.var.ncdf(nc)
    close.ncdf(nc)
    r.mask[]<-t(data)
  }
  #ext<-error_exit(paste("Reanalysis files not found \n",sep=""))
  # set raster files for reanalysis data (ra) and gridded observations (ob)
  nc <- open.ncdf(file)
  nc.info<-get.info.from.nc(nc,input.filetype)
  close.ncdf(nc)
  nchar.projstr<-nchar(nc.info$projstr)
# Define raster variable "r"
  r <-raster(ncol=nc.info$nx, nrow=nc.info$ny,
             xmn=nc.info$ex.xmin, xmx=nc.info$ex.xmax,
             ymn=nc.info$ex.ymin, ymx=nc.info$ex.ymax,
             crs=nc.info$projstr)
  r[]<-NA
  n.r<-ncell(r)
  # extract information from the grid
  xy<-xyFromCell(r,1:n.r)
  x<-sort(unique(xy[,1]))
  y<-sort(unique(xy[,2]),decreasing=T)
  rc<-rowColFromCell(r,1:n.r)
  rowgrid<-rc[,1]
  colgrid<-rc[,2]
  n.bins<-length(hist.breaks)
  bin.mat<-matrix(nrow=n.r,ncol=n.bins)
  # read reanalysis
  bin.mat[]<-0
  for (d in 1:nday) {
    file<-paste(input.path,"/",yyyymm.v[d],"/",input.filename,yyyymmdd.v[d],"_",yyyymmdd.v[d],".nc",sep="")
    if (!file.exists(file)) next
    print(file)
    nc<-open.ncdf(file)
    data<-get.var.ncdf(nc)
    close.ncdf(nc)
    r[]<-t(data)
    if (filter.scale!=1) { 
      r.filt<-focal(r,w=matrix(1,nc=filter.scale,nr=filter.scale),fun=mean,na.rm=T)
      r<-r.filt
      rm(r.filt)
    }
    if (mask.flag) {
      r.aux<-mask(r,r.mask)
      r<-r.aux
      rm(r.aux)
    }
    data<-getValues(r)
    storage.mode(data)<-"numeric"
    mask<-which(!is.na(data) & data>=lower.bound)
    for (i in mask) {
      pos<-match(1,ceiling(data[i]/hist.breaks))
      if (is.na(pos)) pos<-length(hist.breaks)
      bin.mat[i,pos]<-bin.mat[i,pos]+1
    }
  }
  # Output
  f <- file(hist.file, "wb")
  writeBin(as.numeric(c(input.filetype,                  # 1
                        nc.info$nx,nc.info$ny,           # 2 3
                        nc.info$dx,nc.info$dy,           # 4 5
                        nc.info$ex.xmin,nc.info$ex.ymin, # 6 7
                        nc.info$ex.xmax,nc.info$ex.ymax, # 8 9 
                        n.r,                             # 10
                        filter.scale                     # 11
                        )),        
                        f,size=4)
  writeBin(as.numeric(nchar.projstr),f,size=4) 
  writeChar(nc.info$projstr,nchars=nchar.projstr,con=f,eos=NULL) 
  writeBin(as.numeric(n.bins),f,size=4) 
  writeBin(as.numeric(c(length(hist.breaks),hist.breaks)),f,size=4)
  for (i in 1:n.r) {
    pos.no0<-which(bin.mat[i,1:n.bins]!=0)
    val.no0<-bin.mat[i,pos.no0]
    n.no0<-length(pos.no0)
    if (n.no0==0) {
      writeBin(as.numeric(c(i,rowgrid[i],colgrid[i],n.no0)),f,size=4)
    } else {
      writeBin(as.numeric(c(i,rowgrid[i],colgrid[i],n.no0,pos.no0,val.no0)),f,size=4)
    }
  }
  writeBin(as.numeric(c(0,0,0,0)),f,size=4)
  close(f)
  return(T)
} # end of function create.hist.prec.freq

#
read.hist.prec.freq.header<-function(f)
{
  head<-readBin(f,numeric(),size=4,n=11)
  nchar<-readBin(f,numeric(),size=4,n=1)
  proj<-readChar(f,nchars=nchar)
  nbins<-readBin(f,numeric(),size=4,n=1)
  hist.n<-readBin(f,numeric(),size=4,n=1)
  breaks<-readBin(f,numeric(),size=4,n=hist.n)
  return(list(file.type=head[1], file.eof=NULL,
              grid.nx=head[2],grid.ny=head[3],grid.dx=head[4],grid.dy=head[5],
              grid.xmn=head[6],grid.ymn=head[7],grid.xmx=head[8],grid.ymx=head[9],
              grid.ncell=head[10],
              grid.filterscale=head[11],
              grid.proj=proj,
              hist.nbins=nbins,
              hist.breaks=breaks,
              hist.freq.vec=NULL,
              hist.freq.mat=NULL))
} # end of function read.hist.prec.freq.header

#
read.hist.prec.freq.next<-function(f,hist.header)
{
  aux<-readBin(f,numeric(),size=4,n=4)
  # eof
  if (aux[1]==0) {
    return(list(file.type=hist.header$file.type, file.eof=T,
                grid.nx=hist.header$grid.nx,grid.ny=hist.header$grid.ny,
                grid.dx=hist.header$grid.dx,grid.dy=hist.header$grid.dy,
                grid.xmn=hist.header$grid.xmn,grid.ymn=hist.header$grid.ymn,
                grid.xmx=hist.header$grid.xmx,grid.ymx=hist.header$grid.ymx,
                grid.ncell=hist.header$grid.ncell,
                grid.filterscale=hist.header$grid.filterscale,
                grid.proj=hist.header$grid.proj,
                hist.nbins=hist.header$hist.nbins,
                hist.breaks=hist.header$hist.breaks,
                hist.freq.vec=NULL,
                hist.freq.mat=NULL))
  }
  # not eof
  vec<-vector(mode="numeric",length=hist.header$hist.nbins)
  vec[]<-NA
  n.no0<-aux[4]
  if (n.no0!=0) {
    vec[]<-0
    pos.no0<-readBin(f,numeric(),size=4,n=n.no0)
    val.no0<-readBin(f,numeric(),size=4,n=n.no0)
    vec[pos.no0]<-val.no0
  }
  return(list(file.type=hist.header$file.type, file.eof=F,
              grid.nx=hist.header$grid.nx,grid.ny=hist.header$grid.ny,
              grid.dx=hist.header$grid.dx,grid.dy=hist.header$grid.dy,
              grid.xmn=hist.header$grid.xmn,grid.ymn=hist.header$grid.ymn,
              grid.xmx=hist.header$grid.xmx,grid.ymx=hist.header$grid.ymx,
              grid.ncell=hist.header$grid.ncell,
              grid.filterscale=hist.header$grid.filterscale,
              grid.proj=hist.header$grid.proj,
              hist.nbins=hist.header$hist.nbins,
              hist.breaks=hist.header$hist.breaks,
              hist.freq.vec=vec,
              hist.freq.mat=NULL))
} # end of function read.hist.prec.freq.next
