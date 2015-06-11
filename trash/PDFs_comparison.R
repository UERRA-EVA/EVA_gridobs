# << PDFs_comparison.R >>
#
#------------------------------------------------------------------------------
# -- Libraries
library(raster)
library(ncdf)
#..............................................................................
# -- Functions

#+
pdfs.overlapping.score<-function(freq1,freq2) {
  if ( sum(freq1)==0 | sum(freq2)==0 | 
       any(is.na(freq1)) | any(is.na(freq2)) ) return(NA)
  dens1<-freq1/sum(freq1)
  dens2<-freq2/sum(freq2)
  score<-sum(pmin(freq1,freq2))
  return(score)
}

#+ 
ks.test.wilks<-function(freq1,freq2,alpha) {
  ks<-vector(mode="numeric",length=3)
  if ( sum(freq1)==0 | sum(freq2)==0 | 
       any(is.na(freq1)) | any(is.na(freq2)) ) return(NA)
  sum.f1<-sum(freq1)
  sum.f2<-sum(freq2)
  dens1<-freq1/sum.f1
  dens2<-freq2/sum.f2
  d.threshold<-(-0.5*(1/sum.f1+1/sum.f2)*log(alpha/2))**0.5
  ks[1]<-max(abs(cumsum(dens1)-cumsum(dens2)))
  ks[2]<-1
  if (ks[1]>d.threshold) ks[2]<-0
  ks[3]<-d.threshold
  return(ks)
}

# + manage fatal error
error_exit<-function(str=NULL) {
  print("Fatal Error:")
  if (!is.null(str)) print(str)
  quit(status=1)
}
#..............................................................................
# MAIN - MAIN - MAIN - MAIN - MAIN - MAIN - MAIN - MAIN - MAIN - MAIN - MAIN - 
#..............................................................................
# read command line with configuration file
arguments <- commandArgs()
arguments
config.file<-arguments[3]
# checks
if (length(arguments)!=3) 
  ext<-error_exit(paste("Error in command line arguments: \n",
  " R --vanilla configurationFile\n",sep=""))
if (!file.exists(config.file)) ext<-error_exit(paste("configuration file not found \n",
  config.file,"\n",sep=""))
