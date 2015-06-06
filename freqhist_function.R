# 'create.hist.freq
# 'read.hist.freq
#
create.hist.freq<-function(date.begin,date.end,
                           input.path,input.filename,
                           input.filetype, hist.file,
                           hist.breaks,
                           lower.bound=NULL,
                           filter.scale=1)
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
    if (input.filetype==1) { 
      file<-paste(input.path,"/",yyyymm.v[d],"/",input.filename,yyyymmdd.v[d],".nc",sep="")
    } else if (input.filetype==2) { 
      file<-paste(input.path,"/",yyyymm.v[d],"/",input.filename,yyyymmdd.v[d],"_",yyyymmdd.v[d],".nc",sep="")
    }
    if (file.exists(file)) {
      flag.filefound<-T
      break
    }
  }
  #check
  if (!flag.filefound) return(F) 
  #ext<-error_exit(paste("Reanalysis files not found \n",sep=""))
  # set raster files for reanalysis data (ra) and gridded observations (ob)
  nc <- open.ncdf(file)
#  data <- get.var.ncdf(nc)
  if (input.filetype==1) {
    dx<-nc$dim$easting$vals[2]-nc$dim$easting$vals[1]
    ex.xmin<-min(nc$dim$easting$vals)-dx/2
    ex.xmax<-max(nc$dim$easting$vals)+dx/2
    dy<-nc$dim$northing$vals[2]-nc$dim$northing$vals[1]
    ex.ymin<-min(nc$dim$northing$vals)-dy/2
    ex.ymax<-max(nc$dim$northing$vals)+dy/2
    nx<-nc$dim$easting$len
    ny<-nc$dim$northing$len
  } else if (input.filetype==2) {
    dx<-nc$dim$X$vals[2]-nc$dim$X$vals[1]
    ex.xmin<-min(nc$dim$X$vals)-dx/2
    ex.xmax<-max(nc$dim$X$vals)+dx/2
    dy<-nc$dim$Y$vals[2]-nc$dim$Y$vals[1]
    ex.ymin<-min(nc$dim$Y$vals)-dy/2
    ex.ymax<-max(nc$dim$Y$vals)+dy/2
    nx<-nc$dim$X$len
    ny<-nc$dim$Y$len
  }
  close.ncdf(nc)
# Define raster variable "r"
  r <-raster(ncol=nx, nrow=ny,
             xmn=ex.xmin, xmx=ex.xmax,
             ymn=ex.ymin, ymx=ex.ymax)
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
    if (input.filetype==1) { 
      file<-paste(input.path,"/",yyyymm.v[d],"/",input.filename,yyyymmdd.v[d],".nc",sep="")
    } else if (input.filetype==2) { 
      file<-paste(input.path,"/",yyyymm.v[d],"/",input.filename,yyyymmdd.v[d],"_",yyyymmdd.v[d],".nc",sep="")
    }
    if (!file.exists(file)) next
    print(file)
    nc<-open.ncdf(file)
    data<-get.var.ncdf(nc)
    close.ncdf(nc)
    r[]<-t(data)
    data<-getValues(r)
    if (filter.scale!=1) { 
      r.filt<-focal(r,w=matrix(1,nc=filter.scale,nr=filter.scale),fun=mean,na.rm=T)
      r<-r.filt
      rm(r.filt)
    }
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
                        nx,ny,dx,dy,                     # 2 3 4 5
                        ex.xmin,ex.ymin,ex.xmax,ex.ymax, # 6 7 8 9 
                        n.r,                             # 10
                        filter.scale,                    # 11
                        n.bins)),                        # 12
                        f,size=4) 
  writeBin(as.numeric(c(length(hist.breaks),hist.breaks)),f,size=4)
  for (i in 1:n.r) {
    pos.no0<-which(bin.mat[i,1:n.bins]!=0)
    val.no0<-bin.mat[i,pos.no0]
    n.no0<-length(pos.no0)
    if (n.no0==0) next
    writeBin(as.numeric(c(i,rowgrid[i],colgrid[i],n.no0,pos.no0,val.no0)),f,size=4)
  }
  writeBin(as.numeric(c(0,0,0,0)),f,size=4)
  close(f)
  return(T)
} # end of function create.hist.freq

