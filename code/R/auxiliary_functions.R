# extract the date from a file name in our standardized format
get_date_from_filename <- function(filename){
  as.Date(substr(filename, start = 1, stop = 10))
}

# get the date of the next Monday following after a given date
next_monday <- function(date){
  nm <- rep(NA, length(date))
  for(i in seq_along(date)){
    nm[i] <- date[i] + (0:6)[weekdays(date[i] + (0:6)) == "Monday"]
  }
  return(as.Date(nm, origin = "1970-01-01"))
}

# among a set of forecast dates: choose those which are Mondays and those which are Sundays,
# Saturdays or Fridays if no forecast is available from Monday (or a day closer to Monday)
choose_relevant_dates <- function(dates){
  wds <- weekdays(dates)
  next_mondays <- next_monday(dates)
  relevant_dates <- c()
  for(day in c("Monday", "Sunday", "Saturday", "Friday")){
    relevant_dates <- c(relevant_dates, dates[wds == day &
                                                !(next_mondays %in% relevant_dates) &
                                                !((next_mondays - 1) %in% relevant_dates) &
                                                !((next_mondays - 2) %in% relevant_dates)
                                              ])
  }
  relevant_dates <- as.Date(relevant_dates, origin = "1970-01-01")
  return(as.Date(relevant_dates, origin = "1970-01-01"))
}

# modify the alpha value of a given color (to generate transparent versions for prediction bands)
modify_alpha <- function(col, alpha){
  x <- col2rgb(col)/255
  rgb(x[1], x[2], x[3], alpha = alpha)
}