process_ucla_file <- function(ucla_filepath, truth_jhu_cum, forecast_date, country = "Germany", location = "GM", type = "death"){

  # check forecast date
  if(!(weekdays(forecast_date) %in% c("Saturday", "Sunday", "Monday"))) stop("Extraction function requires forecast day to be a Sat, Sun or Mon.")
  
  # read in data:
  dat_orig <- read.csv(ucla_filepath, colClasses = list(Date = "Date"))
  # restrict to country:
  dat_country <- subset(dat_orig, Region == country)


  # add epi week:
  # dat_country_long$epi_week <- MMWRweek::MMWRweek(dat_country_long$target_end_date)$MMWRweek

  ### cumulative targets, daily:
  if(type == "death"){
    values_cum <- c(dat_country$pre_fata, dat_country$lower_pre_fata, dat_country$upper_pre_fata)
  }
  if(type == "case"){
    values_cum <- c(dat_country$pre_confirm, dat_country$lower_pre_confirm, dat_country$upper_pre_confirm)
  }

  daily_cum <- data.frame(forecast_date = forecast_date,
                        target_end_date = dat_country$Date,
                        location = location,
                        location_name = country,
                        value = values_cum,
                        type = rep(c("point", "quantile", "quantile"), each = nrow(dat_country)),
                        quantile = rep(c(NA, 0.025, 0.975), each = nrow(dat_country))
  )
  daily_cum$target <- paste(as.numeric(daily_cum$target_end_date - daily_cum$forecast_date), "day ahead cum", type)

  # cumulative targets, weekly:
  weekly_cum <- subset(daily_cum, weekdays(target_end_date) == "Saturday")
  weekly_cum$target <- paste(ceiling((weekly_cum$target_end_date - forecast_date)/7 -
                                 (weekdays(forecast_date) %in% c("Tuesday", "Wednesday", "Thursday", "Friday"))),
                             "wk ahead cum", type)

  ### incident targets, daily:
  if(type == "death"){
    values_inc <- c(dat_country$pre_fata_daily, dat_country$lower_pre_fata_daily, dat_country$upper_pre_fata_daily)
  }
  if(type == "case"){
    values_inc <- c(dat_country$pre_confirm_daily, dat_country$lower_pre_confirm_daily, dat_country$upper_pre_confirm_daily)
  }

  daily_inc <- data.frame(forecast_date = forecast_date,
                          target_end_date = dat_country$Date,
                          location = location,
                          location_name = country,
                          value = values_inc,
                          type = rep(c("point", "quantile", "quantile"), each = nrow(dat_country)),
                          quantile = rep(c(NA, 0.025, 0.975), each = nrow(dat_country))
  )
  daily_inc$target <- paste(as.numeric(daily_inc$target_end_date - daily_inc$forecast_date), "day ahead inc", type)
  
  ### incident targets weekly
  last_jhu_cum <- subset(truth_jhu_cum, weekdays(date) == "Saturday" &
                        date <= forecast_date & date >= forecast_date - 7) # [2,]
  if(nrow(last_jhu_cum) != 1) stop("Please update JHU truth data.")

  weekly_inc <- subset(weekly_cum, type == "point")
  weekly_inc <- weekly_inc[order(weekly_inc$target_end_date), ] # be sure that sorted
  weekly_inc$target <- gsub("cum", "inc", weekly_inc$target)
  weekly_inc$value[-1] <- diff(weekly_inc$value)
  weekly_inc$value[1] <- weekly_inc$value[1] - last_jhu_cum$value

  result <- rbind(weekly_cum, weekly_inc, daily_cum, daily_inc)

  return(result)
}
