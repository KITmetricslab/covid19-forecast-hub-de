## script for processing Geneva data
## Johannes Bracher
## Jannik Deuschel
## April 2020

source("process_MIT_file_germany.R")
# make sure that English names of days and months are used
Sys.setlocale("LC_TIME", "C")

dir.create("../../data-processed/MIT_CovidAnalytics-DELPHI", showWarnings = FALSE)
files_to_process <- list.files("./", recursive = FALSE)
files_to_process <- files_to_process[grepl(".csv", files_to_process) &
                                       grepl("Global_", files_to_process)]

forecast_dates <- lapply(files_to_process, date_from_MIT_filepath)

# proces files:
for(i in 1:length(files_to_process)) {
  tmp_dat <- process_MIT_file(files_to_process[i], forecast_date = forecast_dates[[i]])
  write.csv(tmp_dat,
            paste0("../../data-processed/MIT_CovidAnalytics-DELPHI/", forecast_dates[[i]],
                   "-Germany-MIT_CovidAnalytics-DELPHI.csv"),
            row.names = FALSE)
}