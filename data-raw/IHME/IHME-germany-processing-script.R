# Author: Konstantin Görgen
# Date: Mon May 11 13:57:10 2020
# --------------
#################################################################################
###### This file has been adapted from code provided in the US COVID19 forecast hub:
###### https://github.com/reichlab/covid19-forecast-hub/tree/master/data-raw/IHME/IHME-processing.R
###### The original file has been provided under the MIT license, and so is this adapted version.
#################################################################################

## reformat IHME forecasts
# Run from data-raw/IHME
source("process_IHME_functions.R")

## list all files and read
filepaths <- list.files("./",pattern = "Hospitalization_all_locs.csv", recursive =TRUE,full.names = TRUE)

  for(i in 1:length(filepaths)){
    formatted_file <- make_qntl_dat(filepaths[i])
 
    date<-get_date(filepaths[i])
    
    write_csv(formatted_file,
              path = paste0("../../data-processed/IHME-CurveFit/",
                            date,
                            "-Germany-IHME-CurveFit.csv"))
  }

