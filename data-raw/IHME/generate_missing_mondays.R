# Takes already processed IHME files and generates forecasts for missing Mondays
# Jakob Ketterer
# December 2020

Sys.setlocale(category = "LC_TIME", locale = "English")

countries <- c("Germany", "Poland")

# directories
dir_processed <- "../../data-processed/IHME-CurveFit/"
dir_export <- "../../data-temp/IHME-CurveFit/"

# generate Mondays from today till 12th October 2020
start_date <- as.Date("2020-10-12") 
dates <- seq(start_date, Sys.Date(), by="day")
mon_dates <- as.Date(dates[weekdays(dates) == "Monday"])

# get available processed forecast dates
all_files <- list.files(dir_processed, pattern=".csv")
files_processed <- all_files[grep("-Germany-IHME-CurveFit.csv", all_files)]
dates_processed <- as.Date(gsub("-Germany-IHME-CurveFit.csv", "", files_processed))

# get relevant available forecast dates (relevant = start_date or after)
last_forecast_date <- tail(dates_processed[dates_processed <= start_date], n=1)
dates_relevant <- as.Date(c(last_forecast_date, dates_processed[dates_processed > start_date])) 

# get missing Mondays
mons_missing <- as.Date(setdiff(mon_dates, dates_relevant), origin="1970-01-01")
# print("Missing Mondays:")
# print(mons_missing)

# for each missing Monday, get closest available forecast date from the past (reference date)
ref_dates <- numeric(length=length(mons_missing))
for (i in seq(length(mons_missing))){
  mon_missing <- mons_missing[i]
  ref_dates[i] <- tail(dates_relevant[dates_relevant <= mon_missing], n=1)
}
ref_dates <- as.Date(ref_dates, origin="1970-01-01")
# print("Reference Dates:")
# print(ref_dates)

# for each Monday, generate forecast file by modifying the reference forecast file
for (i in seq(length(mons_missing))){
  ref_date <- ref_dates[i]
  mon_missing <- mons_missing[i]
  # print(ref_date)
  
  # iterate over countries
  for (country in countries){
    # open reference forecast file
    ref_file_name <- paste0(dir_processed, ref_date, "-", country, "-IHME-CurveFit.csv")
    # print(ref_file_name)
    ref_frame <- read.csv(ref_file_name, header = TRUE)
    
    # get number of days between missing Monday and reference date
    days_btw <- as.integer(mon_missing - ref_date)
    # print(days_btw)
    
    # shift targets of reference forecasts to get missing Monday forecasts targets
    # only cumulative targets can be shifted
    ref_frame <- ref_frame[grepl("cum", unlist(ref_frame["target"], use.names=FALSE)),]
    
    # N_new day ahead cum with N_new = N - days_btw
    day_frame <- ref_frame[grepl("day", unlist(ref_frame["target"], use.names=FALSE)),]
    # print(dim(day_frame[1]))
    transform_daily_targets <- function(x){
      N <- strsplit(x, " ")[[1]][1]
      N_new <- as.integer(N) - days_btw
      return (sub(N, as.character(N_new), x))
    }
    day_frame$target <- unlist(lapply(day_frame$target, transform_daily_targets), use.names = FALSE)
    
    # N' wk ahead cum with N' = N - floor(days_btw/7)
    wk_frame <- ref_frame[grepl("wk", unlist(ref_frame["target"], use.names=FALSE)),]
    # print(dim(wk_frame[1]))
    transform_weekly_targets <- function(x){
      N <- strsplit(x, " ")[[1]][1]
      N_new <- as.integer(N) - floor(days_btw/7)
      return (sub(N, as.character(N_new), x))
    }
    wk_frame$target <- unlist(lapply(wk_frame$target, transform_weekly_targets), use.names = FALSE)
    
    # merge daily and weekly targets
    mon_frame <- rbind(day_frame, wk_frame)
    
    # delete rows with N_new = 0 or N_new < 0
    keep_target <- rep(TRUE, dim(mon_frame)[1])
    for (i in seq(dim(mon_frame)[1])){
      tar <- mon_frame["target"][i,]
      # print(tar)
      N_new <- as.integer(strsplit(tar, " ")[[1]][1])
      if (!is.na(N_new) & N_new > 0){
        keep_target[i] <- TRUE
      } else {
        keep_target[i] <- FALSE
      }
    }
    mon_frame <- mon_frame[keep_target,]
    
    # adapt forecast date to missing Monday date
    mon_frame["forecast_date"] <- rep(mon_missing, dim(mon_frame)[1])
    
    # save data frame to csv
    filename <- paste0(dir_export, mon_missing, "-", country, "-", "IHME-CurveFit.csv")
    # print(filename)
    write.csv(mon_frame, file = filename, row.names = FALSE, quote=FALSE)
    
  }
}
