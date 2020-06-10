#################################################################################
###### This file has been adapted from code provided in the US COVID19 forecast hub:
###### https://github.com/reichlab/covid19-forecast-hub/blob/master/data-raw/Geneva/Geneva-processing-script.R
###### Author of original code: Johannes Bracher
###### The original file has been provided under the MIT license, and so is this adapted version.
#################################################################################

## script for processing Geneva data
## Johannes Bracher
## April 2020

source("process_geneva_file_germany.R")
# make sure that English names of days and months are used
Sys.setlocale(category = "LC_TIME", locale = "en_US.UTF8")

dir.create("../../data-processed/Geneva-DeterministicGrowth", showWarnings = FALSE)

files_to_process <- list.files("./", recursive = FALSE)
files_to_process <- files_to_process[grepl(".csv", files_to_process) &
                                       (grepl("predictions_death", files_to_process) |
                                          grepl("deaths_predictions", files_to_process))]
forecast_dates <- lapply(files_to_process, date_from_geneva_filepath)

# proces files:
for(i in 1:length(files_to_process)) {
  tmp_dat <- process_geneva_file(files_to_process[i], forecast_date = forecast_dates[[i]])
  write.csv(tmp_dat,
            paste0("../../data-processed/Geneva-DeterministicGrowth/", forecast_dates[[i]],
                   "-Germany-Geneva-DeterministicGrowth.csv"),
            row.names = FALSE)
}

