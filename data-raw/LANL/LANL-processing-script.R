## script for processing LANL data 
## Nicholas Reich, Jarad Niemi (US)
## Jannik Deuschel
## April 2020

library(tidyverse)

source("process_lanl_file.R")
source("process_global_lanl_file.R")

lanl_filenames <- list.files(".", pattern=".csv", full.names=FALSE)
dates <- unlist(lapply(lanl_filenames, FUN = function(x) substr(basename(x), 0, 10)))
#most_recent_date <- max(as.Date(dates))

for(dat in dates){
  cum_filename <- paste0(dat, "_deaths_quantiles_global_website.csv")
  inc_filename <- paste0(dat, "_deaths_incidence_quantiles_global_website.csv")


  ### 
  ger_cum_filename <- paste0(dat, "_deaths_quantiles_global_website.csv")
  ger_inc_filename <- paste0(dat, "_deaths_incidence_quantiles_global_website.csv")

  ger_cum <- process_global_lanl_file(ger_cum_filename)
  ger_inc <- process_global_lanl_file(ger_inc_filename)

  names(ger_cum)[names(ger_cum) == "location"] <- "location_name"
  names(ger_inc)[names(ger_inc) == "location"] <- "location_name"

  ger_cum["location"] <- "GM"
  ger_inc["location"] <- "GM"

  total <- rbind(ger_cum, ger_inc)

  write_csv(total, 
            paste0("../../data-processed/LANL-GrowthRate/", 
                            dat, 
                            "-LANL-GrowthRate.csv"))
}