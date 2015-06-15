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
source(paste(local.path.to.extlib,"/freqhist_function.R",sep=""))
#..............................................................................
fh<-create.hist.prec.freq(date.begin=date.b.string,
                          date.end=date.e.string,
                          input.path=ob.input.path,
                          input.filename=ob.input.filename,
                          input.filetype=2,
                          hist.file=ob.hist.prec,
                          hist.breaks=precipitation.breaks,
                          lower.bound=precipitation.dailydef,
                          filter.scale=ob.filter.scale,
                          mask.file=ob.mask.file,
                          mask.filetype=ob.mask.filetype)
#..............................................................................
print("Exit with Success")
quit(status=0)
