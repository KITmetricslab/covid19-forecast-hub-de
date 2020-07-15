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

# function to add a forecast to the plot
# Arguments:
# forecasts_to_plot: the data.frame data_to_plot containing the relevant forecasts
# timezero: forecasts from which date are to be shown?
# model: the model from which forecasts are to be shown
# add_points: are point forecasts to be shown as dots?
# add_intervals: are forecast intervals to be shown as shaded areas?
# add_past: are last two past values to be shown if they are available?
# pch: the point shape for point forecasts
# col: the colour
# alpha.col: the degree of transparenca for shaded areas
add_forecast_to_plot <- function(forecasts_to_plot,
                                 timezero,
                                 location,
                                 model,
                                 add_points = TRUE,
                                 add_intervals = TRUE,
                                 add_past = FALSE,
                                 pch = 21,
                                 col = "blue",
                                 alpha.col = 0.3){
  # shaded areas for forecast intervals:
  if(add_intervals){
    # get upper bounds:
    subs_upper <- forecasts_to_plot[which(forecasts_to_plot$model == model &
                                            forecasts_to_plot$location == location &
                                            forecasts_to_plot$timezero == timezero &
                                            forecasts_to_plot$type == "quantile" &
                                            forecasts_to_plot$quantile > 0.51), ]
    subs_upper <- subs_upper[order(subs_upper$target_end_date, decreasing = TRUE), ]
    # get lower bounds:
    subs_lower <- forecasts_to_plot[which(forecasts_to_plot$model == model &
                                            forecasts_to_plot$timezero == timezero &
                                            forecasts_to_plot$location == location &
                                            forecasts_to_plot$target_end_date >= timezero - 7 &
                                            forecasts_to_plot$type %in% c("quantile", "observed") &
                                            (forecasts_to_plot$quantile < 0.51 | is.na(forecasts_to_plot$quantile))), ]
    subs_lower <- subs_lower[order(subs_lower$target_end_date), ]

    # put both together:
    subs_intervals <- rbind(subs_lower, subs_upper)

    # obtain transparent colour
    col_transp <- modify_alpha(col, alpha.col)

    # if polygon would disappear because only to points are available: draw small rectangle
    if(nrow(subs_intervals) == 2){
      subs_intervals <- rbind(subs_intervals, subs_intervals[2:1, ])
      subs_intervals$target_end_date <- subs_intervals$target_end_date + c(0, 0, 1, 1)
    }
    # draw the polygon:
    polygon(subs_intervals$target_end_date,
            subs_intervals$value, col = col_transp, border = NA)
  }

  # points for point forecasts:
  if(add_points){
    if(is.na(pch)) pch <- 0 # if truth data is unknown: set to squares
    # select the relevant points:
    subs_points <- forecasts_to_plot[which(forecasts_to_plot$model == model &
                                             forecasts_to_plot$timezero == timezero &
                                             forecasts_to_plot$location == location &
                                             forecasts_to_plot$type == "point"), ]
    # draw points
    points(subs_points$target_end_date, subs_points$value, col = col,
           pch = pch, lwd = 2)
  }

  # add last observations
  if(add_past){
    if(is.na(pch)) pch <- 0 # if truth data is unknown: set to squares
    # select relevant points:
    subs_past <- forecasts_to_plot[which(forecasts_to_plot$model == model &
                                           forecasts_to_plot$timezero == timezero &
                                           forecasts_to_plot$location == location &
                                           forecasts_to_plot$type == "observed"), ]
    # draw points:
    points(subs_past$target_end_date, subs_past$value, col = col,
           pch = pch, lwd = 2)
  }
}

# create an empty plot to which forecasts can be added
# Arguments:
# start: left xlim
# end: right xlim
# ylim
empty_plot <- function(start = as.Date("2020-03-01"), end = Sys.Date() + 28, ylim = c(0, 100000)){
  dats <- seq(from = round(start) - 14, to = round(end) + 14, by = 1)

  par(mar = c(4.5, 5, 2, 2))
  plot(NULL, ylim = ylim, xlim = c(start, end),
       xlab = "time", ylab = "", axes = FALSE)
  title(ylab = "cumulative deaths", line = 3.5)
  xlabs <- dats[weekdays(dats) == "Saturday"]
  abline(v = xlabs, col = "grey")

  # horizontal ablines:
  abline(h = axTicks(2), col = "grey")

  axis(1, at = xlabs, labels = xlabs, cex = 0.7)
  axis(2)
  graphics::box()
}

