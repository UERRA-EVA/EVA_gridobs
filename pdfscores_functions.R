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

