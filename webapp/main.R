
library(shiny)
key = scan("../key", what = character()) # 
load("../data/champion-info.rdata")
load("../data/champions.rdata")
#load model
load("../data/xgb_mod.rdata")
#runApp(host = "128.195.185.159", port = 3838)

runApp()


# for test
if(F){
  accountId = "dA6gR7LsPXhfTi7dDmptWXjqVYQKYRaJDu8TwHwlnJ3SqCk"
  this.match.id = "3257517038"
}