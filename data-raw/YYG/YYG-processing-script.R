#################################################################################
###### This file has been adapted from code provided in the US COVID19 forecast hub:
###### URL of original file
###### Author of original code: Johannes Bracher
###### The original file has been provided under the MIT license, and so is this adapted version.
#################################################################################

## Jannik Deuschel
## May 2020

## Jakob Ketterer
## August 2020
## Support for case forecasts
source("process_YYG_file_germany.R")
# make sure that English names of days and months are used
Sys.setlocale("LC_TIME", "C")

dir.create("../../data-processed/YYG-ParamSearch", showWarnings = FALSE)
files_to_process <- list.files("./", recursive = FALSE)
files_to_process <- files_to_process[grepl(".csv", files_to_process) &
                                       grepl("_global", files_to_process)]

forecast_dates <- lapply(files_to_process, date_from_YYG_filepath)

#list of country abbreviation pairs
countries <- list(c("Germany", "GM"), c("Poland", "PL"))


# proces files:
for(i in 1:length(files_to_process)) {
  
  for (pair in countries){

    # print(forecast_dates[[i]])

    processed_data <- process_YYG_file(files_to_process[i], 
                                forecast_date = forecast_dates[[i]],
                                func_country=pair[1],
                                abbr=pair[2])
    
    if (!is.null(processed_data$deaths)) {
       # write death forecasts
    write.csv(processed_data$deaths,
              paste0("../../data-processed/YYG-ParamSearch/", forecast_dates[[i]],
                     "-", pair[1],"-YYG-ParamSearch.csv"),
              row.names = FALSE)
    }
    
    ########################
    # NOT IN USE: case forecasts include estimates of unreported cases and don't comply with our standards!
    ########################

    # if (!is.null(processed_data$cases)) {
    #    # write case forecasts
    #    write.csv(processed_data$cases,
    #                  paste0("../../data-processed/YYG-ParamSearch/", forecast_dates[[i]],
    #                         "-", pair[1],"-YYG-ParamSearch-case.csv"),
    #                  row.names = FALSE)
    # }
  }
}

