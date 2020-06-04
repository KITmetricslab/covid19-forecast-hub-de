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
    relevant_dates <- c(relevant_dates, dates[wds == day &
                                                !(next_mondays %in% relevant_dates) &
                                                !((next_mondays - 1) %in% relevant_dates) &
                                                !((next_mondays - 2) %in% relevant_dates)
                                              ])
  }
  relevant_dates <- as.Date(relevant_dates, origin = "1970-01-01")
  return(as.Date(relevant_dates, origin = "1970-01-01"))
}

modify_alpha <- function(col, alpha){
  x <- col2rgb(col)/255
  rgb(x[1], x[2], x[3], alpha = alpha)
}

add_forecast_to_plot <- function(forecasts_to_plot, truth, timezero, model,
                                 add_points = TRUE,
                                 add_intervals = TRUE,
                                 add_past = FALSE,
                                 col = "blue", alpha.col = 0.3){
  if(add_intervals){
    # last_truth <- truth[truth$date == timezero - 2, "value"]

    subs_upper <- forecasts_to_plot[which(forecasts_to_plot$model == model &
                                             forecasts_to_plot$timezero == timezero &
                                             forecasts_to_plot$type == "quantile" &
                                             forecasts_to_plot$quantile > 0.51), ]
    subs_upper <- subs_upper[order(subs_upper$target_end_date, decreasing = TRUE), ]
    subs_lower <- forecasts_to_plot[which(forecasts_to_plot$model == model &
                                             forecasts_to_plot$timezero == timezero &
                                            forecasts_to_plot$target_end_date >= timezero - 7 &
                                             forecasts_to_plot$type %in% c("quantile", "observed") &
                                             (forecasts_to_plot$quantile < 0.51 | is.na(forecasts_to_plot$quantile))), ]
    subs_lower <- subs_lower[order(subs_lower$target_end_date), ]

    subs_intervals <- rbind(subs_lower, subs_upper)
    print(subs_intervals)

    col_transp <- modify_alpha(col, alpha.col)
    # temporarily removed last_truth from polygon as last truth can be different from model to model
    if(nrow(subs_intervals) == 2){
      subs_intervals <- rbind(subs_intervals, subs_intervals[2:1, ])
      subs_intervals$target_end_date <- subs_intervals$target_end_date + c(0, 0, 1, 1)
    }
    polygon(subs_intervals$target_end_date,
            subs_intervals$value, col = col_transp, border = NA)
    # polygon(c(timezero - 2, subs_intervals$target_end_date),
    #         c(last_truth, subs_intervals$value), col = col_transp, border = NA)
  }

  if(add_points){
    subs_points <- forecasts_to_plot[which(forecasts_to_plot$model == model &
                                              forecasts_to_plot$timezero == timezero &
                                              forecasts_to_plot$type == "point"), ]
    points(subs_points$target_end_date, subs_points$value, col = col,
           pch = 21, lwd = 2)
  }

  if(add_past){
    subs_past <- forecasts_to_plot[which(forecasts_to_plot$model == model &
                                             forecasts_to_plot$timezero == timezero &
                                             forecasts_to_plot$type == "observed"), ]
    points(subs_past$target_end_date, subs_past$value, col = col,
           pch = 21, lwd = 2)
  }
}

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

add_truth_to_plot <- function(truth, timezero, pch){
  truth <- subset(truth, weekdays(truth$date) == "Saturday")
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


highlight_timezero <- function(timezero, ylim = c(-1000, 100000)){
  rect(xleft = timezero - 3, xright = timezero, ybottom = ylim[1], ytop = ylim[2],
       col = "grey90", border = NA)
  abline(v = timezero - 2, col = "grey")
  abline(v = timezero, lty = 2)
}


plot_forecasts <- function(forecasts_to_plot, truth,
                           timezero, models, selected_truth = names(truth)[1],
                           start = as.Date("2020-03-01"), end = Sys.Date() + 28,
                           ylim = c(0, 100000),
                           show_pi = TRUE,
                           add_model_past = FALSE,
                           cols, alpha.col = 0.5,
                           pch_truths,
                           legend = TRUE,
                           highlight_target_end_date = NULL,
                           point_pred_legend = NULL){
  empty_plot(start = start, end = end, ylim = ylim)
  highlight_timezero(timezero)
  abline(v = highlight_target_end_date)

  if(length(models) > 0){
    if(show_pi){
      for(i in seq_along(models)){
        add_forecast_to_plot(forecasts_to_plot = forecasts_to_plot,
                             truth = truth,
                             timezero = timezero,
                             model = models[i], add_intervals = TRUE,
                             add_past = FALSE, add_points = FALSE,
                             col = cols[i])
      }
    }
  }

    for(t in selected_truth){
      add_truth_to_plot(truth[[t]], timezero, pch = pch_truths[t])
    }

  if(length(models) > 0){
    for(i in seq_along(models)){
      add_forecast_to_plot(forecasts_to_plot = forecasts_to_plot,
                           truth = truth,
                           timezero = timezero,
                           model = models[i],
                           add_points = TRUE, add_intervals = FALSE,
                           add_past = FALSE, col = cols[i])
    }

    if(add_model_past){
      for(i in seq_along(models)){
        add_forecast_to_plot(forecasts_to_plot = forecasts_to_plot,
                             truth = truth,
                             timezero = timezero,
                             model = models[i],
                             add_points = FALSE, add_intervals = FALSE,
                             add_past = TRUE, col = cols[i])
      }
    }
  }

  if(legend){
    legend("topleft", col = cols, pch = 21, legend = paste0(models, ":", point_pred_legend),
           lwd = 2, lty = 0, bty = "n")
  }

}
