EVA\_gridobs
=============
UERRA common evaluation procedure: assessing uncertainties in reanalysis by evaluation against gridded observational datasets

Reanalysis and gridded observations are assumed to be: on the same coordinate reference system and grid; same temporal aggregation.

Tip: use fimex for regridding (https://wiki.met.no/fimex/start)

List of Skill-Scores/Tests
--------------------------
Developed and tested for daily precipitation
- [x] Probability Density Functions (PDFs) related skill-scores (PDFs are approximated by comparing discrete histograms):
  - [x] difference between modes: mode(reanalysis) - mode(observation)
  - [x] relative precipitation biases = ( mode(reanalysis) / mode(obsevration) - 1 ) * 100%
  - [x] overlapping skill-score (see [1], Eq.(1))
- [x] two-sample Kolmogorov-Smirnov (K-S) test, or Smirnov test (see [2], Eqs (5.17-18)
- [ ] Fractional skill-score
- [ ] Optical-flow

[1] Mayer, S. et al. (2015). Identifying added value in high-resolution climate simulations over Scandinavia. Tellus A

[2] Wilks, D. S. (2011). Statistical methods in the atmospheric sciences (Vol. 100). Academic press.

Installation
------------
1. following libraries must be installed on your system:
  * netcdf-bin
  * libnetcdf-dev
  * netcdf-bin

2. get the following packages from r-cran repository:
  * sp (ver 1.0-9)
  * raster (ver 2.1-25)
  * ncdf (ver 1.6.6)

4. clone git hub repository (git clone ...)

Running the programs (examples):
--------------------------------
1. Edit configuration file according to the instructions reported in .../etc/config\_list.r
2. Create histograms approximating the frequency distribution of precipitation values (note: see in the directory "data" for test data with frequency distributions)
  * for the reanalysis

    ```
    R --vanilla your_configuration_file < prec_freqhist_reanalysis.R
    ```
  * for the gridded observational dataset (is it possible to aggregate the data to a coarser resolution)
 
    ```
    R --vanilla your_configuration_file < prec_freqhist_gridobs.R
    ```
3. Get the mode of reanalysis and gridded observation PDF:

  ```
  R --vanilla your_configuration_file < mode.R 
  ```
4. Compute the difference between modes and relative precipitation biases:
 
  ```
  R --vanilla your_configuration_file < modediff.R 
  ```
  ```
  R --vanilla your_configuration_file < modeRelErrscores.R 
  ```
5. Compute the PDF overlapping skill-score:
 
  ```
  R --vanilla your_configuration_file < pdfscores.R 
  ```
6. K-S test:
 
  ```
  R --vanilla your_configuration_file < KSscores.R 
  ```
