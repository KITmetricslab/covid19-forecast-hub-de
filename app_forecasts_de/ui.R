library(shiny)
library(shinyjs)
library(shinydashboard)


dashboardPage(
  title = "Interactive visualization of COVID19 death forecasts (Germany)",
  dashboardHeader(title = "KIT-ECON"),
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
              titlePanel("Interactive visualization of COVID19 death forecasts (Germany)"),
              uiOutput("inp_select_date"),
              uiOutput("inp_select_model"),
              checkboxGroupInput("select_truths", "Select truth data to display:",
                                 choiceNames = c("RKI", "ECDC", "JHU"),
                                 choiceValues = c("RKI", "ECDC", "JHU"),
                                 selected = "ECDC", inline = TRUE),
              checkboxInput("show_pi", label = "Show 90% prediction interval where available", value = TRUE),
              checkboxInput("show_model_past", label = "Show past values assumed by models where available", value = TRUE),
              plotOutput("plot_forecasts", height = 500)
      ),

      # tab with info on disease:
      tabItem(tabName = "background")
    )
  )
)
