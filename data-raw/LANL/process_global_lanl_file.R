#################################################################################
###### This file has been adapted from code provided in the US COVID19 forecast hub:
###### URL of original file
###### Author of original code: Nicholas Reich, Jarad Niemi
###### The original file has been provided under the MIT license, and so is this adapted version.
#################################################################################

## LANL cumulative death data functions
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

source("../../code/processing-fxns/get_next_saturday.R")

#' turn LANL forecast file into quantile-based format
#'
#' @param lanl_filepath path to a lanl submission file
#'
#' @details designed to process either an incidence or cumulative death forecast
#'
#' @return a data.frame in quantile format

process_global_lanl_file <- function(lanl_filepath, country, abbr){
    
    ## check this is an deaths file or not
    death_or_case <- ifelse(grepl("deaths", basename(lanl_filepath)), "death", "case") 

    ## check this is an incident deaths file or not
    inc_or_cum <- ifelse(grepl("incidence", basename(lanl_filepath)), "inc", "cum")
    
    ## check this is a weekly forecast file or not
    weekly_or_daily <- ifelse(grepl("weekly", basename(lanl_filepath)), "weekly", "daily")
    
    ## read in forecast dates
    timezero <- as.Date(substr(basename(lanl_filepath), 0, 10))
    
    ## read in data
    if (file.exists(lanl_filepath)){
      if (weekly_or_daily == "weekly"){ 
        dat <- read.csv(lanl_filepath)
      } else {
        dat <- read.csv(lanl_filepath)
      }
        forecast_date <- unique(dat$fcst_date)
    } else {
        return (NULL)
    }
    
    ## filter for country
    dat <- subset(dat, name == country)

    if(forecast_date != timezero)
        stop("timezero in the filename is not equal to the forecast date in the data")

    
    ## put data into long format
    date_col <- ifelse(weekly_or_daily == "daily", "date", "end_date")
    quantile_names_wide <- colnames(dat)[startsWith(colnames(dat), "q.")]
    quantile_names_long <- as.numeric(sub("q", "0", quantile_names_wide))
    
    dat_quantiles <- subset(dat, date_col > forecast_date & obs == 0)
    dat_quantiles <- reshape(dat_quantiles, direction = "long", varying=quantile_names_wide, v.names="value", timevar="quantile", times=quantile_names_long)
    
    if (ncol(dat_quantiles)==0){
      return (NULL)
    }
    
    ## subset and rename
    dat_quantiles <- subset(dat_quantiles, select = c("fcst_date", date_col, "quantile", "value", "name"))
    names(dat_quantiles) <- c("forecast_date", "target_end_date", "quantile", "value", "location_name")
    rownames(dat_quantiles) <- NULL
    dat_quantiles$type <- "quantile"
    dat_quantiles$quantile <- round(dat_quantiles$quantile, 3)
    
    ## create targets column
    if (weekly_or_daily == "daily"){
      dat_quantiles$target <- paste(as.Date(dat_quantiles$target_end_date)-as.Date(dat_quantiles$forecast_date), "day ahead", inc_or_cum, death_or_case)
    
    } else {
      
      # check if forecast day is Sunday or Monday => 1 wk ahead for Saturday of same week 
      fcst_wk_day <- weekdays(timezero)
      same_week <- ifelse(fcst_wk_day == "Sunday" | fcst_wk_day == "Monday", TRUE, FALSE)
      
      # calculate numer of wk ahead 
      day_diff <- as.Date(dat_quantiles$target_end_date)-as.Date(dat_quantiles$forecast_date)
      nr_wk_ahead <- numeric(length=length(day_diff))
      if (same_week == TRUE){
        nr_wk_ahead <- ceiling(day_diff/7)
      } else {
        nr_wk_ahead <- floor(day_diff/7)
      }
      
      dat_quantiles$target <- paste(nr_wk_ahead, "wk ahead", inc_or_cum, death_or_case)
    }

    ## make and merge point estimates as medians
    dat_points <- subset(dat_quantiles, dat_quantiles$quantile==0.5)
    dat_points$type <- "point"
    dat_points$quantile <- NA
    
    ## add ground_truth for daily data
    if (weekly_or_daily == "daily"){ 
      dat_past <- subset(dat, date <= forecast_date)
  
      truth_col <- ifelse (death_or_case == "death", "truth_deaths", "truth_confirmed")
      value_col <- ifelse(inc_or_cum == "cum", truth_col, "q.50")
  
      dat_past <- reshape(dat_past, direction = "long",
                          varying = list(c(value_col)),
                          times = c(paste("day ahead",  inc_or_cum, death_or_case)))
  
      # Add and rename columns
      dat_past$quantile <- NA
      dat_past$type <- "observed"
      colnames(dat_past)[colnames(dat_past) ==
                           value_col] <- "value"
      colnames(dat_past)[colnames(dat_past) ==
                           "name"] <- "location_name"
      colnames(dat_past)[colnames(dat_past) ==
                           "fcst_date"] <- "forecast_date"
  
      dat_past$id <- NULL
      rownames(dat_past) <- NULL
  
      # get forecast horizons:
      dat_past$horizon <- as.numeric(as.Date(dat_past$date) - as.Date(forecast_date))
      dat_past$target <- paste(dat_past$horizon, dat_past$time)
      
      # remove unneeded columns
      dat_past$time <- dat_past$horizon <- NULL
  
      colnames(dat_past)[colnames(dat_past) == "date"] <- "target_end_date"
      
      
      # reorder
      dat_past <- dat_past[, c("forecast_date", "target", "target_end_date",
                               "location_name", "type", "quantile", "value")]
      
      all_dat <- rbind(dat_quantiles, dat_points, dat_past)
    } else {
      all_dat <- rbind(dat_quantiles, dat_points)
    }

    all_dat$location <- NA
    all_dat$location <- abbr

    all_dat$location_name <- NA
    all_dat$location_name <- country
    
    all_dat <- all_dat[, c("forecast_date", "target", "target_end_date",
                           "location", "type", "quantile", "value", "location_name")]

    ## final formatting
    # forecast_date,target,target_end_date,location,type,quantile,value,location_name

    all_dat <- subset(all_dat, target %in% c(paste((-1):130, "day ahead cum", death_or_case),
                                             paste((-1):130, "day ahead inc", death_or_case),
                                             paste((-1):20, "wk ahead cum", death_or_case),
                                             paste((-1):20, "wk ahead inc", death_or_case)))
    
    return(all_dat)
    
}



# dat_test <- process_global_lanl_file("2020-12-06_global_cumulative_daily_cases_website.csv", country="Germany", abbr="GM")
