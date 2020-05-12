# Author: Konstantin Görgen
# Date: Fri May 08 14:51:21 2020
# --------------
#################################################################################
###### This file has been adapted from code provided in the US COVID19 forecast hub:
###### https://github.com/reichlab/covid19-forecast-hub/tree/master/data-raw/IHME/IHME-processing.R
###### The original file has been provided under the MIT license, and so is this adapted version.
#################################################################################

## Functions to process IHME files

get_date <- function(path) {
  temp_path <- dirname(path)
  slashes <- unlist(gregexpr("/", temp_path))
  last_slash <- slashes[length(slashes)]
  date.1 <-
    gsub("_", "-", substring(dirname(path), first = last_slash + 1))
  if (coerceable_to_date(date.1)) {
    return(as.Date(date.1))
  } else {
    date.2 <- substr(date.1, start = 1, end = 10)
    if (coerceable_to_date(date.2)) {
      return(as.Date(date.2))
    } else {
      stop("Path cannot be coerced to date. Please rename folders")
    }
  }
}

coerceable_to_date <- function(x) {
  !is.na(as.Date(as.character(x), tz = "UTC", format = "%Y-%m-%d"))
}

# Main Function to process IHME data

#' Transform matrix of samples for one location into a quantile-format data_frame
#'
#' @param path the forecast file path
#' @param all_states Should all states be forecasted or just on Federal Level, default=FALSE, not implemented yet
#' @return long-format data_frame with quantiles
#'
make_qntl_dat <- function(path, all_states = FALSE) {
  require(tidyverse)
  require(MMWRweek)
  require(lubridate)
  
  
  data <- read.csv(path, stringsAsFactors = FALSE)
  forecast_date <- get_date(path)
  
  # make sure that all names are the same over different data sets
  
  # date should always be named date
  if (names(data)[grep("date", names(data))] != "date") {
    data <- data %>%
      dplyr::rename(date = names(data)[grep("date", names(data))])
  }
  # remove death smoothed column, only NA for Germany
  if (length(grep("smoothed", names(data))) > 0) {
    data <- data %>%
      dplyr::select(-grep("smoothed", names(data)))
  }
  # if (sum(grepl("location_name",names(data)))>0 & !("location" %in% names(data))){
  #   data<-data %>%
  #     dplyr::rename(location=location_name)
  # }
  # delete column V1 if possible
  if (sum(grepl("V1", names(data))) > 0) {
    data <- data %>%
      dplyr::select(-"V1")
  }
  # data <- data %>%
  #  dplyr::select(-names(data)[which(grepl("location",names(data)))])#[-which(names(data)[which(grepl("location",names(data))==TRUE)]=="location")])
  
  ## read state code
  state_fips_codes <-
    read.csv("../../template/state_codes_germany.csv",
             stringsAsFactors = FALSE)[,-1]
  
  ## code for incident deaths
  
  col_list1 <-
    c(
      grep("location_name", colnames(data)),
      grep("date", colnames(data)),
      grep("death", colnames(data))
    )
  death_qntl1 <- data[, col_list1] %>% # only take important rows
    dplyr::rename(date_v = date) %>%
    # uncomment if you only want one week ahead forecasts
    # dplyr::filter(as.Date(as.character(date_v)) %in% c(forecast_date+1:7)) %>%
    # delete non-forecasts
    dplyr::filter(as.Date(as.character(date_v)) > forecast_date) %>%
    # add column with target_id
    dplyr::mutate(target_id = paste(
      difftime(as.Date(as.character(date_v)), forecast_date, units = "days"),
      "day ahead inc death"
    )) %>%
    # get quantiles in right format
    dplyr::rename("0.025" = deaths_lower,
                  "0.975" = deaths_upper,
                  "NA" = deaths_mean) %>%
    # change data from wide to long,i.e. change everything but name, date and target
    # creates two columns, one "value" with value contained in either NA,0.025,0.975
    # and one "quantile" with either "NA", "0.025" or "0.975"
    tidyr::pivot_longer(-c(location_name, date_v, target_id),
                        names_to = "quantile",
                        values_to = "value") %>%
    # add type column, specifying point or quantile calculation
    dplyr::mutate(type = ifelse(quantile == "NA", "point", "quantile"),
                  forecast_date = forecast_date) %>%
    # add in the state fips codes
    dplyr::left_join(state_fips_codes, by = c("location_name" = "state_name")) %>%
    # rename columns to match output standard
    dplyr::rename(location = state_code) %>%
    dplyr::rename(target_end_date = date_v)
  
  ## code for cumulative deaths
  
  col_list2 <-
    c(
      grep("location_name", colnames(data)),
      grep("date", colnames(data)),
      grep("totdea", colnames(data))
    )
  death_qntl2 <- data[, col_list2] %>% # only take important rows
    dplyr::rename(date_v = date) %>%
    # uncomment if you only want one week ahead forecasts
    # dplyr::filter(as.Date(as.character(date_v)) %in% c(forecast_date+1:7)) %>%
    # delete non-forecasts
    dplyr::filter(as.Date(as.character(date_v)) > forecast_date) %>%
    # add column with target_id
    dplyr::mutate(target_id = paste(
      difftime(as.Date(as.character(date_v)), forecast_date, units = "days"),
      "day ahead cum death"
    )) %>%
    # get quantiles in right format
    dplyr::rename("0.025" = totdea_lower,
                  "0.975" = totdea_upper,
                  "NA" = totdea_mean) %>%
    # change data from wide to long,i.e. change everything but name, date and target
    # creates two columns, one "value" with value contained in either NA,0.025,0.975
    # and one "quantile" with either "NA", "0.025" or "0.975"
    tidyr::pivot_longer(-c(location_name, date_v, target_id),
                        names_to = "quantile",
                        values_to = "value") %>%
    # add type column, specifying point or quantile calculation
    dplyr::mutate(type = ifelse(quantile == "NA", "point", "quantile"),
                  forecast_date = forecast_date) %>%
    # add in the state fips codes
    dplyr::left_join(state_fips_codes, by = c("location_name" = "state_name")) %>%
    # rename columns to match output standard
    dplyr::rename(location = state_code) %>%
    dplyr::rename(target_end_date = date_v)
  
  ### hospitalizations, leave out for the moment
  # add hospitalization daily incident (admis)
  
  
  # col_list3 <- c(grep("location", colnames(data)),grep("date", colnames(data)),grep("admis",colnames(data)))
  # death_qntl3 <- data[,c(col_list3)] %>%
  #   dplyr::rename(date_v=date) %>%
  #   # dplyr::filter(as.Date(as.character(date_v)) %in% c(forecast_date+1:7)) %>%
  #   dplyr::filter(as.Date(as.character(date_v)) > forecast_date) %>%
  #   dplyr::mutate(target_id=paste(difftime(as.Date(as.character(date_v)),forecast_date,units="days"),"day ahead inc hosp")) %>%
  #   dplyr::rename("0.025"=admis_lower,"0.975"=admis_upper,"NA"=admis_mean) %>%
  #   gather(quantile, value, -c(location, date_v, target_id)) %>%
  #   dplyr::left_join(state_fips_codes, by=c("location"="state_name")) %>%
  #   dplyr::rename(location_id=state_code) %>%
  #   dplyr::mutate(type=ifelse(quantile=="NA","point","quantile"),forecast_date=forecast_date) %>%
  #   dplyr::rename(target_end_date=date_v)
  
  
  # weekly forecasts
  
  # add if for forecast date weekly
  Sys.setlocale("LC_TIME", "C")
  if (lubridate::wday(forecast_date, label = TRUE, abbr = FALSE) == "Sunday" |
      lubridate::wday(forecast_date, label = TRUE, abbr = FALSE) == "Monday") {
    death_qntl2_1 <- data[, c(col_list2)] %>%
      dplyr::rename(date_v = date) %>%
      dplyr::mutate(
        day_v = lubridate::wday(date_v, label = TRUE, abbr = FALSE),
        ew = unname(MMWRweek(date_v)[[2]])
      ) %>%
      # dplyr::filter(day_v =="Saturday" &
      #                 ew<unname(MMWRweek(forecast_date)[[2]])+6 &
      #                 ew>unname(MMWRweek(forecast_date)[[2]])-1) %>%
      dplyr::filter(day_v == "Saturday" &
                      ew > unname(MMWRweek(forecast_date)[[2]]) - 1) %>%
      dplyr::mutate(target_id = paste((ew - (
        unname(MMWRweek(forecast_date)[[2]])
      ) + 1), "wk ahead cum death"))
  } else {
    death_qntl2_1 <- data[, c(col_list2)] %>%
      dplyr::rename(date_v = date) %>%
      dplyr::mutate(
        day_v = lubridate::wday(date_v, label = TRUE, abbr = FALSE),
        ew = unname(MMWRweek(date_v)[[2]])
      ) %>%
      # dplyr::filter(day_v =="Saturday" &
      #                 ew<(unname(MMWRweek(forecast_date)[[2]])+1)+6 &
      #                 ew>unname(MMWRweek(forecast_date)[[2]])) %>%
      dplyr::filter(day_v == "Saturday" &
                      ew > unname(MMWRweek(forecast_date)[[2]])) %>%
      dplyr::mutate(target_id = paste((ew - (
        unname(MMWRweek(forecast_date)[[2]]) + 1
      )) + 1, "wk ahead cum death"))
  }
  death_qntl2_2 <- death_qntl2_1 %>%
    dplyr::rename("0.025" = totdea_lower,
                  "0.975" = totdea_upper,
                  "NA" = totdea_mean) %>%
    tidyr::pivot_longer(
      -c(location_name, date_v, day_v, ew, target_id),
      names_to = "quantile",
      values_to = "value"
    ) %>%
    # gather(quantile, value, -c(location_name, date_v, day_v, ew, target_id)) %>%
    dplyr::left_join(state_fips_codes, by = c("location_name" = "state_name")) %>%
    dplyr::rename(location = state_code, target_end_date = date_v) %>%
    dplyr::mutate(type = ifelse(quantile == "NA", "point", "quantile"),
                  forecast_date = forecast_date) %>%
    dplyr::select(-"day_v",-"ew")
  
  
  ### combining data
  
  # deleted death_qntl3, only adds hospitalizations
  comb <-
    rbind(death_qntl1, death_qntl2, death_qntl2_2) # deleted death_qntl2_2, needs to be added later
  
  # only take german data (i.e. the ones recognized in state_codes.csv)
  comb <- comb %>%
    dplyr::filter(!is.na(location)) %>%
    # parse to make sure format is right
    dplyr::mutate(
      target_end_date = as.Date(target_end_date),
      quantile = as.numeric(quantile),
      value = as.numeric(value)
    )
  # get final data frame, i.e. order
  final <- comb %>%
    # make sure to not select any extra columns
    dplyr::select(
      forecast_date,
      target_id,
      target_end_date,
      location,
      location_name,
      type,
      quantile,
      value
    ) %>%
    # rename last columns
    dplyr::rename(target = target_id) %>%
    # order them in rows
    arrange(location, type, quantile, target)
  
  return(final)
}
