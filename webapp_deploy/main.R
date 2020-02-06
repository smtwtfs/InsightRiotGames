
library(shiny)

require(rsconnect)

rsconnect::setAccountInfo(name='merc-guild-war', token='C79B9D372356150551FC8E84CC452998', secret='rUp6S5XosWWuhbG7YWu4lKd8W9k6EaIryq16NHOh')

deployApp()

runApp()


# for test
if(F){
  accountId = "dA6gR7LsPXhfTi7dDmptWXjqVYQKYRaJDu8TwHwlnJ3SqCk"
  this.match.id = "3257517038"
}
