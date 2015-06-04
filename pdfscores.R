#
source("./pdfscores_functions.R")
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
