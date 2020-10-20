#################################################################################
###### This file has been adapted from code provided in the US COVID19 forecast hub:
###### https://github.com/reichlab/covid19-forecast-hub/blob/master/data-raw/Geneva/process_geneva_file.R
###### Author of original code: Johannes Bracher
###### The original file has been provided under the MIT license, and so is this adapted version.
#################################################################################

## USC death data functions
## Jakob Ketterer
## July 2020

# convert colnames to forecast dates
col_to_date <- function(col) {
  return(as.Date(gsub("X", "", col), format="%Y.%m.%d"))
}

#' turn USC forecast file into quantile-based format
#'
#' @param usc_filepath path to a USC submission file
#' @param forecast_date the time at which the forecast was issued
#' @param country the country in human-radable format. Used for subsetting of USC data and location_name in result
#' @param location the FIPS code of the country
#' @param type is a "death" or a "case" forecast file to be processed?
#'
#' @details typically forecast_date will be a Monday and the 1-week ahead
#' forecast will be for the EW of the Monday. 1-day-ahead would be Tuesday.
#'
#' @return a data.frame in quantile format

process_usc_file <- function(usc_filepath, forecast_date, truth, country = "Germany", location = "GM", type = "death"){
  if(length(country) != length(location)) stop("country and location need to have the same length.")
  for(i in 1:length(country)){
    to_add <- process_usc_file0(usc_filepath = usc_filepath,
                                forecast_date = forecast_date,
                                truth = truth,
                                country = country[i],
                                location = location[i],
                                type = type)
    if(i == 1){
      ret <- to_add
    }else{
      ret <- rbind(ret, to_add)
    }
  }
  return(ret)
}

process_usc_file0 <- function(usc_filepath, forecast_date, truth, country = "Germany", location = "GM", type = "death"){

  # read in data:
  dat_orig <- read.csv(usc_filepath)
  # restrict to country:
  dat_country <- subset(dat_orig, Country == country)

  # restrict truth to country
  truth <- truth[truth$location == location, ]

  # bring to long format, extract necessary values from old data frame
  dat_country_long <- data.frame(
    target_end_date = col_to_date(colnames(dat_country)[-1:-2]),
    cum_value = as.numeric(dat_country[1, -1:-2])# cum deaths
  )

  # check that truth data agrees with first entries of USC files:
  truth_to_check <- truth[truth$date == min(dat_country_long$target_end_date), "value"]
  if(dat_country_long$cum_value[which.min(dat_country_long$target_end_date)] != truth_to_check){
    warning("Mismatch with truth data in", location, " - forecast_date:", forecast_date)
  }

  # add last 14 truth values:
  truth_to_add <- truth[truth$date %in% (min(dat_country_long$target_end_date) - (1:14)),
                        c("date", "value")]
  colnames(truth_to_add) <- c("target_end_date", "cum_value")
  dat_country_long <- rbind(truth_to_add, dat_country_long)

  dat_country_long$weekday <- weekdays(dat_country_long$target_end_date)
  dat_country_long$inc_value = c(NA, diff(dat_country_long$cum_value, lag = 1))# inc deaths

  # add epi week:
  dat_country_long$epi_week <- MMWRweek::MMWRweek(dat_country_long$target_end_date)$MMWRweek

  ### incident targets:

  # daily:
  daily_inc <- data.frame(forecast_date = forecast_date,
                          target = paste(dat_country_long$target_end_date - forecast_date,
                                         "day ahead inc", type),
                          target_end_date = dat_country_long$target_end_date,
                          location = location,
                          location_name = country,
                          type = ifelse(dat_country_long$target_end_date > forecast_date, "point", "observed"),
                          quantile = NA,
                          value = dat_country_long$inc_value)
  daily_inc <- daily_inc[order(daily_inc$target_end_date), ]

  # weekly:
  weekly_inc0 <- aggregate(dat_country_long$inc_value, by = list(epi_week = dat_country_long$epi_week),
                           FUN = sum)
  colnames(weekly_inc0)[2] <- "weekly_inc_value"
  dat_country_long <- merge(dat_country_long, weekly_inc0, by = "epi_week", all.x = TRUE)
  dat_country_long_sat <- subset(dat_country_long, weekday == "Saturday")
  current_epi_week <- MMWRweek::MMWRweek(forecast_date)$MMWRweek - ifelse(weekdays(forecast_date) %in% c("Sunday", "Monday"), 1, 0)
  weekly_inc <- data.frame(forecast_date = forecast_date,
                           target = paste(ceiling(as.numeric(dat_country_long_sat$target_end_date - forecast_date)/7) -
                                            (weekdays(forecast_date) %in% c("Tuesday", "Wednesday", "Thursday", "Friday")),
                                          "wk ahead inc", type),
                           target_end_date = dat_country_long_sat$target_end_date,
                           location = location,
                           location_name = country,
                           type = ifelse(dat_country_long_sat$target_end_date > forecast_date, "point", "observed"),
                           quantile = NA,
                           value = dat_country_long_sat$weekly_inc_value)
  weekly_inc <- weekly_inc[order(weekly_inc$target_end_date), ]

  ### cumulative targets:
  # daily:
  daily_cum <- data.frame(forecast_date = forecast_date,
                          target = paste(dat_country_long$target_end_date - forecast_date,
                                         "day ahead cum", type),
                          target_end_date = dat_country_long$target_end_date,
                          location = location,
                          location_name = country,
                          type = ifelse(dat_country_long$target_end_date > forecast_date, "point", "observed"),
                          quantile = NA,
                          value = dat_country_long$cum_value)
  daily_cum <- daily_cum[order(daily_cum$target_end_date), ]

  # weekly:
  weekly_cum <- data.frame(forecast_date = forecast_date,
                           target = paste(ceiling(as.numeric(dat_country_long_sat$target_end_date - forecast_date)/7 -
                                                    (weekdays(forecast_date) %in% c("Tuesday", "Wednesday", "Thursday", "Friday"))),
                                          "wk ahead cum", type),
                           target_end_date = dat_country_long_sat$target_end_date,
                           location = location,
                           location_name = country,
                           type = ifelse(dat_country_long_sat$target_end_date > forecast_date, "point", "observed"),
                           quantile = NA,
                           value = dat_country_long_sat$cum_value)
  weekly_cum <- weekly_cum[order(weekly_cum$target_end_date), ]

  # pool:
  result <- rbind(weekly_inc, weekly_cum, daily_inc, daily_cum)

  # remove superfluous observed values and NAs:
  allowed_targets <- c(paste(-1:100, "day ahead inc", type),
                       paste(-1:100, "day ahead cum", type),
                       paste(-1:30, "wk ahead inc", type),
                       paste(-1:30, "wk ahead cum", type))

  result <- subset(result, target %in% allowed_targets &
                     !is.na(value))

  return(result)
}
