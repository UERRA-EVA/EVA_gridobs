# CONFIGURATION FILE
#
# -- date parameters --
# begin YYYY.MM.DD
date.b.string<-"2014.01.02"
# end YYYY.MM.DD
date.e.string<-"2014.12.30"
#..............................................................................
# local path to external libraries
#local.path.to.extlib<-"/disk1/projects/EVA_gridobs"
local.path.to.extlib<-"/home/cristianl/projects/EVA_gridobs"
#..............................................................................
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
# -- Mask file
ob.mask.file<-"/home/cristianl/projects/seNorge2/geoinfo/seNorge2_dem_UTM33.nc"
ob.mask.filetype<-3
#..............................................................................
# -- Precipitation parameters --
precipitation.dailydef<-0.5 #mm
# Precipitaton breaks - rules:
# - first class must have 0 elements;
# - first label must be less than precipitation.dailydef (however, be care-
#   full in setting the class width because it will be used to obtain density)
# - each class label mark the maximum value within the class 
# Example
# precipitation.breaks<-c(1,2,3,...) 
#  first class empty
#  second class includes values greater than 1 and less or equal to 2,...
# tip: the mid value for each class is
#  for (i in 1:(length(precipitation.breaks)-1)) print(mean(precipitation.breaks[i:(i+1)]))
precipitation.breaks<-c(0.499,1.5:30.5,49.5,70.5,99.5,150.5,199.5,500.5)
#..............................................................................
# -- Test parameters --
# KS alpha level
ks.alpha<-0.05
#..............................................................................
# -- Output --
main.output.path<-"/home/cristianl/EVA_gridobs_output"
#main.output.path<-"/disk1/EVA_gridobs_output"
# histograms (binary files)
ra.hist.prec<-"nora10_PREC1d_hist_2014.dat"
ob.hist.prec<-"seNorge2_PREC1d_hist_2014.dat"
# descriptive statistics
ra.output.mode.nc<-"nora10_PREC1d_hist_mode_2014.nc"
ob.output.mode.nc<-"seNorge2_PREC1d_hist_mode_2014.nc"
ra.output.mode.png<-"nora10_PREC1d_hist_mode_2014.png"
ob.output.mode.png<-"seNorge2_PREC1d_hist_mode_2014.png"
# score indexes (netcdf)
score.output.mode.diff.nc<-"nora10_seNorge2_PREC1d_modediff_2014.nc"
score.output.mode.RelErr.nc<-"nora10_seNorge2_PREC1d_moderelerr_2014.nc"
score.output.pdf.nc<-"nora10_seNorge2_PREC1d_pdfoverscore_2014.nc"
score.output.ksD.nc<-"nora10_seNorge2_PREC1d_ksd_2014.nc"
score.output.ksT.nc<-"nora10_seNorge2_PREC1d_kstest_2014.nc"
# score indexes (graphic)
score.output.mode.diff.png<-"nora10_seNorge2_PREC1d_modediff_2014.png"
score.output.mode.RelErr.png<-"nora10_seNorge2_PREC1d_moderelerr_2014.png"
score.output.pdf.png<-"nora10_seNorge2_PREC1d_pdfoverscore_2014.png"
score.output.ksD.png<-"nora10_seNorge2_PREC1d_ksd_2014.png"
score.output.ksT.png<-"nora10_seNorge2_PREC1d_kstest_2014.png"
