require("RPostgreSQL")
library(RPostgreSQL)
library(rjson)
library(dplyr)
library(plyr)
library(gtools)
## JUNTAMOS TODAS LOS MESES

######201808

kk <- readLines("dat/Bicimad_Stations_201808.json")
kk= paste(kk, collapse="")
tmp <- fromJSON(kk)

total<- c()

for (var in tmp$root[]){
  id<- var$`_id`
  stations<- var$stations
  res <- ldply(var$stations, as.data.frame)
  res$fecha <- id
  total<- rbind(total,res)
}

sta_201808<-data.frame(total)

######201809

kk <- readLines("dat/Bicimad_Stations_201809.json")
kk= paste(kk, collapse="")
tmp <- fromJSON(kk)

total<- c()

for (var in tmp$root[]){
  id<- var$`_id`
  stations<- var$stations
  res <- ldply(var$stations, as.data.frame)
  res$fecha <- id
  total<- rbind(total,res)
}

sta_201809<-data.frame(total)

######201810

kk <- readLines("dat/Bicimad_Stations_201810.json")
kk= paste(kk, collapse="")
tmp <- fromJSON(kk)

total<- c()

for (var in tmp$root[]){
  id<- var$`_id`
  stations<- var$stations
  res <- ldply(var$stations, as.data.frame)
  res$fecha <- id
  total<- rbind(total,res)
}

sta_201810<-data.frame(total)

######201811

kk <- readLines("dat/Bicimad_Stations_201811.json")
kk= paste(kk, collapse="")
tmp <- fromJSON(kk)

total<- c()

for (var in tmp$root[]){
  id<- var$`_id`
  stations<- var$stations
  res <- ldply(var$stations, as.data.frame)
  res$fecha <- id
  total<- rbind(total,res)
}

sta_201811<-data.frame(total)

######201812

kk <- readLines("dat/Bicimad_Stations_201812.json")
kk= paste(kk, collapse="")
tmp <- fromJSON(kk)

total<- c()

for (var in tmp$root[]){
  id<- var$`_id`
  stations<- var$stations
  res <- ldply(var$stations, as.data.frame)
  res$fecha <- id
  total<- rbind(total,res)
}

sta_201812<-data.frame(total)

##AGRUPAMOS TODAS LAS TABLAS EN total
total <- smartbind(sta_201808, sta_201809,sta_201810,sta_201811,sta_201812)

##DEJAMOS SOLO LAS COLUMNAS QUE ESTAN EN EL SERVIDOR (LAS NECESARIAS)
total1 = total [ , c(13,14,3,5,6,12)]

##PONEMOS LOS MISMOS NOMBRES QUE EN EL SERVIDOR
colnames(total1)<-c("id_station", "date","reservations_count","total_bases","free_bases","dock_bikes")

##CONECTAMOS CON EL SERVIDOR


# create a connection
# save the password that we can "hide" it as best as we can by collapsing it
pw <- {
  "LosTilos114"
}




# loads the PostgreSQL driver
drv <- dbDriver("PostgreSQL")
# creates a connection to the postgres database
# note that "con" will be used later in each connection to the database
con <- dbConnect(drv, dbname = "postgres",
                 host = "postgre-sqltest.cpdeokpzufj1.us-west-2.rds.amazonaws.com", port = 5432,
                 user = "xseed", password = pw)
rm(pw) # removes the password

# check for the cartable
dbExistsTable(con, "station_status_hourly")

##ACTUALIAMOS LA TABLA
dbWriteTable(con, c("station_status_hourly"), value=total1,append=TRUE, row.names=FALSE)

