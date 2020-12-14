#################################################################################
###### This file has been adapted from code provided in the US COVID19 forecast hub:
###### URL of original file
###### Author of original code: Nicholas Reich, Jarad Niemi (US)
###### The original file has been provided under the MIT license, and so is this adapted version.
#################################################################################

## script for processing LANL data 
## Jannik Deuschel
## April 2020

## support for case forecasts
## Jakob Ketterer
## August 2020

## LANL model v1 -> v2
## added support for weekly incidence forecasts
## adapted to changes in filenames
## remove causes for warnings
## Changes in LANL output format
## Jakob Ketterer
## November 2020

## Replace packages with base-R
## Jakob Ketterer
## December 2020

Sys.setlocale("LC_TIME", "C")

source("process_global_lanl_file.R")

countries = list(c("Germany", "GM"), c("Poland", "PL"))

# only process files that have not been created yet
lanl_filenames_processed <- list.files("../../data-processed/LANL-GrowthRate/", pattern=".csv", full.names=FALSE)
lanl_filenames_raw <- list.files(".", pattern=".csv", full.names=FALSE)

dates_processed <- unlist(lapply(lanl_filenames_processed, FUN = function(x) substr(basename(x), 0, 10)))
dates_raw <- unlist(lapply(lanl_filenames_raw, FUN = function(x) substr(basename(x), 0, 10)))

dates <- setdiff(dates_raw, dates_processed)
print(c("Generating forecasts for the following dates:", dates))

for(dat in dates){

  for (combination in countries){

    ## death forecasts
    # death forecast filenames per date
      # daily
      cum_daily_deaths_filename <- paste0(dat, "_global_cumulative_daily_deaths_website.csv")
      filenames <- list(cum_daily_deaths_filename)
      inc_daily_deaths_filename <- paste0(dat, "_global_incidence_daily_deaths_website.csv")
      filenames <- append(filenames, inc_daily_deaths_filename)

      # weekly
      cum_weekly_deaths_filename <- paste0(dat, "_global_cumulative_weekly_deaths_website.csv")
      filenames <- append(filenames, cum_weekly_deaths_filename)
      inc_weekly_deaths_filename <- paste0(dat, "_global_incidence_weekly_deaths_website.csv")
      filenames <- append(filenames, inc_weekly_deaths_filename)

    # process death data
      final_frame <- data.frame()
      for (filename in filenames){
        sub_frame <- process_global_lanl_file(filename,
                                          country=combination[1],
                                          abbr=combination[2])
        if (!(is.null(frame))){
          final_frame <- rbind(final_frame, sub_frame)
        } else {
          print(c("Processed data of", filename, "is empty!"))
        }
      }

      if (!(is.null(final_frame))){
        write.csv(final_frame,
                  file=paste0("../../data-processed/LANL-GrowthRate/", dat,
                       "-", combination[1], "-LANL-GrowthRate.csv"),
                  quote = FALSE,
                  row.names = FALSE)
      }


    ## case forecasts
    # case forecast filenames per date
      # daily
      cum_daily_cases_filename <- paste0(dat, "_global_cumulative_daily_cases_website.csv")
      filenames <- list(cum_daily_cases_filename)
      inc_daily_cases_filename <- paste0(dat, "_global_incidence_daily_cases_website.csv")
      filenames <- append(filenames, inc_daily_cases_filename)

      # weekly
      cum_weekly_cases_filename <- paste0(dat, "_global_cumulative_weekly_cases_website.csv")
      filenames <- append(filenames, cum_weekly_cases_filename)
      inc_weekly_cases_filename <- paste0(dat, "_global_incidence_weekly_cases_website.csv")
      filenames <- append(filenames, inc_weekly_cases_filename)

    # process death data
      final_frame <- data.frame()
      for (filename in filenames){
        sub_frame <- process_global_lanl_file(filename,
                                              country=combination[1],
                                              abbr=combination[2])
        if (!(is.null(frame))){
          final_frame <- rbind(final_frame, sub_frame)
        } else {
          print(c("Processed data of", filename, "is empty!"))
        }
      }

      if (!(is.null(final_frame))){
        write.csv(final_frame,
                  file=paste0("../../data-processed/LANL-GrowthRate/", dat,
                         "-", combination[1], "-LANL-GrowthRate-case.csv"), 
                  quote = FALSE,
                  row.names = FALSE)
      }
  }
}
