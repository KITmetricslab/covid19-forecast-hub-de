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
                                 timezero = NULL,
                                 horizon = NULL,
                                 location,
                                 target,
                                 model,
                                 add_points = TRUE,
                                 add_intervals = TRUE,
                                 add_past = FALSE,
                                 pch = 21,
                                 col = "blue",
                                 alpha.col = 0.3){

  if((is.null(timezero) & is.null(horizon)) |
     (!is.null(timezero) & ! is.null(horizon))){
    cat("Please specify exactly one out of timezero and horizon.")
  }

  selection_target <- grepl(paste(horizon, target), forecasts_to_plot$target) # target matched target against either only "type"
  # of target (death or case) or also horizon
  selection_timezero <- if(is.null(timezero)){
    rep(TRUE, nrow(forecasts_to_plot))
  }else{
    forecasts_to_plot$timezero == timezero
  }

  # shaded areas for forecast intervals:
  if(add_intervals){
    # get upper bounds:
    subs_upper <- forecasts_to_plot[which(forecasts_to_plot$model == model &
                                            selection_target &
                                            forecasts_to_plot$location == location &
                                            selection_timezero &
                                            forecasts_to_plot$type %in% c("quantile", "observed") &
                                            (forecasts_to_plot$quantile > 0.51 | is.na(forecasts_to_plot$quantile))), ]
    subs_upper <- subs_upper[order(subs_upper$target_end_date), ]
    # get lower bounds:
    subs_lower <- forecasts_to_plot[which(forecasts_to_plot$model == model &
                                            selection_target &
                                            selection_timezero &
                                            forecasts_to_plot$location == location &
                                            forecasts_to_plot$type %in% c("quantile", "observed") &
                                            (forecasts_to_plot$quantile < 0.49 | is.na(forecasts_to_plot$quantile))), ]
    subs_lower <- subs_lower[order(subs_lower$target_end_date), ]

    # obtain transparent colour
    col_transp <- modify_alpha(col, alpha.col)

    plot_weekly_bands(dates = subs_upper$target_end_date, lower = subs_lower$value, upper = subs_upper$value,
                      col = col_transp, border = NA, separate_all = !is.null(horizon))
  }

  # points for point forecasts:
  if(add_points){
    if(is.na(pch)) pch <- 0 # if truth data is unknown: set to squares

    # if plotting by forecast date:
    if(!is.null(timezero)){
      # select the relevant points:
      subs_points_truth <- forecasts_to_plot[which(forecasts_to_plot$model == model &
                                               selection_target &
                                               selection_timezero &
                                               forecasts_to_plot$location == location &
                                               forecasts_to_plot$type %in% c("point", "observed")), ]
      # draw points
      points(subs_points_truth$target_end_date, subs_points_truth$value, col = col,
             pch = pch, lwd = 1, type = "b")
    }

    # if plotting by horizon:
    if(!is.null(horizon)){
      subs_points <- forecasts_to_plot[which(forecasts_to_plot$model == model &
                                               selection_target &
                                               selection_timezero &
                                               forecasts_to_plot$location == location &
                                               forecasts_to_plot$type %in% c("point")), ]
      subs_truths <- forecasts_to_plot[which(forecasts_to_plot$model == model &
                                               grepl(paste("0 wk ahead", target), forecasts_to_plot$target) &
                                               selection_timezero &
                                               forecasts_to_plot$location == location &
                                               forecasts_to_plot$type %in% c("observed")), ]
      subs_points_truths <- rbind(subs_points, subs_truths)

      lines_by_timezero(subs_points_truths, type = "b", pch = NA, col = col)
      points(subs_points$target_end_date, subs_points$value, col = col)
    }
  }
}

lines_by_timezero <- function(forecasts, ...){
  timezeros <- unique(forecasts$timezero)
  for(i in seq_along(timezeros)){
    subs <- subset(forecasts, timezero == timezeros[i])
    subs <- subs[order(subs$target_end_date), ]
    lines(subs$target_end_date, subs$value, ...)
  }
}

