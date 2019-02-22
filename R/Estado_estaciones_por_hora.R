library(rjson)
library(dplyr)
library(plyr)

kk <- readLines("https://dev.gutrade.io/gaston/Bicimad_Stations_201811.json")
tmp<- fromJSON("https://dev.gutrade.io/gaston/Bicimad_Stations_201811.json")
kk= paste(kk, collapse="")
tmp <- fromJSON(kk)

total<- c()

for (var in tmp$root[]){
  id<- var$`_id`
  stations<- var$stations
  res <- ldply(var$stations, as.data.frame)
  res$id <- id
  total<- rbind(total,res)
}

head(total)
