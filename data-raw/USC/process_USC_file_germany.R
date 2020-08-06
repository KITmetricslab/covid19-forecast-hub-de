#################################################################################
###### This file has been adapted from code provided in the US COVID19 forecast hub:
###### https://github.com/reichlab/covid19-forecast-hub/blob/master/data-raw/Geneva/process_geneva_file.R
###### Author of original code: Johannes Bracher
###### The original file has been provided under the MIT license, and so is this adapted version.
#################################################################################

## USC death data functions
## Johannes Bracher, Jakob Ketterer
## July 2020

# convert colnames to forecast dates
col_to_date <- function(col) {
    return(as.Date(gsub("X", "", col), format="%Y.%m.%d"))
}

#' helper funtion to extract a date from a USC path name
#'
#' @param usc_filepath the path from which to extract the date
#'
#' @return an object of class date

date_from_usc_filepath <- function(usc_filepath){
  # first forecast date extracted from 3rd header column
  # Assumption: day before first forecast date is date_zero
  dat <- read.csv(usc_filepath)
  return(as.Date(col_to_date(colnames(dat)[3])-1))
}

#' turn USC forecast file into quantile-based format
#'
#' @param usc_filepath path to a USC submission file
#' @param date_zero the time at which the forecast was issued; is internally compared
#'  to date indicated in file name
#'
#' @details typically timezero will be a Monday and the 1-week ahead
#' forecast will be for the EW of the Monday. 1-day-ahead would be Tuesday.
#'
#' @return a data.frame in quantile format

process_usc_file <- function(usc_filepath, date_zero, horizon.days, horizon.wks){

  # extract USC forecast date from path:
  check_forecast_date <- date_from_usc_filepath(usc_filepath)

  # plausibility check: does date_zero agree with file name?
  if(is.na(check_forecast_date)){
    warning("forecast date could not be extracted from usc_filepath")
  } else {
    if(check_forecast_date != date_zero) stop("date_zero and date in file name differ.")
  }

  dat_orig <- read.csv(usc_filepath)

  # day before first date in columns
  day_zero <- weekdays(date_zero, abbreviate = TRUE)

  # restrict to Germany:
  dat_ger <- subset(dat_orig, Country == "Germany")

  # extract necessary values from old data frame
  dates <- col_to_date(colnames(dat_ger)[-1:-2])
  days <- weekdays(dates, abbreviate = TRUE)
  cum_values <- as.numeric(dat_ger[1,-1:-2])      # cum deaths
  inc_values <- diff(cum_values, lag=1)           # inc deaths
  inc_values <- c(NA, inc_values)
#   Attention: 0 day ahead inc death data not available as no cum value for day before day_zero

  ## show forecasts for  days maximum
  horizon_days_max <- as.numeric(difftime(tail(dates, n=1), date_zero, units="days"))
  if (horizon_days_max < horizon.days) {
      stop_day = horizon_days_max
  } else {
      stop_day = horizon.days
  }

  target <- character()
  target_end_date <- as.Date(character())
  value <- numeric()

  # there are no observed values in the data
  start_day <- 1

  # calculate target desctiptions for given forecasts
  for (i in start_day:stop_day){
      date <- dates[i]
      horizon <- as.numeric(difftime(date, date_zero, units="days"))
      stopifnot(horizon == i)
      
      ## day forecasts
      # cum day forecast
      cum_tar <- paste(horizon, " day ahead cum death")
      target <- c(target, cum_tar)
      cum_val <- cum_values[i]
      value <- c(value, cum_val)
      target_end_date <- c(target_end_date, date)

      # inc day forecast
      inc_tar <- paste(horizon, " day ahead inc death")
      target <- c(target, inc_tar)
      inc_val <- inc_values[i]
      value <- c(value, inc_val)
      target_end_date <- c(target_end_date, date)
  }

  ## show forecasts for 1 wk ahead maximum
  # If the forecast was issued before Tuesday, one week ahead forecast means Saturday that same week.
  same_week <- ifelse(day_zero %in% c("So", "Mo"), TRUE, FALSE)

  # calculate number of forecasted epidemic weeks
  saturdays <- dates[days == "Sa"]
 
  # whether to interpret the first predicted saturday as 0 or 1 wk ahead
  if (same_week == TRUE){
      # there are no ground truth saturdays in the data => 0 wk ahead doesnt exist
      start_wk <- 1   # start with 1 wk ahead forecast, first saturday is end date of current epidemic week 
      horizon_wks_max <- length(saturdays)
      begin_inc <- 2  # first inc data exists between saturday 1 and 2
  } else {
      # there are no ground truth saturdays in the data => 0 wk ahead refers to first predicted saturday
      start_wk <- 0   # start with 0 wk ahead forecast
      horizon_wks_max <- length(saturdays) - 1   # 1 wk ahead forecast refers to next epidemic week
      begin_inc <- 1  # first inc data exists between saturday 0 and 1
  }

  # limit number of weekly forecasts
  if (horizon_wks_max < horizon.wks) {
      stop_wk = horizon_wks_max
  } else {
      stop_wk = horizon.wks
  }

  sat_index = 1 # counter for saturday vector

  for (i in start_wk:stop_wk){
      sat_date <- saturdays[sat_index] 

      ## wk forecasts
      date_index <- which(dates == sat_date)[1]
      # cum wk forecast
      cum_tar <- paste(i, " wk ahead cum death")
      target <- c(target, cum_tar)
      cum_val <- cum_values[date_index]
      value <- c(value, cum_val)
      target_end_date <- c(target_end_date, sat_date)

      # inc wk forecast
      # weekly incident forecasts only possible from week begin_inc on
      if(i >= begin_inc){
      inc_tar <- paste(i, " wk ahead inc death")
      target <- c(target, inc_tar)
      inc_sum <- sum(inc_values[(date_index-6):date_index]) # calculation of inc wk forecasts as sum of inc deaths between Saturdays
      value <- c(value, inc_sum)
      target_end_date <- c(target_end_date, sat_date)
      }

      sat_index <- sat_index + 1
  }
  
  # plausibility checks
  stopifnot(length(target) == length(target_end_date) & length(target) == length(value) & length(target_end_date) == length(value))
  no_of_forecasts <- length(target)

  ## create new data frame with different forecast values in rows instead of columns
  forecast_date <- rep(date_zero, no_of_forecasts)
  location <- rep("GM", no_of_forecasts)
  location_name <- rep("Germany", no_of_forecasts)
  type <- ifelse(target_end_date > forecast_date, "point", "observed")
  quantile <- rep(NA, no_of_forecasts)
  
  dat <- data.frame(forecast_date, target, target_end_date, location, location_name, type, quantile, value, row.names = NULL, check.rows = FALSE, check.names = TRUE, stringsAsFactors = default.stringsAsFactors())
  return(dat)
}
