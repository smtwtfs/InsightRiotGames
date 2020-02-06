library(shiny)

fluidPage(
  titlePanel("Infinity Loop"),
  
  sidebarPanel(
    textInput("sn", "Summoner ID", value = "mumuyyy"),
    actionButton("player.ana", "Player Analytics", style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
    
    hr(),
    actionButton("player.match", "Show Matches", style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
    
    hr(),
    selectInput(inputId = "mid", "Match ID", choices= ""),
    actionButton("run", "Match Analytics", style="color: #fff; background-color: #337ab7; border-color: #2e6da4")
  ),
  
  mainPanel(
    fluidRow(
      column(3,
             wellPanel(style = "background-color: #fff; border-color: #2c3e50; height: 460px;",
                       htmlOutput("playerBasic"))),
      column(6,
             wellPanel(style = "background-color: #fff; border-color: #2c3e50; height: 460px;",
                       plotOutput("hist"))),
      fluidRow(column(3,
             
             wellPanel(style = "background-color: #fff; border-color: #2c3e50; height: 300px;",
                       htmlOutput("match.info"),
                       tableOutput("metaInfo"),
                       textOutput("time")),
             wellPanel(style = "background-color: #fff; border-color: #2c3e50; height: 150px;",
                       htmlOutput("prediction.title"),
                       h4(htmlOutput("prediction"))))
      )
    ) #for fluidrow
    
  ),
  
  hr(),
  h4("Real-time Query"),
  fluidRow(wellPanel(style = "background-color: #fff; border-color: #2c3e50; height: 300px;",
                     #textOutput("oText")
                     verbatimTextOutput("oText")
  ))
  
  
  
)


### Comments, unused code, etc


# Fraction of atom pair. Not used anymore
# helpText("- OR - : use fraction (atom pair/backbone length)"),
# fluidRow(
#   column(1, checkboxInput("by.am.f", NULL, value = FALSE, width = NULL)),
#   column(9, textInput("am.t.f", "Atom pair thres. frac.", value = 0.2))
# ),