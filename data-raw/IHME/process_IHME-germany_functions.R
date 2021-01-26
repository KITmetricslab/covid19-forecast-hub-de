# Author: Konstantin G?rgen
# Date: Fri May 08 14:51:21 2020
# --------------
#################################################################################
###### This file has been adapted from code provided in the US COVID19 forecast hub:
###### https://github.com/reichlab/covid19-forecast-hub/tree/master/data-raw/IHME/IHME-processing.R
###### The original file has been provided under the MIT license, and so is this adapted version.
#################################################################################

# fixed issues with change of year
# January 2021
# Jakob Ketterer


#Function to get real and reported forecast date

#' Check when the last non-zero forecast is equal in mean, upper and lower quantil
#'
#' @param path the forecast file path
#' @param country country you want to check the forecast date for
#' @return vector with reported forecast date and observed forecast date, i.e. last observed value
#'

get_forecast_date<-function(path,country="Germany") {
  
  data <- data.table::fread(path, stringsAsFactors = FALSE,data.table=FALSE) %>% filter(location_name==country) %>%
    mutate(date=as.Date(date))
  given_forecast_date <- get_date(path)
  is_equal_lmu<-data$deaths_mean==data$deaths_upper & data$deaths_lower==data$deaths_mean
  is_not_zero<-data$deaths_mean!=0
  real_date<-max(data$date[is_equal_lmu & is_not_zero],na.rm = TRUE)
  
  return(c(report_date=given_forecast_date,Real_forecast_date=real_date))
}

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
#' @param forecast_date the real forecast date as extracted from file, i.e. last date where observations, not projections are available
#' @param submission_date the date that is indicated on the file, i.e. when the forecasts where submitted, important for target in week ahead forecasts
#' @param country the country you want the forecast for, currently supported: Germany and Poland
#' @return long-format data_frame with quantiles
#'



