#################################################################################
###### This file has been adapted from code provided in the US COVID19 forecast hub:
###### https://github.com/reichlab/covid19-forecast-hub/blob/master/data-raw/Geneva/Geneva-processing-script.R
###### Author of original code: Johannes Bracher
###### The original file has been provided under the MIT license, and so is this adapted version.
#################################################################################

## script for processing USC data
## Jakob Ketterer & Johannes Bracher
## July 2020

source("process_USC_file_germany.R")
# make sure that English names of days and months are used
Sys.setlocale(category = "LC_TIME", locale = "en_US.UTF8")

processed_path <- paste(gsub("/data-raw/USC","",getwd()),"/data-processed/USC-SIkJalpha/")
processed_path <- gsub(" ", "", processed_path)

dir.create(processed_path, showWarnings = FALSE)

dirs_to_process <- gsub("./", "", list.dirs(recursive = FALSE))

forecast_dates <- as.Date(dirs_to_process)

# proces files:
for(i in 1:length(dirs_to_process)) {
  # Deaths, Germany:
  dat_germany_death <- process_usc_file(usc_filepath = paste0(dirs_to_process[i], "/global_forecasts_deaths.csv"),
                                        forecast_date = forecast_dates[[i]],
                                        type = "death",
                                        country = "Germany",
                                        location = "GM")
  file_name_germany_death <- paste0(processed_path, forecast_dates[[i]], "-Germany-USC-SIkJalpha.csv")
  write.csv(dat_germany_death, file_name_germany_death, row.names = FALSE)

  # Cases, Germany:
  dat_germany_case <- process_usc_file(usc_filepath = paste0(dirs_to_process[i], "/global_forecasts_cases.csv"),
                                        forecast_date = forecast_dates[[i]],
                                        type = "case",
                                        country = "Germany",
                                        location = "GM")
  file_name_germany_case <- paste0(processed_path, forecast_dates[[i]], "-Germany-USC-SIkJalpha-case.csv")
  write.csv(dat_germany_case, file_name_germany_case, row.names = FALSE)

  # Deaths, Poland:
  dat_poland_death <- process_usc_file(usc_filepath = paste0(dirs_to_process[i], "/global_forecasts_deaths.csv"),
                                       forecast_date = forecast_dates[[i]],
                                       type = "death",
                                       country = "Poland",
                                       location = "PL")
  file_name_poland_death <- paste0(processed_path, forecast_dates[[i]], "-Poland-USC-SIkJalpha.csv")
  write.csv(dat_poland_death, file_name_poland_death, row.names = FALSE)

  # Cases, Poland:
  dat_poland_case <- process_usc_file(usc_filepath = paste0(dirs_to_process[i], "/global_forecasts_cases.csv"),
                                      forecast_date = forecast_dates[[i]],
                                      type = "case",
                                      country = "Poland",
                                      location = "PL")
  file_name_poland_case <- paste0(processed_path, forecast_dates[[i]], "-Poland-USC-SIkJalpha-case.csv")
  write.csv(dat_poland_case, file_name_poland_case, row.names = FALSE)

  cat("File", i, "/", length(dirs_to_process), "\n")
}
