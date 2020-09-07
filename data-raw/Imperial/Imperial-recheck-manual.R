# Independently ee-computing some quantiles for Imperial
# Johannes Bracher

# to be run in directory where file lies
# setwd("/home/johannes/Documents/COVID/covid19-forecast-hub-de/data-raw/Imperial")

# choose a date for which to check:
forecast_date <- as.Date("2020-05-03")

# get raw data:
dat_raw <- readRDS(paste0("ensemble_model_predictions_", forecast_date, ".rds"))
# get processed data:
dat_processed <- read.csv(paste0("../../data-processed/Imperial-ensemble1/", forecast_date,
                          "-Germany-Imperial-ensemble1.csv"))
dat_processed$forecast_date <- as.Date(dat_processed$forecast_date)
dat_processed$target_end_date <- as.Date(dat_processed$target_end_date)


# restrict to Germany:
dat_raw <- dat_raw$`2020-05-03`$Germany

# check if the two contained ensembles are the same
all.equal(dat_raw$si_1, dat_raw$si_2)
# [1] "Mean relative difference: 0.156786"


# get truth data (JHU):
truth <- read.csv("../../data-truth/truth-Cumulative Deaths_Germany.csv")
truth$date <- as.Date(truth$date)

# get count at forecast date:
truth_forecast_date <- truth$value[truth$date == forecast_date]

# compute cumulative sums from samples:
dat_raw$si_1_cum <- dat_raw$si_1
dat_raw$si_2_cum <- dat_raw$si_2
for(i in 1:nrow(dat_raw$si_1)){
  dat_raw$si_1_cum[i, ] <- cumsum(dat_raw$si_1[i, ]) + truth_forecast_date
  dat_raw$si_2_cum[i, ] <- cumsum(dat_raw$si_2[i, ]) + truth_forecast_date
}

# compare quantiles:
tg_end_date <- forecast_date + 6

ps <- c(0.1, 0.5, 0.9)
quantile(dat_raw$si_2_cum[, as.character(tg_end_date)], probs = ps)
quantile(dat_raw$si_2[, as.character(tg_end_date)], probs = ps)

subset(dat_processed, target_end_date %in% tg_end_date & quantile %in% c(0.1, 0.5, 0.9))
# cumulative seem alright, but week-ahead incident deaths seem faulty

# get LANL for comparison:
dat_processed_lanl <- read.csv(paste0("../../data-processed/LANL-GrowthRate/", forecast_date,
                                 "-Germany-LANL-GrowthRate.csv"))
dat_processed_lanl$forecast_date <- as.Date(dat_processed_lanl$forecast_date)
dat_processed_lanl$target_end_date <- as.Date(dat_processed_lanl$target_end_date)

subset(dat_processed_lanl, target_end_date %in% tg_end_date & quantile %in% c(0.1, 0.5, 0.9))