# read config parameters
source(config.file)
#..............................................................................
# set Time-related variables
start.string<-paste(date.b.string,sep="")
end.string<-paste(date.e.string,sep="")
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
print(timeseq)
print(nhour)
print(dayseq)
print(nday)
#..............................................................................
# read (common) grid parameters
flag.filefound<-F
for (d in 1:nday) {
  rafile<-paste(ra.input.path,"/",yyyymm.v[d],"/",ra.input.filename,yyyymmdd.v[d],".nc",sep="")
  if (file.exists(rafile)) {
    flag.filefound<-T
    break
  }
}
#check
if (!flag.filefound) ext<-error_exit(paste("Reanalysis files not found \n",sep=""))
# set raster files for reanalysis data (ra) and gridded observations (ob)
ra<-raster(rafile)
ob<-ra
# extract information on the grid
xy<-xyFromCell(ra,1:ncell(ra))
x<-sort(unique(xy[,1]))
y<-sort(unique(xy[,2]),decreasing=T)
rc<-rowColFromCell(ra,1:ncell(ra))
rowgrid<-rc[,1]
colgrid<-rc[,2]
# note: number of bins is equal to the precipitation.bins.maxvalue
# because we assume each bin is 1mm wide
n.bins<-precipitation.bins.maxvalue
ra.bin.mat<-matrix(nrow=ncell(ra),ncol=n.bins)
ob.bin.mat<-matrix(nrow=ncell(ra),ncol=n.bins)
# read reanalysis
ra.bin.mat[]<-0
jump<-T
if (!jump) {
  for (d in 1:nday) {
    rafile<-paste(ra.input.path,"/",yyyymm.v[d],"/",ra.input.filename,yyyymmdd.v[d],".nc",sep="")
    if (!file.exists(rafile)) next
    print(rafile)
    ra<-raster(rafile)
    ra.data<-getValues(ra)
    storage.mode(ra.data)<-"numeric"
    mask<-which(!is.na(ra.data) & ra.data>=precipitation.dailydef)
    for (i in mask) {
      pos<-min(ceiling(ra.data[i]),precipitation.bins.maxvalue)
      ra.bin.mat[i,pos]<-ra.bin.mat[i,pos]+1
    }
  }
#
  out <- file(ra.output.histtmp, "wb")
  for (i in 1:ncell(ra)) {
    pos.no0<-which(ra.bin.mat[i,1:n.bins]!=0)
    val.no0<-ra.bin.mat[i,pos.no0]
    n.no0<-length(pos.no0)
    if (n.no0==0) next
    writeBin(as.numeric(c(i,rowgrid[i],colgrid[i],n.no0,pos.no0,val.no0)),out,size=4)
  }
  writeBin(as.numeric(c(0,0,0,0)),out,size=4)
  close(out)
}
jump<-F
if (!jump) {
  f<-file(ra.output.histtmp,"rb")
  killerloop<-T
  while (killerloop) {
    aux<-readBin(f,numeric(),size=4,n=4)
    i<-aux[1]
    if (i==0) break
    ra.bin.mat[i,]<-0
    n.n0<-aux[4]
    pos.no0<-readBin(f,numeric(),size=4,n=n.n0)
    val.no0<-readBin(f,numeric(),size=4,n=n.n0)
    ra.bin.mat[i,pos.no0]<-val.no0
  }
  close(f)
}
# read observations 
ob.bin.mat[]<-0
jump<-T
if (!jump) {
  for (d in 1:nday) {
#  seNorge_v2_0_PREC1d_grid_20140131_20140131.nc
    obfile<-paste(ob.input.path,"/",yyyymm.v[d],"/",ob.input.filename,yyyymmdd.v[d],"_",yyyymmdd.v[d],".nc",sep="")
    if (!file.exists(obfile)) next
    print(obfile)
    nc <- open.ncdf(obfile)
    data <- get.var.ncdf(nc)
    close.ncdf(nc)
    ob[]<-NA
    # put data on raster variable (t=transpose)
    ob[]<-t(data)
    ob.data<-getValues(ob)
    storage.mode(ob.data)<-"numeric"
    mask<-which(!is.na(ob.data) & ob.data>=precipitation.dailydef)
    for (i in mask) {
      pos<-min(ceiling(ob.data[i]),precipitation.bins.maxvalue)
      ob.bin.mat[i,pos]<-ob.bin.mat[i,pos]+1
    }
  }
  #
  out <- file(ob.output.histtmp, "wb")
  for (i in 1:ncell(ob)) {
    pos.no0<-which(ob.bin.mat[i,1:n.bins]!=0)
    val.no0<-ob.bin.mat[i,pos.no0]
    n.no0<-length(pos.no0)
    if (n.no0==0) next
    writeBin(as.numeric(c(i,rowgrid[i],colgrid[i],n.no0,pos.no0,val.no0)),out,size=4)
  }
  writeBin(as.numeric(c(0,0,0,0)),out,size=4)
  close(out)
}
#  mat<-matrix(readBin(f,real(),size=4,60000000),ncol=16,byrow=TRUE)
jump<-F
if (!jump) {
  f<-file(ob.output.histtmp,"rb")
  killerloop<-T
  while (killerloop) {
    aux<-readBin(f,numeric(),size=4,n=4)
    i<-aux[1]
    if (i==0) break
    ob.bin.mat[i,]<-0
    n.n0<-aux[4]
    pos.no0<-readBin(f,numeric(),size=4,n=n.n0)
    val.no0<-readBin(f,numeric(),size=4,n=n.n0)
    ob.bin.mat[i,pos.no0]<-val.no0
  }
  close(f)
}
#..............................................................................
# compute scores
ra.density<-vector()
ob.density<-vector()
pdfs.overlapping.score<-vector(mode="numeric",length=ncell(ra))
ks.d<-vector(mode="numeric",length=ncell(ra))
ks.test<-vector(mode="numeric",length=ncell(ra))
pdfs.overlapping.score<-NA
ks.d[]<-NA
ks.test[]<-NA
r.pdfs.overlapping.score<-ra
r.pdfs.overlapping.score[]<-NA
for (i in 1:ncell(ra)) {
  if (i%%10000==0) print(paste(i,ncell(ra),round(i/ncell(ra),2)))
  pdfs.overlapping.score[i]<-pdfs.overlapping.score(ra.bin.mat[i,],ob.bin.mat[i,])
  if (is.na(pdfs.overlapping.score[i])) next
  ks.res<-ks.test.wilks(ra.bin.mat[i,],ob.bin.mat[i,],ks.alpha)
  ks.d[i]<-ks.res[1]
  ks.test[i]<-ks.res[2]
}
#..............................................................................
# write output files
r.out<-ra
r.out[]<-NA
r.out[]<-pdfs.overlapping.score
writeRaster(r.out,filename=score.output.pdf,format="CDF",overwrite=TRUE)
r.out[]<-ks.d
writeRaster(r.out,filename=score.output.ksD,format="CDF",overwrite=TRUE)
r.out[]<-ks.test
writeRaster(r.out,filename=score.output.ksT,format="CDF",overwrite=TRUE)
#..............................................................................
# Exit
print("Success Exit")
q(status=0)
