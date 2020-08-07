#' helper funtion to extract a date from a CU path name
#'
#' @param YGG_filepath the path from which to extract the date
#'
#' @return an object of class date


date_from_YYG_filepath <- function(YGG_filepath){
  raw_date <- gsub(".csv", "", gsub("_global", "", YGG_filepath))
  return(as.Date(raw_date))
}

#' turn MIT forecast file into quantile-based format
#'
#' @param yyg_filepath path to a YYG submission file
#' @param forecast_date the time at which the forecast was issued;
#' @param country the desired country 
#' @param abr abbreviation of the country used in location col
#' @details 
#' 
#' 
#' @return a data.frame in quantile format

process_YYG_file<- function(yyg_filepath, forecast_date, func_country, abbr){
  
  dat <- NULL
  dat <- read.csv(yyg_filepath)
  dat <- subset(dat, country == func_country)
  
  if (nrow(dat) == 0){
    return (NULL)
  }
  dat$date <- as.Date(dat$date)
  dat$location <- NA
  dat$location <- abbr
  dat$country <- NULL
  
  ## Process predictions
  ## ---------------------------------------------

  dat_pred <- subset(dat, date > forecast_date)
  
  # Process DEATH predictions
  # ---------------------------------------------

  # process mean data
  daily_dat_mean <- reshape(dat_pred, direction = "long", 
                            varying = list(c("predicted_deaths_mean", 
                                             "predicted_total_deaths_mean")),
                            times = c("day ahead inc death", 
                                      "day ahead cum death"))
  
  daily_dat_mean$quantile <- NA
  daily_dat_mean$type <- "point"
  colnames(daily_dat_mean)[colnames(daily_dat_mean) == 
                             "predicted_deaths_mean"] <- "value"
  daily_dat_mean$predicted_deaths_lower <- NULL
  daily_dat_mean$predicted_deaths_upper <- NULL
  daily_dat_mean$predicted_total_deaths_lower <- NULL
  daily_dat_mean$predicted_total_deaths_upper <- NULL
  daily_dat_mean$actual_deaths <- NULL
  daily_dat_mean$total_deaths <- NULL
  
  # process lower quantile
  daily_dat_lower <- reshape(dat_pred, direction = "long", 
                            varying = list(c("predicted_deaths_lower",
                                             "predicted_total_deaths_lower")),
                            times = c("day ahead inc death",
                                      "day ahead cum death"))
  
  daily_dat_lower$quantile <- 0.025
  daily_dat_lower$type <- "quantile"
  colnames(daily_dat_lower)[colnames(daily_dat_lower) == 
                             "predicted_deaths_lower"] <- "value"
  daily_dat_lower$predicted_deaths_mean <- NULL
  daily_dat_lower$predicted_deaths_upper <- NULL
  daily_dat_lower$predicted_total_deaths_mean <- NULL
  daily_dat_lower$predicted_total_deaths_upper <- NULL
  daily_dat_lower$actual_deaths <- NULL
  daily_dat_lower$total_deaths <- NULL
  
  # process upper quantile
  daily_dat_upper <- reshape(dat_pred, direction = "long", 
                             varying = list(c("predicted_deaths_upper", 
                                              "predicted_total_deaths_upper")),
                             times = c("day ahead inc death", 
                                       "day ahead cum death"))
  daily_dat_upper$quantile <- 0.975
  daily_dat_upper$type <- "quantile"
  colnames(daily_dat_upper)[colnames(daily_dat_upper) == 
                              "predicted_deaths_upper"] <- "value"
  daily_dat_upper$predicted_deaths_mean <- NULL
  daily_dat_upper$predicted_deaths_lower <- NULL
  daily_dat_upper$predicted_total_deaths_mean <- NULL
  daily_dat_upper$predicted_total_deaths_lower <- NULL
  daily_dat_upper$actual_deaths <- NULL
  daily_dat_upper$total_deaths <- NULL
  
  
  # Process ground truth data
  # -------------------------
  
  dat_past <- subset(dat, date <= forecast_date)
  
  dat_past <- reshape(dat_past, direction = "long", 
                      varying = list(c("actual_deaths", "total_deaths")),
                      times = c("day ahead inc death", "day ahead cum death"))
  
  dat_past$quantile <- NA
  dat_past$type <- "observed"
  colnames(dat_past)[colnames(dat_past) == 
                       "actual_deaths"] <- "value"
  
  dat_past$predicted_deaths_lower <- NULL
  dat_past$predicted_deaths_mean <-  NULL
  dat_past$predicted_deaths_upper <- NULL
  dat_past$predicted_total_deaths_lower <- NULL
  dat_past$predicted_total_deaths_mean <- NULL
  dat_past$predicted_total_deaths_upper <- NULL
  
  daily_dat <- rbind(dat_past,daily_dat_mean, daily_dat_lower, daily_dat_upper)
  
  daily_dat$id <- NULL
  rownames(daily_dat) <- NULL
  
  # get forecast horizons:
  daily_dat$horizon <- as.numeric(daily_dat$date - forecast_date)
  daily_dat$target <- paste(daily_dat$horizon, daily_dat$time)
  
  # remove unneeded columns
  daily_dat$time <- daily_dat$horizon <- NULL
  
  # add required ones:
  daily_dat$forecast_date <- forecast_date
  daily_dat$location_name <- func_country
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
    ends_weekly_forecasts$target <- paste((-1):(nrow(ends_weekly_forecasts) -2), "wk ahead cum death")
    # restrict to respective cumulative forecasts:
    weekly_dat <- subset(daily_dat, target_end_date %in% ends_weekly_forecasts$end &
                           grepl("cum", daily_dat$target))
    weekly_dat$target <- NULL
    weekly_dat <- merge(weekly_dat, ends_weekly_forecasts, by.x = "target_end_date", by.y = "end")
    weekly_dat <- weekly_dat[, colnames(daily_dat)]
    
    daily_dat <- rbind(daily_dat, weekly_dat)
  }
  
  # final death forecast dataframe
  daily_dat <- subset(daily_dat, target %in% c(paste((-1):130, "day ahead cum death"),
                                               paste((-1):130, "day ahead inc death"),
                                               paste((-1):20, "wk ahead cum death")))


  ########################
  # NOT IN USE: case forecasts include estimates of unreported cases and don't comply with our standards!
  ########################

  # Process CASE predictions
  # ---------------------------------------------
  
  # inc and cum case predictions from 2020-04-23 on
  # inc case predictions from 2020-04-08 on
  daily_dat_cases <- NULL 

  # if (as.Date(forecast_date) >= as.Date("2020-04-23")){
  #   # process mean data
  #   daily_dat_mean_cases <- reshape(dat_pred, direction = "long", 
  #                             varying = list(c("predicted_new_infected_mean", 
  #                                             "predicted_total_infected_mean")),
  #                             times = c("day ahead inc case", 
  #                                       "day ahead cum case"))
    
  #   daily_dat_mean_cases$quantile <- NA
  #   daily_dat_mean_cases$type <- "point"
  #   colnames(daily_dat_mean_cases)[colnames(daily_dat_mean_cases) == 
  #                             "predicted_new_infected_mean"] <- "value"
  #   daily_dat_mean_cases$predicted_new_infected_lower <- NULL
  #   daily_dat_mean_cases$predicted_new_infected_upper <- NULL
  #   daily_dat_mean_cases$predicted_total_infected_lower <- NULL
  #   daily_dat_mean_cases$predicted_total_infected_upper <- NULL
    
  #   # process lower quantile
  #   daily_dat_lower_cases <- reshape(dat_pred, direction = "long", 
  #                             varying = list(c("predicted_new_infected_lower",
  #                                             "predicted_total_infected_lower")),
  #                             times = c("day ahead inc case",
  #                                       "day ahead cum case"))
    
  #   daily_dat_lower_cases$quantile <- 0.025
  #   daily_dat_lower_cases$type <- "quantile"
  #   colnames(daily_dat_lower_cases)[colnames(daily_dat_lower_cases) == 
  #                             "predicted_new_infected_lower"] <- "value"
  #   daily_dat_lower_cases$predicted_new_infected_mean <- NULL
  #   daily_dat_lower_cases$predicted_new_infected_upper <- NULL
  #   daily_dat_lower_cases$predicted_total_infected_mean <- NULL
  #   daily_dat_lower_cases$predicted_total_infected_upper <- NULL
    
  #   # process upper quantile
  #   daily_dat_upper_cases <- reshape(dat_pred, direction = "long", 
  #                             varying = list(c("predicted_new_infected_upper", 
  #                                               "predicted_total_infected_upper")),
  #                             times = c("day ahead inc case", 
  #                                       "day ahead cum case"))
  #   daily_dat_upper_cases$quantile <- 0.975
  #   daily_dat_upper_cases$type <- "quantile"
  #   colnames(daily_dat_upper_cases)[colnames(daily_dat_upper_cases) == 
  #                               "predicted_new_infected_upper"] <- "value"
  #   daily_dat_upper_cases$predicted_new_infected_mean <- NULL
  #   daily_dat_upper_cases$predicted_new_infected_lower <- NULL
  #   daily_dat_upper_cases$predicted_total_infected_mean <- NULL
  #   daily_dat_upper_cases$predicted_total_infected_lower <- NULL
    
    
  #   # Process ground truth data
  #   # -------------------------

  #   daily_dat_cases <- rbind(daily_dat_mean_cases, daily_dat_lower_cases, daily_dat_upper_cases)
    
  #   daily_dat_cases$id <- NULL
  #   rownames(daily_dat_cases) <- NULL
    
  #   # get forecast horizons:
  #   daily_dat_cases$horizon <- as.numeric(daily_dat_cases$date - forecast_date)
  #   daily_dat_cases$target <- paste(daily_dat_cases$horizon, daily_dat_cases$time)
    
  #   # remove unneeded columns
  #   daily_dat_cases$time <- daily_dat_cases$horizon <- NULL
    
  #   # add required ones:
  #   daily_dat_cases$forecast_date <- forecast_date
  #   daily_dat_cases$location_name <- func_country
  #   colnames(daily_dat_cases)[colnames(daily_dat_cases) == "date"] <- "target_end_date"
    
  #   daily_dat_cases <- daily_dat_cases[, c("forecast_date", "target", "target_end_date", "location",
  #                             "location_name", "type", "quantile", "value")]
    
  #   # add one-week-ahead cumulative forecast if possible as well as 0 and -1-week ahead forecasts:
  #   # get day of the week of forecast_date:
  #   day <- weekdays(forecast_date, abbreviate = TRUE)
    
  #   # When do the one-week-ahead forecast end?
  #   next_dates <- seq(from = forecast_date, length.out = 14, by = 1)
  #   next_days <- weekdays(next_dates, abbreviate = TRUE)
  #   if(day %in% c("Sun", "Mon")){
  #     forecast_1_wk_ahead_end <- next_dates[next_days == "Sat"][1]
  #   }else{
  #     forecast_1_wk_ahead_end <- next_dates[next_days == "Sat"][2]
  #   }
  #   # Whether the one-week-ahead forecast can be computed depends on the day
  #   # the forecasts were issued:
  #   if(max(daily_dat_cases$target_end_date) > forecast_1_wk_ahead_end - 14){
  #     ends_weekly_forecasts <- data.frame(end = seq(from = forecast_1_wk_ahead_end - 14,
  #                                                   by = 7, to = max(daily_dat_cases$target_end_date)))
  #     ends_weekly_forecasts$target <- paste((-1):(nrow(ends_weekly_forecasts) -2), "wk ahead cum case")
  #     # restrict to respective cumulative forecasts:
  #     weekly_dat <- subset(daily_dat_cases, target_end_date %in% ends_weekly_forecasts$end &
  #                           grepl("cum", daily_dat_cases$target))
  #     weekly_dat$target <- NULL
  #     weekly_dat <- merge(weekly_dat, ends_weekly_forecasts, by.x = "target_end_date", by.y = "end")
  #     weekly_dat <- weekly_dat[, colnames(daily_dat_cases)]
      
  #     daily_dat_cases <- rbind(daily_dat_cases, weekly_dat)
  #   }
    
  #   daily_dat_cases <- subset(daily_dat_cases, target %in% c(paste((-1):130, "day ahead cum case"),
  #                                               paste((-1):130, "day ahead inc case"),
  #                                               paste((-1):20, "wk ahead cum case")))
  # }
  
  return(list("deaths" = daily_dat, "cases" = daily_dat_cases)) 
}


