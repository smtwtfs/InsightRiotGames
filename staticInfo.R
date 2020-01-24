# Get some of the documentation file.
require(jsonlite)
require("httr")

# Get queueID (key table)
queueID.info = fromJSON(content(GET("http://static.developer.riotgames.com/docs/lol/queues.json"), as = "text", encoding = "latin1"))

# Get champion info (id-key-name table)
champion.info = fromJSON(content(GET("http://ddragon.leagueoflegends.com/cdn/10.1.1/data/en_US/champion.json"), as = "text", encoding = "latin1"))
champion.info = t(sapply(champion.info$data, function(X){list(id=X$id, key=X$key, name=X$name)}))


save(champion.info, file = "data/champion-info.rdata")
