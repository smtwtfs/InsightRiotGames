library(shiny)

fluidPage(
  
  titlePanel("Summoner Info"),
  
  sidebarPanel(
    # fluidRow(
    #   column(6, checkboxInput("nmr", "NMR Only", value = FALSE, width = NULL)),
    #   column(6, checkboxInput("crystal", "Crystal Only", value = FALSE, width = NULL))
    # ),
    # uiOutput("selectFolder"),
    #uiOutput("selectFiles"),
    # 
    # hr(),
    #checkboxInput("use.en", "Use energy filter", value = T, width = NULL),
    textInput("sn", "Summoner ID", value = "mumuyyy"),
    actionButton("player.match", "Show Matches", style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
    hr(),
    actionButton("player.ana", "Show Player Analytics", style="color: #fff; background-color: #337ab7; border-color: #2e6da4"),
    
    #textInput("mid", "Match ID", value = ""),
    
    # checkboxInput("use.am", "Use atom pair filter", value = FALSE, width = NULL),
    # textInput("am.t", "Atom Pair Threshold", value = 10),
    
    hr(),
    selectInput(inputId = "mid", "Match ID", choices= ""),
    actionButton("run", "Match Analytics", style="color: #fff; background-color: #337ab7; border-color: #2e6da4")
    
  ),
  
  mainPanel(
    # htmlOutput("info"),
    wellPanel(style = "background-color: #fff; border-color: #2c3e50; height: 300px;",
    tableOutput("metaInfo"),
    textOutput("time"),
    textOutput("test"),
    h4(htmlOutput("prediction")))
    
    
    
    
    # rglwidgetOutput("widget", width = "100%", height = 600),
    # hr(),
    # plotOutput("hist"),
    # helpText("Energy histogram of the selected stucture. Note that the ties that are displayed in the figure above are highlighted blue."),
    # hr(),
    # helpText("KNOWN ISSUES: A lot. More specifically: "),
    # helpText("1. Image cannot be rotated on most of the mobile browers"),
    # helpText("2. No permission to install V8 package (for randomly coloring the nodes) on Odin (yet). requires package libv8-dev"),
    # hr(),
    # helpText("FIXED ISSUES"),
    # helpText("1. If the network is empty caused by bad threshold, it gives error (Error in d[i, 1] : subscript out of bounds). This is a gplot3d issue.")
    # 
    # #textOutput("warn")
    # #h4(htmlOutput("past")),
    # #HTML('<hr>'),
    # #h4(htmlOutput("summary")),
    # #conditionalPanel('input.type=="文字"', h4(htmlOutput("text"))),
    # #conditionalPanel('input.type=="表格"', tableOutput("table")),
  ),
  
    hr(),
    h4("Real-time Query"),
    #verbatimTextOutput("oText"),
  
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