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
forecast_dates <- as.Date(all_dirs)
seq_forecast_dates <- seq(from = min(forecast_dates, na.rm = TRUE), 
                          to = max(forecast_dates, na.rm = TRUE), by = 1)
mondays <- seq_forecast_dates[weekdays(seq_forecast_dates) == "Monday"]

already_processed0 <- list.files(processed_path)
already_processed <- substr(already_processed0[grepl("2020-", already_processed0)], 1, 10)
mondays <- mondays[!(as.character(mondays) %in% already_processed)]


fips_codes_germany <-  c("GM01", "GM02", "GM03", "GM04",
                         "GM05", "GM06", "GM07", "GM08",
                         "GM09", "GM10", "GM11", "GM12",
                         "GM13", "GM14", "GM15", "GM16")

fips_codes_poland <-  c("PL72", "PL73", "PL74", "PL75",
                        "PL76", "PL77", "PL78", "PL79",
                        "PL80", "PL81", "PL82", "PL83",
                        "PL84", "PL85", "PL86", "PL87")

# read in truths (both ECDC and JHU):
cum_truth_ecdc <- cum_truth_jhu <- list()
cum_truth_ecdc$GM$case <- read.csv("../../data-truth/RKI/truth_RKI-Cumulative Cases_Germany.csv",
                              colClasses = c(date = "Date"))
cum_truth_ecdc$GM$death <- read.csv("../../data-truth/RKI/truth_RKI-Cumulative Deaths_Germany.csv",
                               colClasses = c(date = "Date"))
cum_truth_ecdc$PL$case <- read.csv("../../data-truth/MZ/truth_MZ-Cumulative Cases_Poland.csv",
                                   colClasses = c(date = "Date"))
cum_truth_ecdc$PL$death <- read.csv("../../data-truth/MZ/truth_MZ-Cumulative Deaths_Poland.csv",
                                    colClasses = c(date = "Date"))

cum_truth_jhu$GM$case <- read.csv("../../data-truth/JHU/truth_JHU-Cumulative Cases_Germany.csv",
                                  colClasses = c(date = "Date"))
cum_truth_jhu$GM$death <- read.csv("../../data-truth/JHU/truth_JHU-Cumulative Deaths_Germany.csv",
                                   colClasses = c(date = "Date"))
cum_truth_jhu$PL$case <- read.csv("../../data-truth/JHU/truth_JHU-Cumulative Cases_Poland.csv",
                              colClasses = c(date = "Date"))
cum_truth_jhu$PL$death <- read.csv("../../data-truth/JHU/truth_JHU-Cumulative Deaths_Poland.csv",
                               colClasses = c(date = "Date"))


# process files - handling regional and national level forecasts separately.
# National level is taken from global* files. Regional level forecasts are taken from other* files.
# National level refer to JHU, regional level to ECDC.
# Chose to do this way as JHU-based seem to be more stable (in terms of availability and absence of occasoinal
# convergence issues).
for(i in 1:length(mondays)) {
  # Deaths, Germany:
  dat_germany_death <- process_usc_file(monday = mondays[i],
                                        truth = cum_truth_jhu$GM$death,
                                        type = "death",
                                        country = "Germany",
                                        location = "GM")
  
  dat_germany_death_regional <- process_usc_file(monday = mondays[i],
                                        truth = cum_truth_ecdc$GM$death,
                                        type = "death",
                                        country = fips_codes_germany,
                                        location = fips_codes_germany)
  
  file_name_germany_death <- paste0(processed_path, mondays[[i]], "-Germany-USC-SIkJalpha.csv")
  write.csv(rbind(dat_germany_death, dat_germany_death_regional),
            file_name_germany_death, row.names = FALSE)

  # Cases, Germany:
  dat_germany_case <- process_usc_file(monday = mondays[i],
                                       truth = cum_truth_jhu$GM$case,
                                       type = "case",
                                       country = "Germany",
                                       location = "GM")
  
  dat_germany_case_regional <- process_usc_file(monday = mondays[i],
                                                truth = cum_truth_ecdc$GM$case,
                                                type = "case",
                                                country = fips_codes_germany,
                                                location = fips_codes_germany)
  
  file_name_germany_case <- paste0(processed_path, mondays[[i]], "-Germany-USC-SIkJalpha-case.csv")
  write.csv(rbind(dat_germany_case, dat_germany_case_regional),
            file_name_germany_case, row.names = FALSE)

  # Deaths, Poland:
  dat_poland_death <- process_usc_file(monday = mondays[i],
                                       truth = cum_truth_jhu$PL$death,
                                       type = "death",
                                       country = "Poland",
                                       location = "PL")
  
  dat_poland_death_regional <- process_usc_file(monday = mondays[i],
                                                truth = cum_truth_ecdc$PL$death,
                                                type = "death",
                                                country = fips_codes_poland,
                                                location = fips_codes_poland)
  
  file_name_poland_death <- paste0(processed_path, mondays[[i]], "-Poland-USC-SIkJalpha.csv")
  write.csv(rbind(dat_poland_death, dat_poland_death_regional),
            file_name_poland_death, row.names = FALSE)
  
  # Cases, Poland:
  dat_poland_case <- process_usc_file(monday = mondays[i],
                                      truth = cum_truth_jhu$PL$case,
                                      type = "case",
                                      country = "Poland",
                                      location = "PL")
  
  dat_poland_case_regional <- process_usc_file(monday = mondays[i],
                                               truth = cum_truth_ecdc$PL$case,
                                               type = "case",
                                               country = fips_codes_poland,
                                               location = fips_codes_poland)
  
  file_name_poland_case <- paste0(processed_path, mondays[[i]], "-Poland-USC-SIkJalpha-case.csv")
  write.csv(rbind(dat_poland_case, dat_poland_case_regional),
            file_name_poland_case, row.names = FALSE)

}
