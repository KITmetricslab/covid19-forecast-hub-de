# extract the date from a file name in our standardized format
get_date_from_filename <- function(filename){
  as.Date(substr(filename, start = 1, stop = 10))
}

# select correct file
select_file <- function(files, forecast_date, target_type, country, tol = 4){
  if(!target_type %in% c("case", "death")) stop("target_type needs to be from c('death', 'case').")
  # restrict to csv files:
  files <- files[grepl(".csv", files) & grepl(country, files)]

  # restrict to files for respective target:
  if(target_type == "death") files <- files[!grepl("case", files) & !grepl("ICU", files)]
  if(target_type == "case") files <- files[grepl("case", files)]

  # extract dates:
  dates <- get_date_from_filename(files)

  # restrict to dates within in the correct range:
  dates_eligible <- dates[dates %in% (forecast_date - 0:tol)]
  if(length(dates_eligible) == 0) stop("No forecast files found among ",
                                       paste(head(files, 2), collapse = ", "),
                                       "...")
  # choose most current:
  date_selected <- max(dates_eligible)
  return(files[dates == date_selected])
}

# function to get date of last Saturday:
get_last_saturday <- function(forecast_date){
  if(!weekdays(forecast_date) == "Monday") warning("forecast_date should be a Monday.")
  (forecast_date - (0:6))[weekdays(forecast_date - (0:6)) == "Saturday"]
}
