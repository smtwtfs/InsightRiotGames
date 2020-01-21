# get a list of active users.

require(jsonlite)
require("httr")
source("key.r") # mark the key, and key functions

library(readr)
#mystring <- read_file("data/sample/matches3.json", locale = locale(encoding = "latin1"))

  
# 
# matches = fromJSON(mystring, simplifyVector = F)$matches
# 
# matches[[1]]$participantIdentities[[1]]$player$summonerName
# matches[[1]]$participantIdentities[[1]]$player$summonerId
# matches[[1]]$participantIdentities[[1]]$player
# matches[[1]]$gameCreation


# step 1: get one seed summoner name and account id.
name = "RiotSchmick"; part.id = 1
name = "L3gislacerator"; part.id = 2
name = "Ghösts"; part.id = 3
name = "mumuyyy"; part.id = 4
name = "sleep time go"; part.id = 5

# get account id from name.
id.info = fromJSON(content(GET(akey('https://na1.api.riotgames.com/lol/summoner/v4/summoners/by-name/',name)), as = "text", encoding = "latin1"))

# step 2: gets a bunch of matches from user
match.info = fromJSON(content(GET(akey('https://na1.api.riotgames.com/lol/match/v4/matchlists/by-account/',id.info$accountId)), as = "text", encoding = "latin1"))

#as.POSIXct(match.info$matches$timestamp/1000, origin="1970-01-01") # process date

matchids = match.info$matches$gameId
active.account.id = NULL

for(i in 1:length(matchids)){
  id = matchids[i]
  match.temp= fromJSON(content(GET(akey('https://na1.api.riotgames.com/lol/match/v4/matches/',id)), as = "text", encoding = "latin1"))
  id.temp = match.temp$participantIdentities$player$currentAccountId
  if(length(id.temp) != 10){ 
    print(paste0("Match ID: ", id,  ", # ids: ", length(id.temp), ", Status: ", match.temp$status$status_code))
  } else {
  active.account.id = c(active.account.id, id.temp)
  }
  Sys.sleep(1/18)
}

save(active.account.id, file = paste0("data/seed_account_id_",part.id,".rdata"))




### combine.


part.ids = 1:4
seed.accounts = unlist(lapply(paste0("data/seed_account_id_",part.ids,".rdata"), function(X){
  ls = load(X); return(get(ls))
}))
saveRDS(seed.accounts, file = "data/seed_account_id.rds")