make_qntl_dat <- function(path,forecast_date,submission_date, country="Germany",cases=FALSE) {
  require(tidyverse)
  require(MMWRweek)
  require(lubridate)
  require(data.table)
  
  forecast_date<-as.Date(forecast_date)
  submission_date<-as.Date(submission_date)
  #use data.table package, faster to read in
  #leave data type as data.frame for compatibility with tidyverse
  #use utf-8 to keep Umlaut-characters
  data <-fread(path, stringsAsFactors = FALSE,data.table=FALSE,encoding="UTF-8")
 
  #Get Baden-Wurttemberg (with umlaut u) and replace with u
  data$location_name[grep("Baden-W",data$location_name)]<-"Baden-Wurttemberg"
  
  #change ? to u
  #data$location_name<-gsub("?","u",data$location_name)
  
  #New Change in IHME location names, u is now Ã¼
  #data$location_name<-gsub("ü","u",data$location_name)

  #forecast date is given from function now
  #forecast_date <- get_date(path)
  
  # make sure that all names are the same over different data sets
  
  # date should always be named date
  if (names(data)[grep("date", names(data))] != "date") {
    data <- data %>%
      dplyr::rename(date = names(data)[grep("date", names(data))])
  }
  # remove death or case smoothed column, not regarded (yet)
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
  state_name<-ifelse(country=="Germany","germany","poland")
  code_fips<-paste0("../../template/state_codes_",state_name,".csv")
  state_fips_codes <-
    fread(code_fips,data.table = FALSE,encoding = "UTF-8",
             stringsAsFactors = FALSE)
  
  #first filter data so only your desired countries/regions are manipulated (speeds up procedure)
  
  data<-data %>% left_join(state_fips_codes, by = c("location_name" = "state_name")) %>% 
    dplyr::filter(!is.na(state_code))
  
  #if there are NA-values for cum-deaths, replace them with value from last day
  
  count<-0
  if(1%in%which(is.na(data$totdea_mean))) #check if first entry is NA, omit that one
  {
    data<-data[-1,]
  }
    
  while(sum(is.na(data$totdea_mean))>0 ) #stop if there is no NA left
  {
    count<-count+1
    data$totdea_mean[is.na(data$totdea_mean)]<-data$totdea_mean[which(is.na(data$totdea_mean))-1]
    data$totdea_lower[is.na(data$totdea_lower)]<-data$totdea_lower[which(is.na(data$totdea_lower))-1]
    data$totdea_upper[is.na(data$totdea_upper)]<-data$totdea_upper[which(is.na(data$totdea_upper))-1]
    
  }
    
  ## code for incident deaths or cases (var names might be confusing since they
  #seem only to cover cases, but are general)
  
  col_list1 <-
    c(
      setdiff(
        c(
          grep("location_name", colnames(data)),
          grep("date", colnames(data)),
          grep("death", colnames(data)) ),
        c(
          grep("rate",colnames(data)),grep("data",colnames(data))
        )
      )
    )
  death_qntl1 <- data[, col_list1] %>% # only take important rows
    dplyr::rename(date_v = date) %>%
    # uncomment if you only want one week ahead forecasts
    # dplyr::filter(as.Date(as.character(date_v)) %in% c(forecast_date+1:7)) %>%
    # delete non-forecasts expect for 0 day and -1 day ahead that are kept
    # and only forecast up to 130 days into the future
    dplyr::filter((as.Date(as.character(date_v)) > forecast_date-2) &
                    (as.Date(as.character(date_v))-forecast_date<=130)) %>%
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
    # add type column, specifying point or quantile calculation and whether or
    # not we are at observed value or forecast
    dplyr::mutate(type = ifelse(quantile == "NA",
                                ifelse(date_v>forecast_date,"point","observed"),
                                "quantile")) %>%
    #add forecast_date column
    #dplyr::mutate(forecast_date = forecast_date) %>%
    #remove quantiles for observed values, since they are equal to point
    dplyr::filter(date_v>forecast_date | type!="quantile") %>%
    # add in the state fips codes
    dplyr::left_join(state_fips_codes, by = c("location_name" = "state_name")) %>%
    # rename columns to match output standard
    dplyr::rename(location = state_code) %>%
    dplyr::rename(target_end_date = date_v)

  ## code for cumulative deaths
  col_list2 <-
    c(
      setdiff(
        c(
          grep("location_name", colnames(data)),
          grep("date", colnames(data)),
          grep("totdea", colnames(data)) ),
        c(
          grep("rate",colnames(data))
        )
      )
    )
  death_qntl2 <- data[, col_list2] %>% # only take important rows
    dplyr::rename(date_v = date) %>%
    # uncomment if you only want one week ahead forecasts
    # dplyr::filter(as.Date(as.character(date_v)) %in% c(forecast_date+1:7)) %>%
    # delete non-forecasts and only forecast up to 130 days in the future
    dplyr::filter(as.Date(as.character(date_v)) > forecast_date-2 &
                    (as.Date(as.character(date_v))-forecast_date<=130)) %>%
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
    dplyr::mutate(type = ifelse(quantile == "NA",
                                ifelse(date_v>forecast_date,"point","observed"),
                                "quantile")) %>%
    #remove quantiles for observed values, since they are equal to point
    dplyr::filter(date_v>forecast_date | type!="quantile") %>%
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
  
  ## weekly forecasts
  
  # add if for forecast date weekly
  
  #see if you're on Windows or other OS
  if(Sys.info()[1]=="Windows") {
    Sys.setlocale("LC_TIME", "English")
  } else {
    Sys.setlocale(category = "LC_TIME", locale = "en_US.UTF8")
  }

  if (lubridate::wday(submission_date, label = TRUE, abbr = FALSE) == "Sunday" |
      lubridate::wday(submission_date, label = TRUE, abbr = FALSE) == "Monday") {
    death_qntl2_1 <- data[, c(col_list2)] %>%
      dplyr::rename(date_v = date) %>%
      dplyr::filter(date_v >= submission_date) %>%  # avoids ew difference issues with change of year
      dplyr::mutate(
        day_v = lubridate::wday(date_v, label = TRUE, abbr = FALSE),
        ew = unname(MMWRweek(date_v)[[2]])
      ) %>%
      # dplyr::filter(day_v =="Saturday" &
      #                 ew<unname(MMWRweek(forecast_date)[[2]])+6 &
      #                 ew>unname(MMWRweek(forecast_date)[[2]])-1) %>%
      
      #add -1, 0 week ahead (-3 in formula) and only forecast 20 weeks ahead
      #since 1 week ahead means difference of zero, take <20
      dplyr::filter(day_v == "Saturday" &
                      ew > unname(MMWRweek(submission_date)[[2]]) - 3 &
                      ew-unname(MMWRweek(submission_date)[[2]]) <20) %>%
      dplyr::mutate(target_id = paste((ew - (
        unname(MMWRweek(submission_date)[[2]])
      ) + 1), "wk ahead cum death"))
  } else {
    death_qntl2_1 <- data[, c(col_list2)] %>%
      dplyr::rename(date_v = date) %>%
      dplyr::filter(date_v >= submission_date) %>% # avoids ew difference issues with change of year
      dplyr::mutate(
        day_v = lubridate::wday(date_v, label = TRUE, abbr = FALSE),
        ew = unname(MMWRweek(date_v)[[2]])
      ) %>%
      # dplyr::filter(day_v =="Saturday" &
      #                 ew<(unname(MMWRweek(forecast_date)[[2]])+1)+6 &
      #                 ew>unname(MMWRweek(forecast_date)[[2]])) %>%
      dplyr::filter(day_v == "Saturday" &
                      ew > unname(MMWRweek(submission_date)[[2]])-2) %>%
      dplyr::mutate(target_id = paste((ew - (
        unname(MMWRweek(submission_date)[[2]]) + 1
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
    # add type column, specifying point or quantile calculation
    dplyr::mutate(type = ifelse(quantile == "NA",
                                ifelse(date_v>forecast_date,"point","observed"),
                                "quantile")) %>%
    #remove quantiles for observed values, since they are equal to point
    dplyr::filter(date_v>forecast_date | type!="quantile") %>%
    # gather(quantile, value, -c(location_name, date_v, day_v, ew, target_id)) %>%
    dplyr::left_join(state_fips_codes, by = c("location_name" = "state_name")) %>%
    dplyr::rename(location = state_code, target_end_date = date_v) %>%
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
      value = as.numeric(value),
      forecast_date=forecast_date
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

