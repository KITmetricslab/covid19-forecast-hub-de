get_date_from_filename <- function(filename){
  as.Date(substr(filename, start = 1, stop = 10))
}

next_monday <- function(date){
  nm <- rep(NA, length(date))
  for(i in seq_along(date)){
    nm[i] <- date[i] + (0:6)[weekdays(date[i] + (0:6)) == "Monday"]
  }
  return(as.Date(nm, origin = "1970-01-01"))
}

choose_relevant_dates <- function(dates){
  wds <- weekdays(dates)
  next_mondays <- next_monday(dates)
  relevant_dates <- c()
  for(day in c("Monday", "Sunday", "Saturday", "Friday")){
    relevant_dates <- c(relevant_dates, dates[wds == day & !(next_mondays %in% relevant_dates)])
  }
  relevant_dates <- as.Date(relevant_dates, origin = "1970-01-01")
  return(as.Date(relevant_dates, origin = "1970-01-01"))
}

modify_alpha <- function(col, alpha){
  x <- col2rgb(col)/255
  rgb(x[1], x[2], x[3], alpha = alpha)
}

add_forecast_to_plot <- function(forecasts_to_plot, truth, timezero, model,
                                 element = c("both", "points", "intervals"),
                                 col = "blue", alpha.col = 0.3){
  if(element %in% c("both", "intervals")){
    last_truth <- truth[truth$date == timezero - 2, "value"]

    subs_upper <- forecasts_to_plot[which(forecasts_to_plot$model == model &
                                             forecasts_to_plot$timezero == timezero &
                                             forecasts_to_plot$type == "quantile" &
                                             forecasts_to_plot$quantile > 0.51), ]
    subs_upper <- subs_upper[order(subs_upper$target_end_date, decreasing = TRUE), ]
    subs_lower <- forecasts_to_plot[which(forecasts_to_plot$model == model &
                                             forecasts_to_plot$timezero == timezero &
                                             forecasts_to_plot$type == "quantile" &
                                             forecasts_to_plot$quantile < 0.51), ]
    subs_lower <- subs_lower[order(subs_lower$target_end_date), ]

    subs_intervals <- rbind(subs_lower, subs_upper)

    col_transp <- modify_alpha(col, alpha.col)
    polygon(c(timezero - 2, subs_intervals$target_end_date),
            c(last_truth, subs_intervals$value), col = col_transp, border = NA)
  }

  if(element %in% c("both", "points")){
    subs_points <- forecasts_to_plot[which(forecasts_to_plot$model == model &
                                              forecasts_to_plot$timezero == timezero &
                                              forecasts_to_plot$type == "point"), ]
    points(subs_points$target_end_date, subs_points$value, col = col,
           pch = 21, lwd = 2)
  }
}

empty_plot <- function(start = as.Date("2020-03-01"), end = Sys.Date() + 28, ylim = c(0, 100000)){
  dats <- seq(from = start, to = end, by = 1)

  plot(NULL, ylim = ylim, xlim = c(start, end),
       xlab = "time", ylab = "cumulative deaths", axes = FALSE)
  xlabs <- dats[weekdays(dats) == "Saturday"]
  abline(v = xlabs, col = "grey")
  axis(1, at = xlabs, labels = xlabs, cex = 0.7)
  axis(2)
  box()
}

add_truth_to_plot <- function(truth, timezero){
  truth <- subset(truth, weekdays(truth$date) == "Saturday")
  inds_obs <- which(truth$date < timezero)
  inds_unobs <- which(truth$date > timezero)
  ind_last <- which(truth$date == timezero - 2)
  lines(truth$date[c(ind_last, inds_unobs)], truth$value[c(ind_last, inds_unobs)],
         col = "grey25", lwd = 2)
  points(truth$date[c(ind_last, inds_unobs)], truth$value[c(ind_last, inds_unobs)],
         pch = 16, col = "grey25", bg = "white", lwd = 2)
  lines(truth$date[inds_obs], truth$value[inds_obs], lwd = 2)
  points(truth$date[inds_obs], truth$value[inds_obs],
         pch = 16, bg = "white", lwd = 2)
}


highlight_timezero <- function(timezero, ylim = c(-1000, 100000)){
  rect(xleft = timezero - 3, xright = timezero, ybottom = ylim[1], ytop = ylim[2],
       col = "grey90", border = NA)
  abline(v = timezero - 2, col = "grey")
  abline(v = timezero, lty = 2)
}


plot_forecasts <- function(forecasts_to_plot, truth,
                           timezero, models,
                           start = as.Date("2020-03-01"), end = Sys.Date() + 28,
                           ylim = c(0, 100000),
                           show_pi = TRUE,
                           cols, alpha.col = 0.5,
                           legend = TRUE){
  empty_plot(ylim = ylim)
  highlight_timezero(timezero)

  if(length(models) > 0){
    if(show_pi){
      for(i in seq_along(models)){
        add_forecast_to_plot(forecasts_to_plot = forecasts_to_plot,
                             truth = truth,
                             timezero = timezero,
                             model = models[i], element = "intervals", col = cols[i])
      }
    }

    add_truth_to_plot(truth, timezero)

    for(i in seq_along(models)){
      add_forecast_to_plot(forecasts_to_plot = forecasts_to_plot,
                           truth = truth,
                           timezero = timezero,
                           model = models[i], element = "points", col = cols[i])
    }

    if(legend){
      legend("topleft", col = cols, pch = 21, legend = models, lwd = 2, lty = 0, bty = "n")
    }
  }


}
