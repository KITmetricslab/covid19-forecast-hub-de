# Author: Konstantin Görgen
# Date: Sat May 09 12:16:26 2020
# --------------
# Modification: Changed variables in final matrix in function format_imperial
# Author: Konstantin Görgen
# Date: 2020-05-10
# --------------
#################################################################################
###### This file has been adapted from code provided in the US COVID19 forecast hub:
###### https://github.com/reichlab/covid19-forecast-hub/tree/master/data-raw/Imperial/Imperial-processing.R
###### Author of original code: Jarad Niemi
###### The original file has been provided under the MIT license, and so is this adapted version.
#################################################################################

##Helper Functions for Imperial Script

# Function from Reichlab repo

#' Calculate the date of the next Saturday
#'
#' @param date date for calculation
#'
#' @return a date of the subsequent Saturday. if date is a Saturday, it will return this day itself.
get_next_saturday <- function(date) {
  require(lubridate)
  date <- as.Date(date)
  ## calculate days until saturday (day 7)
  diff <- 7 - wday(date)
  ## add to given date
  new_date <- diff + date
  return(new_date)
}

#Function to extract date from Imperial Path
#' Calculate the date of the computation from file path
#'
#' @param path file path of .rds file
#'
#' @return the date of publication as in the file name as a date object
get_date<-function(path)
{
  as.Date(substr(path,start=nchar(path)-13,stop=nchar(path)-4))
}

#Main function for Germany, adapted from Reichlab Repo