# add a truth curve to plot:
# Arguments:
# truth: data.frame containing dates and truth values
# timezero: the forecast date considered (truths to the right of this date are shown in grey)
# pch: the point shape
add_truth_to_plot <- function(truth, location, timezero, pch){
  truth <- truth[weekdays(truth$date) == "Saturday" &
                   truth$location == location, ]
  inds_obs <- which(truth$date < timezero)
  inds_unobs <- which(truth$date > timezero)
  ind_last <- which(truth$date == timezero - 2)
  lines(truth$date[c(ind_last, inds_unobs)], truth$value[c(ind_last, inds_unobs)],
        col = "grey25", lwd = 2)
  points(truth$date[c(ind_last, inds_unobs)], truth$value[c(ind_last, inds_unobs)],
         pch = pch, col = "grey25", bg = "white", lwd = 2)
  lines(truth$date[inds_obs], truth$value[inds_obs], lwd = 2)
  points(truth$date[inds_obs], truth$value[inds_obs],
         pch = pch, bg = "white", lwd = 2)
}

# add a lighgrey bar to highlight the forecast date:
highlight_timezero <- function(timezero, ylim = c(-1000, 100000)){
  rect(xleft = timezero - 3, xright = timezero, ybottom = ylim[1], ytop = ylim[2],
       col = "grey90", border = NA)
  abline(v = timezero - 2, col = "grey")
  abline(v = timezero, lty = 2)
}

# wrapper function to generate entire plot
# Arguments:
# forecasts_to_plot: the data.frame data_to_plot containing the relevant forecasts
# truth: named list containing truth data.frames
# timezero: forecasts from which date are to be shown?
# location: which location is to be shown?
# models: the model sfrom which forecasts are to be shown
# selected_truth: names of the truth data sets to be shown
# start: left xlim
# end: right xlim
# ylim
# show_pi: should forecast bands be shown?
# add_model_past: are last two past values to be shown if they are available?
# truth_data_used: data.frame mapping models to the used truth data
# cols: colours
# alpha.col: the degree of transparenca for shaded areas
# pch.truths: the point shape for point forecasts
# legend: should a legend be added
# add_points: are point forecasts to be shown as dots?
# highlight_target_end_date: target_end_date to highlight (when user hovers over it)
# point_pred_legend: text to paste into the legend (can be used to show point forecasts)
plot_forecasts <- function(forecasts_to_plot, truth,
                           timezero, models, selected_truth = names(truth)[1],
                           location = "GM",
                           start = as.Date("2020-03-01"), end = Sys.Date() + 28,
                           ylim = c(0, 100000),
                           show_pi = TRUE,
                           add_model_past = FALSE,
                           truth_data_used = NA,
                           cols, alpha.col = 0.5,
                           pch_truths,
                           pch_forecasts,
                           legend = TRUE,
                           highlight_target_end_date = NULL,
                           point_pred_legend = NULL){
  # fresh plot:
  empty_plot(start = start, end = end, ylim = ylim)
  # highlight the forecast date:
  highlight_timezero(timezero)
  abline(v = highlight_target_end_date)

  # add forecast bands:
  if(length(models) > 0){
    if(show_pi){
      for(i in seq_along(models)){
        add_forecast_to_plot(forecasts_to_plot = forecasts_to_plot,
                             timezero = timezero,
                             location = location,
                             model = models[i], add_intervals = TRUE,
                             add_past = FALSE, add_points = FALSE,
                             col = cols[i])
      }
    }
  }

  # add truths:
  for(t in selected_truth){
    add_truth_to_plot(truth = truth[[t]], location = location, timezero = timezero,
                      pch = pch_truths[t])
  }

  # add point forecasts:
  if(length(models) > 0){
    for(i in seq_along(models)){
      add_forecast_to_plot(forecasts_to_plot = forecasts_to_plot,
                           timezero = timezero,
                           location = location,
                           model = models[i],
                           add_points = TRUE, add_intervals = FALSE,
                           pch = pch_forecasts[truth_data_used[models[i]]],
                           add_past = FALSE, col = cols[i])
    }

    # add past observations:
    if(add_model_past){
      for(i in seq_along(models)){
        add_forecast_to_plot(forecasts_to_plot = forecasts_to_plot,
                             timezero = timezero,
                             location = location,
                             model = models[i],
                             add_points = FALSE, add_intervals = FALSE,
                             pch = pch_forecasts[truth_data_used[models[i]]],
                             add_past = TRUE, col = cols[i])
      }
    }
  }

  # add legends:
  if(legend){
    legend("topleft", col = cols, pch = 21, legend = paste0(models, ":", point_pred_legend),
           lwd = 2, lty = 0, bty = "n")
  }

}
