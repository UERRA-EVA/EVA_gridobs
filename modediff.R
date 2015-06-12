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
f.score.output.mode.diff.nc<-paste(main.output.path,"/",score.output.mode.diff.nc,sep="")
f.score.output.mode.diff.png<-paste(main.output.path,"/",score.output.mode.diff.png,sep="")
# compute the score
mode.diff<-mode.diff.grid.memsaver(hist.file1=f.ra.hist.prec,hist.file2=f.ob.hist.prec)
# output session
aux<-write.score(header=mode.diff$hist.header,score=mode.diff$score,file.out=f.score.output.mode.diff.nc)
#aux<-plot.pdf.overlapping.score(header=pdfscore$hist.header,pdfscore=pdfscore$pdfscore,file.out=f.score.output.pdf.png)
# exit
print("Exit with Success")
quit(status=0)
