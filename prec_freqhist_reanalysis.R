# + freqhist.R
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
      " R --vanilla configurationFile < freqhist.R \n",sep=""))
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
# set output file names
f.ra.hist.prec<-paste(main.output.path,"/",ra.hist.prec,sep="")
#..............................................................................
fh<-create.hist.prec.freq(date.begin=date.b.string,
                          date.end=date.e.string,
                          input.path=ra.input.path,
                          input.filename=ra.input.filename,
                          input.filetype=1,
                          hist.file=f.ra.hist.prec,
                          hist.breaks=precipitation.breaks,
                          lower.bound=precipitation.dailydef,
                          mask.file=ob.mask.file,
                          mask.filetype=ob.mask.filetype)
#..............................................................................
print("Exit with Success")
quit(status=0)
