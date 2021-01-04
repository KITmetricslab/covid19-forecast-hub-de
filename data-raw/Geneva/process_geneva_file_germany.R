#################################################################################
###### This file has been adapted from code provided in the US COVID19 forecast hub:
###### https://github.com/reichlab/covid19-forecast-hub/blob/master/data-raw/Geneva/process_geneva_file.R
###### Author of original code: Johannes Bracher
###### The original file has been provided under the MIT license, and so is this adapted version.
#################################################################################

## Geneva death and case data functions
## Johannes Bracher
## April 2020

## Use daily JHU based forecasts after ECDC switched to weekly reporting interval
## Jakob Ketterer
## December 2020

#' helper funtion to extract a date from a CU path name
#'
#' @param geneva_filepath the path from which to extract the date
#'
#' @return an object of class date

date_from_geneva_filepath <- function(geneva_filepath){
  # if(grepl("JHU", geneva_filepath)) stop("Please use ECDC rather than JHU forecast files for US COVID-19 forecast hub.")
  
  # for JHU files:
  geneva_filepath <- gsub("JHU_deaths_predictions_", "", geneva_filepath)
  geneva_filepath <- gsub("JHU_cases_predictions_", "", geneva_filepath)
  
  # for ECDC files:
  geneva_filepath <- gsub("ECDC_deaths_predictions_", "", geneva_filepath)
  geneva_filepath <- gsub("ECDC_cases_predictions_", "", geneva_filepath)
  
  # for older files:
  geneva_filepath <- gsub("predictions_deaths_", "", geneva_filepath)
  geneva_filepath <- gsub("predictions_cases_", "", geneva_filepath)
  as.Date(gsub("_", "-", gsub(".csv", "", geneva_filepath)))
}

#' turn Geneva forecast file into quantile-based format
#'
#' @param geneva_filepath path to a Geneva submission file
#' @param forecast_date the time at which the forecast was issued; is internally compared
#'  to date indicated in file name
#' @param country The name of the country in order to subset the Geneva data frame
#' @param location the FIPS code to be used for the location variable
#'
#' @details typically timezero will be a Monday and the 1-week ahead
#' forecast will be for the EW of the Monday. 1-day-ahead would be Tuesday.
#'
#' @return a data.frame in quantile format

process_geneva_file <- function(geneva_filepath, forecast_date, country = "Germany", location = "GM", type = "death"){

  # extract Geneva forecast date from path:
  check_forecast_date <- date_from_geneva_filepath(geneva_filepath)
  # plausibility check: does forecast_date agree with file name?
  if(is.na(check_forecast_date)){
    warning("forecast date could not be extracted from geneva_filepath")
  }else{
    if(check_forecast_date != forecast_date) stop("forecast_date and date in file name differ.")
  }
  
  dat <- read.csv(geneva_filepath)

  # restrict to US, format:
  dat <- dat[dat$country == country, ]
  dat$date <- as.Date(dat$date)
  # dat <- subset(dat, date > forecast_date) # restrict to timepoints after forecast date
  dat$location <- location
  dat$location_name <- country
  dat$country <- NULL
  dat$X <- dat$observed <- NULL

  # adapt colnames where necessary (newer files):
  colnames(dat)[colnames(dat) == "cumul"] <- "cumulative"
  colnames(dat)[colnames(dat) == "daily"] <- "per.day"

  # transform to wide format, tidy up:
  daily_dat <- reshape(dat, direction = "long", varying = list(c("per.day", "cumulative")),
                       times = c(paste("day ahead inc", type),
                                 paste("day ahead cum", type)))
  daily_dat$id <- NULL
  rownames(daily_dat) <- NULL

  # get forecast horizons:
  daily_dat$horizon <- as.numeric(daily_dat$date - forecast_date)
  daily_dat$target <- paste(daily_dat$horizon, daily_dat$time)

  # remove unneeded columns
  daily_dat$time <- daily_dat$horizon <- NULL

  # add required ones:
  daily_dat$quantile <- NA
  daily_dat$type = ifelse(daily_dat$date > forecast_date, "point", "observed")
  daily_dat$forecast_date <- forecast_date

  # adapt colnames and order
  colnames(daily_dat)[colnames(daily_dat) == "per.day"] <- "value"
  colnames(daily_dat)[colnames(daily_dat) == "date"] <- "target_end_date"
  daily_dat <- daily_dat[, c("forecast_date", "target", "target_end_date", "location",
                             "location_name", "type", "quantile", "value")]

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
  if(max(daily_dat$target_end_date) > forecast_1_wk_ahead_end - 14){
    ends_weekly_forecasts <- data.frame(end = seq(from = forecast_1_wk_ahead_end - 14,
                                                  by = 7, to = max(daily_dat$target_end_date)))
    ends_weekly_forecasts$target <- paste((-1):(nrow(ends_weekly_forecasts) -2), "wk ahead cum", type)
    # restrict to respective cumulative forecasts:
    weekly_dat <- subset(daily_dat, target_end_date %in% ends_weekly_forecasts$end &
                           grepl("cum", daily_dat$target))
    weekly_dat$target <- NULL
    weekly_dat <- merge(weekly_dat, ends_weekly_forecasts, by.x = "target_end_date", by.y = "end")
    weekly_dat <- weekly_dat[, colnames(daily_dat)]

    # add incident forecast: start with cumulative forecasts
    weekly_dat_inc <- weekly_dat
    # override target:
    weekly_dat_inc$target <- gsub("cum", "inc", weekly_dat_inc$target)
    # sort (just to be sure)
    weekly_dat_inc <- weekly_dat_inc[order(weekly_dat_inc$target_end_date), ]
    # compute differences
    weekly_dat_inc$value <- c(NA, diff(weekly_dat_inc$value))
    # remove rist row with NA
    weekly_dat_inc <- weekly_dat_inc[-1, ]

    # add to data frame:
    daily_dat <- rbind(daily_dat, weekly_dat_inc, weekly_dat)
  }

  # restrict to target greater or equal to -1 days ahead:
  daily_dat <- daily_dat[daily_dat$target %in% c(paste((-1):30, "day ahead cum", type),
                                                 paste((-1):30, "day ahead inc", type),
                                                 paste((-1):7, "wk ahead cum", type),
                                                 paste((-1):7, "wk ahead inc", type)), ]

  return(daily_dat)
}
