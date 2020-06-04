#
# This is the server logic of a Shiny web application. You can run the
# application by clicking 'Run App' above.
#
# Find out more about building applications with Shiny here:
#
#    http://shiny.rstudio.com/
#

library(shiny)
library(RColorBrewer)

source("code/app_functions.R")

# Choose the right option, depending on your system:
# ----------------------------------------------------------------------------

# unix command
Sys.setlocale(category = "LC_TIME", locale = "en_US.UTF8")

# command that should work cross-platform
# Sys.setlocale(category = "LC_TIME","English")

# ----------------------------------------------------------------------------

forecasts_to_plot <- read.csv("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/app_forecasts_de/data/forecasts_to_plot.csv")
forecasts_to_plot$forecast_date <- as.Date(forecasts_to_plot$forecast_date)
forecasts_to_plot$timezero <- as.Date(forecasts_to_plot$timezero)
forecasts_to_plot$target_end_date <- as.Date(forecasts_to_plot$target_end_date)
forecasts_to_plot <- subset(forecasts_to_plot, grepl("cum", target))

# get timezeros
timezeros <- as.character(sort(unique(forecasts_to_plot$timezero), decreasing = TRUE))

# get models:
models <- sort(as.character(unique(forecasts_to_plot$model)))
cols_models <- brewer.pal(n = 8, name = 'Dark2')
names(cols_models) <- models

# get truth data:

dat_truth <- list()
# dat_truth$RKI <- read.csv("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/RKI/truth-Cumulative%20Deaths_Germany.csv", stringsAsFactors = FALSE)
# dat_truth$RKI$date <- as.Date(dat_truth$RKI$date)
dat_truth$ECDC <- read.csv("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/ECDC/truth_ECDC-Cumulative%20Deaths_Germany.csv", stringsAsFactors = FALSE)
dat_truth$ECDC$date <- as.Date(dat_truth$ECDC$date)
dat_truth$JHU <- read.csv("https://raw.githubusercontent.com/KITmetricslab/covid19-forecast-hub-de/master/data-truth/JHU/truth_JHU-Cumulative%20Deaths_Germany.csv", stringsAsFactors = FALSE)
dat_truth$JHU$date <- as.Date(dat_truth$JHU$date)

truths <- names(dat_truth)
pch_truths <- c(17, 16)
pch_truth_empty <- c(2, 1)
names(pch_truths) <- truths

# Define server logic required to draw a histogram
shinyServer(function(input, output) {

  coords <- reactiveValues(click = NULL)
  observe({
    input$coord_click
    if(!is.null(input$coord_click)){
      coords$click <- input$coord_click
    }
  })
  observe({
    if(!is.null(input$coord_brush)){
      coords$brush <- list(xlim = as.Date(c(input$coord_brush$xmin, input$coord_brush$xmax), origin = "1970-01-01"),
                                 ylim = c(input$coord_brush$ymin, input$coord_brush$ymax))
    }
    if(!is.null(input$coord_dblclick)){
      coords$brush <- list(xlim = NULL, ylim = NULL)
    }
  })
  observe({
    input$coord_hover
    if(!is.null(input$coord_hover)){
      coords$hover <- input$coord_hover
    }
  })

  selected <- reactiveValues()
  observe({
    if(!is.null(coords$hover$x)){
      hover_date <- as.Date(round(coords$hover$x), origin = "1970-01-01")
      if(weekdays(hover_date) == "Saturday"){
        # get date
        selected$target_end_date <- hover_date
        # get point estimates:
        subs <- subset(forecasts_to_plot,
                       timezero == as.Date(input$select_date) &
                       target_end_date == hover_date & type %in% c("point", "observed"))

        point_pred <- data.frame(model = models)
        point_pred <- merge(point_pred, subs, by = "model", all.x = TRUE)
        selected$point_pred <- round(point_pred$value)

        selected$truths <- c(subset(dat_truth$JHU, date == as.Date(selected$target_end_date))$value,
                             subset(dat_truth$ECDC, date == as.Date(selected$target_end_date))$value)
      }else{
        selected$target_end_date <- NULL
        selected$point_pred <- NULL
        selected$truths <- NULL
      }
    }
  })

  output$inp_select_model <- renderUI(
    checkboxGroupInput("select_models", "Select models to display:",
                       choiceNames = models,
                       choiceValues = models,
                       selected = models, inline = TRUE)
  )

  output$inp_select_date <- renderUI(
    selectInput("select_date", "Select forecast date:", choices = timezeros)
  )

  output$plot_forecasts <- renderPlot({
    par(las = 1)
    plot_forecasts(forecasts_to_plot = forecasts_to_plot,
                   truth = dat_truth,
                   timezero = if(is.null(input$select_date)){as.Date("2020-06-01")}else{as.Date(input$select_date)},
                   models = input$select_models,
                   selected_truth = input$select_truths,
                   start = if(is.null(coords$brush$xlim)){
                     as.Date("2020-03-01")
                   }else{
                     coords$brush$xlim[1]
                   },
                   end = if(is.null(coords$brush$xlim)){
                     Sys.Date() + 28
                   }else{
                     coords$brush$xlim[2]
                   },
                   # start = as.Date("2020-03-01"),
                   # end = Sys.Date() + 28,
                   ylim = if(is.null(coords$brush$ylim)){
                     c(0, 12000)
                   }else{
                     coords$brush$ylim
                   },
                   col = cols_models[input$select_models], alpha.col = 0.5,
                   pch_truths = pch_truths,
                   legend = FALSE,
                   show_pi = input$show_pi,
                   add_model_past = input$show_model_past,
                   highlight_target_end_date = selected$target_end_date)
    legend("topleft", col = cols_models, legend = paste0(models, ": ", selected$point_pred), lty = 0, bty = "n",
           pch = ifelse(models %in% input$select_models, 16, 1), pt.cex = 1.3)
    legend("top", col = "black", legend = paste0(c("ECDC/RKI", "JHU"), ": ", selected$truths), lty = 0, bty = "n",
           pch = ifelse(truths %in% input$select_truths, pch_truths, pch_truth_empty),
           pt.cex = 1.3)
  })

})
