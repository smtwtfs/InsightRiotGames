library(shiny)
#source("color.r")
require(jsonlite)
require("httr")
source("../key-func.r")
key = scan("../key", what = character()) # 
load("../data/champion-info.rdata")

data.path = ""
if( Sys.info()["sysname"] == "Linux"){
  data.path = ""
}

function(input, output, session) {
  query<-reactiveValues(a='')
  
  ###=======================================================###
  # Query this players match data and update it to selectize. #
  ###=======================================================###
  output$test <- renderText({ 
    paste0("Game started at: ", ana.player()$test)
  })
  
  ###=======================================================###
  # Query this players match data and update it to selectize. #
  ###=======================================================###
  observeEvent(input$player.match, {
    # get account id from name.
    id = fromJSON(content(GET(akey('https://na1.api.riotgames.com/lol/summoner/v4/summoners/by-name/',input$sn)), as = "text", encoding = "latin1"))$accountId
    query$a= paste0(query$a,diskey('https://na1.api.riotgames.com/lol/summoner/v4/summoners/by-name/',input$sn), sep = '\n')
    
    match.info = fromJSON(content(GET(akey('https://na1.api.riotgames.com/lol/match/v4/matchlists/by-account/',id)), as = "text", encoding = "latin1"))$matches
    query$a= paste0(query$a, diskey('https://na1.api.riotgames.com/lol/match/v4/matchlists/by-account/',id), sep = "\n")
    
    gameId = match.info$gameId
    
    disp = sapply(match.info$champion, function(X){champions[X==champions[,1],2]})
    time = as.POSIXct(match.info$timestamp/1000, origin="1970-01-01")
    time = strftime(time, format="%y.%m.%d %H:%M")
    disp = paste(time, disp, sep = " ")
    names(gameId) <- disp
    
    updateSelectInput(session, "mid", choices= gameId)
  })
  
  
  ###=======================================================###
  # Analysis this players data                               #
  ###=======================================================###
   ana.player <- eventReactive(input$player.ana, {
    
    accountid = fromJSON(content(GET(akey('https://na1.api.riotgames.com/lol/summoner/v4/summoners/by-name/',input$sn)), as = "text", encoding = "latin1"))$accountId
    
    # infor include start and end
    this.match = fromJSON(content(GET(akey('https://na1.api.riotgames.com/lol/match/v4/matchlists/by-account/', accountid)), as = "text", encoding = "latin1"))
    # pure info
    if(!is.null(this.match$status)){
    }
    
    match.info = this.match$matches 
    total.game = this.match$totalGames
    
    if(total.game > 100) {
      begin.index = 99;end.index= 199
      while(begin.index < min(total.game, 200)){
        this.match = fromJSON(content(GET(akey('https://na1.api.riotgames.com/lol/match/v4/matchlists/by-account/', begin.index = begin.index , end.index = end.index, accountid)), as = "text", encoding = "latin1"))
        
        query$a = paste0(query$a,diskey('https://na1.api.riotgames.com/lol/match/v4/matchlists/by-account/', begin.index = begin.index , end.index = end.index, accountid), sep = "\n")
        
        begin.index = begin.index + 99; end.index = begin.index + 100
        total.game = this.match$totalGames
        if(match.info[nrow(match.info), 'gameId'] == this.match$matches[1,'gameId']) {
          match.info = match.info[-nrow(match.info),]
        }
        match.info = rbind(match.info, this.match$matches)
        Sys.sleep(0.5) # make sure we don't exceed the 100 per two minutes limit.
      }
    }
    
    match.info$time = as.POSIXct(match.info$timestamp/1000, origin="1970-01-01") 
    write.csv(match.info, file =paste0("data/matchlist/",this.account))
    
    return(list(test= "test"))
  })
  
  # observeEvent
  observeEvent(T,{
    output$oText <- renderText({query$a})
  })
  
  #####=======================================#####
  # When user clicked the button "Match Analysis" #
  #####=======================================#####
  
  analysis <- eventReactive(input$run, {
    this.match.id = input$mid
    
    this.match = fromJSON(content(GET(akey('https://na1.api.riotgames.com/lol/match/v4/matches/', this.match.id)), as = "text", encoding = "latin1"))
    
    query$a= paste0(query$a,diskey('https://na1.api.riotgames.com/lol/match/v4/matches/', this.match.id), seq = "\n")
    # gether some info
    this.playerid = this.match$participantIdentities$participantId[this.match$participantIdentities$player$summonerName == input$sn]
    
    this.playerinfo = this.match$participants[this.match$participants$participantId==this.playerid,]
    
    this.playerteamid = this.playerinfo$teamId
    
    # whether win or not
    win=this.match$teams$win[this.match$teams$teamId == this.playerteamid]
    
    # 4 allies 
    allies.ind = this.match$participants$championId[this.match$participants$teamId == this.playerteamid & this.match$participants$participantId !=this.playerid]
    # 5 enemies
    enemies.ind = this.match$participants$championId[this.match$participants$teamId != this.playerteamid]
    
    # players champion
    me.ind = this.match$participants$championId[this.match$participants$participantId ==this.playerid]
    
    me = unlist(sapply(as.character(me.ind),  function(X){champion.info[,1][champion.info[,2] == X]}))
    allies = unlist(sapply(as.character(allies.ind), function(X){champion.info[,1][champion.info[,2] == X]}))
    enemies = unlist(sapply(as.character(enemies.ind),  function(X){champion.info[,1][champion.info[,2] == X]}))
    
    time = as.POSIXct(this.match$gameCreation/1000, origin="1970-01-01") 
    
    # calculate the likelihood to quit based on model.
    champ.onehot = matrix(0, nrow = 1, ncol = nrow(champions))
    colnames(champ.onehot) = paste0(champions[,2],".self")
    champ.onehot[1,which(as.numeric(champions[,1])==me.ind)] = 1
    
    ally.onehot = matrix(0, nrow = 1, ncol = nrow(champions))
    colnames(ally.onehot) = paste0(champions[,2],".ally")
    ally.onehot[1, which(as.numeric(champions[,1])==allies.ind[1])] = 1
    ally.onehot[1, which(as.numeric(champions[,1])==allies.ind[2])] = 1
    ally.onehot[1, which(as.numeric(champions[,1])==allies.ind[3])] = 1
    ally.onehot[1, which(as.numeric(champions[,1])==allies.ind[4])] = 1
    
    enemy.onehot = matrix(0, nrow = 1, ncol = nrow(champions))
    colnames(enemy.onehot) = paste0(champions[,2],".enemy")
    enemy.onehot[1, which(as.numeric(champions[,1])==enemies.ind[1])] = 1
    enemy.onehot[1, which(as.numeric(champions[,1])==enemies.ind[2])] = 1
    enemy.onehot[1, which(as.numeric(champions[,1])==enemies.ind[3])] = 1
    enemy.onehot[1, which(as.numeric(champions[,1])==enemies.ind[4])] = 1
    enemy.onehot[1, which(as.numeric(champions[,1])==enemies.ind[5])] = 1
    
    
    # When deployed, make sure that the same time zone is used.
    hour = as.numeric(strftime(time, format="%H"))
    min = round(as.numeric(strftime(time, format="%M"))/60, digits = 1)
    hour = hour +min
    
    x = data.frame(hour = hour, win = as.numeric(win == "Win"), champ.onehot, ally.onehot, enemy.onehot)
    x = as.matrix(x)
    
    prob = predict(mod.x, newdata =x)
    return(list(me =me, al=allies, en=enemies, time = time, prob = prob))
  })
  
  output$metaInfo<- renderTable({
    # analysis()
    table = cbind(c(analysis()$me,analysis()$al),analysis()$en) 
    colnames(table) = c("Allies","Enemies")
    return(table)
  })
  
  output$time <- renderText({ 
    paste0("Game started at: ", analysis()$time)
  })
  
  output$prediction <- renderText({ 
    likelihood = (sin(as.numeric(strftime(analysis()$time, format="%H"))/4-0.6)+1.6)/3.3
    paste0("Predicted probability for play = <b style=\"color:red;\">", round(analysis()$prob, digits = 4),"</b>")
  })
  # output$widget <- renderRglwidget({
  #   scene = analysis()$scene
  #   rglwidget(scene)
  # })
  
  output$hist <- renderPlot({
    binden = analysis()$binden
    adj = analysis()$picked.tie
    highlight.hist(binden[binden!=0], binden[adj],  col.value = "#5555f6",  breaks = 20,main = "",col = "grey100")
  })

  
  # output$selectFolder<- renderUI({
  #   cc = list.dirs(data.path, full.names = F, recursive = F)
  #   if(dir.exists(paste0(data.path, "fibril.topologies.IGB1_200MIN_salt"))){
  #     selectizeInput(inputId = "folder", "Folder", choices=cc, selected = "fibril.topologies.IGB1_200MIN_salt")
  #   } else {
  #     selectizeInput(inputId = "folder", "Folder", choices=cc)
  #   }
  # })
  
  
}