# create an empty plot to which forecasts can be added
# Arguments:
# start: left xlim
# end: right xlim
# ylim
empty_plot <- function(start = as.Date("2020-03-01"), target = "cum death",
                       end = Sys.Date() + 28, ylim = c(0, 100000)){
  dats <- seq(from = round(start) - 14, to = round(end) + 14, by = 1)

  plot(NULL, ylim = ylim, xlim = c(start, end),
       xlab = "time", ylab = "", axes = FALSE)

  yl <- switch (target,
                "cum death" = "cumulative deaths",
                "inc death" = "incident deaths",
                "inc case" = "incident cases",
                "cum case" = "cumulative cases"
  )
  title(ylab = yl, line = 3.5)
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
add_truth_to_plot <- function(truth, target, location, timezero, pch){
  truth <- truth[weekdays(truth$date) == "Saturday" &
                   truth$location == location, ]
  inds_obs <-  if(is.null(timezero)){
    rep(TRUE, nrow(truth))
  }else{
    which(truth$date < timezero)
  }
  inds_unobs <- which(truth$date > timezero)
  ind_last <- which(truth$date == timezero - 2)
  lines(truth$date[c(ind_last, inds_unobs)], truth[c(ind_last, inds_unobs), target],
        col = "grey25", lwd = 2)
  points(truth$date[c(ind_last, inds_unobs)], truth[c(ind_last, inds_unobs), target],
         pch = pch, col = "grey25", bg = "white", lwd = 2)
  lines(truth$date[inds_obs], truth[inds_obs, target], lwd = 2)
  points(truth$date[inds_obs], truth[inds_obs, target],
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
                           target = "cum death",
                           timezero = NULL,
                           horizon = NULL,
                           models,
                           selected_truth = "ECDC",
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
  empty_plot(start = start, target = target, end = end, ylim = ylim)
  # highlight the forecast date:
  if(!is.null(timezero)){
    highlight_timezero(timezero, ylim = ylim + c(-1, 1)*diff(ylim))
  }
  abline(v = highlight_target_end_date)

  # add forecast bands:
  if(length(models) > 0){
    if(show_pi){
      for(i in seq_along(models)){
        add_forecast_to_plot(forecasts_to_plot = forecasts_to_plot,
                             target = target,
                             timezero = timezero,
                             horizon = horizon,
                             location = location,
                             model = models[i], add_intervals = TRUE,
                             add_past = FALSE, add_points = FALSE,
                             col = cols[i])
      }
    }
  }

  # add truths:
  for(t in selected_truth){
    add_truth_to_plot(truth = truth[[t]], target = target,
                      location = location, timezero = timezero,
                      pch = pch_truths[t])
  }

  # add point forecasts:
  if(length(models) > 0){
    for(i in seq_along(models)){
      add_forecast_to_plot(forecasts_to_plot = forecasts_to_plot,
                           target = target,
                           timezero = timezero,
                           location = location,
                           horizon = horizon,
                           model = models[i],
                           add_points = TRUE, add_intervals = FALSE,
                           pch = pch_forecasts[truth_data_used[models[i]]],
                           add_past = add_model_past, col = cols[i])
    }
  }

  # add legends:
  if(legend){
    legend("topleft", col = cols, pch = 21, legend = paste0(models, ":", point_pred_legend),
           lwd = 2, lty = 0, bty = "n")
  }

}

split_indices_at_gaps <- function(x, step = 7){
  indices <- seq_along(x)
  ret <- list()
  i <- 1
  while(any(diff(x) > step)){
    ret[[i]] <- indices[1:(min(which(diff(x) > step)))]
    x <- tail(x, length(x) - length(ret[[i]]))
    indices <- tail(indices, length(indices) - length(ret[[i]]))
    i <- i + 1
  }
  ret[[i]] <- indices
  return(ret)
}

plot_one_band <- function(dates, lower, upper, ...){
  if(length(dates) == 1){
    dates <- c(dates - 2, dates, dates + 2)
    lower <- rep(lower, 3)
    upper <- rep(upper, 3)
  }
  polygon(c(dates, rev(dates)), c(lower, rev(upper)), ...)
}

plot_weekly_bands <- function(dates, lower, upper, separate_all = FALSE, ...){
  indices <- split_indices_at_gaps(as.numeric(dates),
                                   step = ifelse(separate_all, 1, 7))
  for(i in 1:length(indices)){
    plot_one_band(dates[indices[[i]]],
                  lower[indices[[i]]],
                  upper[indices[[i]]], ...)
  }
}
