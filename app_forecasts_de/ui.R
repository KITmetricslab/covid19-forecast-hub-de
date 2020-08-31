library(shiny)
library(shinyjs)
library(shinydashboard)


dashboardPage(
  title = "Interactive visualization of COVID19 death forecasts (Germany)",
  dashboardHeader(title = ""),
  skin = "yellow",
  ## Sidebar content
  dashboardSidebar(
    sidebarMenu(
      menuItem("Forecasts", tabName = "forecasts", icon = icon("area-chart")),
      menuItem("Background", tabName = "background", icon = icon("gear")))
  ),
  ## Body content
  dashboardBody(
    tabItems(

      # start tab:
      tabItem(tabName = "forecasts",
              titlePanel("Interactive visualization of forecasts of COVID19 deaths  in Germany"),
              # input elements generated on server side:
              radioButtons("select_stratification", "Show forecasts by:",
                           choices = list("Forecast date" = "forecast_date",
                                          "Forecast horizon" = "horizon"),
                           selected = "forecast_date", inline = TRUE),

              div(style="display:inline-block", uiOutput("inp_select_date")),
              div(style="display:inline-block", selectInput("select_target", label = "Select target:",
                                                            choices = list("cumulative deaths" = "cum death",
                                                                           "incident deaths" = "inc death",
                                                                           "cumulative cases" = "cum case",
                                                                           "incident cases" = "inc case"))),
              div(style="display:inline-block", uiOutput("inp_select_location")),
              uiOutput("inp_select_model"),

              actionButton("show_all", "Show all"),
              actionButton("hide_all", "Hide all"),
              div(style="display:inline-block",
                  checkboxInput("show_pi", label = "Show 95% prediction interval where available", value = TRUE)
              ),
              radioButtons("select_truths", "Select handling of truth data:",
                                 choiceNames = c("Show original forecasts", "Shift all forecasts to ECDC/RKI data", "Shift all forecasts to JHU data"),
                                 choiceValues = c("both", "ECDC", "JHU"),
                                 selected = c("both"), inline = TRUE),

              # checkboxInput("show_model_past", label = "Show past values assumed by models where available", value = TRUE),
              tags$b("Draw rectangle to zoom in, double click to zoom out. Hover over grey line to display numbers (point forecasts and observed)."),
              h3(""),
              # plot:
              plotOutput("plot_forecasts", height = 500,
                         click = "coord_click", hover = "coord_hover",
                         brush = brushOpts(id = "coord_brush", resetOnNew = TRUE),
                         dblclick = clickOpts("coord_dblclick"))
      ),

      # tab on background:
      tabItem(tabName = "background",
              h3("Purpose"),
              "This interactive visualization is part of the",
              tags$a(href = "https://github.com/KITmetricslab/covid19-forecast-hub-de/",
                     "German version of the COVID-19 forecast hub."),
              "The forecasts shown here have been created by various independent international research groups. Links to these",
              "groups, the respective raw data and licences can be found",
              tags$a(href = "https://github.com/KITmetricslab/covid19-forecast-hub-de#teams-generating-forecasts", "here."),
              "The repository also contains the",
              tags$a(href = "https://github.com/KITmetricslab/covid19-forecast-hub-de/tree/master/app_forecasts_de", "code"),
              "behind this app.",
              "This effort is inspired by the",
              tags$a(href = "https://github.com/reichlab/covid19-forecast-hub", "US COVID-19 forecast hub."),
              h3("Creators"),
              "The following persons are contributing to the forecast hub (in alphabetical order): Johannes Bracher,",
              "Jannik Deuschel, Tilmann Gneiting, Konstantin Görgen, Melanie Schienle. Details can be found",
              tags$a(href = "https://github.com/KITmetricslab/covid19-forecast-hub-de#forecast-hub-team", "here."),
              "All contributors are members of the",
              tags$a(href = "https://statistik.econ.kit.edu/index.php", "Chair of Econometrics and Statistics, Karlsruhe Institute of Technology"),
              "and/or the",
              tags$a(href = "https://www.h-its.org/research/cst/", "Computational Statistics Group at Heidelberg Institute of Theoretical Studies."),
              "Note, however, that the forecast hub is not officially endorsed by neither KIT nor HITS.",
              "This Shiny app has been implemented by Johannes Bracher.")
    )
  )
)
