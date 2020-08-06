#################################################################################
###### This file has been adapted from code provided in the US COVID19 forecast hub:
###### URL of original file
###### Author of original code: Nicholas Reich, Jarad Niemi
###### The original file has been provided under the MIT license, and so is this adapted version.
#################################################################################

## LANL cumulative death data functions
## Jannik Deuschel
## April 2020

source("../../code/processing-fxns/get_next_saturday.R")

#' turn LANL forecast file into quantile-based format
#'
#' @param lanl_filepath path to a lanl submission file
#'
#' @details designed to process either an incidence or cumulative death forecast
#'
#' @return a data.frame in quantile format
process_global_lanl_file <- function(lanl_filepath, country, abbr,
                              forecast_dates_file = "../../template/covid19-death-forecast-dates.csv") {
    require(tidyverse)
    require(MMWRweek)
    require(lubridate)
  
    if(!grepl("deaths", lanl_filepath)) 
      stop("check to make sure this is a deaths file")

    ## check this is an incident deaths file or not
    inc_or_cum <- ifelse(grepl("incidence", basename(lanl_filepath)),
        "inc", "cum")
    
    ## read in forecast dates
    fcast_dates <- read_csv(forecast_dates_file)
    timezero <- as.Date(substr(basename(lanl_filepath), 0, 10))
    
    ## read in data
    dat <- read_csv(lanl_filepath)
    forecast_date <- unique(dat$fcst_date)
    
    if(forecast_date != timezero)
        stop("timezero in the filename is not equal to the forecast date in the data")
    
    
    ## put into long format
    dat_long <- tidyr::pivot_longer(dat, cols=starts_with("q."), 
                             names_to = "q", 
                             values_to = "cum_deaths") %>%
        dplyr::filter(dates > forecast_date, countries == country) %>%
        dplyr::mutate(quantile = as.numeric(sub("q", "0", q)), type="quantile") %>%
        dplyr::select(countries, type, quantile, cum_deaths, dates) %>%
        dplyr::rename(
            location = countries, 
            value = cum_deaths,
            target_end_date = dates)
    
    if (ncol(dat_long)==0){
      return (NULL)
    }
    
    ## create tables corresponding to the days for each of the targets
    n_day_aheads <- length(unique(dat_long$target_end_date))
    n_week_aheads <- sum(wday(unique(dat_long$target_end_date))==7)
        
    day_aheads <- tibble(
        target = paste(1:n_day_aheads, "day ahead", inc_or_cum, "death"), 
        target_end_date = forecast_date+1:n_day_aheads)

    ## merge so targets are aligned with dates
    fcast_days <- inner_join(day_aheads, dat_long) 
    fcast_all <- fcast_days %>% ## this will be overwritten if cumulative file.
        mutate(forecast_date = forecast_date)
    
    ## only do week-ahead for cumulative counts
    if(inc_or_cum == "cum") {
        if(wday(forecast_date) <= 2 ) { ## sunday = 1, ..., saturday = 7
            ## if timezero is Sun or Mon, then the current epiweek ending on Saturday is the "1 week-ahead"
            week_aheads <- tibble(
                target = paste(1:n_week_aheads, "wk ahead cum death"),
                target_end_date = get_next_saturday(forecast_date+seq(0, by=7, length.out = n_week_aheads))
            )
        } else {
            ## if timezero is after Monday, then the next epiweek is "1 week-ahead"
            week_aheads <- tibble(
                target = paste(1:n_week_aheads, "wk ahead cum death"), 
                target_end_date = get_next_saturday(forecast_date+seq(7, by=7, length.out = n_week_aheads))
            )
        }
        
        ## merge so targets are aligned with dates
        fcast_weeks <- inner_join(week_aheads, dat_long)
        fcast_all <- bind_rows(fcast_days, fcast_weeks) %>%
            mutate(forecast_date = forecast_date)
    }
    
    
    ## make and merge point estimates as medians
    point_ests <- fcast_all %>% 
        filter(quantile==0.5) %>% 
        mutate(quantile=NA, type="point")
    
    
    ## add ground_truth
    ## ------------------
    dat_past <- subset(dat, dates <= forecast_date)
    dat_past <- subset(dat_past, countries == country)
    
    value_col <- ifelse(inc_or_cum == "cum", "truth_deaths", "q.50")
    
    
    dat_past <- reshape(dat_past, direction = "long", 
                        varying = list(c(value_col)),
                        times = c(paste("day ahead",  inc_or_cum ,"death", sep=" ")))
    
    # Add and rename columns
    dat_past$quantile <- NA
    dat_past$type <- "observed"
    colnames(dat_past)[colnames(dat_past) == 
                         value_col] <- "value"
    colnames(dat_past)[colnames(dat_past) == 
                         "countries"] <- "location_name"
    colnames(dat_past)[colnames(dat_past) == 
                         "fcst_date"] <- "forecast_date"
    
    dat_past$id <- NULL
    rownames(dat_past) <- NULL
    
    # get forecast horizons:
    dat_past$horizon <- as.numeric(dat_past$dates - forecast_date)
    dat_past$target <- paste(dat_past$horizon, dat_past$time)
    
    # remove unneeded columns
    dat_past$time <- dat_past$horizon <- NULL
    
    colnames(dat_past)[colnames(dat_past) == "dates"] <- "target_end_date"
    
    # add one-week-ahead cumulative forecast if possible as well as 0 and -1-week ahead forecasts:
    # get day of the week of forecast_date:
    day <- weekdays(forecast_date, abbreviate = TRUE)
    
    # When do the one-week-ahead forecast end?
    next_dates <- seq(from = forecast_date, length.out = 14, by = 1)
    next_days <- weekdays(next_dates, abbreviate = TRUE)
    if(day %in% c("Sun", "Mon")){
      forecast_1_wk_ahead_end <- next_dates[next_days == "Sat"][1]
    }else{
      forecast_1_wk_ahead_end <- next_dates[next_days == "Sat"][2]
    }
    # Whether the one-week-ahead forecast can be computed depends on the day
    # the forecasts were issued:
    if(max(dat_past$target_end_date) > forecast_1_wk_ahead_end - 14){
      ends_weekly_forecasts <- data.frame(end = seq(from = forecast_1_wk_ahead_end - 14,
                                                    by = 7, to = max(dat_past$target_end_date)))
      ends_weekly_forecasts$target <- paste((-1):(nrow(ends_weekly_forecasts) -2), "wk ahead cum death")
      # restrict to respective cumulative forecasts:
      weekly_dat <- subset(dat_past, target_end_date %in% ends_weekly_forecasts$end &
                             grepl("cum", dat_past$target))
      weekly_dat$target <- NULL
      weekly_dat <- merge(weekly_dat, ends_weekly_forecasts, by.x = "target_end_date", by.y = "end")
      weekly_dat <- weekly_dat[, colnames(dat_past)]
      
      dat_past <- rbind(dat_past, weekly_dat)
    }
    
    dat_past <- dat_past[, c("forecast_date", "target", "target_end_date",
                             "location_name", "type", "quantile", "value")]
    
    all_dat <- bind_rows(fcast_all, point_ests, dat_past) %>%
        arrange(type, target, quantile) %>%
        mutate(quantile = round(quantile, 3)) %>%
        ## making sure ordering is right :-)
        select(forecast_date, target, target_end_date, location, type, quantile, value)
    
    # Add country
    all_dat$location <- NA
    all_dat$location <- abbr
    
    all_dat$location_name <- NA
    all_dat$location_name <- country
    
    all_dat <- subset(all_dat, target %in% c(paste((-1):130, "day ahead cum death"),
                                             paste((-1):130, "day ahead inc death"),
                                             paste((-1):20, "wk ahead cum death")))
    
    return(all_dat)
}