#################################################################################
###### This file has been adapted from code provided in the US COVID19 forecast hub:
###### URL of original file
###### Author of original code: Nicholas Reich, Jarad Niemi (US)
###### The original file has been provided under the MIT license, and so is this adapted version.
#################################################################################

## script for processing LANL data 
## Jannik Deuschel
## April 2020

library(tidyverse)

Sys.setlocale("LC_TIME", "C")

source("process_global_lanl_file.R")

lanl_filenames <- list.files(".", pattern=".csv", full.names=FALSE)
dates <- unlist(lapply(lanl_filenames, FUN = function(x) substr(basename(x), 0, 10)))
#most_recent_date <- max(as.Date(dates))

for(dat in dates){
  cum_filename <- paste0(dat, "_deaths_quantiles_global_website.csv")
  inc_filename <- paste0(dat, "_deaths_incidence_quantiles_global_website.csv")
  print(cum_filename)

  ### 
  ger_cum_filename <- paste0(dat, "_deaths_quantiles_global_website.csv")
  ger_inc_filename <- paste0(dat, "_deaths_incidence_quantiles_global_website.csv")

  ger_cum <- process_global_lanl_file(ger_cum_filename)
  ger_inc <- process_global_lanl_file(ger_inc_filename)

  total <- rbind(ger_cum, ger_inc)

  write_csv(total, 
            paste0("../../data-processed/LANL-GrowthRate/", 
                            dat, 
                            "-Germany-LANL-GrowthRate.csv"))
}
