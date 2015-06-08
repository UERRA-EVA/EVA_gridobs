#
to_density<-function(freq,breaks) {
  # first bin is supposed to have freq=0, because breaks[1] < min value in data
  breaks.width<-c(1,diff(breaks))
  dens<-freq/(breaks.width*sum(freq))
  return(dens)
} # end of function to_density

#
check.freq.break<-function(freq1,freq2,breaks1,breaks2) {
  if ( sum(freq1)==0 | sum(freq2)==0 | 
       any(is.na(freq1)) | any(is.na(freq2)) ) {
#    print("pdfs.overlapping.score: freq must be non-zero somewhere and not NAs are allowed")
    return(F)
  }
  if (any(breaks1!=breaks2) | length(breaks1)!=length(breaks2)) {
#    print("pdfs.overlapping.score: breaks must be the same")
    return(F)
  }
  return(T)
} # end of function check.freq.break

#+
pdfs.overlapping.score<-function(freq1,freq2,breaks1,breaks2) {
  chk<-check.freq.break(freq1,freq2,breaks1,breaks2)
  if (!chk) return(0)
  dens1<-to_density(freq1,breaks1)
  dens2<-to_density(freq2,breaks2)
  score<-sum(pmin(dens1,dens2))
  return(score)
} # end of function pdfs.overlapping.score

#+ 
ks.test.wilks<-function(freq1,freq2,breaks1,breaks2,alpha) {
  ks<-list(Ds=NA,Ds.thresh=NA,Test=NA)
  chk<-check.freq.break(freq1,freq2,breaks1,breaks2)
  if (!chk) return(NA)
  dens1<-to_density(freq1,breaks1)
  dens2<-to_density(freq2,breaks2)
  sum.f1<-sum(freq1)
  sum.f2<-sum(freq2)
  d.threshold<-(-0.5*(1/sum.f1+1/sum.f2)*log(alpha/2))**0.5
  ks$Ds<-max(abs(cumsum(dens1)-cumsum(dens2)))
  ks$Test<-1
  if (ks$Ds>d.threshold) ks$Test<-0
  ks$Ds.thresh<-d.threshold
  return(ks)
} # end of function ks.test.wilks

#
#pdf.overlapping.score.grid<-function(hist.freq1,hist.freq2) {
#  score<-vector(mode="numeric",length=hist.freq1$ncell)
#  for (i in 1:hist.freq1$ncell) 
#    score[i]<-pdfs.overlapping.score(freq1=hist.freq1$bin.mat[i,],
#                                     freq2=hist.freq2$bin.mat[i,],
#                                     breaks1=hist.freq1$hist.breaks,
#                                     breaks2=hist.freq2$hist.breaks)
#  return(score)
#} # end of function pdf.overlapping.score.grid

#
#ks.test.wilks.grid<-function(hist.freq1,hist.freq2,aplha) {
#  Ds<-vector(mode="numeric",length=hist.freq1$ncell)
#  Tst<-vector(mode="numeric",length=hist.freq1$ncell)
#  Thr<-vector(mode="numeric",length=hist.freq1$ncell)
#  for (i in 1:hist.freq1$ncell) { 
#    ks<-ks.test.wilks(freq1=hist.freq1$bin.mat[i,],
#                      freq2=hist.freq2$bin.mat[i,],
#                      alpha=alpha,
#                      breaks1=hist.freq1$hist.breaks,
#                      breaks2=hist.freq2$hist.breaks)
#    Ds[i]<-ks$Ds
#    Tst[i]<-ks$test
#    Thr[i]<-ks$Ds.thresh
#  }
#  return(list(Ds=Ds,Test=Tst,Ds.thres=Thr,alpha=alpha))
#} # end of function ks.test.wilks.grid

#
pdf.overlapping.score.grid.memsaver<-function(hist.file1,hist.file2) {
  if (missing(hist.file1) | missing(hist.file2)) 
    stop("pdf.overlapping.score.grid.memsaver: must provide a file name")
  if (!file.exists(hist.file1) | !file.exists(hist.file2)) 
    stop("pdf.overlapping.score.grid.memsaver: file not found")
  f1<-file(hist.file1,"rb")
  hist.header1<-read.hist.freq.header(f1)
  f2<-file(hist.file2,"rb")
  hist.header2<-read.hist.freq.header(f2)
print(hist.header1)
print(hist.header2)
  score<-vector(mode="numeric",length=hist.header1$grid.ncell)
  score[]<-NA
  for (i in 1:hist.header1$grid.ncell) {
    if ((i%%100000)==0) print(paste(i,hist.header1$grid.ncell,round(i/hist.header1$grid.ncell,2)))
    data1<-read.hist.freq.next(f1,hist.header1)
    data2<-read.hist.freq.next(f2,hist.header2)
    if (!is.null(data1$file.eof) | !is.null(data2$file.eof)) {
      if (data1$file.eof | data2$file.eof) stop("unexpected eof")
    }
    if (!any(is.na(data1$hist.freq.vec)) & !any(is.na(data2$hist.freq.vec))) 
      score[i]<-pdfs.overlapping.score(freq1=data1$hist.freq.vec,
                                       freq2=data2$hist.freq.vec,
                                       breaks1=data1$hist.breaks,
                                       breaks2=data2$hist.breaks)
  }
  close(f1)
  close(f2)
  return( list(pdfscore=score,
               hist.header=hist.header1) )
} # end of function pdf.overlapping.score.grid.memsaver

#
ks.test.wilks.grid.memsaver<-function(hist.file1,hist.file2) {
  if (missing(hist.file1) | missing(hist.file2)) 
    stop("pdf.overlapping.score.grid.memsaver: must provide a file name")
  if (!file.exists(hist.file1) | !file.exists(hist.file2)) 
    stop("pdf.overlapping.score.grid.memsaver: file not found")
  f1<-file(hist.file1,"rb")
  hist.header1<-read.hist.freq.header(f1)
  f2<-file(hist.file2,"rb")
  hist.header2<-read.hist.freq.header(f2)
  Ds<-vector(mode="numeric",length=hist.header1$grid.ncell)
  Tst<-vector(mode="numeric",length=hist.header1$grid.ncell)
  Thr<-vector(mode="numeric",length=hist.header1$grid.ncell)
  for (i in 1:hist.header1$grid.ncell) { 
    data1<-read.hist.freq.next(f1,hist.header1)
    data2<-read.hist.freq.next(f2,hist.header2)
    if (data1$eof | data2$eof) stop("unexpected eof")
    ks<-ks.test.wilks(freq1=data1$hist.freq.vec,
                      freq2=data2$hist.freq.vec,
                      alpha=alpha,
                      breaks1=data1$hist.breaks,
                      breaks2=data2$hist.breaks)
    Ds[i]<-ks$Ds
    Tst[i]<-ks$test
    Thr[i]<-ks$Ds.thresh
  }
  return( list(Ds=Ds,
               Test=Tst,
               Ds.thres=Thr,
               alpha=alpha) )
} # end of function ks.test.wilks.grid.memsaver
