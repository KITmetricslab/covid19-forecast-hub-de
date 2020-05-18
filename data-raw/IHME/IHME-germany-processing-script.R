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


## list all files and read
filepaths <-
  list.files("./",
             pattern = "Hospitalization_all_locs.csv",
             recursive = TRUE,
             full.names = TRUE)

#check for IHME first forecast date
list_forecast<-list()
for (i in 1:length(filepaths))
{
  list_forecast[[i]]<-get_forecast_date(filepaths[i])
}
real_vs_reported<-t(as.data.frame(list_forecast))
rownames(real_vs_reported)<-as.character(real_vs_reported[,1])

#delete reports that have no new forecast horizon, always keep oldest
keep_report<-rep(TRUE,length(filepaths))

for (i in 2:dim(real_vs_reported)[1]){
  
  keep_report[i]<-!real_vs_reported[i,2]==real_vs_reported[i-1,2]
}
filepaths<-filepaths[keep_report]

forecast_dates<-real_vs_reported[keep_report,]


for (i in 1:length(filepaths)) {
  formatted_file <- make_qntl_dat(filepaths[i],forecast_date=forecast_dates[i,2],
                                  submission_date=forecast_dates[i,1])
  
  date <- get_date(filepaths[i])
  
  write_csv(
    formatted_file,
    path = paste0(
      "../../data-processed/IHME-CurveFit/",
      date,
      "-Germany-IHME-CurveFit.csv"
    )
  )
}


