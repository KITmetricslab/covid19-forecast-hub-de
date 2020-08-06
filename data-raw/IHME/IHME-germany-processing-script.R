# Author: Konstantin Görgen
# Date: Mon May 11 13:57:10 2020
# --------------
# Modification: Added Submission and Forecast date
# Author: Konstantin Görgen
# Date: 18.05.2020
# --------------
#################################################################################
###### This file has been adapted from code provided in the US COVID19 forecast hub:
###### https://github.com/reichlab/covid19-forecast-hub/tree/master/data-raw/IHME/IHME-processing.R
###### The original file has been provided under the MIT license, and so is this adapted version.
#################################################################################

## reformat IHME forecasts
# Run from data-raw/IHME
source("process_IHME-germany_functions.R")
require(tidyverse)
require(MMWRweek)
require(lubridate)


## list all files and read
filepaths <-
  list.files("./",
             pattern = "Hospitalization_all_locs.csv",
             recursive = TRUE,
             full.names = FALSE,
             ignore.case = TRUE)

#remove files that are not main model
filepaths<-filepaths[-c(grep("Best",filepaths),grep("Worse",filepaths))]
for(country in c("Germany","Poland"))
{
  #check for IHME first forecast date
  list_forecast<-list()
  for (i in 1:length(filepaths))
  {
    list_forecast[[i]]<-get_forecast_date(filepaths[i],country=country)
  }
  real_vs_reported<-t(as.data.frame(list_forecast))
  rownames(real_vs_reported)<-as.character(real_vs_reported[,1])
  
  #delete reports that have no new forecast horizon, always keep oldest
  keep_report<-rep(TRUE,length(filepaths))
  
  for (i in 2:dim(real_vs_reported)[1]){
    
    keep_report[i]<-!real_vs_reported[i,2]==real_vs_reported[i-1,2]
  }
  filepaths<-filepaths[keep_report]
  #exclude everything with date before July
  filepaths<-filepaths[real_vs_reported[keep_report,2]>as.Date("2020-07-01")]
  
  forecast_dates<-real_vs_reported[keep_report & real_vs_reported[,2]>as.Date("2020-07-01"),]
  
  
  for (i in 1:length(filepaths)) {
    #changed submission date to real forecast date, to change back, change to [i,1] in submission_date=forecast_dates[i,2]
    formatted_file <- make_qntl_dat(path=filepaths[i],forecast_date=forecast_dates[i,2],
                                    submission_date=forecast_dates[i,2],country=country) 
    
    #date <- get_date(filepaths[i])
    date<-forecast_dates[i,2]
    
    write_csv(
      formatted_file,
      path = paste0(
        "../../data-processed/IHME-Hybrid-SEIR/",
        date,
        "-",country,"-IHME-Hybrid-SEIR.csv"
      )
    )
    print(paste0("Finished with date ",date," in country ", country) )
  }
}


