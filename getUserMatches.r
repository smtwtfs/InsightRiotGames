# get a list of active users.

require(jsonlite)
require("httr")
#library(readr)
source("key-func.r")

load("data/account_id/active_account_id_2.rdata")

for (a in 411:length(active.account.id)){
  this.account= active.account.id[[a]]
  
  # find whether there are the same account in the fold already. 
  if(file.exists(paste0("data/matchlist/",this.account))){
    write(paste0("Ind: ",a,", UID: ",this.account),file="data/matchlist/log/000log",append=T)
    next
  }
  
  # infor include start and end
  match.info.debug = fromJSON(content(GET(akey('https://na1.api.riotgames.com/lol/match/v4/matchlists/by-account/', this.account)), as = "text", encoding = "latin1"))
  # pure info
  match.info = match.info.debug$matches 
  total.game = match.info.debug$totalGames
  
  if(total.game > 100) {
    begin.index = 99;end.index= 199
    while(begin.index < total.game){
      this.match = fromJSON(content(GET(akey('https://na1.api.riotgames.com/lol/match/v4/matchlists/by-account/', begin.index = begin.index , end.index = end.index, this.account)), as = "text", encoding = "latin1"))
      
      begin.index = begin.index + 99; end.index = begin.index + 100
      total.game = this.match$totalGames
      if(match.info[nrow(match.info), 'gameId'] == this.match$matches[1,'gameId']) {
        match.info = match.info[-nrow(match.info),]
      }
      match.info = rbind(match.info, this.match$matches)
      Sys.sleep(120/80) # make sure we don't exceed the 100 per two minutes limit.
    }
  }
  
  match.info$time = as.POSIXct(match.info$timestamp/1000, origin="1970-01-01") 
  write.csv(match.info, file =paste0("data/matchlist/",this.account))
}

