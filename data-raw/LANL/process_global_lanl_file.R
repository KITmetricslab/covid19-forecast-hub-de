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

source("../../code/processing-fxns/get_next_saturday.R")

#' turn LANL forecast file into quantile-based format
#'
#' @param lanl_filepath path to a lanl submission file
#'
#' @details designed to process either an incidence or cumulative death forecast
#'
#' @return a data.frame in quantile format

process_global_lanl_file <- function(lanl_filepath, country, abbr){
    
    library(tidyverse, lib.loc="../../Rdeps"))
    library(MMWRweek, lib.loc="../../Rdeps"))
    library(lubridate, lib.loc="../../Rdeps"))
    
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
        dat <- read_csv(lanl_filepath, col_types = cols(
          .default = col_double(),
          key = col_character(),
          week_ahead = col_integer(),
          fcst_date = col_date(format = ""),
          name = col_character(),
          big_group = col_character(),
          start_date = col_date(format = ""),
          end_date = col_date(format = "")
        ))
      } else {
        dat <- read_csv(lanl_filepath, col_types = cols(
          .default = col_double(),
          date = col_date(format = ""),
          key = col_character(),
          fcst_date = col_date(format = ""),
          name = col_character(),
          big_group = col_character()
        ))
      }
        forecast_date <- unique(dat$fcst_date)
    } else {
        return (NULL)
    }
    

    if(forecast_date != timezero)
        stop("timezero in the filename is not equal to the forecast date in the data")
    
    
    #### process weekly files/targets
    if (weekly_or_daily == "weekly"){
      
      # dat$weeks_ahead <- epiweek(dat$end_date) - epiweek(dat$fcst_date)
      
      dat_long <- tidyr::pivot_longer(dat, cols=starts_with("q."),
                                      names_to = "q",
                                      values_to = "value") %>%
        dplyr::filter(end_date > forecast_date, name == country) %>%  # adjust here for -1 and 0 wk ahead?
        dplyr::filter(obs == 0) %>% # only include forecasts
        dplyr::mutate(quantile = as.numeric(sub("q", "0", q)), type="quantile") %>%
        dplyr::mutate(target = paste(week_ahead, "wk ahead",inc_or_cum, death_or_case)) %>%
        dplyr::select(name, type, quantile, value, end_date, target) %>%
        dplyr::rename(
          location = name,
          target_end_date = end_date)
      
      if (ncol(dat_long)==0){
        return (NULL)
      }
      
      point_ests <- dat_long %>%
        filter(quantile==0.5) %>%
        mutate(quantile=NA, type="point")
      
      dat_all <- rbind(point_ests, dat_long)
      
      dat_all$forecast_date <- forecast_date
      dat_all$location_name <- dat_all$location
      dat_all$location <- abbr
      
      dat_final <- dplyr::relocate(dat_all, forecast_date, target, target_end_date, location, type, quantile, value)
      return(dat_final)
      
    }
    
    #### process daily files/targets
    ## put into long format
    dat_long <- tidyr::pivot_longer(dat, cols=starts_with("q."),
                                    names_to = "q",
                                    values_to = "value") %>%
      dplyr::filter(date > forecast_date, name == country) %>%
      dplyr::filter(obs == 0) %>% # only include forecasts
      dplyr::mutate(quantile = as.numeric(sub("q", "0", q)), type="quantile") %>%
      dplyr::select(name, type, quantile, value, date) %>%
      dplyr::rename(
        location = name,
        target_end_date = date)

    if (ncol(dat_long)==0){
      return (NULL)
    }

    ## create tables corresponding to the days for each of the targets
    n_day_aheads <- length(unique(dat_long$target_end_date))
    n_week_aheads <- sum(wday(unique(dat_long$target_end_date))==7)

    day_aheads <- tibble(
            target = paste(1:n_day_aheads, "day ahead", inc_or_cum, death_or_case),
            target_end_date = forecast_date+1:n_day_aheads)

    ## merge so targets are aligned with dates
    fcast_days <- inner_join(day_aheads, dat_long, by = "target_end_date")
    fcast_all <- fcast_days %>% ## this will be overwritten if cumulative file.
        mutate(forecast_date = forecast_date)

    
    # DEPR: wk ahead cum targets
    # # ## only do week-ahead for cumulative counts
    # if(inc_or_cum == "cum") {
    #      if(wday(forecast_date) <= 2 ) { ## sunday = 1, ..., saturday = 7
    #          ## if timezero is Sun or Mon, then the current epiweek ending on Saturday is the "1 week-ahead"
    #          week_aheads <- tibble(
    #              target = paste(1:n_week_aheads, "wk ahead cum", death_or_case),
    #              target_end_date = get_next_saturday(forecast_date+seq(0, by=7, length.out = n_week_aheads))
    #          )
    #      } else {
    #          ## if timezero is after Monday, then the next epiweek is "1 week-ahead"
    #          week_aheads <- tibble(
    #              target = paste(1:n_week_aheads, "wk ahead cum", death_or_case),
    #              target_end_date = get_next_saturday(forecast_date+seq(7, by=7, length.out = n_week_aheads))
    #          )
    #      }
    # 
    #      ## merge so targets are aligned with dates
    #      fcast_weeks <- inner_join(week_aheads, dat_long)
    #      fcast_all <- bind_rows(fcast_days, fcast_weeks) %>%
    #          mutate(forecast_date = forecast_date)
    #  }
    
      
      
    ## make and merge point estimates as medians
    point_ests <- fcast_all %>%
        filter(quantile==0.5) %>%
        mutate(quantile=NA, type="point")


    ## add ground_truth
    ## ------------------
    dat_past <- subset(dat, date <= forecast_date)
    dat_past <- subset(dat_past, name == country)

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
    dat_past$horizon <- as.numeric(dat_past$date - forecast_date)
    dat_past$target <- paste(dat_past$horizon, dat_past$time)

    # remove unneeded columns
    dat_past$time <- dat_past$horizon <- NULL

    colnames(dat_past)[colnames(dat_past) == "date"] <- "target_end_date"
    
    # DEPR: wk ahead cum targets
    # # add one-week-ahead cumulative forecast if possible as well as 0 and -1-week ahead forecasts:
    # # get day of the week of forecast_date:
    # day <- weekdays(forecast_date, abbreviate = TRUE)
    # 
    # # When do the one-week-ahead forecast end?
    # next_dates <- seq(from = forecast_date, length.out = 14, by = 1)
    # next_days <- weekdays(next_dates, abbreviate = TRUE)
    # if(day %in% c("Sun", "Mon")){
    #   forecast_1_wk_ahead_end <- next_dates[next_days == "Sat"][1]
    # }else{
    #   forecast_1_wk_ahead_end <- next_dates[next_days == "Sat"][2]
    # }
    # # Whether the one-week-ahead forecast can be computed depends on the day
    # # the forecasts were issued:
    # if(max(dat_past$target_end_date) > forecast_1_wk_ahead_end - 14){
    #   ends_weekly_forecasts <- data.frame(end = seq(from = forecast_1_wk_ahead_end - 14,
    #                                                 by = 7, to = max(dat_past$target_end_date)))
    #   ends_weekly_forecasts$target <- paste((-1):(nrow(ends_weekly_forecasts) -2), "wk ahead cum", death_or_case)
    #   # restrict to respective cumulative forecasts:
    #   weekly_dat <- subset(dat_past, target_end_date %in% ends_weekly_forecasts$end &
    #                          grepl("cum", dat_past$target))
    #   weekly_dat$target <- NULL
    #   weekly_dat <- merge(weekly_dat, ends_weekly_forecasts, by.x = "target_end_date", by.y = "end")
    #   weekly_dat <- weekly_dat[, colnames(dat_past)]
    # 
    #   dat_past <- rbind(dat_past, weekly_dat)
    # }
    
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
    
    all_dat <- subset(all_dat, target %in% c(paste((-1):130, "day ahead cum", death_or_case),
                                             paste((-1):130, "day ahead inc", death_or_case),
                                             paste((-1):20, "wk ahead cum", death_or_case)))
    
    return(all_dat)
}


# death_cum_weekly <- process_global_lanl_file("2020-10-28_weekly_deaths_quantiles.csv", country="Germany", abbr="GM")

# death_cum <- process_global_lanl_file("2020-10-28_deaths_quantiles_global_website.csv", country="Germany", abbr="GM")

# death_cum <- process_global_lanl_file("2020-10-25_deaths_quantiles_global_website.csv", country="Germany", abbr="GM")
