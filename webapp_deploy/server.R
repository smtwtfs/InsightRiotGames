library(shiny)
require(jsonlite)
require(xgboost)

require("httr")
source("key-func.r")
source("color.r")

key = scan("key", what = character()) # 
load("data/champion-info.rdata")
load("data/champions.rdata")
load("data/xgb_mod.rdata")

function(input, output, session) {
  query<-reactiveValues(a='')
  player.info<-reactiveValues(a=FALSE)
  ###=======================================================###
  # test #
  ###=======================================================###
  output$test <- renderText({ 
    paste0("total games = ", analysis()$al)
  })
  
  ###=======================================================###
  # Analysis this players history data                        #
  ###=======================================================###
  ana.player <- eventReactive(input$player.ana, {
    player.info$a = T
    accountid = fromJSON(content(GET(akey('https://na1.api.riotgames.com/lol/summoner/v4/summoners/by-name/',input$sn, ke = input$key)), as = "text", encoding = "latin1"))$accountId
    
    # infor include start and end
    this.match = fromJSON(content(GET(akey('https://na1.api.riotgames.com/lol/match/v4/matchlists/by-account/', accountid, ke = input$key)), as = "text", encoding = "latin1"))
    
    # pure info
    match.info = this.match$matches 
    total.game = this.match$totalGames
    
    if(total.game > 100) {
      begin.index = 99;end.index= 199
      while(begin.index < min(total.game, 600)){
        this.match = fromJSON(content(GET(akey('https://na1.api.riotgames.com/lol/match/v4/matchlists/by-account/', begin.index = begin.index , end.index = end.index, accountid, ke = input$key)), as = "text", encoding = "latin1"))
        
        query$a = paste0(query$a,diskey('https://na1.api.riotgames.com/lol/match/v4/matchlists/by-account/', begin.index = begin.index , end.index = end.index, accountid, ke = input$key), sep = "\n")
        
        begin.index = begin.index + 99; end.index = begin.index + 100
        total.game = this.match$totalGames
        if(match.info[nrow(match.info), 'gameId'] == this.match$matches[1,'gameId']) {
          match.info = match.info[-nrow(match.info),]
        }
        match.info = rbind(match.info, this.match$matches)
        Sys.sleep(0.5) # make sure we don't exceed the 100 per two minutes limit.
      }
    }
    
    time = as.POSIXct(match.info$timestamp/1000, origin="1970-01-01") 
    ItN = as.numeric(-diff(time), units = "hours")
    
    # Averga pause duration
    ave.pause = mean(ItN[ItN > 2])
    
    # Ave. game per session = num games / num sessions.
    ng = length(ItN)
    ns = sum(ItN > 2)
    gps = ng/ns
    
    return(list(total.game = total.game, ItN = ItN, ave.pause = ave.pause, gps = gps))
  })
  
  ###==============================================###
  #  Render this players basic information           #
  ###==============================================###
  output$playerBasic<- renderText({
    return(paste0(
      "<p><span style=\"font-family: Tahoma, Geneva, sans-serif;\"><strong><span style=\"color: rgb(255, 34, 34); font-size: 18px;\">",
      input$sn,
      "</span></strong><strong><span style=\"font-size:18px;\">&nbsp;Basic Statistics</span></strong></span></p>
      <p><span style=\"font-family: Tahoma, Geneva, sans-serif;\"><span style=\"font-size: 
      16px;\">(compared with player base average)</span></span></p> <hr>
      <p><span style=\"font-family: Tahoma, Geneva, sans-serif;\"><strong>Total Number of Games:&nbsp;</strong></span>
      <br>&nbsp; &nbsp; &nbsp; ", 
      ana.player()$total.game, 
      " / (1549)</p>
      <p><span style=\"font-family: Tahoma, Geneva, sans-serif;\"><strong>Ave. Games per Session:&nbsp;</strong></span>
      <br>&nbsp; &nbsp; &nbsp; ",
      round(ana.player()$gps, digits = 2),
      " / (3.88) </p>
      <p><span style=\"font-family: Tahoma, Geneva, sans-serif;\"><strong>Ave. Pause Duration:&nbsp;</strong></span>
      <br>&nbsp; &nbsp; &nbsp; ",
      round(ana.player()$ave.pause, digits = 2),    " / (35.40)</p>"
    ))
  })
  
  
  ###==============================================###
  #  Plot histogram for selected player              #
  ###==============================================###
  output$hist <- renderPlot({
    load("data/iterval2next.rdata")
    hh = hist(ItN.overall, breaks = c(-Inf, seq(0, to = 1000, by = 2), Inf), plot = F)
    hh$counts = log(hh$counts); hh$counts = hh$counts+0.5; hh$counts[hh$counts ==-Inf] = 0
    # normalize
    hh$counts = hh$counts/max(hh$counts)
    cols = adjustcolor(col.b(101),alpha.f = 0.7)[1+round(100*hh$counts)] 
    
    par(mar = c(4,0,2,0))
    plot(hh, freq = TRUE, xlim = c(0,250), ylab = "", xlab = "Hours", yaxt = "n", main = "", col = cols,border = F)
    text(x = 90, y = 1, labels = input$sn, col = "red", font = 2, pos = 2, cex = 1.5)
    text(x = 88, y = 1, labels = "Playing Patterns (Time Between Games)", pos = 4, cex = 1.3, font = 2)
    
    
    ItN = ana.player()$ItN
    h = hist(ItN, breaks = c(-Inf, seq(0, to = 1000, by = 2), Inf), plot = F)
    h$counts = log(h$counts); h$counts = h$counts+0.5; h$counts[h$counts ==-Inf] = 0
    h$counts = h$counts/max(h$counts)
    
    par(new =T)
    plot(h, freq = TRUE, xlim = c(0,250), ylab = "", xlab = "", yaxt = "n", xaxt="n", main = "", col = "white")
    legend(x = 170, y = 0.8, fill = c("white", cols[7]), legend = c(input$sn, "Player base Ave."), text.col = c("red","black"), text.font = 2)
  })
  
  
  
  
  ###=======================================================###
  # Query this players match data and update it to selectize. #
  ###=======================================================###
  observeEvent(input$player.ana, {
    # get account id from name.
    id = fromJSON(content(GET(akey('https://na1.api.riotgames.com/lol/summoner/v4/summoners/by-name/',input$sn, ke = input$key)), as = "text", encoding = "latin1"))$accountId
    query$a= paste0(query$a,diskey('https://na1.api.riotgames.com/lol/summoner/v4/summoners/by-name/',input$sn, ke = input$key), sep = '\n')
    
    match.info = fromJSON(content(GET(akey('https://na1.api.riotgames.com/lol/match/v4/matchlists/by-account/',id, ke = input$key)), as = "text", encoding = "latin1"))$matches
    query$a= paste0(query$a, diskey('https://na1.api.riotgames.com/lol/match/v4/matchlists/by-account/',id, ke = input$key), sep = "\n")
    
    gameId = match.info$gameId
    
    disp = sapply(match.info$champion, function(X){champions[X==champions[,1],2]})
    time = as.POSIXct(match.info$timestamp/1000, origin="1970-01-01")
    time = strftime(time, format="%y.%m.%d %H:%M")
    disp = paste(time, disp, sep = " ")
    names(gameId) <- disp
    
    updateSelectInput(session, "mid", choices= gameId)
  })
  
  
  
  #####=======================================#####
  # A specific match analysis #
  #####=======================================#####
  output$match.info<- renderText({
    return(
      "<p><span style=\"font-family: Tahoma, Geneva, sans-serif;\"><strong><span style=\"font-size:18px;\">&nbsp;Match Information</span></strong></span></p>")
    })
  
  analysis <- eventReactive(input$run, {

    player.info$a = F
    
    this.match.id = input$mid
    
    this.match = fromJSON(content(GET(akey('https://na1.api.riotgames.com/lol/match/v4/matches/', this.match.id, ke = input$key)), as = "text", encoding = "latin1"))
    
    query$a= paste0(query$a,diskey('https://na1.api.riotgames.com/lol/match/v4/matches/', this.match.id, ke = input$key), seq = "\n")
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
    table = cbind(c(analysis()$me,analysis()$al),analysis()$en)
    colnames(table) = c("Allies","Enemies")
    return(table)
  })
  
  output$time <- renderText({ 
    paste0("Game started at: ", analysis()$time)
  })
  
  ## make predictions
  
  output$prediction.title<- renderText({
    return(
      "<p><span style=\"font-family: Tahoma, Geneva, sans-serif;\"><strong><span style=\"font-size:18px;\">&nbsp;Prediction</span></strong></span></p>")
  })
  
  output$prediction <- renderText({ 
    likelihood = (sin(as.numeric(strftime(analysis()$time, format="%H"))/4-0.6)+1.6)/3.3
    paste0("Predicted probability for play = <b style=\"color:red;\">", round(analysis()$prob, digits = 4),"</b>")
  })
  
  
  output$oText <- renderText({query$a})
  
  
  
  
}
