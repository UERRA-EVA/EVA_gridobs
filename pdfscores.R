#
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
  ks<-list(Ds=NA,Ds.thresh=NA,Test=NA)
  if ( sum(freq1)==0 | sum(freq2)==0 | 
       any(is.na(freq1)) | any(is.na(freq2)) ) return(ks)
  sum.f1<-sum(freq1)
  sum.f2<-sum(freq2)
  dens1<-freq1/sum.f1
  dens2<-freq2/sum.f2
  d.threshold<-(-0.5*(1/sum.f1+1/sum.f2)*log(alpha/2))**0.5
  ks$Ds<-max(abs(cumsum(dens1)-cumsum(dens2)))
  ks$Test<-1
  if (ks$Ds>d.threshold) ks$Test<-0
  ks$Ds.thresh<-d.threshold
  return(ks)
}

#
pdf.overlapping.score.grid<-function(freqhist1,freqhist2) {
  score<-vector(mode="numeric",length=freqhist1$ncell)
  for (i in 1:freqhist1$ncell) 
    score[i]<-pdfs.overlapping.score(freqhist1$bin.mat[i,],freqhist2$bin.mat[i,])
  return(score)
} # end of function pdf.overlapping.score.grid

#
ks.test.wilks.grid<-function(freqhist1,freqhist2,aplha) {
  Ds<-vector(mode="numeric",length=freqhist1$ncell)
  Tst<-vector(mode="numeric",length=freqhist1$ncell)
  Thr<-vector(mode="numeric",length=freqhist1$ncell)
  for (i in 1:freqhist1$ncell) { 
    ks<-ks.test.wilks(freqhist1$bin.mat[i,],freqhist2$bin.mat[i,],alpha)
    Ds[i]<-ks$Ds
    Tst[i]<-ks$test
    Thr[i]<-ks$Ds.thresh
  }
  return(list(Ds=Ds,Test=Tst,Ds.thres=Thr,alpha=alpha))
} # end of function ks.test.wilks.grid

#
pdf.overlapping.score.grid.memsaver<-function(hist.file1,hist.file2) {
  if (missing(hist.file1) | missing(hist.file2)) 
    stop("pdf.overlapping.score.grid.memsaver: must provide a file name")
  if (!file.exists(hist.file1) | !file.exists(hist.file2)) 
    stop("pdf.overlapping.score.grid.memsaver: file not found")
  f1<-file(hist.file1,"rb")
  hist.header1<-read.freq.hist.header(f1)
  f2<-file(hist.file2,"rb")
  hist.header2<-read.freq.hist.header(f2)
  score<-vector(mode="numeric",length=hist.header1$ncell)
  for (i in 1:hist.header1$ncell) { 
    hist.freq1<-read.freq.hist.next(f1,hist.header1)
    hist.freq2<-read.freq.hist.next(f2,hist.header2)
    if (hist.freq1$eof | hist.freq2$eof) stop("unexpected eof")
    score[i]<-pdfs.overlapping.score(hist.freq1$bin.vec[],hist.freq2$bin.vec[])
  }
  return(score)
} # end of function pdf.overlapping.score.grid.memsaver

#
ks.test.wilks.grid.memsaver<-function(hist.file1,hist.file2) {
  if (missing(hist.file1) | missing(hist.file2)) 
    stop("pdf.overlapping.score.grid.memsaver: must provide a file name")
  if (!file.exists(hist.file1) | !file.exists(hist.file2)) 
    stop("pdf.overlapping.score.grid.memsaver: file not found")
  f1<-file(hist.file1,"rb")
  hist.header1<-read.freq.hist.header(f1)
  f2<-file(hist.file2,"rb")
  hist.header2<-read.freq.hist.header(f2)
  Ds<-vector(mode="numeric",length=hist.header1$ncell)
  Tst<-vector(mode="numeric",length=hist.header1$ncell)
  Thr<-vector(mode="numeric",length=hist.header1$ncell)
  for (i in 1:hist.header1$ncell) { 
    hist.freq1<-read.freq.hist.next(f1,hist.header1)
    hist.freq2<-read.freq.hist.next(f2,hist.header2)
    if (hist.freq1$eof | hist.freq2$eof) stop("unexpected eof")
    ks<-ks.test.wilks(hist.freq1$bin.vec[],hist.freq2$bin.vec[],alpha)
    Ds[i]<-ks$Ds
    Tst[i]<-ks$test
    Thr[i]<-ks$Ds.thresh
  }
  return(list(Ds=Ds,Test=Tst,Ds.thres=Thr,alpha=alpha))
} # end of function ks.test.wilks.grid.memsaver
