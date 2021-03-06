#
to_density<-function(freq,breaks) {
  # first bin is supposed to have freq=0, because breaks[1] < min value in data
  # bin value marks the end of the aggregation interval
  breaks.width<-c(1,diff(breaks))
  dens<-freq/(breaks.width*sum(freq))
  return(dens)
} # end of function to_density

#+ Determines the mode given the histogram frequencies
hist.mode<-function(freq,breaks) {
  dens<-to_density(freq,breaks)
  mode.indx<-min(which(dens==max(dens,na.rm=T)))
  mode<-NA
  if (length(mode.indx)>0) 
    mode<-mean(breaks[(mode.indx-1):mode.indx])
  return(list(value=mode,index=mode.indx))
} # end of function hist.mode

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
mode.diff<-function(freq1,freq2,breaks1,breaks2) {
  chk<-check.freq.break(freq1,freq2,breaks1,breaks2)
  if (!chk) return(0)
  mode1<-hist.mode(freq1,breaks1)
  mode2<-hist.mode(freq2,breaks2)
  score<-mode1$value - mode2$value
  return(score)
} # end of function mode.Diff

#+
mode.RelErr.score<-function(freq1,freq2,breaks1,breaks2) {
  chk<-check.freq.break(freq1,freq2,breaks1,breaks2)
  if (!chk) return(0)
  mode1<-hist.mode(freq1,breaks1)
  mode2<-hist.mode(freq2,breaks2)
  score<-(mode1$value/mode2$value-1)*100
  return(score)
} # end of function mode.RelErr.score


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

#..............................................................................
# GRID - GRID - GRID - GRID - GRID - GRID - GRID - GRID - GRID - GRID - GRID - 
#------------------------------------------------------------------------------
#
hist.mode.grid.memsaver<-function(hist.file) {
  if (missing(hist.file)) 
    stop("hist.mode.grid.memsaver: must provide a file name")
  if (!file.exists(hist.file)) 
    stop("hist.mode.grid.memsaver: file not found")
  f<-file(hist.file,"rb")
  hist.header<-read.hist.prec.freq.header(f)
  mode<-vector(mode="numeric",length=hist.header$grid.ncell)
  mode[]<-NA
  for (i in 1:hist.header$grid.ncell) {
    if ((i%%100000)==0) print(paste(i,hist.header$grid.ncell,round(i/hist.header$grid.ncell,2)))
    data<-read.hist.prec.freq.next(f,hist.header)
    if (!is.null(data$file.eof)) {
      if (data$file.eof) stop("unexpected eof")
    }
    if (!any(is.na(data$hist.freq.vec))) { 
      aux<-hist.mode(data$hist.freq.vec,data$hist.breaks)
      mode[i]<-aux$value
    }
  }
  close(f)
  return( list(mode=mode,
               hist.header=hist.header) )
} # end of function hist.mode.grid.memsaver

mode.diff.grid.memsaver<-function(hist.file1,hist.file2) {
  if (missing(hist.file1) | missing(hist.file2)) 
    stop("mode.diff.grid.memsaver: must provide a file name")
  if (!file.exists(hist.file1) | !file.exists(hist.file2)) 
    stop("mode.diff.grid.memsaver: file not found")
  f1<-file(hist.file1,"rb")
  hist.header1<-read.hist.prec.freq.header(f1)
  f2<-file(hist.file2,"rb")
  hist.header2<-read.hist.prec.freq.header(f2)
#  print(hist.header1)
#  print(hist.header2)
  score<-vector(mode="numeric",length=hist.header1$grid.ncell)
  score[]<-NA
  for (i in 1:hist.header1$grid.ncell) {
    if ((i%%100000)==0) print(paste(i,hist.header1$grid.ncell,round(i/hist.header1$grid.ncell,2)))
    data1<-read.hist.prec.freq.next(f1,hist.header1)
    data2<-read.hist.prec.freq.next(f2,hist.header2)
    if (!is.null(data1$file.eof) | !is.null(data2$file.eof)) {
      if (data1$file.eof | data2$file.eof) stop("unexpected eof")
    }
    if (!any(is.na(data1$hist.freq.vec)) & !any(is.na(data2$hist.freq.vec))) 
      score[i]<-mode.diff(freq1=data1$hist.freq.vec,
                          freq2=data2$hist.freq.vec,
                          breaks1=data1$hist.breaks,
                          breaks2=data2$hist.breaks)
  }
  close(f1)
  close(f2)
  return( list(score=score,
               hist.header=hist.header1) )
} # end of function mode.diff.grid.memsaver