#
read.hist.freq.header<-function(f)
{
  head<-readBin(f,numeric(),size=4,n=9)
  hist.n<-readBin(f,numeric(),size=4,n=1)
  breaks<-readBin(f,numeric(),size=4,n=hist.n)
  return(list(file.type=head[1], file.eof=NULL,
              grid.nx=head[2],grid.ny=head[3],grid.dx=head[4],grid.dy=head[5],
              grid.xmn=head[6],grid.ymn=head[7],grid.xmx=head[8],grid.ymx=head[9],
              grid.ncell=head[10],
              grid.filterscale=head[11],
              hist.nbins=head[12],
              hist.breaks=breaks,
              hist.freq.vec=NULL,
              hist.freq.mat=NULL))
} # end of function read.hist.freq.header

#
read.hist.freq.next<-function(f,hist.header)
{
  aux<-readBin(f,numeric(),size=4,n=4)
  i<-aux[1]
  if (i==0) {
    return(list(file.type=hist.header$file.type, file.eof=T,
                grid.nx=hist.header$grid.nx,grid.ny=hist.header$grid.ny,
                grid.dx=hist.header$grid.dx,grid.dy=hist.header$grid.dy,
                grid.xmn=hist.header$grid.xmn,grid.ymn=hist.header$grid.ymn,
                grid.xmx=hist.header$grid.xmx,grid.ymx=hist.header$grid.ymx,
                grid.ncell=hist.header$grid.ncell,
                grid.filterscale=hist.header$grid.filterscale,
                hist.nbins=hist.header$hist.nbins,
                hist.breaks=hist.header$hist.breaks,
                hist.freq.vec=NULL,
                hist.freq.mat=NULL))
  }
  vec<-vector(mode="numeric",length=hist.header$n.bins)
  vec[]<-0
  n.n0<-aux[4]
  pos.no0<-readBin(f,numeric(),size=4,n=n.n0)
  val.no0<-readBin(f,numeric(),size=4,n=n.n0)
  vec[pos.no0]<-val.no0
  return(list(file.type=hist.header$file.type, file.eof=F,
              grid.nx=hist.header$grid.nx,grid.ny=hist.header$grid.ny,
              grid.dx=hist.header$grid.dx,grid.dy=hist.header$grid.dy,
              grid.xmn=hist.header$grid.xmn,grid.ymn=hist.header$grid.ymn,
              grid.xmx=hist.header$grid.xmx,grid.ymx=hist.header$grid.ymx,
              grid.ncell=hist.header$grid.ncell,
              grid.filterscale=hist.header$grid.filterscale,
              hist.nbins=hist.header$hist.nbins,
              hist.breaks=hist.header$hist.breaks,
              hist.freq.vec=vec,
              hist.freq.mat=NULL))
} # end of function read.hist.freq.next

#
#read.hist.freq.tot<-function(hist.file)
#{
#  if (missing(hist.file)) stop("read.hist.freq: must provide a file name")
#  if (!file.exists(hist.file)) stop("read.hist.freq: file not found")
#  f<-file(hist.file,"rb")
#  hist<-read.hist.freq.header(f)
#  aux.bin.mat<-matrix(nrow=nc,ncol=nb)
#  aux.bin.mat[]<-0
#  killerloop<-T
#  count<-0
#  while (killerloop) {
#    aux<-readBin(f,numeric(),size=4,n=4)
#    i<-aux[1]
#    if (i==0) break
#    n.n0<-aux[4]
#    pos.no0<-readBin(f,numeric(),size=4,n=n.n0)
#    val.no0<-readBin(f,numeric(),size=4,n=n.n0)
#    aux.bin.mat[i,pos.no0]<-val.no0
#    count<-count+1
#    if (count>100000000) break
#  }
#  close(f)
#  if (count>100000000) return(F) 
#  return(list(filetype=head[1],
#              nx=head[2],ny=head[3],dx=head[4],dy=head[5],
#              xmin=head[6],ymin=head[7],xmax=head[8],ymax=head[9],
#              ncell=head[10],
#              n.bins=head[11],
#              filter.scale=head[12],
#              hist.breaks=breaks,
#              bin.vec=NULL,
#              bin.mat=aux.bin.mat,
#              eof=NULL))
#} # end of function read.hist.freq



