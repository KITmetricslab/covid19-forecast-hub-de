## script for processing UCLA data
## Johannes Bracher
## October 2020

## remove issues with turn of the year 2020 -> 2021
## Jakob Ketterer
## Januar 2021

source("process_UCLA_file_germany.R")

# make sure that English names of days and months are used
# Sys.setlocale(category = "LC_TIME", locale = "English")

Sys.setlocale(category = "LC_TIME", locale = "en_US.UTF8")

dir.create("../../data-processed/UCLA-SuEIR/", showWarnings = FALSE)


locations <- c("GM") # Poland not available
location_names <- c("Germany")

deaths_jhu_gm <- read.csv("../../data-truth/JHU/truth_JHU-Cumulative Deaths_Germany.csv",
                       colClasses = list(date = "Date"))
cases_jhu_gm <- read.csv("../../data-truth/JHU/truth_JHU-Cumulative Cases_Germany.csv",
                       colClasses = list(date = "Date"))

all_files <- list.files()
files_to_process <- all_files[grepl("pred_world", all_files)]

# ignore the 13 dates belonging to 2020 to avoid issues
files_to_process <- files_to_process[-(length(files_to_process)-12):-length(files_to_process)]
forecast_dates <- as.Date(paste0("2021-", gsub(".csv", "", gsub("pred_world_", "", files_to_process))))
files_to_process
# ignore all files from 2021 that have been processed already
filenames_processed <- list.files("../../data-processed/UCLA-SuEIR/", pattern=".csv", full.names=FALSE)
dates_processed <- unlist(lapply(filenames_processed, FUN = function(x) as.Date(substr(basename(x), 0, 10))))

# forecasts and corresponding files that have not been processed yet
forecast_dates <- as.Date(setdiff(forecast_dates, dates_processed), origin = "1970-01-01")
files_to_process <- sort(files_to_process)[(length(files_to_process)-length(forecast_dates)+1):length(files_to_process)]

forecast_dates
files_to_process

for(j in seq_along(locations)){
  for(i in seq_along(files_to_process)){
    if (length(forecast_dates) == 1){
      forecast_date = forecast_dates
      file_to_process = files_to_process
    } else {
      forecast_date = forecast_dates[i]
      file_to_process = files_to_process[i]
    }
    cases <- process_ucla_file(ucla_filepath = file_to_process,
                               truth_jhu_cum = cases_jhu_gm,
                               forecast_date = forecast_date, 
                               type = "case",
                               country = location_names[j], location = locations[j])
    write.csv(cases, file = paste0("../../data-processed/UCLA-SuEIR/",
                                  forecast_date, "-", location_names[j], "-",
                                  "UCLA-SuEIR-case.csv"), row.names = FALSE)
    
    deaths <- process_ucla_file(ucla_filepath = file_to_process, 
                                truth_jhu_cum = deaths_jhu_gm,
                                forecast_date = forecast_date, 
                                type = "death",
                                country = location_names[j], location = locations[j])
    write.csv(deaths, file = paste0("../../data-processed/UCLA-SuEIR/",
                                  forecast_date, "-", location_names[j], "-",
                                  "UCLA-SuEIR.csv"), row.names = FALSE)

  }
}

