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
#Sys.setlocale(category = "LC_TIME", locale = "English")

# this is necessary for Linux VMs
Sys.setlocale(category = "LC_TIME", locale = "en_US.UTF8")

dir.create("../../data-processed/SDSC-ISG_TrendModel", showWarnings = FALSE)

vector_countries <- c("Germany", "Poland")
vector_fips <- c("GM", "PL")

# Process death files:

death_files_to_process <- list.files("./", recursive = FALSE)
death_files_to_process <- death_files_to_process[grepl(".csv", death_files_to_process) &
                                       (grepl("predictions_death", death_files_to_process) |
                                          grepl("deaths_predictions", death_files_to_process))]
death_forecast_dates <- lapply(death_files_to_process, date_from_geneva_filepath)

# check which ones are already processed:
files_already_processed <- list.files("../../data-processed/SDSC-ISG_TrendModel")
dates_already_processed <- as.Date(substr(files_already_processed, start = 1, stop = 10))

# restrict to those not yet processed:
death_files_to_process <- death_files_to_process[!death_forecast_dates %in% dates_already_processed]
death_forecast_dates <- death_forecast_dates[!death_forecast_dates %in% dates_already_processed]


for(i in 1:length(death_files_to_process)) {
  for(j in seq_along(vector_countries)){
    tmp_dat <- process_geneva_file(death_files_to_process[i], forecast_date = death_forecast_dates[[i]],
                                      country = vector_countries[j], location = vector_fips[j], type = "death")
    write.csv(tmp_dat,
              paste0("../../data-processed/SDSC-ISG_TrendModel/", death_forecast_dates[[i]],
                     "-", vector_countries[j], "-SDSC-ISG_TrendModel.csv"),
              row.names = FALSE)
  }
  cat("processing ", i, "/", length(death_files_to_process), "\n")
}

# Process case files:

case_files_to_process <- list.files("./", recursive = FALSE)
case_files_to_process <- case_files_to_process[grepl(".csv", case_files_to_process) &
                                                   (grepl("predictions_case", case_files_to_process) |
                                                      grepl("cases_predictions", case_files_to_process))]
case_forecast_dates <- lapply(case_files_to_process, date_from_geneva_filepath)

# restrict to those not yet processed:
case_files_to_process <- case_files_to_process[!case_forecast_dates %in% dates_already_processed]
case_forecast_dates <- case_forecast_dates[!case_forecast_dates %in% dates_already_processed]

for(i in 1:length(case_files_to_process)) {
  for(j in seq_along(vector_countries)){
    tmp_dat <- process_geneva_file(case_files_to_process[i], forecast_date = case_forecast_dates[[i]],
                                   country = vector_countries[j], location = vector_fips[j], type = "case")
    write.csv(tmp_dat,
              paste0("../../data-processed/SDSC-ISG_TrendModel/", case_forecast_dates[[i]],
                     "-", vector_countries[j], "-SDSC-ISG_TrendModel-case.csv"),
              row.names = FALSE)
  }
  cat("processing ", i, "/", length(case_files_to_process), "\n")
}