#' Read in and transform matrix of samples for one location into a quantile-format data_frame
#'
#' @param path Path of raw file location
#' @param location the FIPS code for the location for this matrix
#' @param qntls set of quantiles for which forecasts will be computed, defaults to c(0.025, 0.1, 0.2, .5, 0.8, .9, 0.975)
#'
#' @return long-format data_frame with quantiles
#' 
#' @details Assumes that the matrix gives 1 through 7 day ahead forecasts
#'
format_imperial<-function(path,location="Germany", qntls=c(0.01, 0.025, seq(0.05, 0.95, by=0.05), 0.975, 0.99))
{
  require(tidyverse)
  require(lubridate)
  
  #check whether new ensemble data or old DeCa Data file
  new_format<-grepl("ensemble_model_predictions",path)
  
  #get date of publication
  date_publish<-get_date(path)
  if(new_format) {
    #take data for Germany and second column which gives main ensemble result
    data_raw<-readRDS(path)[[as.character(date_publish)]]$Germany[[2]]
  } else {
    #only take first since both are identical for Germany
    data_raw<-readRDS(path)$Predictions$Germany[[1]]
  }
  
 
  
  #get timezero as in Reichlab function, i.e. date of official forecast collection
  timezero<-date_publish
  
  ##From here, adaption of Reichlab Function
  ##
  
  ## create tables corresponding to the days for each of the targets
  day_aheads <- tibble(
    target = paste(1:7, "day ahead inc death"),
    target_cum = paste(1:7, "day ahead cum death"),
    target_end_date = timezero+1:7)
  week_aheads <- tibble(
    target = "1 wk ahead inc death", 
    target_cum = "1 wk ahead cum death", 
    target_end_date = get_next_saturday(timezero) + (wday(timezero)>2)*7)
  
  ## make cumulative death counts
  obs_data <- read_csv("../../data-truth/truth-Cumulative Deaths_Germany.csv") %>%
    mutate(date = as.Date(date, "%m/%d/%y"))
  last_obs_date <- as.Date(colnames(data_raw)[1])-1
  last_obs_death <- obs_data$value[which(obs_data$location_name=="Germany" & obs_data$date==last_obs_date)]
  sample_mat_cum <- matrixStats::rowCumsums(as.matrix(data_raw)) + last_obs_death
  
  ## indices and samples for incident deaths 
  which_days <- which(colnames(data_raw) %in% as.character(day_aheads$target_end_date))
  which_weeks <- which(colnames(data_raw) %in% as.character(week_aheads$target_end_date))
  samples_daily <- data_raw[,which_days]
  samples_weekly <- data_raw[,which_weeks]
  samples_daily_cum <- sample_mat_cum[,which_days]
  samples_weekly_cum <- sample_mat_cum[,which_weeks]
  
  ## choosing quantile type=1 b/c more compatible with discrete samples
  ## other choices gave decimal answers
  qntl_daily <- apply(samples_daily, FUN=function(x) quantile(x, qntls, type=1), MAR=2) 
  colnames(qntl_daily) <- day_aheads$target[which(day_aheads$target_end_date %in% as.Date(colnames(samples_daily)))]
  qntl_daily_long <- as_tibble(qntl_daily) %>%
    mutate(location=location, quantile = qntls, type="quantile") %>%
    pivot_longer(cols=contains("day ahead"), names_to = "target") %>%
    inner_join(day_aheads)
  
  ## daily cumulative quantiles
  qntl_daily_cum <- apply(samples_daily_cum, FUN=function(x) quantile(x, qntls, type=1), MAR=2) 
  colnames(qntl_daily_cum) <- day_aheads$target_cum[which(day_aheads$target_end_date %in% as.Date(colnames(samples_daily)))]
  qntl_daily_cum_long <- as_tibble(qntl_daily_cum) %>%
    mutate(location=location, quantile = qntls, type="quantile") %>%
    pivot_longer(cols=contains("day ahead"), names_to = "target") %>%
    inner_join(day_aheads, by=c("target" = "target_cum"))
  
  if(is.null(dim(samples_weekly))){
    ## if only one week
    qntl_weekly <- enframe(quantile(samples_weekly, qntls, type=1)) %>% select(value)
    colnames(qntl_weekly) <- "1 wk ahead inc death"
    qntl_weekly_long <- qntl_weekly %>%
      mutate(location=location, quantile = qntls, type="quantile") %>%
      pivot_longer(cols=contains("wk ahead"), names_to = "target") %>%
      inner_join(week_aheads)
    
    qntl_weekly_cum <- enframe(quantile(samples_weekly_cum, qntls, type=1)) %>% select(value)
    colnames(qntl_weekly_cum) <- "1 wk ahead cum death"
    qntl_weekly_cum_long <- qntl_weekly_cum %>%
      mutate(location=location, quantile = qntls, type="quantile") %>%
      pivot_longer(cols=contains("wk ahead"), names_to = "target") %>%
      inner_join(week_aheads, by=c("target" = "target_cum"))
  } else { 
    ## if there are more than 1 weeks
    qntl_weekly <- apply(samples_weekly, FUN=function(x) quantile(x, qntls, type=1), MAR=2) 
    colnames(qntl_weekly) <- week_aheads$target[which(week_aheads$target_end_date %in% as.Date(colnames(qntl_weekly)))]
    qntl_weekly_long <- as_tibble(qntl_weekly) %>%
      mutate(location=location, quantile = qntls, type="quantile") %>%
      pivot_longer(cols=contains("wk ahead"), names_to = "target") %>%
      inner_join(week_aheads)
    
    qntl_weekly_cum <- apply(samples_weekly_cum, FUN=function(x) quantile(x, qntls, type=1), MAR=2) 
    colnames(qntl_weekly_cum) <- week_aheads$target[which(week_aheads$target_end_date %in% as.Date(colnames(samples_weekly)))]
    qntl_weekly_cum_long <- as_tibble(qntl_weekly_cum) %>%
      mutate(location=location, quantile = qntls, type="quantile") %>%
      pivot_longer(cols=contains("wk ahead"), names_to = "target") %>%
      inner_join(week_aheads, by=c("target" = "target_cum"))
  }
  
  qntl_dat_long <- bind_rows(
    qntl_daily_long, qntl_weekly_long,
    qntl_daily_cum_long, qntl_weekly_cum_long
  )    
  
  point_ests <- qntl_dat_long %>% 
    filter(quantile==0.5) %>% 
    mutate(quantile=NA, type="point")
  
  #before adding together data, add in additional column location_name
  #location_name: actual name
  #location: fips_code
  
  #get fips codes
  state_fips_codes<-read.csv("../../template/state_codes_germany.csv",stringsAsFactors = FALSE)
  location_name<-location
  location_fips<-state_fips_codes[which(location==state_fips_codes[,2]),1]
  
  all_dat <- bind_rows(qntl_dat_long, point_ests) %>%
    arrange(type, target, quantile) %>%
    mutate(quantile = round(quantile, 3), forecast_date = timezero,location=location_fips,location_name=location_name) %>%
    select(forecast_date, target, target_end_date,location,location_name,type,quantile,value)
  

  
  return(all_dat)
 
  
}


