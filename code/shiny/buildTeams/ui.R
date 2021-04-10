require(shiny)

shinyUI(navbarPage(
  title="PENGUIN LEAGUE TEAM SELECTION", 
  inverse=TRUE,
  
  tabPanel(
    title="Build Teams",
    sidebarLayout(
      sidebarPanel(
        uiOutput("whichRoster"),
        br(),
        wellPanel(uiOutput("selections"))
      ),
      
      mainPanel(
        uiOutput("tabHeader"),
        actionButton('dl', 'Save Roster'),
        br(),
        span(strong(uiOutput("saveYesMess"), style="color:blue")),
        span(strong(uiOutput("saveErrMess"), style="color:red")),
        span(strong(uiOutput("dupMess"), style="color:red")),
        br(),
        dataTableOutput("playerTable")
      )
    )
  )
))


