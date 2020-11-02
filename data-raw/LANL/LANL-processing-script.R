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

# Warnings can be ignored

library(tidyverse)
suppressWarnings(library(tidyverse))

Sys.setlocale("LC_TIME", "C")

source("process_global_lanl_file.R")

lanl_filenames <- list.files(".", pattern=".csv", full.names=FALSE)
dates <- unlist(lapply(lanl_filenames, FUN = function(x) substr(basename(x), 0, 10)))
#most_recent_date <- max(as.Date(dates))

countries = list(c("Germany", "GM"), c("Poland", "PL"))

for(dat in dates){

  for (combination in countries){
    
    ## death forecasts

    # death forecast files per date
    cum_filename_deaths <- paste0(dat, "_deaths_quantiles_global_website.csv")
    inc_filename_deaths <- paste0(dat, "_deaths_incidence_quantiles_global_website.csv")

    # process death data
    processed_deaths_cum <- process_global_lanl_file(cum_filename_deaths, 
                                        country=combination[1],
                                        abbr=combination[2])

    processed_deaths_inc <- process_global_lanl_file(inc_filename_deaths, 
                                        country=combination[1],
                                        abbr=combination[2])
    
    # write death forecasts cum / inc in common file
    if (!(is.null(processed_deaths_cum))){
      total <- rbind(processed_deaths_cum, processed_deaths_inc)
      write_csv(total, 
                paste0("../../data-processed/LANL-GrowthRate/", dat, 
                "-", combination[1], "-LANL-GrowthRate.csv"))
    }

    ## case forecasts

    # case forecast files per date
    cum_filename_cases <- paste0(dat, "_confirmed_quantiles_global_website.csv")
    inc_filename_cases <- paste0(dat, "_confirmed_incidence_quantiles_global_website.csv")

    # process case data
    processed_cases_cum <- process_global_lanl_file(cum_filename_cases, 
                                        country=combination[1],
                                        abbr=combination[2])

    processed_cases_inc <- process_global_lanl_file(inc_filename_cases, 
                                        country=combination[1],
                                        abbr=combination[2])
    
    # write case forecasts cum / inc in common file
    if (!(is.null(processed_cases_cum))){
      total <- rbind(processed_cases_cum, processed_cases_inc)
      write_csv(total, 
                paste0("../../data-processed/LANL-GrowthRate/", dat, 
                "-", combination[1], "-LANL-GrowthRate-case.csv"))
    }
  }
}
