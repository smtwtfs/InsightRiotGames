# get a list of active users.

require(jsonlite)
require("httr")
source("key.r") # mark the key

akey <- function(..., ke = NULL){
  if(is.null(ke)){ke = key}
  st = paste0(...)
  return(paste0(st, "?api_key=", ke))
}

key = "RGAPI-0edc6473-4856-47c3-a80c-c8a7286b39ca"

seed.accounts = readRDS("data/seed_account_id.rds")

active.account.id = rep(NA, 10000)
counter = 1
part.id = 1

for(j in 271:length(seed.accounts)) {
  # get account ids from seed account id. save every 10,000 ids.
  # (each parts file would contain~ 5000 ids)
  
  # step 2: gets a bunch of matches from user
  match.info = fromJSON(content(GET(akey('https://na1.api.riotgames.com/lol/match/v4/matchlists/by-account/',seed.accounts[[j]])), as = "text", encoding = "latin1"))
  
  matchids = match.info$matches$gameId

   for(i in 1:length(matchids)){
    id = matchids[i]
    match.temp= fromJSON(content(GET(akey('https://na1.api.riotgames.com/lol/match/v4/matches/',id)), as = "text", encoding = "latin1"))
    id.temp = match.temp$participantIdentities$player$currentAccountId
    if(length(id.temp) != 10){ 
      print(paste0("Match ID: ", id,  ", # ids: ", length(id.temp)))
    } else {
      active.account.id[counter:(counter+9)] = id.temp
      if(counter == length(active.account.id)-9){
        save(active.account.id, file = paste0("data/account_id/active_account_id_",part.id,".rdata"))
        active.account.id = rep(NA, 5000)
        counter = 1
        part.id = part.id+1
      } else {
        counter = counter +10
      }
    }
    Sys.sleep(60*2/101)
  }

}




#as.POSIXct(match.info$matches$timestamp/1000, origin="1970-01-01") # process date

