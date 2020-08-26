# read in week ahead forecasts from a given file
read_week_ahead <- function(path){
  dat <- read.csv(path, colClasses = c(location = "character", forecast_date = "Date", target_end_date = "Date"),
                  stringsAsFactors = FALSE)
  return(subset(dat, target %in% c(paste(1:4, "wk ahead inc death"), paste(1:4, "wk ahead cum death"))))
}

# get shift between cumulative numbers in two truth data sets. Differences for incident counts are set to zero
get_shift <- function(truth1, truth2, date){
  truth1 <- truth1[truth1$date == date, ]
  truth2 <- truth2[truth2$date == date, ]
  both_truth <- merge(truth1, truth2, by = c("date", "location", "target"))
  both_truth$shift <- both_truth$value.x - both_truth$value.y
  both_truth$shift[grepl("inc", both_truth$target)] <- 0
  return(both_truth[, c("date", "location", "target", "shift")])
}

# evaluate predictive quantiles:
evaluate_quantiles <- function(forecasts, name_truth_model, name_truth_eval, truth_model, truth_eval, detailed = FALSE){

  forecast_date <- unique(forecasts$forecast_date)
  if(length(forecast_date) > 1) stop("multiple forecast dates detected, aborting")

  forecasts <- subset(forecasts, type == "quantile")
  if(length(unique(forecasts$quantile)) != 23) stop("Not all quantiles available.")

  forecasts_wide <- reshape(forecasts, direction = "wide", timevar = "quantile",
                            v.names = "value", idvar = c("location", "target_end_date", "target"))
  forecasts_wide$target_type <- get_target_type(forecasts_wide$target)
  forecasts_wide$type <- NULL

  # determine difference between truth_model and truth_evaluation for last observation:
  last_saturday <- get_last_saturday(forecast_date)

  # get shift between model and evaluation truth at last observed values:
  shift <- get_shift(truth_eval, truth_model, date = last_saturday)

  # add evaluation truths and shift:
  colnames(truth_eval)[colnames(truth_eval) == "value"] <- "truth"
  forecasts_wide <- merge(forecasts_wide, truth_eval[, c("date", "location", "truth", "target")],
                          by.x = c("target_end_date", "location", "target_type"),
                          by.y = c("date", "location", "target"), all.x = TRUE)
  forecasts_wide <- merge(forecasts_wide, shift,
                          by.x = c("location", "target_type"),
                          by.y = c("location", "target"), all.x = TRUE)

  # shift quantile values:
  forecasts_wide[, grepl("value", colnames(forecasts_wide))] <-
    forecasts_wide[, grepl("value", colnames(forecasts_wide))] + forecasts_wide$shift

  # add names of truth data:
  forecasts_wide$truth_data_eval <- name_truth_eval
  forecasts_wide$truth_data_model <- name_truth_model

  coverage_levels <- c(0:9/10, 0.95, 0.98) # median can be treated like the 0% PI

  # get weighted interval widths. Note that this already contains the weighting with alpha/2
  for(coverage in coverage_levels){
    forecasts_wide[, paste0("wgt_iw_", coverage)] <-
      (1 - coverage)/2*(
        forecasts_wide[paste0("value.", 1 - (1 - coverage)/2)] -
          forecasts_wide[paste0("value.", (1 - coverage)/2)]
      )
  }

  # get weighted penalties. Note that this already contains the weighting with alpha/2,
  # which makes the terms simpler
  for(coverage in coverage_levels){
    q_u <- 1 - (1 - coverage)/2
    forecasts_wide[, paste0("wgt_pen_u_", coverage)] <-
      pmax(0, forecasts_wide$truth - forecasts_wide[, paste0("value.", q_u)])

    q_l <- (1 - coverage)/2
    forecasts_wide[, paste0("wgt_pen_l_", coverage)] <-
      pmax(0, forecasts_wide[, paste0("value.", q_l)] - forecasts_wide$truth)
  }

  forecasts_wide$wgt_iw <- rowMeans(forecasts_wide[, grepl("wgt_iw", colnames(forecasts_wide))])
  forecasts_wide$wgt_pen_u <- rowMeans(forecasts_wide[, grepl("wgt_pen_u", colnames(forecasts_wide))])
  forecasts_wide$wgt_pen_l <- rowMeans(forecasts_wide[, grepl("wgt_pen_l", colnames(forecasts_wide))])
  forecasts_wide$wis <- forecasts_wide$wgt_iw + forecasts_wide$wgt_pen_u + forecasts_wide$wgt_pen_l

  # get PIT values:
  forecasts_wide$pit_lower <- forecasts_wide$pit_upper <- NA
  for(i in 1:nrow(forecasts_wide)){
    pit_temp <- compute_pit_values(truth = forecasts_wide$truth[i],
                                   quantiles = unlist(forecasts_wide[i, grepl("value.0", colnames(forecasts_wide))]),
                                   quantile_levels = c(0.01, 0.025, 1:19/20, 0.975, 0.99))
    forecasts_wide$pit_lower[i] <- pit_temp$pit_lower
    forecasts_wide$pit_upper[i] <- pit_temp$pit_upper
  }

  if(!detailed) forecasts_wide <- forecasts_wide[, c("forecast_date", "target_end_date", "location",
                                                     "value.0.025", "value.0.25", "value.0.5", "value.0.75", "value.0.975",
                                                     "truth", "truth_data_eval", "truth_data_model", "shift",
                                                     "wgt_iw", "wgt_pen_u", "wgt_pen_l", "wis",
                                                     "pit_lower", "pit_upper")]
  return(forecasts_wide)
}

