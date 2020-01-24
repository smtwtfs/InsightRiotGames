
#-------------------------------------------------------------
# Input: 
# Output: 
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

save(index.account.hash, file = "data/matchlist_index-account-hash.rdata")
save(interval, file = "data/matchlist_interval.rdata")

source("color.r")
require(jsonlite)
require("httr")
source("key-func.r")
key = scan("key", what = character()) # key is just a file with pure key information.

load("data/matchlist_index-account-hash.rdata")
load(file = "data/matchlist_interval.rdata")

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

for(i in 1849:nrow(interval)){
  this.match.id = interval$gameid[i]
  accountid = index.account.hash[index.account.hash[,1] ==interval$index[i],2]
  
  this.match = fromJSON(content(GET(akey('https://na1.api.riotgames.com/lol/match/v4/matches/', this.match.id)), as = "text", encoding = "latin1"))
  
  if(is.null(this.match$participants)){
    next
  }
  if(nrow(this.match$participants) ==1){
    next
  }
  # gether some info
  this.playerid = this.match$participantIdentities$participantId[this.match$participantIdentities$player$accountId == accountid]
  
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
    save(interval, file=paste0("data/intervaltemp_",i,".rdata"))
  }
  Sys.sleep(120/100)
}






load("data/account_id/active_account_id_1.rdata")

a = 1
this.account= active.account.id[[a]]

# infor include start and end
match.info.debug = fromJSON(content(GET(akey('https://na1.api.riotgames.com/lol/match/v4/matchlists/by-account/', this.account)), as = "text", encoding = "latin1"))
# pure info

if(!is.null(match.info.debug$status)){
  write(paste0("Ind: ",a,", UID: ",this.account), file="data/matchlist/log/000log",append=T)
  next
}

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
    Sys.sleep(120/70) # make sure we don't exceed the 100 per two minutes limit.
  }
}

match.info$time = as.POSIXct(match.info$timestamp/1000, origin="1970-01-01") 
write.csv(match.info, file =paste0("data/matchlist/",this.account))
}















# average pause duration (later on: vs. number of games per session)
interval.p = interval[interval$ItN>2,]
# average pause duration
apd = aggregate(interval.p$ItN, list(interval.p$index), mean)

#remove outlier in apd
apd2 = apd[apd[,2] < 200,2]
png("plot/average-pause-per-player.png", 9,9, unit = "in", res = 200)
hist(apd2, breaks = 40, main = "Average Pause per Player", xlab = "Hours", col = rev(col.p(100)))
dev.off()
# games per session 
# everytime a pause happens, that marks a new session. 
ng = aggregate(interval$ItN, list(interval$index), length) # number of games

# aggregate(interval$ItN, list(interval$index), function(X){sum(X>2)}) # same as next line
ns = aggregate(interval.p$ItN, list(interval.p$index), length)
gps = ng/ns

gps2 = gps[apd[,2] < 200,2]

png("plot/pause-vs-games.png", 9,9, unit = "in", res = 200)
plot(gps2, apd2, pch =16, col = "#00000088", cex= 0.5, xlab = "Games per Session", ylab ="Average Pause Duration")
dev.off()



