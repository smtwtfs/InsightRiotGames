source("color.r")

#-------------------------------------------------------------
# Input: 
# Output: 
#-------------------------------------------------------------

load("data/interval_71000.rdata")
interval = interval[interval$win !="0",]

# target variable
interval$breaks = interval$ItN > 2
interval[is.na(interval)] = 0

#time = format(interval$time, tz="America/Los_Angeles", usetz=TRUE)
hour =as.numeric(strftime(interval$time, format="%H"))
min = round(as.numeric(strftime(interval$time, format="%M"))/60, digits = 1)
hour = hour + min
interval$hour = hour

#tiredness ( how many games has player continously)

b.pos = c(0,which(interval['breaks'] == 1))
ses = rep(0,length(b.pos))
for(i in 1:length(ses)){
  ses[i] = i - max(b.pos[b.pos<i])
}


xx= subset(interval, select = -c(index, gameid, ItN, time, breaks))
yy=as.integer(interval[,'breaks'])
yy[is.na(yy)] = 0

load("data/champions.rdata")

champ.onehot = matrix(0, nrow = nrow(xx), ncol = nrow(champions))
colnames(champ.onehot) = paste0(champions[,2],".self")
for(i in 1:nrow(xx)){
  champ.onehot[i, which(as.numeric(champions[,1])==xx$champion[i])] = 1
}

ally.onehot = matrix(0, nrow = nrow(xx), ncol = nrow(champions))
colnames(ally.onehot) = paste0(champions[,2],".ally")
for(i in 1:nrow(xx)){
  ally.onehot[i, which(as.numeric(champions[,1])==xx$ally1[i])] = 1
  ally.onehot[i, which(as.numeric(champions[,1])==xx$ally2[i])] = 1
  ally.onehot[i, which(as.numeric(champions[,1])==xx$ally3[i])] = 1
  ally.onehot[i, which(as.numeric(champions[,1])==xx$ally4[i])] = 1
}

enemy.onehot = matrix(0, nrow = nrow(xx), ncol = nrow(champions))
colnames(enemy.onehot) = paste0(champions[,2],".enemy")
for(i in 1:nrow(xx)){
  enemy.onehot[i, which(as.numeric(champions[,1])==xx$enemy1[i])] = 1
  enemy.onehot[i, which(as.numeric(champions[,1])==xx$enemy2[i])] = 1
  enemy.onehot[i, which(as.numeric(champions[,1])==xx$enemy3[i])] = 1
  enemy.onehot[i, which(as.numeric(champions[,1])==xx$enemy4[i])] = 1
  enemy.onehot[i, which(as.numeric(champions[,1])==xx$enemy5[i])] = 1
}

x = data.frame(hour = xx$hour, win = as.numeric(xx$win == "Win"), champ.onehot, ally.onehot, enemy.onehot)
x = as.matrix(x)
#yy = as.numeric(as.character(yy))

#test
test.ind = sample(1:nrow(x), replace = F, size = round(nrow(x)/5))
x.test = x[test.ind,]
x.train = x[-test.ind,]
y.test = yy[test.ind]
y.train = yy[-test.ind]
#rf#
#require("randomForest")

#xgb#
require(xgboost)
mod.x = xgboost(x.train, y.train, nrounds = 500)

importance = xgb.importance(model = mod.x)
save(importance, file = "data/xgb_importance.rdata")

y.pred = predict(mod.x, newdata  = x.test)
save(y.pred, y.test, file = "data/xgb_pred.rdata")
save(mod.x, file = "data/xgb_mod.rdata")

load("data/xgb_pred.rdata")
simple_roc <- function(labels, scores){
  labels <- labels[order(scores, decreasing=TRUE)]
  data.frame(TPR=cumsum(labels)/sum(labels), FPR=cumsum(!labels)/sum(!labels), labels)
}
rocc = simple_roc(y.test, y.pred)

mean(y.pred)
rand = sample(c(0,1), size = length(y.pred), replace = T, prob = c(1-mean(y.pred), mean(y.pred)))
pred = round(y.pred)

mean(pred== y.test)
mean(rand== y.test)
