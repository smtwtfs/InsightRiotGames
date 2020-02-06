library(shiny)

fluidPage(
  titlePanel("Infinity Loop"),
  
  sidebarPanel(
    textInput("sn", "Summoner ID", value = "mumuyyy"),
    actionButton("player.ana", "Player Analytics & Show Matches", style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
    
    #hr(),
    #actionButton("player.match", "Show Matches", style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
    
    hr(),
    selectInput(inputId = "mid", "Match ID", choices= ""),
    actionButton("run", "Match Analytics", style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
    hr(),
    passwordInput("key", "API Key", value = "RGAPI-d402326b-fe47-4fac-b9fb-12bda90c47db", width = NULL, placeholder = "RGAPI-652fd4a4-XXXX-XXXX-XXXX-XXXXXXXXXXXXX"),
    hr(),
    h5(shiny::HTML("<p>Example Summoner:</p><p>AnDa</p><p>unth3</p><p>REDMAN00687</p>"))
  ),
  
  mainPanel(
    fluidRow(
      column(3,
             wellPanel(style = "background-color: #fff; border-color: #2c3e50; height: 550px;",
                       htmlOutput("playerBasic"))),
      column(6,
             wellPanel(style = "background-color: #fff; border-color: #2c3e50; height: 550px;",
                       plotOutput("hist"))),
      fluidRow(column(3,
             
             wellPanel(style = "background-color: #fff; border-color: #2c3e50; height: 355px;",
                       htmlOutput("match.info"),
                       tableOutput("metaInfo"),
                       textOutput("time")),
             wellPanel(style = "background-color: #fff; border-color: #2c3e50; height: 175px;",
                       htmlOutput("prediction.title"),
                       h4(htmlOutput("prediction"))))
      )
    ) #for fluidrow
    
  ),
  
  hr(),
  h4("Real-time Query"),
  fluidRow(wellPanel(style = "background-color: #fff; border-color: #2c3e50; overflow-y:scroll; height: 150px;",
                     
                     verbatimTextOutput("oText")
                     
  )),
  
  h5(shiny::HTML("
 <p><b>Infinity Loop</b> · Play Forever<br>
 <b>Code</b> · <a href=\"https://github.com/smtwtfs/InsightRiotGames\">github.com/smtwtfs/InsightRiotGames</a><br>
<b>Yue Yu</b> · Data Science Fellow · 2020 · <a href=\"https://www.linkedin.com/in/yueyuca/\">Linkedin</a></p>
"))    
)


### Comments, unused code, etc


# Fraction of atom pair. Not used anymore
# helpText("- OR - : use fraction (atom pair/backbone length)"),
# fluidRow(
#   column(1, checkboxInput("by.am.f", NULL, value = FALSE, width = NULL)),
#   column(9, textInput("am.t.f", "Atom pair thres. frac.", value = 0.2))
# ),