# compute upper and lower bounds on PIT values
compute_pit_values <- function(truth, quantiles, quantile_levels, tol = 0.001){
  if(is.na(truth)){
    pit_lower <- pit_upper <- NA
  }else{
    quantiles <- c(-1, quantiles, Inf)
    quantile_levels <- c(0, quantile_levels, 1)
    ind_lower <- max(which(quantiles + tol < truth))
    pit_lower <- quantile_levels[ind_lower]
    tied <- which(abs(truth - quantiles) < tol)
    if(length(tied) > 0){
      pit_upper <- quantile_levels[max(tied) + 1]
    }else{
      pit_upper <- quantile_levels[ind_lower + 1]
    }
  }
  return(list(pit_lower = pit_lower,
              pit_upper = pit_upper))
}

# evaluate point forecasts
evaluate_point <- function(forecasts, name_truth_model, name_truth_eval, truth_model, truth_eval, detailed = FALSE){

  forecast_date <- unique(forecasts$forecast_date)
  if(length(forecast_date) > 1) stop("multiple forecast dates detected, aborting")

  # treat quantile forecasts:
  forecasts <- subset(forecasts, type == "point")
  colnames(forecasts)[colnames(forecasts) == "value"] <- "value.point"
  forecasts$target_type <- get_target_type(forecasts$target)
  forecasts$type <- NULL

  # determine difference between truth_model and truth_evaluation for last observation:
  last_saturday <- get_last_saturday(forecast_date)

  # get shift between model and evaluation truth at last observed values:
  shift <- get_shift(truth_eval, truth_model, date = last_saturday)

  # add evaluation truths and shift:
  colnames(truth_eval)[colnames(truth_eval) == "value"] <- "truth"
  forecasts <- merge(forecasts, truth_eval[, c("date", "location", "truth", "target")],
                     by.x = c("target_end_date", "location", "target_type"),
                     by.y = c("date", "location", "target"), all.x = TRUE)
  forecasts <- merge(forecasts, shift,
                     by.x = c("location", "target_type"),
                     by.y = c("location", "target"), all.x = TRUE)

  # shift quantile values:
  forecasts$value.point <- forecasts$value.point + forecasts$shift

  # add names of truth data:
  forecasts$truth_data_eval <- name_truth_eval
  forecasts$truth_data_model <- name_truth_model

  forecasts$ae <- abs(forecasts$value.point - forecasts$truth)

  if(!detailed) forecasts <- forecasts[, c("forecast_date", "target_end_date", "target", "location",
                                           "value.point",
                                           "truth", "truth_data_eval", "truth_data_model", "shift",
                                           "ae")]
  return(forecasts)
}

