# simple plots of national level forecasts in a submitted file.

# unix command to change language
Sys.setlocale(category = "LC_TIME", locale = "en_US.UTF8")

# command that should work cross-platform
# Sys.setlocale(category = "LC_TIME","English")

# get functions for plotting:
source("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/code/app_check_submission/plot_functions.R")

# get truth data:
dat_truth0 <- read.csv("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/app_forecasts_de/data/truth_to_plot_ecdc.csv",
                      colClasses = list("date" = "Date"), stringsAsFactors = FALSE)



path_forecast <- "https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-processed/LANL-GrowthRate/2021-02-21-Germany-LANL-GrowthRate.csv"
dat_forecasts <- read_week_ahead(path_forecast)
forecast_date <- as.Date(get_date_from_filename(basename(path_forecast)))

# re-format truth to fit format required by function:
dat_truth <- list("inc death" = dat_truth0[, c("date", "location", "inc_death")],
                  "cum death" = dat_truth0[, c("date", "location", "cum_death")],
                  "inc case" = dat_truth0[, c("date", "location", "inc_case")],
                  "cum case" = dat_truth0[, c("date", "location", "cum_case")])
for(i in seq_along(dat_truth)) colnames(dat_truth[[i]]) <- c("date", "location", "value")

# determine which targets are available:
contained_targets <- c(if(any(grepl("inc death", dat_forecasts$target))) "inc death",
                       if(any(grepl("cum death", dat_forecasts$target))) "cum death",
                       if(any(grepl("inc case", dat_forecasts$target))) "inc case",
                       if(any(grepl("cum case", dat_forecasts$target))) "cum case")

# determine which locations are available:
contained_locations <- intersect(c("PL", "GM"), dat_forecasts$location)

# number of plots to generate:
n_plots <- length(contained_locations)*length(contained_targets)

# generate plot:

png("plot.png", width = 450, height = 250*n_plots)
par(mfrow = c(n_plots, 1))
for(location in contained_locations){
  for(target in contained_targets){
    try({
      plot_forecast(dat_forecasts,
                    forecast_date = forecast_date,
                    location = location,
                    truth = dat_truth[[target]],
                    target_type = target,
                    levels_coverage = c(0.5, 0.95),
                    start = as.Date(forecast_date) - 49,
                    end = as.Date(forecast_date) + 28)
      title(paste(location, ", ", target))
      legend("topleft", legend = c("50%PI", "95% PI"), col = c("#699DAF", "#D3D3D3"),
             pch = 15, bty = "n")
      
    })
  }
}
dev.off()
