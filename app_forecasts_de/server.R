library(shiny)
library(RColorBrewer)

# read in plotting functions etc
source("code/app_functions.R")

# Choose the right option, depending on your system:
# ----------------------------------------------------------------------------

# unix command
Sys.setlocale(category = "LC_TIME", locale = "en_US.UTF8")

# command that should work cross-platform
# Sys.setlocale(category = "LC_TIME","English")

# ----------------------------------------------------------------------------

# read in data set compiled specificaly for Shiny app:
forecasts_to_plot <- read.csv("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/app_forecasts_de/data/forecasts_to_plot.csv",
                              stringsAsFactors = FALSE)
forecasts_to_plot$forecast_date <- as.Date(forecasts_to_plot$forecast_date)
forecasts_to_plot$timezero <- as.Date(forecasts_to_plot$timezero)
forecasts_to_plot$target_end_date <- as.Date(forecasts_to_plot$target_end_date)

# exclude some models because used data is neither ECDC nor JHU:
models_to_exclude <- c("LeipzigIMISE-rkiV1", "LeipzigIMISE-ecdcV1", "Imperial-ensemble1")
forecasts_to_plot <- subset(forecasts_to_plot, !(model %in% models_to_exclude) )

# get timezeros, i.e. Mondays on which forecasts were made:
timezeros <- as.character(sort(unique(forecasts_to_plot$timezero), decreasing = TRUE))

# read in location codes (FIPS):
location_codes <- read.csv("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/template/state_codes_germany.csv",
                           stringsAsFactors = FALSE)
locations <- location_codes$state_code
names(locations) <- location_codes$state_name
# re-order:
locations <- locations[locations != "GM"]
locations <- locations[order(names(locations))]
names(locations) <- paste0(".. ", names(locations))
locations <- c("Germany" = "GM", "Poland" = "PL", locations)

# get names of models which appear in the data:
models <- sort(as.character(unique(forecasts_to_plot$model)))

# assign colours to models (currently restricted to eight):
cols_models <- c(brewer.pal(n = 8, name = 'Dark2'), "cyan3", "firebrick1", "tan1")
cols_models <- cols_models[seq_along(models)]
names(cols_models) <- models

# get truth data:
dat_truth <- list()
dat_truth$JHU <- get_truths(file_cum_death = "https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/JHU/truth_JHU-Cumulative%20Deaths_Germany.csv",
                            file_inc_death = "https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/JHU/truth_JHU-Incident%20Deaths_Germany.csv",
                            file_cum_case = "https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/JHU/truth_JHU-Cumulative%20Cases_Germany.csv",
                            file_inc_case = "https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/JHU/truth_JHU-Incident%20Cases_Germany.csv")

dat_truth$ECDC <- get_truths(file_cum_death = "https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/RKI/truth_RKI-Cumulative%20Deaths_Germany.csv",
                             file_inc_death = "https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/RKI/truth_RKI-Incident%20Deaths_Germany.csv",
                             file_cum_case = "https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/RKI/truth_RKI-Cumulative%20Cases_Germany.csv",
                             file_inc_case = "https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/RKI/truth_RKI-Incident%20Cases_Germany.csv")


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

