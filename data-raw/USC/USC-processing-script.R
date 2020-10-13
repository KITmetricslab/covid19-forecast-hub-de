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

# identify files which remain to be processed:
all_dirs <- gsub("./", "", list.dirs(recursive = FALSE))
already_processed0 <- list.files(processed_path)
already_processed <- substr(already_processed0[grepl("2020-", already_processed0)], 1, 10)
dirs_to_process <- all_dirs[!(all_dirs %in% already_processed)]

forecast_dates <- as.Date(dirs_to_process)

fips_codes_germany <-  c("GM",
                         "GM01", "GM02", "GM03", "GM04",
                         "GM05", "GM06", "GM07", "GM08",
                         "GM09", "GM10", "GM11", "GM12",
                         "GM13", "GM14", "GM15", "GM16")

# read in truths:
cum_truth <- list()
cum_truth$GM$case <- read.csv("../../data-truth/RKI/truth_RKI-Cumulative Cases_Germany.csv",
                              colClasses = c(date = "Date"))
cum_truth$GM$death <- read.csv("../../data-truth/RKI/truth_RKI-Cumulative Deaths_Germany.csv",
                               colClasses = c(date = "Date"))
cum_truth$PL$case <- read.csv("../../data-truth/JHU/truth_JHU-Cumulative Cases_Poland.csv",
                              colClasses = c(date = "Date"))
cum_truth$PL$death <- read.csv("../../data-truth/JHU/truth_JHU-Cumulative Deaths_Poland.csv",
                               colClasses = c(date = "Date"))


# process files:
for(i in 1:length(dirs_to_process)) {
  # Deaths, Germany:
  dat_germany_death <- process_usc_file(usc_filepath = paste0(dirs_to_process[i], "/other_forecasts_deaths.csv"),
                                        forecast_date = forecast_dates[[i]],
                                        truth = cum_truth$GM$death,
                                        type = "death",
                                        country = fips_codes_germany,
                                        location = fips_codes_germany)
  file_name_germany_death <- paste0(processed_path, forecast_dates[[i]], "-Germany-USC-SIkJalpha.csv")
  write.csv(dat_germany_death, file_name_germany_death, row.names = FALSE)

  # Cases, Germany:
  dat_germany_case <- process_usc_file(usc_filepath = paste0(dirs_to_process[i], "/other_forecasts_cases.csv"),
                                       forecast_date = forecast_dates[[i]],
                                       truth = cum_truth$GM$case,
                                       type = "case",
                                       country = fips_codes_germany,
                                       location = fips_codes_germany)
  file_name_germany_case <- paste0(processed_path, forecast_dates[[i]], "-Germany-USC-SIkJalpha-case.csv")
  write.csv(dat_germany_case, file_name_germany_case, row.names = FALSE)

  # Deaths, Poland:
  dat_poland_death <- process_usc_file(usc_filepath = paste0(dirs_to_process[i], "/global_forecasts_deaths.csv"),
                                       forecast_date = forecast_dates[[i]],
                                       truth = cum_truth$PL$death,
                                       type = "death",
                                       country = "Poland",
                                       location = "PL")
  file_name_poland_death <- paste0(processed_path, forecast_dates[[i]], "-Poland-USC-SIkJalpha.csv")
  write.csv(dat_poland_death, file_name_poland_death, row.names = FALSE)

  # Cases, Poland:
  dat_poland_case <- process_usc_file(usc_filepath = paste0(dirs_to_process[i], "/global_forecasts_cases.csv"),
                                      forecast_date = forecast_dates[[i]],
                                      truth = cum_truth$PL$case,
                                      type = "case",
                                      country = "Poland",
                                      location = "PL")
  file_name_poland_case <- paste0(processed_path, forecast_dates[[i]], "-Poland-USC-SIkJalpha-case.csv")
  write.csv(dat_poland_case, file_name_poland_case, row.names = FALSE)

  cat("File", i, "/", length(dirs_to_process), "\n")
  i <- i + 1
}
# check warnings (indicate if something went wrong with truth data alignment)
warnings()
