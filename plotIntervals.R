source("color.r")

#-------------------------------------------------------------
# Input: Individual Matchlists under the matchlist folder. 
# Output: Some exploratory plots.
#-------------------------------------------------------------

# Given currently using 2 hours as the interval threshold to differentiated pause vs consective, Find the mean of the two type of actions.

# list files but not folders
files = setdiff(list.files(path = "data/matchlist/"), list.dirs(path = "data/matchlist/",recursive = FALSE, full.names = FALSE))

interval = NULL
count = 1
for (f in files){
  tt = read.csv(paste0("data/matchlist/",f), stringsAsFactors = F)
  #find interval to next game (ItN)
  time = as.POSIXlt.character(tt$time)
  ItN = as.numeric(-diff(time), units = "hours")
  # if include account id
  #temp = data.frame(encryptedAccountId = f, time = time[-1], ItN = ItN)
  # if include index (1-to-1 matching to account id)
  temp = data.frame(index = count, time = time[-1], ItN = ItN)
  interval = rbind(interval, temp)
  count = count+1
}

# analysis
# Remove outliers
ItN = interval$ItN[interval$ItN < 500]
hist(ItN, breaks = 200)

# pauses vs. breaks
itn =list()
itn$wait = ItN[ItN<=2& ItN>=0]
itn$pause = ItN[ItN>2]

# histgram of waits
png("plot/HistWait.png", 9,6, units = "in", res = 300)
hist(itn[[1]], breaks =100, col = rev(col.p(100)), xlab = "Hours", ylab = "Count", main = "Histogram of Wait Interval", border = "#0000003f")
dev.off()

# histgram of pauses
hh = hist(itn[[2]], breaks = 200, plot = F)
hh$counts = log(hh$counts); hh$counts[hh$counts==-Inf] = 0

cols = rev(col.b(8))[findInterval(hh$mids, vec = 24*c(0,1,2,3,4,5,6,7))]

png("plot/HistPause.png", 9,6, units = "in", res = 300)
plot(hh, col = cols, border = NA, xaxt = "n", yaxt ="n", main = "Histogram of Pause Interval", xlab = "Days", ylab = "Log-count")
abline(v = 24*1:20, col = "#00000033")
axis(1, 24*(0:22), labels = 0:22)
axis(2, log(c(1,10,100,1000,10000)), labels = c(1,10,100,1000,10000))
dev.off()

##
load("data/interval_180000.rdata")
ItNs = interval$ItN[interval$win !=0]
ItNs = ItNs[ItNs<1000]

hh = hist(ItNs, breaks = 200, plot = T)
#hh$counts = log(hh$counts); hh$counts[hh$counts==-Inf] = 0

cols = rev(col.r(8))[findInterval(hh$mids, vec = 2*c(0,1,2,3,4,5,6,7))]
png("plot/HistItN.png", 9,5, units = "in", res = 300)
plot(hh, col = cols, main = "Histogram of Pause Interval", xlab = "Hours", ylab = "count")
dev.off()

rm(itn)

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



