#################################################################################
###### This file has been adapted from code provided in the US COVID19 forecast hub:
###### URL of original file
###### Author of original code: Johannes Bracher
###### The original file has been provided under the MIT license, and so is this adapted version.
#################################################################################

## Jannik Deuschel
## May 2020

source("process_YYG_file_germany.R")
# make sure that English names of days and months are used
Sys.setlocale("LC_TIME", "C")

dir.create("../../data-processed/YYG-ParamSearch", showWarnings = FALSE)
files_to_process <- list.files("./", recursive = FALSE)
files_to_process <- files_to_process[grepl(".csv", files_to_process) &
                                       grepl("_global", files_to_process)]

forecast_dates <- lapply(files_to_process, date_from_YYG_filepath)

# proces files:
for(i in 1:length(files_to_process)) {
  tmp_dat <- process_YYG_file(files_to_process[i], forecast_date = forecast_dates[[i]])
  print(forecast_dates[[i]])
  write.csv(tmp_dat,
            paste0("../../data-processed/YYG-ParamSearch/", forecast_dates[[i]],
                   "-Germany-YYG-ParamSearch.csv"),
            row.names = FALSE)
}

