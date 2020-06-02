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
                   timezero = as.Date(input$select_date),
                   models = input$select_models,
                   selected_truth = input$select_truths,
                   start = as.Date("2020-03-01"), end = Sys.Date() + 28,
                   ylim = c(0, 12000),
                   col = cols_models[input$select_models], alpha.col = 0.5,
                   pch_truths = pch_truths,
                   legend = FALSE,
                   show_pi = input$show_pi,
                   add_model_past = input$show_model_past)
    legend("topleft", col = cols_models, legend = models, lty = 0, bty = "n",
           pch = ifelse(models %in% input$select_models, 16, 1), pt.cex = 1.3)
    legend("top", col = "black", legend = c("ECDC/RKI", "JHU"), lty = 0, bty = "n",
           pch = ifelse(truths %in% input$select_truths, pch_truths, pch_truth_empty),
           pt.cex = 1.3)
  })

})