#
mode.RelErr.score.grid.memsaver<-function(hist.file1,hist.file2) {
  if (missing(hist.file1) | missing(hist.file2)) 
    stop("mode.RelErr.score.grid.memsaver: must provide a file name")
  if (!file.exists(hist.file1) | !file.exists(hist.file2)) 
    stop("mode.RelErr.score.grid.memsaver: file not found")
  f1<-file(hist.file1,"rb")
  hist.header1<-read.hist.prec.freq.header(f1)
  f2<-file(hist.file2,"rb")
  hist.header2<-read.hist.prec.freq.header(f2)
#  print(hist.header1)
#  print(hist.header2)
  score<-vector(mode="numeric",length=hist.header1$grid.ncell)
  score[]<-NA
  for (i in 1:hist.header1$grid.ncell) {
    if ((i%%100000)==0) print(paste(i,hist.header1$grid.ncell,round(i/hist.header1$grid.ncell,2)))
    data1<-read.hist.prec.freq.next(f1,hist.header1)
    data2<-read.hist.prec.freq.next(f2,hist.header2)
    if (!is.null(data1$file.eof) | !is.null(data2$file.eof)) {
      if (data1$file.eof | data2$file.eof) stop("unexpected eof")
    }
    if (!any(is.na(data1$hist.freq.vec)) & !any(is.na(data2$hist.freq.vec))) 
      score[i]<-mode.RelErr.score(freq1=data1$hist.freq.vec,
                                  freq2=data2$hist.freq.vec,
                                  breaks1=data1$hist.breaks,
                                  breaks2=data2$hist.breaks)
  }
  close(f1)
  close(f2)
  return( list(score=score,
               hist.header=hist.header1) )
} # end of function mode.RelErr.score.grid.memsaver

#
pdf.overlapping.score.grid.memsaver<-function(hist.file1,hist.file2,rm.mode.diff=F) {
  if (missing(hist.file1) | missing(hist.file2)) 
    stop("pdf.overlapping.score.grid.memsaver: must provide a file name")
  if (!file.exists(hist.file1) | !file.exists(hist.file2)){ 
    print("Fatal Error:")
    print(hist.file1)
    print(hist.file2)
    stop("pdf.overlapping.score.grid.memsaver: file not found")
  }
  f1<-file(hist.file1,"rb")
  hist.header1<-read.hist.prec.freq.header(f1)
  f2<-file(hist.file2,"rb")
  hist.header2<-read.hist.prec.freq.header(f2)
#  print(hist.header1)
#  print(hist.header2)
  score<-vector(mode="numeric",length=hist.header1$grid.ncell)
  score[]<-NA
  for (i in 1:hist.header1$grid.ncell) {
    if ((i%%100000)==0) print(paste(i,hist.header1$grid.ncell,round(i/hist.header1$grid.ncell,2)))
    data1<-read.hist.prec.freq.next(f1,hist.header1)
    data2<-read.hist.prec.freq.next(f2,hist.header2)
    if (!is.null(data1$file.eof) | !is.null(data2$file.eof)) {
      if (data1$file.eof | data2$file.eof) stop("unexpected eof")
    }
    if (!any(is.na(data1$hist.freq.vec)) & !any(is.na(data2$hist.freq.vec))) { 
      freq.1<-data1$hist.freq.vec
      freq.2<-data2$hist.freq.vec
      breaks.1<-data1$hist.breaks
      breaks.2<-data2$hist.breaks
      if (rm.mode.diff) {
        mode1<-hist.mode(freq.1,breaks.1)
        mode2<-hist.mode(freq.2,breaks.2)
        if (mode1$value!=mode2$value) {
          max.mode.1or2<-which.max(c(mode1$value,mode2$value))
          mdiff<-as.integer(abs(mode1$index-mode2$index))
          if (max.mode.1or2==1) {
            freq.2<-c(rep(0,mdiff),freq.2[1:(length(freq.2)-mdiff)])
          } else {
            freq.1<-c(rep(0,mdiff),freq.1[1:(length(freq.1)-mdiff)])
          }
        }
      }
      score[i]<-pdfs.overlapping.score(freq1=freq.1,
                                       freq2=freq.2,
                                       breaks1=breaks.1,
                                       breaks2=breaks.2)
    }
  }
  close(f1)
  close(f2)
  return( list(pdfscore=score,
               hist.header=hist.header1) )
} # end of function pdf.overlapping.score.grid.memsaver

