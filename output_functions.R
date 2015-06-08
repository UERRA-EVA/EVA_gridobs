#
plot.pdf.overlapping.score<-function(header,pdfscore,file.out)
{
  require(raster)
#
  print("1")
  pdfbreaks<-seq(0,1,by=0.1)
  pdfcols<-c("gray",rev(rainbow(9)))
#
  print("2")
  r <-raster(ncol=header$grid.nx, nrow=header$grid.ny,
             xmn=header$grid.xmn, xmx=header$grid.xmx,
             ymn=header$grid.ymn, ymx=header$grid.ymx,
             crs=header$grid.proj)
  r[]<-NA
  r[]<-pdfscore
# 
  png(file=file.out,width=1200,height=1200)
  image(r,breaks=pdfbreaks,col=pdfcols)
#  contour(r,levels=pdfbreaks,drawlabels=F,col="black",lwd=0.8,add=T)
  leg.str<-paste("(",round(pdfbreaks[1],1),",",round(pdfbreaks[2],1),"]",sep="")
  for (i in 3:length(pdfbreaks)) leg.str<-c(leg.str, paste("(",round(pdfbreaks[i-1],1),",",round(pdfbreaks[i],1),"]",sep=""))
  legend(x="bottomright",fill=pdfcols,legend=leg.str,cex=1.5)
  dev.off()
# write output files
  return() 
}