# Define server logic:
shinyServer(function(input, output) {

  # reactive values to store various mouse coordinates (prefer this to using coordinates
  # directly as NULL values can be avoided):
  coords <- reactiveValues()
  # single click:
  observe({
    input$coord_click
    if(!is.null(input$coord_click)){
      coords$click <- input$coord_click
    }
  })
  # brush, i.e. drawing rectangle:
  observe({
    if(!is.null(input$coord_brush)){
      coords$brush <- list(xlim = as.Date(c(input$coord_brush$xmin, input$coord_brush$xmax), origin = "1970-01-01"),
                           ylim = c(input$coord_brush$ymin, input$coord_brush$ymax))
    }
    if(!is.null(input$coord_dblclick)){
      coords$brush <- list(xlim = NULL, ylim = NULL)
    }
  })
  # hover:
  observe({
    input$coord_hover
    if(!is.null(input$coord_hover)){
      coords$hover <- input$coord_hover
    }
  })

  # reactive values to store options selected through mouse coordinates:
  selected <- reactiveValues()
  # target_end_date selected by hovering, along with associated truth and point forecast values
  observe({
    if(!is.null(coords$hover$x)){
      # click_date <- as.Date(round(coords$click$x), origin = "1970-01-01")
      hover_date <- as.Date(round(coords$hover$x), origin = "1970-01-01")
      if(weekdays(hover_date) == "Saturday"){
        # get dates
        selected$target_end_date <- hover_date
        # get point estimates:
        subs <- subset(forecasts_to_plot,
                       timezero == as.Date(input$select_date) &
                         grepl(input$select_target, target) &
                         location == input$select_location &
                         target_end_date == hover_date & type %in% c("point", "observed"))
        point_pred <- data.frame(model = models)
        point_pred <- merge(point_pred, subs, by = "model", all.x = TRUE)
        selected$point_pred <- round(point_pred$value)

        # get truths:
        selected$truths <- c(subset(dat_truth$ECDC, date == as.Date(selected$target_end_date) &
                                      location == input$select_location)[, input$select_target],
                             subset(dat_truth$JHU, date == as.Date(selected$target_end_date) &
                                      location == input$select_location)[, input$select_target])
      }else{
        selected$target_end_date <- NULL
        selected$point_pred <- NULL
        selected$truths <- NULL
      }
    }
  })

  # input element for selection of models to show in plot:
  output$inp_select_model <- renderUI(
    checkboxGroupInput("select_models", "Select models to display:",
                       choiceNames = models,
                       choiceValues = models,
                       selected = models, inline = TRUE)
  )

  # input element to select forecast date:
  output$inp_select_date <- renderUI(
    selectInput("select_date", "Select forecast date:", choices = timezeros)
  )

  # input element to select location:
  output$inp_select_location <- renderUI(
    selectInput("select_location", "Select location:", choices = locations, selected = "GM")
  )

  # plot (all wrapped up in function plot_forecasts)
  output$plot_forecasts <- renderPlot({
    par(mar = c(4.5, 5, 4, 2), las = 1)

    # determine ylim:
    yl <-
      if(is.null(coords$brush$ylim)){
        if(is.null(input$select_location)){
          c(0, 12000)
        }else{
          c(0, 1.2*max(dat_truth$ECDC[dat_truth$ECDC$location == input$select_location, input$select_target]))
        }
      }else{
        coords$brush$ylim
      }

    plot_forecasts(forecasts_to_plot = forecasts_to_plot,
                   truth = dat_truth,
                   target = input$select_target,
                   timezero = if(is.null(input$select_date)){as.Date("2020-06-01")}else{as.Date(input$select_date)},
                   models = input$select_models,
                   location = input$select_location,
                   truth_data_used = truth_data_used,
                   selected_truth = input$select_truths,
                   start = if(is.null(coords$brush$xlim)){
                     as.Date("2020-04-01")
                   }else{
                     coords$brush$xlim[1]
                   },
                   end = if(is.null(coords$brush$xlim)){
                     Sys.Date() + 28
                   }else{
                     coords$brush$xlim[2]
                   },
                   ylim = yl,
                   col = cols_models[input$select_models], alpha.col = 0.5,
                   pch_truths = pch_full,
                   pch_forecasts = pch_empty,
                   legend = FALSE,
                   show_pi = input$show_pi,
                   add_model_past = input$show_model_past,
                   highlight_target_end_date = selected$target_end_date)
    abline(h = 0)

    # add legends manually:
    legend("topleft", col = cols_models, legend = paste0(models, ": ", selected$point_pred), lty = 0, bty = "n",
           pch = ifelse(models %in% input$select_models,
                        pch_full[truth_data_used], pch_empty[truth_data_used]),
           pt.cex = 1.3)
    legend("top", col = "black", legend = paste0(c("ECDC/RKI", "JHU"), ": ", selected$truths), lty = 0, bty = "n",
           pch = ifelse(truths %in% input$select_truths, pch_full, pch_empty),
           pt.cex = 1.3)

    # add title manually:
    title(names(locations)[which(locations == input$select_location)])
  })

})
