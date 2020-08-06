#################################################################################
###### This file has been adapted from code provided in the US COVID19 forecast hub:
###### https://github.com/reichlab/covid19-forecast-hub/blob/master/data-raw/Geneva/Geneva-processing-script.R
###### Author of original code: Johannes Bracher
###### The original file has been provided under the MIT license, and so is this adapted version.
#################################################################################

## script for processing USC data
## Johannes Bracher
## April 2020

# optional working dir setting
setwd("./data-raw/USC/")

source("process_USC_file_germany.R")
# make sure that English names of days and months are used
Sys.setlocale(category = "LC_TIME", locale = "en_US.UTF8")

processed_path <- paste(gsub("/data-raw/USC","",getwd()),"/data-processed/USC-SIkJalpha/")
processed_path <- gsub(" ", "", processed_path)

dir.create(processed_path, showWarnings = FALSE)

files_to_process <- list.files("./", recursive = FALSE)
files_to_process <- files_to_process[grepl("global_deaths_quarantine_1.csv", files_to_process)]
# TODO: handle multiple source csv files with different names vs overwriting

forecast_dates <- lapply(files_to_process, date_from_usc_filepath)

# determine forecast horizon
horizon.days = 30
horizon.wks = 4

# proces files:
for(i in 1:length(files_to_process)) {
  tmp_dat <- process_usc_file(usc_filepath = files_to_process[i], 
                              date_zero = forecast_dates[[i]], 
                              horizon.days = horizon.days, 
                              horizon.wks = horizon.wks)
  file_name <- paste0(processed_path, forecast_dates[[i]], "-Germany-USC-SIkJalpha.csv")
  write.csv(tmp_dat, file_name, row.names = FALSE)
}