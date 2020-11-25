## script for processing UCLA data
## Johannes Bracher
## October 2020

source("process_UCLA_file_germany.R")

# make sure that English names of days and months are used
#Sys.setlocale(category = "LC_TIME", locale = "English")

Sys.setlocale(category = "LC_TIME", locale = "en_US.UTF8")

dir.create("../../data-processed/UCLA-SuEIR/", showWarnings = FALSE)


locations <- c("GM") # Poland not available
location_names <- c("Germany")

all_files <- list.files()
files_to_process <- all_files[grepl("pred_world", all_files)]

forecast_dates <- as.Date(paste0("2020-", gsub(".csv", "", gsub("pred_world_", "", files_to_process))))

for(j in seq_along(locations)){
  for(i in seq_along(files_to_process)){
    cases <- process_ucla_file(files_to_process[i], forecast_dates[i], type = "case",
                               country = location_names[j], location = locations[j])
    write.csv(cases, file = paste0("../../data-processed/UCLA-SuEIR/",
                                  forecast_dates[i], "-", location_names[j], "-",
                                  "UCLA-SuEIR-case.csv"), row.names = FALSE)

    deaths <- process_ucla_file(files_to_process[i], forecast_dates[i], type = "death",
                                country = location_names[j], location = locations[j])
    write.csv(deaths, file = paste0("../../data-processed/UCLA-SuEIR/",
                                  forecast_dates[i], "-", location_names[j], "-",
                                  "UCLA-SuEIR.csv"), row.names = FALSE)

  }
}

