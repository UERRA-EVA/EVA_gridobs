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
source(paste(local.path.to.extlib,"/freqhist_functions.R",sep=""))
source(paste(local.path.to.extlib,"/pdfscores_functions.R",sep=""))
source(paste(local.path.to.extlib,"/output_functions.R",sep=""))
#..............................................................................
# set output file names
f.score.output.pdf.nc<-paste(main.output.path,"/",score.output.pdf.nc,sep="")
f.score.output.pdf.png<-paste(main.output.path,"/",score.output.pdf.png,sep="")
# compute the score
pdfscore<-pdf.overlapping.score.grid.memsaver(hist.file1=ra.hist.prec,hist.file2=ob.hist.prec)
# output session
aux<-write.score(header=pdfscore$hist.header,score=pdfscore$pdfscore,file.out=f.score.output.pdf.nc)
aux<-plot.pdf.overlapping.score(header=pdfscore$hist.header,pdfscore=pdfscore$pdfscore,file.out=f.score.output.pdf.png)
# exit
print("Exit with Success")
quit(status=0)
