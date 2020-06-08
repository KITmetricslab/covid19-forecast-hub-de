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
              titlePanel("Interactive visualization of forecasts of COVID19 deaths  in Germany (in development)"),
              uiOutput("inp_select_date"),
              uiOutput("inp_select_model"),
              checkboxGroupInput("select_truths", "Select truth data to display:",
                                 choiceNames = c("ECDC/RKI", "JHU"),
                                 choiceValues = c("ECDC", "JHU"),
                                 selected = "ECDC", inline = TRUE),
              checkboxInput("show_pi", label = "Show 95% prediction interval where available", value = TRUE),
              checkboxInput("show_model_past", label = "Show past values assumed by models where available", value = TRUE),
              tags$b("Draw rectangle to zoom in, double click to zoom out. Hover over grey line to display numbers (point forecasts and observed)."),
              h3(""),
              plotOutput("plot_forecasts", height = 500,
                         click = "coord_click", hover = "coord_hover",
                         brush = brushOpts(id = "coord_brush", resetOnNew = TRUE),
                         dblclick = clickOpts("coord_dblclick"))
      ),

      # tab with info on disease:
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
