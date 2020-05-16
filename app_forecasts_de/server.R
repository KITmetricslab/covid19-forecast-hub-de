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

forecasts_to_plot <- read.csv("data/forecasts_to_plot.csv")
forecasts_to_plot$forecast_date <- as.Date(forecasts_to_plot$forecast_date)
forecasts_to_plot$timezero <- as.Date(forecasts_to_plot$timezero)
forecasts_to_plot$target_end_date <- as.Date(forecasts_to_plot$target_end_date)

# get truth data:
dat_truth <- read.csv("../data-truth/truth-Cumulative Deaths_Germany.csv")
dat_truth$date <- as.Date(dat_truth$date)

cols <- c("red", "blue", "darkgreen", "purple")
models <- sort(as.character(unique(forecasts_to_plot$model)))
timezeros <- as.character(sort(unique(forecasts_to_plot$timezero), decreasing = TRUE))

cols <- brewer.pal(n = 8, name = 'Dark2')
names(cols) <- models


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
                   start = as.Date("2020-03-01"), end = Sys.Date() + 28,
                   ylim = c(0, 12000),
                   col = cols[input$select_models], alpha.col = 0.5,
                   legend = FALSE,
                   show_pi = input$show_pi,
                   add_model_past = input$show_model_past)
    legend("topleft", col = cols, legend = models, lty = 0, bty = "n",
           pch = ifelse(models %in% input$select_models, 16, 1), pt.cex = 1.3)
  })

})
