# CONFIGURATION FILE
#
# -- date parameters --
# begin YYYY.MM.DD
date.b.string<-"2014.01.02"
# end YYYY.MM.DD
date.e.string<-"2014.12.30"
#..............................................................................
# local path to external libraries
local.path.to.extlib<-""
#.......................i.......................................................
# -- Re-analysis input dataset --
# netcdf input files are expected to be:
# (1) on the same coordinate reference system and grid as the observations
# (2) the time aggregation should be the same as the observations
# (3) organized as:
#     ra.input.path/YYYYMM/ra.input.filenameYYYYMMDD_YYYYMMDD.nc
ra.input.path<-"/lustre/mnt/cristianl/nora10_prec1d"
ra.input.filename<-"nora10_prec1d_"
#..............................................................................
# -- Gridded observation dataset --
# netcdf input files are expected to be:
# (1) on the same coordinate reference system and grid as the Reanalysis
# (2) the time aggregation should be the same as the Reanalysis
# (3) organized as:
#     ob.input.path/YYYYMM/ob.input.filenameYYYYMMDD_YYYYMMDD.nc
ob.input.path<-"/lustre/mnt/cristianl/seNorge2/PREC1d/gridded_dataset"
ob.input.filename<-"seNorge_v2_0_PREC1d_grid_"
# spatial aggregation parameter
ob.filter.scale<-1
#..............................................................................
# -- Precipitation parameters --
precipitation.dailydef<-0.5 #mm
precipitation.breaks<-c(0,1:30,50,75,100,150,200,500)
#..............................................................................
# -- Test parameters --
# KS alpha level
ks.alpha<-0.05
#..............................................................................
# -- Output --
# histograms (binary files)
ra.output.hist<-"/home/cristianl/histograms/nora10_PREC1d_hist_2014.dat"
ob.output.hist<-"/home/cristianl/histograms/seNorge2_PREC1d_hist_2014.dat"
# score indexes (netcdf)
score.output.pdf<-"pdfoverscore.nc"
score.output.ksD<-"ksd.nc"
score.output.ksT<-"kstest.nc"
# score indexes (graphic)
score.output.pdf.png<-"pdfoverscore.png"
