# + pdfscores.R
#
#==============================================================================
# load libraries
library(ncdf)
library(raster)
# read command line with configuration file
arguments <- commandArgs()
arguments
config.file<-arguments[3]
# checks
if (length(arguments)!=3) {
    print(paste("Error in command line arguments: \n",
          " R --vanilla configurationFile < pdfscores.R \n",sep=""))
      quit(status=1)
}
if (!file.exists(config.file)) {
    print(paste("configuration file not found \n",
         config.file,"\n",sep=""))
      quit(status=1)
}
#..............................................................................
# read config parameters
source(config.file)
# load external functions
source(paste(local.path.to.extlib,"/functions/freqhist_functions.R",sep=""))
source(paste(local.path.to.extlib,"/functions/pdfscores_functions.R",sep=""))
source(paste(local.path.to.extlib,"/functions/output_functions.R",sep=""))
#..............................................................................
f.ra.hist.prec<-paste(main.output.path,"/",ra.hist.prec,sep="")
f.ob.hist.prec<-paste(main.output.path,"/",ob.hist.prec,sep="")
# set output file names
f.ra.output.mode.nc<-paste(main.output.path,"/",ra.output.mode.nc,sep="")
f.ob.output.mode.nc<-paste(main.output.path,"/",ob.output.mode.nc,sep="")
f.ra.output.mode.png<-paste(main.output.path,"/",ra.output.mode.png,sep="")
f.ob.output.mode.png<-paste(main.output.path,"/",ob.output.mode.png,sep="")
# compute the score
ra.mode<-hist.mode.grid.memsaver(hist.file=f.ra.hist.prec)
ob.mode<-hist.mode.grid.memsaver(hist.file=f.ob.hist.prec)
# output session
aux<-write.score(header=ra.mode$hist.header,score=ra.mode$mode,file.out=f.ra.output.mode.nc)
aux<-write.score(header=ob.mode$hist.header,score=ob.mode$mode,file.out=f.ob.output.mode.nc)
#aux<-plot.pdf.overlapping.score(header=pdfscore$hist.header,pdfscore=pdfscore$pdfscore,file.out=f.score.output.pdf.png)
# exit
print("Exit with Success")
quit(status=0)
