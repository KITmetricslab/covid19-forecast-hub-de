# Author: Konstantin Görgen
# Date: Fri May 08 14:51:21 2020
# --------------
# Modification:
# Author:
# Date:
# --------------

##Functions to process IHME files

get_date<-function(path)
{
  temp_path<-dirname(path)
  slashes<-unlist(gregexpr("/",temp_path))
  last_slash<-slashes[length(slashes)]
  date.1<-gsub("_", "-",substring(dirname(path),first=last_slash+1))
  if(coerceable_to_date(date.1))
  {return(as.Date(date.1))} else
  {
    date.2<-substr(date.1,start=1,end=10)
    if(coerceable_to_date(date.2))
    {
      return(as.Date(date.2))
    } else 
    {
      stop("Path cannot be coerced to date. Please rename folders")
    }
    }
  }

coerceable_to_date<-function(x)
{
  !is.na(as.Date(as.character(x), tz = 'UTC', format = '%Y-%m-%d'))
}

#Main Function to process IHME data

#' Transform matrix of samples for one location into a quantile-format data_frame
#'
#' @param path the forecast file path
#' @param all_states Should all states be forecasted or just on Federal Level, default=FALSE
#' @return long-format data_frame with quantiles
#' 
make_qntl_dat <- function(path,all_states=FALSE) {
  require(tidyverse)
  require(MMWRweek)
  require(lubridate)
  
 
  data_raw <- read.csv(path, stringsAsFactors = FALSE)
  timezero<-get_date(path)
  
  # format read-in file
  data_raw <- data_raw %>%
    dplyr::select(grep("location_name",names(data_raw)),grep("date",names(data_raw)),
                  grep("death",names(data_raw)))
  
  #only take Germany and its states out of data, read state names from fips codes
  if(all_states)
  {
    state_fips_codes<-read.csv("state_codes_germany.csv",stringsAsFactors = FALSE)[,-1]
    names_germany<-state_fips_codes$state_name
    data_germany<-data_raw[data_raw$location_name %in% names_germany,]
  } else {
    data_germany<-data_raw[data_raw$location_name=="Germany",]
  }
 
#parse as date
  data_germany$date<-as.Date(data_germany$date)
  
  
  ####Adapted from reichlab from here:
  
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
  last_obs_date <- timezero #is this the last date of observations?
  #all observed deaths
  last_obs_death <- obs_data$value[which(obs_data$location_name=="Germany" & obs_data$date==last_obs_date)]
  sample_mat_cum <- data_germay %>% mutate(value=ifelse(obs_data$date<=last_obs_date,data_germany$  
                                                          
                                                          (data_germany,obs_data[1:which(data_germany$date==last_obs_date],
                              )
    matrixStats::rowCumsums(as.matrix(data_germany)) + last_obs_death
  
  data_germany_cleaned<-data_germany
  in_ihme<-data_germany_cleaned$date %in% obs_data$date
  in_true<-obs_data$date %in% data_germany$date
  obs_data_replace<-obs_data$value[in_true & obs_data$date<=last_obs_date]
  data_germany_cleaned[in_ihme & data_germany_cleaned$date<=last_obs_date,3:5]<-
    cbind(obs_data_replace,obs_data_replace,obs_data_replace)
                       ,
                                                              mutate,obs_data[1:which(data_germany$date==last_obs_date]  
    
  ## indices and samples for incident deaths 
  which_days <- which(colnames(data_germany) %in% as.character(day_aheads$target_end_date))
  which_weeks <- which(colnames(data_germany) %in% as.character(week_aheads$target_end_date))
  samples_daily <- data_germany[,which_days]
  samples_weekly <- data_germany[,which_weeks]
  samples_daily_cum <- sample_mat_cum[,which_days]
  samples_weekly_cum <- sample_mat_cum[,which_weeks]
  
  
  #old code
  if (names(data)[grep("date",names(data))]!="date"){
    data<-data %>%
      dplyr::rename(date=names(data)[grep("date",names(data))])
  }  
  if (sum(grepl("location_name",names(data)))>0 & !("location" %in% names(data))){
    data<-data %>%
      dplyr::rename(location=location_name)
  }
  if (sum(grepl("V1",names(data)))>0){
    data<-data %>%
      dplyr::select(-"V1")
  }
  # data <- data %>%
  #  dplyr::select(-names(data)[which(grepl("location",names(data)))])#[-which(names(data)[which(grepl("location",names(data))==TRUE)]=="location")])
  
  ## read state code
  state_fips_codes<-read.csv("state_codes_germany.csv",stringsAsFactors = FALSE)[,-1]
  col_list1 <- c(grep("location", colnames(data)),grep("date", colnames(data)),grep("death", colnames(data)))
  death_qntl1 <- data[,col_list1] %>%
    dplyr::rename(date_v=date) %>%
    # dplyr::filter(as.Date(as.character(date_v)) %in% c(forecast_date+1:7)) %>%
    dplyr::filter(as.Date(as.character(date_v)) > forecast_date) %>%
    dplyr::mutate(target_id=paste(difftime(as.Date(as.character(date_v)),forecast_date,units="days"),"day ahead inc death")) %>%
    dplyr::rename("0.025"=deaths_lower,"0.975"=deaths_upper,"NA"=deaths_mean) %>%
    gather(quantile, value, -c(location, date_v, target_id)) %>%
    dplyr::left_join(state_fips_codes, by=c("location"="state_name")) %>%
    dplyr::rename(location_id=state_code) %>%
    dplyr::mutate(type=ifelse(quantile=="NA","point","quantile"),forecast_date=forecast_date) %>%
    dplyr::rename(target_end_date=date_v)
  col_list2 <- c(grep("location", colnames(data)),grep("date", colnames(data)),grep("totdea",colnames(data)))
  death_qntl2 <- data[,c(col_list2)] %>%
    dplyr::rename(date_v=date) %>%
    # dplyr::filter(as.Date(as.character(date_v)) %in% c(forecast_date+1:7)) %>%
    dplyr::filter(as.Date(as.character(date_v)) > forecast_date) %>%
    dplyr::mutate(target_id=paste(difftime(as.Date(as.character(date_v)),forecast_date,units="days"),"day ahead cum death")) %>%
    dplyr::rename("0.025"=totdea_lower,"0.975"=totdea_upper,"NA"=totdea_mean) %>%
    gather(quantile, value, -c(location, date_v, target_id)) %>%
    dplyr::left_join(state_fips_codes, by=c("location"="state_name")) %>%
    dplyr::rename(location_id=state_code) %>%
    dplyr::mutate(type=ifelse(quantile=="NA","point","quantile"),forecast_date=forecast_date) %>%
    dplyr::rename(target_end_date=date_v)
  # add hospitalization daily incident (admis)
  col_list3 <- c(grep("location", colnames(data)),grep("date", colnames(data)),grep("admis",colnames(data)))
  death_qntl3 <- data[,c(col_list3)] %>%
    dplyr::rename(date_v=date) %>%
    # dplyr::filter(as.Date(as.character(date_v)) %in% c(forecast_date+1:7)) %>%
    dplyr::filter(as.Date(as.character(date_v)) > forecast_date) %>%
    dplyr::mutate(target_id=paste(difftime(as.Date(as.character(date_v)),forecast_date,units="days"),"day ahead inc hosp")) %>%
    dplyr::rename("0.025"=admis_lower,"0.975"=admis_upper,"NA"=admis_mean) %>%
    gather(quantile, value, -c(location, date_v, target_id)) %>%
    dplyr::left_join(state_fips_codes, by=c("location"="state_name")) %>%
    dplyr::rename(location_id=state_code) %>%
    dplyr::mutate(type=ifelse(quantile=="NA","point","quantile"),forecast_date=forecast_date) %>%
    dplyr::rename(target_end_date=date_v)
  # add if for forecast date weekly
  # if (lubridate::wday(forecast_date,label = TRUE, abbr = FALSE)=="Sunday"|lubridate::wday(forecast_date,label = TRUE, abbr = FALSE)=="Monday"){
  #   death_qntl2_1 <- data[,c(col_list2)] %>%
  #     dplyr::rename(date_v=date) %>%
  #     dplyr::mutate(day_v=lubridate::wday(date_v,label = TRUE, abbr = FALSE),
  #                   ew=unname(MMWRweek(date_v)[[2]])) %>%
  #     # dplyr::filter(day_v =="Saturday" & 
  #     #                 ew<unname(MMWRweek(forecast_date)[[2]])+6 & 
  #     #                 ew>unname(MMWRweek(forecast_date)[[2]])-1) %>%
  #     dplyr::filter(day_v =="Saturday" & ew>unname(MMWRweek(forecast_date)[[2]])-1) %>%
  #     dplyr::mutate(target_id=paste((ew-(unname(MMWRweek(forecast_date)[[2]]))+1),"wk ahead cum death")) 
  # } else {
  #   death_qntl2_1 <- data[,c(col_list2)] %>%
  #     dplyr::rename(date_v=date) %>%
  #     dplyr::mutate(day_v=lubridate::wday(date_v,label = TRUE, abbr = FALSE),
  #                   ew=unname(MMWRweek(date_v)[[2]])) %>%
  #     # dplyr::filter(day_v =="Saturday" & 
  #     #                 ew<(unname(MMWRweek(forecast_date)[[2]])+1)+6 & 
  #     #                 ew>unname(MMWRweek(forecast_date)[[2]])) %>%
  #     dplyr::filter(day_v =="Saturday" & ew>unname(MMWRweek(forecast_date)[[2]])) %>%
  #     dplyr::mutate(target_id=paste((ew-(unname(MMWRweek(forecast_date)[[2]])+1))+1,"wk ahead cum death")) 
  # }
  # death_qntl2_2 <- death_qntl2_1 %>%
  #   dplyr::rename("0.025"=totdea_lower,"0.975"=totdea_upper,"NA"=totdea_mean) %>%
  #   gather(quantile, value, -c(location, date_v, day_v, ew, target_id)) %>%
  #   dplyr::left_join(state_fips_codes, by=c("location"="state_name")) %>%
  #   dplyr::rename(location_id=state_code,target_end_date=date_v) %>%
  #   dplyr::mutate(type=ifelse(quantile=="NA","point","quantile"),forecast_date=forecast_date) %>%
  #   dplyr::select(-"day_v",-"ew")
  # combining data
  comb <-rbind(death_qntl1,death_qntl2,death_qntl3) #deleted death_qntl2_2, needs to be added later
  comb$location[which(comb$location=="Germany")] <- "Germany"
  comb$location_id[which(comb$location=="Germany")] <- "Germany"
  comb <- comb %>%
    dplyr::filter(!is.na(location_id)) %>%
    dplyr::rename(location_name=location)
  comb$quantile[which(comb$quantile=="NA")] <- NA
  comb$quantile <- as.numeric(comb$quantile)
  comb$value <- as.numeric(comb$value)
  final<- comb %>%
    dplyr::select(forecast_date,target_id,target_end_date,location_id,location_name,type,quantile,value) %>%
    dplyr::rename(target=target_id,location=location_id) %>%
    arrange(location,type,quantile,target)
  final$location[which(nchar(final$location)==1)] <- paste0(0,final$location[which(nchar(final$location)==1)])
  return(final)
}