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
#
pdfscore<-pdf.overlapping.score.grid.memsaver(hist.file1=ra.output.histtmp,hist.file2=ob.output.histtmp)
print(pdfscore)
aux<-plot.pdf.overlapping.score(header=pdfscore$hist.header,pdfscore=pdfscore$pdfscore,file.out=score.output.pdf.png)
#
q()