#
ks.test.wilks.grid.memsaver<-function(hist.file1,hist.file2,alpha,rm.mode.diff=F) {
  if (missing(hist.file1) | missing(hist.file2)) 
    stop("ks.test.wilks.grid.memsaver: must provide a file name")
  if (!file.exists(hist.file1) | !file.exists(hist.file2)) 
    stop("ks.test.wilks.grid.memsaver: file not found")
  f1<-file(hist.file1,"rb")
  hist.header1<-read.hist.prec.freq.header(f1)
  f2<-file(hist.file2,"rb")
  hist.header2<-read.hist.prec.freq.header(f2)
  Ds<-vector(mode="numeric",length=hist.header1$grid.ncell)
  Tst<-vector(mode="numeric",length=hist.header1$grid.ncell)
  Thr<-vector(mode="numeric",length=hist.header1$grid.ncell)
  Ds[]<-NA
  Tst[]<-NA
  Thr[]<-NA
  for (i in 1:hist.header1$grid.ncell) {
    if ((i%%100000)==0) print(paste(i,hist.header1$grid.ncell,round(i/hist.header1$grid.ncell,2)))
    data1<-read.hist.prec.freq.next(f1,hist.header1)
    data2<-read.hist.prec.freq.next(f2,hist.header2)
    if (!is.null(data1$file.eof) | !is.null(data2$file.eof)) {
      if (data1$file.eof | data2$file.eof) stop("unexpected eof")
    }
    if (!any(is.na(data1$hist.freq.vec)) & !any(is.na(data2$hist.freq.vec))) {
      freq.1<-data1$hist.freq.vec
      freq.2<-data2$hist.freq.vec
      breaks.1<-data1$hist.breaks
      breaks.2<-data2$hist.breaks
      if (rm.mode.diff) {
        mode1<-hist.mode(freq.1,breaks.1)
        mode2<-hist.mode(freq.2,breaks.2)
        if (mode1$value!=mode2$value) {
          max.mode.1or2<-which.max(c(mode1$value,mode2$value))
          mdiff<-as.integer(abs(mode1$index-mode2$index))
          if (max.mode.1or2==1) {
            freq.2<-c(rep(0,mdiff),freq.2[1:(length(freq.2)-mdiff)])
          } else {
            freq.1<-c(rep(0,mdiff),freq.1[1:(length(freq.1)-mdiff)])
          }
        }
      }
      ks<-ks.test.wilks(freq1=freq.1,
                        freq2=freq.2,
                        alpha=alpha,
                        breaks1=breaks.1,
                        breaks2=breaks.2)
      Ds[i]<-ks$Ds
      Tst[i]<-ks$Test
      Thr[i]<-ks$Ds.thresh
    }
  }
  close(f1)
  close(f2)
  return( list(Ds=Ds,
               Test=Tst,
               Ds.thres=Thr,
               alpha=alpha,
               hist.header=hist.header1) )
} # end of function ks.test.wilks.grid.memsaver
