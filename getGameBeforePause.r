
#-------------------------------------------------------------
# Part 1
#   Input: files in data/matchlist/ folder. each file is a matchlist of one player.
#   Output: matchlist_interval.rdata: big file of list of match ids from all input,
#           match details not filled
# Part 2
#   Input: output of part 1
#   Output: matchlist_intervaltemp.rdata: populated match details within the big form.
#-------------------------------------------------------------

# Given currently using 2 hours as the interval threshold to differentiated waits vs pauses, find out what happened with the last game before pauses. 

# list files but not folders
files = setdiff(list.files(path = "data/matchlist/"), list.dirs(path = "data/matchlist/",recursive = FALSE, full.names = FALSE))

interval = NULL
index.account.hash = NULL
count = 1

for (f in files){
  tt = read.csv(paste0("data/matchlist/",f), stringsAsFactors = F)
  #find interval to next game (ItN)
  time = as.POSIXlt.character(tt$time)
  ItN = as.numeric(-diff(time), units = "hours")
  # if include account id
  #temp = data.frame(encryptedAccountId = f, time = time[-1], ItN = ItN)
  # if include index (1-to-1 matching to account id)
  temp = data.frame(index = count, time = time[-1], ItN = ItN, gameid = tt$gameId[-1], champion = tt$champion[-1])
  interval = rbind(interval, temp)
  index.account.hash = rbind(index.account.hash, data.frame(index = count, accountId = f, stringsAsFactors = F))
  count = count+1
}

interval$win =0
interval$ally1 =0
interval$ally2 =0
interval$ally3 =0
interval$ally4 =0
interval$enemy1 =0
interval$enemy2 =0
interval$enemy3 = 0
interval$enemy4 = 0
interval$enemy5 = 0

save(index.account.hash, file = "data/matchlist_index-account-hash.rdata")
save(interval, file = "data/matchlist_interval.rdata")


source("color.r")
require(jsonlite)
require("httr")
source("key-func.r")
key = scan("key", what = character()) # key is just a file with pure key information.

load("data/matchlist_index-account-hash.rdata")
#load(file = "data/matchlist_interval.rdata")

load("data/intervaltemp.rdata")

for(i in 15065:nrow(interval)){
#for(i in needhelp[80:1500]){
  this.match.id = interval$gameid[i]
  accountid = index.account.hash[index.account.hash[,1] ==interval$index[i],2]
  
  this.match = fromJSON(content(GET(akey('https://na1.api.riotgames.com/lol/match/v4/matches/', this.match.id)), as = "text", encoding = "latin1"))
  
  cat("i=",i, ", message:", this.match$status$message, sep = "")
  if(is.null(this.match$participants)){
    next
  }
  if(nrow(this.match$participants) ==1){
    next
  }
  # gether some info
  this.playerid = this.match$participantIdentities$participantId[this.match$participantIdentities$player$currentAccountId == accountid]
  
  this.playerinfo = this.match$participants[this.match$participants$participantId==this.playerid,]
  
  this.playerteamid = this.playerinfo$teamId
  
  # whether win or not
  win=this.match$teams$win[this.match$teams$teamId == this.playerteamid]
  
  # 4 allies 
  allies = this.match$participants$championId[this.match$participants$teamId == this.playerteamid & this.match$participants$participantId !=this.playerid]
  
  # 5 enemies
  enemies = this.match$participants$championId[this.match$participants$teamId != this.playerteamid]
  
  
  interval[i,]$win = win
  if( (!is.null(allies)) & length(allies) !=0){
    for(j in 1:length(allies)){
      interval[i,6+j] = allies[j]
    }
  }
  if( (!is.null(enemies)) & length(enemies) !=0){
    for(j in 1:length(enemies)){
      interval[i,10+j] = enemies[j]
    }
  }
  if( i %% 100 ==0 ){
    save(interval, file="data/intervaltemp.rdata")
  }
  if( i %% 1000 ==0 ){
    save(interval, file=paste0("data/interval_",i,".rdata"))
  }
  Sys.sleep(120/100)
}

DEBUG=F
if(DEBUG){
  sort(which(interval[,7] == 0 ))[1:1600]
  needhelp = sort(which(interval[,7] == 0 ))[1:1600]
  # before 80 checked
}
  
