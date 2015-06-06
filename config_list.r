date.b.string<-"2014.01.02"
date.e.string<-"2014.12.30"
#..............................................................................
ra.input.path<-"./nora10_prec1d"
ra.input.filename<-"prsum_"
ra.output.histtmp<-"ra_hist_temp.dat"
#..............................................................................
ob.input.path<-"/lustre/mnt/cristianl/seNorge2/PREC1d/gridded_dataset"
ob.input.filename<-"seNorge_v2_0_PREC1d_grid_"
ob.output.histtmp<-"/home/cristianl/histograms/seNorge2_PREC1d_hist_2014.dat"
#..............................................................................
precipitation.dailydef<-0.5 #mm
precipitation.breaks<-c(0,1:30,50,75,100,150,200,500)
#..............................................................................
ks.alpha<-0.05
#..............................................................................
score.output.pdf<-"pdfoverscore.nc"
score.output.ksD<-"ksd.nc"
score.output.ksT<-"kstest.nc"
