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

## support for weekly incidence forecasts
## remove causes for warnings
## Changes in LANL output format
## 1) separation in daily and weekly forecast files
## 2) change in colnames for daily files as of 2020-10-28
    # Details:
    # old colname -> newcolname
    # dates -> dat
    # simple_countries -> key
    # countries -> name
    # _ -> big_group  
## Jakob Ketterer
## November 2020

# Warnings can be ignored

library(tidyverse)

Sys.setlocale("LC_TIME", "C")

source("process_global_lanl_file.R")

countries = list(c("Germany", "GM"), c("Poland", "PL"))

# only process files that have not been created yet
lanl_filenames_processed <- list.files("../../data-processed/LANL-GrowthRate/", pattern=".csv", full.names=FALSE)
lanl_filenames_raw <- list.files(".", pattern=".csv", full.names=FALSE)

dates_processed <- unlist(lapply(lanl_processed_filenames, FUN = function(x) substr(basename(x), 0, 10)))
dates_raw <- unlist(lapply(lanl_filenames, FUN = function(x) substr(basename(x), 0, 10)))

dates <- setdiff(dates, dates_processed)

for(dat in dates){

  for (combination in countries){

    ## death forecasts
    # death forecast filenames per date
      # daily
      cum_daily_deaths_filename <- paste0(dat, "_deaths_quantiles_global_website.csv")
      filenames <- list(cum_daily_deaths_filename)
      inc_daily_deaths_filename <- paste0(dat, "_deaths_incidence_quantiles_global_website.csv")
      filenames <- append(filenames, inc_daily_deaths_filename)

      # weekly
      cum_weekly_deaths_filename <- paste0(dat, "_weekly_deaths_quantiles.csv")
      filenames <- append(filenames, cum_weekly_deaths_filename)
      inc_weekly_deaths_filename <- paste0(dat, "_weekly_deaths_incidence_quantiles.csv")
      filenames <- append(filenames, inc_weekly_deaths_filename)

    # process death data
      final_frame <- data.frame()
      for (filename in filenames){
        sub_frame <- process_global_lanl_file(filename,
                                          country=combination[1],
                                          abbr=combination[2])
        if (!(is.null(frame))){
          final_frame <- rbind(final_frame, sub_frame)
        }
      }

      if (!(is.null(final_frame))){
        write_csv(final_frame,
                  paste0("../../data-processed/LANL-GrowthRate/", dat,
                       "-", combination[1], "-LANL-GrowthRate.csv"))
      }


    ## case forecasts
    # case forecast filenames per date
      # daily
      cum_daily_cases_filename <- paste0(dat, "_confirmed_quantiles_global_website.csv")
      filenames <- list(cum_daily_cases_filename)
      inc_daily_cases_filename <- paste0(dat, "_confirmed_incidence_quantiles_global_website.csv")
      filenames <- append(filenames, inc_daily_cases_filename)

      # weekly
      cum_weekly_cases_filename <- paste0(dat, "_weekly_confirmed_quantiles.csv")
      filenames <- append(filenames, cum_weekly_cases_filename)
      inc_weekly_cases_filename <- paste0(dat, "_weekly_confirmed_incidence_quantiles.csv")
      filenames <- append(filenames, inc_weekly_cases_filename)

    # process death data
      final_frame <- data.frame()
      for (filename in filenames){
        sub_frame <- process_global_lanl_file(filename,
                                              country=combination[1],
                                              abbr=combination[2])
        if (!(is.null(frame))){
          final_frame <- rbind(final_frame, sub_frame)
        }
      }

      if (!(is.null(final_frame))){
        write_csv(final_frame,
                  paste0("../../data-processed/LANL-GrowthRate/", dat,
                         "-", combination[1], "-LANL-GrowthRate-case.csv"))
      }
  }
}
