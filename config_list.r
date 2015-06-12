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
main.output.path<-"/home/cristianl/EVA_gridobs_output"
# histograms (binary files)
ra.hist.prec<-"nora10_PREC1d_hist_2014.dat"
ob.hist.prec<-"seNorge2_PREC1d_hist_2014.dat"
# score indexes (netcdf)
score.output.mode.diff.nc<-"nora10_seNorge2_modediff.nc"
score.output.mode.RelErr.nc<-"nora10_seNorge2_moderelerr.nc"
score.output.pdf.nc<-"nora10_seNorge2_pdfoverscore.nc"
score.output.ksD.nc<-"nora10_seNorge2_ksd.nc"
score.output.ksT.nc<-"nora10_seNorge2_kstest.nc"
# score indexes (graphic)
score.output.mode.diff.png<-"nora10_seNorge2_modediff.png"
score.output.mode.RelErr.png<-"nora10_seNorge2_moderelerr.png"
score.output.pdf.png<-"nora10_seNorge2_pdfoverscore.png"
score.output.ksD.png<-"nora10_seNorge2_ksd.png"
score.output.ksT.png<-"nora10_seNorge2_kstest.png"