# extract last truths; used to append these to evaluation data.frame
get_last_truths <- function(forecasts, name_truth_model, name_truth_eval, truth_model, truth_eval){
  last_saturday <- forecasts$target_end_date[grepl("1 wk ahead", forecasts$target)][1] - 7
  targets_to_include <- unique(get_target_type(forecasts$target))
  locations_to_include <- unique(forecasts$location)
  subs_truth <- subset(truth_eval, date == last_saturday &
                         target %in% targets_to_include &
                         location %in% locations_to_include)

  if(nrow(subs_truth) == 0) return(NULL)

  ret <- data.frame(forecast_date = forecasts$forecast_date[1],
                    target_end_date = last_saturday,
                    target = paste("0 wk ahead", subs_truth$target),
                    target_type = subs_truth$target,
                    location = subs_truth$location,
                    truth_data_eval = name_truth_eval,
                    truth_data_model = name_truth_model,
                    truth = subs_truth$value)

  # get shift between model and evaluation truth at last observed values:
  shift <- get_shift(truth_eval, truth_model, date = last_saturday)
  ret <- merge(ret, shift,
               by.x = c("location", "target_type"),
               by.y = c("location", "target"), all.x = TRUE)
  ret$target_type <- NULL

  ret[, c("value.point", "value.0.025", "value.0.25", "value.0.5", "value.0.75",
          "value.0.975", "ae", "wgt_iw", "wgt_pen_u", "wgt_pen_l", "wis",
          "pit_lower", "pit_upper")] <- NA

  return(ret)
}

# wrapper around evaluation functions for point and quantile forecasts
evaluate_forecasts <- function(forecasts, name_truth_model, name_truth_eval, truth_model, truth_eval){
  eval_point <- evaluate_point(forecasts, name_truth_model, name_truth_eval, truth_model, truth_eval)
  if(any(forecasts$type == "quantile" & length(unique(forecasts$quantile)) >= 23)){
    eval_quantiles <- evaluate_quantiles(forecasts, name_truth_model, name_truth_eval, truth_model, truth_eval, detailed = FALSE)
    eval_point <- merge(eval_point, eval_quantiles, by = c("forecast_date", "target_end_date",
                                                           "location", "truth_data_eval",
                                                           "truth_data_model", "truth", "shift"))
  }else{
    eval_point$value.0.025 <- eval_point$value.0.25 <- eval_point$value.0.5 <-
      eval_point$value.0.75 <- eval_point$value.0.975 <- eval_point$wgt_iw <-
      eval_point$wgt_pen_u <- eval_point$wgt_pen_l <-
      eval_point$wis <- eval_point$pit_lower <- eval_point$pit_upper <- NA
  }
  eval_point <- eval_point[, c("forecast_date", "target_end_date", "target", "location",
                               "truth_data_eval", "truth_data_model", "truth", "shift",
                               paste0("value.", c("point", "0.025", "0.25", "0.5", "0.75", "0.975")),
                               "ae", "wgt_iw", "wgt_pen_u", "wgt_pen_l", "wis",
                               "pit_lower", "pit_upper")]

  last_truths <- get_last_truths(forecasts = forecasts, name_truth_model = name_truth_model,
                                 name_truth_eval = name_truth_eval, truth_model = truth_model,
                                 truth_eval = truth_eval)
  last_truths <- last_truths[, colnames(eval_point)]

  eval_point <- rbind(last_truths, eval_point)

  return(eval_point)
}