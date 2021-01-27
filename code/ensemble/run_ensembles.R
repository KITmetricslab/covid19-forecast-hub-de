# Generating ensemble forecasts for (incident, cumulative) x (cases, deaths)

# Johannes Bracher, August 2020

# setwd("/home/johannes/Documents/Projects/fork_covid19-forecast-hub-de/code/ensemble")

Sys.setlocale(category = "LC_TIME", locale = "en_US.UTF8") # set locale to English

source("../../code/R/auxiliary_functions.R")
source("../../code/R/evaluation_functions.R")
source("../../code/R/ensemble_functions.R")

directory_data_processed <- "../../data-processed"

state_codes_gm <- read.csv("../../template/state_codes_germany.csv")
state_codes_pl <- read.csv("../../template/state_codes_poland.csv")


countries <- c(GM = "Germany", PL = "Poland")
locations <- list("Germany" = state_codes_gm$state_code,
                  "Poland" = state_codes_pl$state_code)


# set date:
forecast_date <- as.Date("2021-01-25")
if(!weekdays(forecast_date) == "Monday") stop("forecast_date should be a Monday.")


# read in truth data:
dat_truth <- list()
dat_truth$JHU <- truth_to_long(read.csv("../../app_forecasts_de/data/truth_to_plot_jhu.csv",
                                        colClasses = list("date" = "Date")))
dat_truth$ECDC <- truth_to_long(read.csv("../../app_forecasts_de/data/truth_to_plot_ecdc.csv",
                                         colClasses = list("date" = "Date")))
dat_truth$ECDC <- subset(dat_truth$ECDC, location %in% c("GM", "PL"))

# read in csv on which models to include:
models_to_include <- read.csv(paste0("included_models/included_models-", forecast_date, ".csv"),
                              stringsAsFactors = FALSE)

# read in csv on truth data use for different models:
truth_data_use <- read.csv("../../app_forecasts_de/data/truth_data_use_detailed.csv",
                           stringsAsFactors = FALSE)

# read in past evaluation results:
eval <- read.csv("../../evaluation/evaluation-ECDC.csv",
                 colClasses = list("timezero" = "Date",
                                   "forecast_date" = "Date",
                                   "target_end_date" = "Date"))


summary_inverse_wis_weights <- NULL

for(country in countries){
  for(target_type in c("case", "death")){
    # undebug(compute_ensemble_multiple_regions)
    # median ensemble:
    median_ensemble_inc <-
      compute_ensemble_multiple_regions(forecast_date = forecast_date,
                                        location = locations[[country]],
                                        country = country,
                                        target_type = target_type,
                                        inc_or_cum = "inc",
                                        dat_truth = dat_truth,
                                        ensemble_type = "median",
                                        models_to_include = models_to_include,
                                        truth_data_use = truth_data_use,
                                        eval = NULL,
                                        directory_data_processed = "../../data-processed")
    
    median_ensemble_cum <-
      compute_ensemble_multiple_regions(forecast_date = forecast_date,
                                        location = locations[[country]],
                                        country = country,
                                        target_type = target_type,
                                        inc_or_cum = "cum",
                                        dat_truth = dat_truth,
                                        ensemble_type = "median",
                                        models_to_include = models_to_include,
                                        truth_data_use = truth_data_use,
                                        eval = NULL,
                                        directory_data_processed = "../../data-processed")
    
    median_ensemble <- rbind(median_ensemble_inc$ensemble,
                             median_ensemble_cum$ensemble)
    
    write.csv(median_ensemble,
              paste0("../../data-processed/KITCOVIDhub-median_ensemble/",
                     forecast_date, "-", country, "-",
                     "KITCOVIDhub-median_ensemble",
                     ifelse(target_type == "case", "-case", ""),
                     ".csv"),
              row.names = FALSE)
    
    # mean ensemble:
    mean_ensemble_inc <-
      compute_ensemble_multiple_regions(forecast_date = forecast_date,
                                        location = locations[[country]],
                                        country = country,
                                        target_type = target_type,
                                        inc_or_cum = "inc",
                                        dat_truth = dat_truth,
                                        ensemble_type = "mean",
                                        models_to_include = models_to_include,
                                        truth_data_use = truth_data_use,
                                        eval = NULL,
                                        directory_data_processed = "../../data-processed")
    
    mean_ensemble_cum <-
      compute_ensemble_multiple_regions(forecast_date = forecast_date,
                                        location = locations[[country]],
                                        country = country,
                                        target_type = target_type,
                                        inc_or_cum = "cum",
                                        dat_truth = dat_truth,
                                        ensemble_type = "mean",
                                        models_to_include = models_to_include,
                                        truth_data_use = truth_data_use,
                                        eval = NULL,
                                        directory_data_processed = "../../data-processed")
    
    mean_ensemble <- rbind(mean_ensemble_inc$ensemble, mean_ensemble_cum$ensemble)
    
    write.csv(mean_ensemble,
              paste0("../../data-processed/KITCOVIDhub-mean_ensemble/",
                     forecast_date, "-", country, "-",
                     "KITCOVIDhub-mean_ensemble",
                     ifelse(target_type == "case", "-case", ""),
                     ".csv"),
              row.names = FALSE)
    
    # inverse WIS ensemble:
    inverse_wis_ensemble_inc <-
      compute_ensemble_multiple_regions(forecast_date = forecast_date,
                                        location = locations[[country]],
                                        country = country,
                                        target_type = target_type,
                                        inc_or_cum = "inc",
                                        dat_truth = dat_truth,
                                        ensemble_type = "inverse_wis",
                                        models_to_include = models_to_include,
                                        truth_data_use = truth_data_use,
                                        eval = eval,
                                        directory_data_processed = "../../data-processed")
    
    inverse_wis_ensemble_cum <-
      compute_ensemble_multiple_regions(forecast_date = forecast_date,
                                        location = locations[[country]],
                                        country = country,
                                        target_type = target_type,
                                        inc_or_cum = "cum",
                                        dat_truth = dat_truth,
                                        ensemble_type = "inverse_wis",
                                        models_to_include = models_to_include,
                                        truth_data_use = truth_data_use,
                                        eval = eval,
                                        directory_data_processed = "../../data-processed")
    
    inverse_wis_ensemble <- list(rbind(inverse_wis_ensemble_inc$ensemble, inverse_wis_ensemble_cum$ensemble))
    
    write.csv(inverse_wis_ensemble,
              paste0("../../data-processed/KITCOVIDhub-inverse_wis_ensemble/",
                     forecast_date, "-", country, "-",
                     "KITCOVIDhub-inverse_wis_ensemble",
                     ifelse(target_type == "case", "-case", ""),
                     ".csv"),
              row.names = FALSE)
    
    weights_invers_wis_ensemble_inc <- cbind(target = paste("inc", target_type), inverse_wis_ensemble_inc$weights)
    weights_invers_wis_ensemble_cum <- cbind(target = paste("cum", target_type), inverse_wis_ensemble_cum$weights)
    
    if(is.null(weights_invers_wis_ensemble_inc)){
      summary_inverse_wis_weights <- rbind(weights_invers_wis_ensemble_inc,
                                           weights_invers_wis_ensemble_cum)
    }else{
      summary_inverse_wis_weights <- rbind(summary_inverse_wis_weights,
                                           weights_invers_wis_ensemble_inc,
                                           weights_invers_wis_ensemble_cum)
    }
  }
}

write.csv(summary_inverse_wis_weights,
          file = paste0("inverse_wis_weights/inverse_wis_weights-", forecast_date, ".csv"),
          row.names = FALSE)

