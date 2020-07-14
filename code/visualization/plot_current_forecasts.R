# setwd("/home/johannes/Documents/COVID/covid19-forecast-hub-de/code/visualization")

source("../../app_forecasts_de/code/app_functions.R")

Sys.setlocale(category = "LC_TIME", locale = "en_US.UTF8")

# names of models which are not to be included in visualization:
models_to_exclude <- c("LeipzigIMISE-rkiV1", "LeipzigIMISE-ecdcV1", "Imperial-ensemble1")

forecasts_to_plot <- read.csv("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/app_forecasts_de/data/forecasts_to_plot.csv",
                              stringsAsFactors = FALSE)
forecasts_to_plot$forecast_date <- as.Date(forecasts_to_plot$forecast_date)
forecasts_to_plot$timezero <- as.Date(forecasts_to_plot$timezero)
forecasts_to_plot$target_end_date <- as.Date(forecasts_to_plot$target_end_date)
forecasts_to_plot <- subset(forecasts_to_plot, grepl("cum", target) &
                              !(model %in% models_to_exclude) &
                              location == "GM")



# get timezeros, i.e. Mondays on which forecasts were made:
timezeros <- as.character(sort(unique(forecasts_to_plot$timezero), decreasing = TRUE))

# get names of models which appear in the data:
models <- sort(as.character(unique(forecasts_to_plot$model)))



# assign colours to models (currently restricted to eight):
cols_models <- c("#1B9E77", "#D95F02", "#7570B3", "#E7298A", "#66A61E", "#E6AB02",
                 "#A6761D", "#666666", "cyan3", "firebrick1", "tan1")
cols_models <- cols_models[seq_along(models)]
names(cols_models) <- models

# get truth data:
dat_truth <- list()
# ECDC:
dat_truth$ECDC <- read.csv("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/ECDC/truth_ECDC-Cumulative%20Deaths_Germany.csv",
                           stringsAsFactors = FALSE)
dat_truth$ECDC$date <- as.Date(dat_truth$ECDC$date)
# JHU;
dat_truth$JHU <- read.csv("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/JHU/truth_JHU-Cumulative%20Deaths_Germany.csv",
                          stringsAsFactors = FALSE)
dat_truth$JHU$date <- as.Date(dat_truth$JHU$date)

# define point shapes for different truth data sources:
truths <- names(dat_truth)
pch_full <- c(17, 16)
pch_empty <- c(2, 1)
names(pch_full) <- names(pch_empty) <- truths

# get data on which model uses which truth data:
truth_data_used0 <- read.csv("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/app_forecasts_de/data/truth_data_use.csv",
                             stringsAsFactors = FALSE)
truth_data_used <- truth_data_used0$truth_data
names(truth_data_used) <- truth_data_used0$model

dates <- seq(from = Sys.Date() - 7, to = Sys.Date() - 1, by = 1)
timezero <- dates[which(weekdays(dates) == "Monday")]

# subset forecasts to those for the shown forecast date:
subs_current <- forecasts_to_plot[forecasts_to_plot$forecast_date >= (timezero - 7), ]
# get last truth values shown in plot:
last_truths <- dat_truth[["ECDC"]]$value[dat_truth$ECDC$date >= Sys.Date() - 32]
# compute ylim from these values:
ylim <- c(0.9*min(last_truths), 1.05*max(subs_current$value))

png("current_forecasts.png", width = 720, height = 360)
# plot:
plot_forecasts(forecasts_to_plot = forecasts_to_plot,
               truth = dat_truth,
               timezero = timezero,
               models = models,
               truth_data_used = truth_data_used,
               selected_truth = c("ECDC", "JHU"),
               start = Sys.Date() - 32,
               end = Sys.Date() + 28,
               ylim = ylim,
               col = cols_models,
               alpha.col = 0.5,
               pch_truths = pch_full,
               pch_forecasts = pch_empty,
               legend = FALSE,
               show_pi = TRUE,
               add_model_past = FALSE)
title("Forecasts of total number of deaths from COVID19 in Germany")
# add legends manually:
legend("topleft", col = cols_models, legend = models, lty = 0, bty = "n",
       pch = pch_full[truth_data_used[models]],
       pt.cex = 1.3)
legend("bottomleft", col = "black", legend = c("ECDC/RKI", "JHU"), lty = 0, bty = "n",
       pch = pch_full, pt.cex = 1.3)
dev.off()

