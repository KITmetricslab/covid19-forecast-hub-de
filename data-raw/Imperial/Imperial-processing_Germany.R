# Author: Konstantin G?rgen
# Date: Sat May 09 12:16:26 2020
# --------------
# Modification: Iterate over both models now, compute weekly incidents correctly
#Modification 2: Include forecasts for poland
# Author: Konstantin G?rgen
# Date: 2020-07-30
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
#' @param poland Do you want to include forecasts for poland as well?
#'
#' @return long-format data_frame with quantiles
#' 
#' @details Assumes that the matrix gives 1 through 7 day ahead forecasts
#'
#'

# path <- "./ensemble_model_predictions_2021-02-21.rds"
# ens_model <- TRUE
# location=c("Germany","Poland")
# qntls=c(0.01, 0.025, seq(0.05, 0.95, by=0.05), 0.975, 0.99)
# poland=TRUE
  
format_imperial<-function(path,ens_model,location=if(poland)c("Germany","Poland")else"Germany", qntls=c(0.01, 0.025, seq(0.05, 0.95, by=0.05), 0.975, 0.99),poland=TRUE)
{

  require(tidyverse)
  require(lubridate)
  require(MMWRweek)
  
  #change dates to English
  #see if you're on Windows or other OS
  if(Sys.info()[1]=="Windows") {
    Sys.setlocale("LC_TIME", "English")
  } else {
    Sys.setlocale(category = "LC_TIME", locale = "en_US.UTF8")
  }
  
  
  #get date of publication
  date_publish<-get_date(path)
  
  #old code, now moved old format in /data-raw/Imperial/Old_Data
  
  
  #check whether new ensemble data or old DeCa Data file
  # new_format<-grepl("ensemble_model_predictions",path)
  
  # if(new_format) {
  #   #take data for Germany and second column which gives main ensemble result
  #   data_raw<-readRDS(path)[[as.character(date_publish)]]$Germany[[2]]
  # } else {
  #   #only take first since both are identical for Germany
  #   data_raw<-readRDS(path)$Predictions$Germany[[1]]
  # }
  
  #now adjust for loop depending on whether or not you want poland in the forecast
  if(poland)
  {
    loop<-c("Germany","Poland")
  } else {
    loop<-"Germany"
  }
  
  #save output in list
  final<-list()
  for( k in 1:length(loop))
  {
    
   data_raw<-readRDS(path)[[as.character(date_publish)]]
   if(is.null(data_raw)) 
   {
     return(print(paste0("Data with date: ",date_publish," is null, Date in File name is probably not equal to prediction date. Check predictions manually and change file name to day before first prediction date")))
   }
    if(sum(names(data_raw)==loop[k])<1)
    {
      final[[k]]<-NA
      next
    }
         
    if(ens_model==1)
    {
      #dat_temp<-readRDS(path)[[as.character(date_publish)]]
      #ind<-which(names(dat_temp)=="Germany"|colnames(dat_temp)=="Poland")
      #data_raw<-dat_temp[[ind]]
      #data_raw<-readRDS(path)[[as.character(date_publish)]]$Germany[[1]]
      
      data_raw<-data_raw[[which(names(data_raw)==loop[k])]][[1]]
      
    } else {
      
      if(ens_model==2)
      {
        #data_raw<-readRDS(path)[[as.character(date_publish)]]$Germany[[2]]
        data_raw<-data_raw[[which(names(data_raw)==loop[k])]][[2]]
      } else {
        stop("Please indicate with ens_model=x (x=1 or x=2) which of the ensemble
           models you would like to process")
      }
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
    #new format, not ECDC file but RKI and MZ source now
    
    #path_truth<-paste0("../../data-truth/ECDC/truth_ECDC-Cumulative Deaths_",loop[k],".csv")
    # obs_data <- read_csv(path_truth) %>%
    #   mutate(date = as.Date(date, "%m/%d/%y"))
    # last_obs_date <- as.Date(colnames(data_raw)[1])-1
    
    if(loop[k]=="Germany")
    {
      path_truth<-"../../data-truth/RKI/truth_RKI-Cumulative Deaths_Germany.csv"
    }
    if(loop[k]=="Poland")
    {
      path_truth<-"../../data-truth/MZ/truth_MZ-Cumulative Deaths_Poland.csv"
    }
    obs_data <- read_csv(path_truth) %>%
        mutate(date = as.Date(date, "%m/%d/%y")) %>%filter(location_name==loop[k])
    last_obs_date <- as.Date(colnames(data_raw)[1])-1
    last_obs_death <- obs_data$value[which(obs_data$location_name==loop[k] & obs_data$date==last_obs_date)]
    sample_mat_cum <- matrixStats::rowCumsums(as.matrix(data_raw)) + last_obs_death
    
    #get true inc counts
    if(loop[k]=="Germany")
    {
      path_truth<-"../../data-truth/RKI/truth_RKI-Incident Deaths_Germany.csv"
    }
    if(loop[k]=="Poland")
    {
      path_truth<-"../../data-truth/MZ/truth_MZ-Incident Deaths_Poland.csv"
    }
    #path_truth<-paste0("../../data-truth/ECDC/truth_ECDC-Incident Deaths_",loop[k],".csv")
    obs_data_inc <- read_csv(path_truth) %>%
      mutate(date = as.Date(date, "%m/%d/%y")) %>%filter(location_name==loop[k])
    last_obs_death_inc <- obs_data_inc$value[which(obs_data_inc$location_name==loop[k] & obs_data_inc$date==last_obs_date)]
    
    ## indices and samples for incident deaths 
    which_days <- which(colnames(data_raw) %in% as.character(day_aheads$target_end_date))
    which_weeks <- which(colnames(data_raw) %in% as.character(week_aheads$target_end_date))
    # print(which_weeks)
    samples_daily <- data_raw[,which_days]
   # samples_weekly <- data_raw[,which_weeks]
    
    #for weekly inc forecasts, use all forecasts in the epidemiological week
    #Since forecasts usually occur on Sunday, we will add the last observed date,i.e
    #Sunday to week counts.
    
    #This is based on the assumption that the last observed date is indeed a Sunday:
    #if not, check and give warning:
    if(!(lubridate::wday(last_obs_date, label = TRUE, abbr = FALSE) == "Sunday"))
    {
      warning("Last observation was not on a Sunday, 1 week ahead incident deaths
              might be incomplete and false")
    }
    samples_weekly<- sample_mat_cum[,which_weeks]-last_obs_death+last_obs_death_inc
    samples_daily_cum <- sample_mat_cum[,which_days]
    samples_weekly_cum <- sample_mat_cum[,which_weeks]
    
    ## choosing quantile type=1 b/c more compatible with discrete samples
    ## other choices gave decimal answers
    qntl_daily <- apply(samples_daily, FUN=function(x) quantile(x, qntls, type=1), MAR=2) 
    colnames(qntl_daily) <- day_aheads$target[which(day_aheads$target_end_date %in% as.Date(colnames(samples_daily)))]
    qntl_daily_long <- as_tibble(qntl_daily) %>%
      mutate(location=location[k], quantile = qntls, type="quantile") %>%
      pivot_longer(cols=contains("day ahead"), names_to = "target") %>%
      inner_join(day_aheads)
    
    ## daily cumulative quantiles
    qntl_daily_cum <- apply(samples_daily_cum, FUN=function(x) quantile(x, qntls, type=1), MAR=2) 
    colnames(qntl_daily_cum) <- day_aheads$target_cum[which(day_aheads$target_end_date %in% as.Date(colnames(samples_daily)))]
    qntl_daily_cum_long <- as_tibble(qntl_daily_cum) %>%
      mutate(location=location[k], quantile = qntls, type="quantile") %>%
      pivot_longer(cols=contains("day ahead"), names_to = "target") %>%
      inner_join(day_aheads, by=c("target" = "target_cum"))
    
    if(is.null(dim(samples_weekly))){
      ## if only one week
      qntl_weekly <- enframe(quantile(samples_weekly, qntls, type=1)) %>% select(value)
      colnames(qntl_weekly) <- "1 wk ahead inc death"
      qntl_weekly_long <- qntl_weekly %>%
        mutate(location=location[k], quantile = qntls, type="quantile") %>%
        pivot_longer(cols=contains("wk ahead"), names_to = "target") %>%
        inner_join(week_aheads)
      
      qntl_weekly_cum <- enframe(quantile(samples_weekly_cum, qntls, type=1)) %>% select(value)
      colnames(qntl_weekly_cum) <- "1 wk ahead cum death"
      qntl_weekly_cum_long <- qntl_weekly_cum %>%
        mutate(location=location[k], quantile = qntls, type="quantile") %>%
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
        mutate(location=location[k], quantile = qntls, type="quantile") %>%
        pivot_longer(cols=contains("wk ahead"), names_to = "target") %>%
        inner_join(week_aheads, by=c("target" = "target_cum"))
    }
    
    qntl_dat_long <- bind_rows(
      qntl_daily_long, qntl_weekly_long,
      qntl_daily_cum_long, qntl_weekly_cum_long
    )    
    #median is included twice, is okay with Reichlab Data Submission Instructions
    #i.e. median is our point forecast
    point_ests <- qntl_dat_long %>% 
      filter(quantile==0.5) %>% 
      mutate(quantile=NA, type="point")
    
    ##now add 0, -1 day and 0,-1 week ahead forecasts, inc and cum
    #weekly forecasts mean:
      #for 0: 
        #inc: incidents in last complete epidemiological week
        #cum: total deaths at the end of last complete epidemiological week
      #for -1: 
        #inc: incidents in the week before the last complete epidemiological week
        #cum: total deaths at the end of the week before the last complete epidemiological week
    
    # what to subtract to get last day of epidemiological week
    dist_to_ep_week<-as.numeric(MMWRweek(last_obs_date)[3]) #gives the day of the ep week
    end_obs_week<-last_obs_date-dist_to_ep_week #gives the end date of ep week
    
    #get value for weekly incidents by substracting cumulative number from Week before
    
    #0 week ahead
    zero_week_inc<-obs_data$value[obs_data$date==end_obs_week]-
      obs_data$value[obs_data$date==(end_obs_week-7)]
    minus_one_week_inc<-obs_data$value[obs_data$date==(end_obs_week-7)]-
      obs_data$value[obs_data$date==(end_obs_week-14)]
    
   observed_point_ests<-
     tibble(target ="-1 day ahead inc death",target_end_date=last_obs_date-1,value=obs_data_inc$value[obs_data_inc$date==(last_obs_date-1)]) %>%
     add_row(target ="0 day ahead inc death",target_end_date=last_obs_date,value=obs_data_inc$value[obs_data_inc$date==(last_obs_date)]) %>%
     add_row(target ="-1 wk ahead inc death",target_end_date=end_obs_week-7,value=minus_one_week_inc) %>%
     add_row(target ="0 wk ahead inc death",target_end_date=end_obs_week,value=zero_week_inc) %>%
     add_row(target ="-1 day ahead cum death",target_end_date=last_obs_date-1,value=obs_data$value[obs_data$date==(last_obs_date-1)]) %>%
     add_row(target ="0 day ahead cum death",target_end_date=last_obs_date,value=obs_data$value[obs_data$date==(last_obs_date)]) %>%
     add_row(target ="-1 wk ahead cum death",target_end_date=end_obs_week-7,value=obs_data$value[obs_data$date==(end_obs_week-7)]) %>%
     add_row(target ="0 wk ahead cum death",target_end_date=end_obs_week,value=obs_data$value[obs_data$date==(end_obs_week)]) %>%
     mutate(type="observed",quantile=NA)
     
  
    
    
    #before adding together data, add in additional column location_name
    #location_name: actual name
    #location: fips_code
    
    #get fips codes
   path_fips<-paste0("../../template/state_codes_",loop[k],".csv")
    state_fips_codes<-read.csv(path_fips,stringsAsFactors = FALSE)
    location_name<-location[k]
    location_fips<-state_fips_codes[which(location[k]==state_fips_codes[,2]),1]
    
    all_dat <- bind_rows(qntl_dat_long, point_ests,observed_point_ests) %>%
      arrange(type, target, quantile) %>%
      mutate(quantile = round(quantile, 3), forecast_date = timezero,location=location_fips,location_name=location_name) %>%
      select(forecast_date, target, target_end_date,location,location_name,type,quantile,value)
    final[[k]]<-all_dat
  }
  
  return(final)
  }


