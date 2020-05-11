#################################################################################
###### This file has been adapted from code provided in the US COVID19 forecast hub:
###### URL of original file
###### Author of original code: Johannes Bracher
###### The original file has been provided under the MIT license, and so is this adapted version.
#################################################################################


#' helper funtion to extract a date from a CU path name
#'
#' @param MIT_filepath the path from which to extract the date
#'
#' @return an object of class date

date_from_MIT_filepath <- function(MIT_filepath){
  raw_date <- gsub(".csv", "", gsub("Global_", "", MIT_filepath))
  year <- substr(raw_date,1, 4)
  month <- substr(raw_date, 5, 6)
  day <- substr(raw_date, 7, 8)
  date <- paste(year, month, day, sep="-")
  print(as.Date(date))
  return(as.Date(date))
}

#' turn MIT forecast file into quantile-based format
#'
#' @param mit_filepath path to a Geneva submission file
#' @param forecast_date the time at which the forecast was issued; Automated checking is not possible, 
#' @details 
#' 
#' 
#' @return a data.frame in quantile format
process_MIT_file<- function(mit_filepath, forecast_date){
  
  dat <- read.csv(mit_filepath)
  dat = subset(dat, Country == "Germany")
  dat$date <- as.Date(dat$Day)
  dat <- subset(dat, date > forecast_date) # restrict to timepoints after forecast date
  dat$location <- NA
  dat$location <- "GM"
  dat$country <- NULL
  dat$X <- dat$observed <- NULL
  daily_dat <- reshape(dat, direction = "long", varying = list(c("Total.Detected.Deaths")),
                       times = c("day ahead cum death"))
  daily_dat$id <- NULL
  rownames(daily_dat) <- NULL
  
  # get forecast horizons:
  daily_dat$horizon <- as.numeric(daily_dat$date - forecast_date)
  daily_dat$target <- paste(daily_dat$horizon, daily_dat$time)
  
  # remove unneeded columns
  daily_dat$time <- daily_dat$horizon <- daily_dat$Province <- daily_dat$Active <- daily_dat$Active.Hospitalized <-
    daily_dat$Active.Ventilated <- daily_dat$Total.Detected <- daily_dat$Cumulative.Hospitalized <- NULL
  
  # add required ones:
  daily_dat$quantile <- NA
  daily_dat$type = "point"
  daily_dat$forecast_date <- forecast_date
  
  colnames(daily_dat)[colnames(daily_dat) == "Total.Detected.Deaths"] <- "value"
  colnames(daily_dat)[colnames(daily_dat) == "Country"] <- "location_name"
  colnames(daily_dat)[colnames(daily_dat) == "date"] <- "target_end_date"
  daily_dat <- daily_dat[, c("forecast_date", "target", "target_end_date", "location",
                             "location_name", "type", "quantile", "value")]
  
  # add one-week-ahead cumulative forecast if possible:
  # get day of the week of forecast_date:
  day <- weekdays(forecast_date, abbreviate = TRUE)
  next_dates <- seq(from = forecast_date, length.out = 14, by = 1)
  next_days <- weekdays(next_dates, abbreviate = TRUE)
  
  if(day %in% c("Sun", "Mon")){
    forecast_1_wk_ahead_end <- next_dates[next_days == "Sat"][1]
  }else{
    forecast_1_wk_ahead_end <- next_dates[next_days == "Sat"][2]
  }
  
  # Whether the one-week-ahead forecast can be computed depends on the day
  # the forecasts were issued:
  if(max(daily_dat$target_end_date) > forecast_1_wk_ahead_end){
    ends_weekly_forecasts <- data.frame(end = seq(from = forecast_1_wk_ahead_end,
                                                  by = 7, to = max(daily_dat$target_end_date)))
    ends_weekly_forecasts$target <- paste(1:nrow(ends_weekly_forecasts), "wk ahead cum death")
    # restrict to respective cumulative forecasts:
    weekly_dat <- subset(daily_dat, target_end_date %in% ends_weekly_forecasts$end &
                           grepl("cum", daily_dat$target))
    weekly_dat$target <- NULL
    weekly_dat <- merge(weekly_dat, ends_weekly_forecasts, by.x = "target_end_date", by.y = "end")
    weekly_dat <- weekly_dat[, colnames(daily_dat)]
    
    daily_dat <- rbind(daily_dat, weekly_dat)
  }

  return(daily_dat)
  
}