library(rjson)
library(dplyr)
library(plyr)
library(datetime)


kk <- readLines("parte4.json")
kk= paste(kk, collapse="")
tmp <- fromJSON(kk)

rm(kk)


f<- function(var) {
  unplug_hourtime<- format(as.datetime(var$unplug_hourTime$`$date`), format = '%Y-%m-%d %H:%M', mark=TRUE)
  oid<- var$`_id`
  user_day_code <- var$user_day_code
  idunplug_station <- as.numeric(var$idunplug_station)
  idplug_station <- as.numeric(var$idplug_station)
  idunplug_base<- as.numeric(var$idunplug_base)
  idplug_base <- as.numeric(var$idplug_base)
  travel_time <- as.numeric(var$travel_time)
  user_type_code <- as.numeric(var$user_type)
  age_range_code <- as.numeric(var$ageRange)
  zip_code <- var$zip_code
  
  write.table(data.frame(oid, user_day_code, idplug_base, user_type_code, idunplug_base, 
                         travel_time, idunplug_station, age_range_code, idplug_station, 
                         unplug_hourtime, zip_code), 'movimientos_octubre2018.csv'  , append= T, sep=';', col.names=FALSE )
}


lapply(tmp$root[], f)


data <- read.csv("movimientos.csv", encoding = 'UTF-8', sep=';')

summary(data)

tmp$root[][1]
# prueba<- format(as.datetime('2017-04-02T14:00:00.000+0200'), format = '%Y-%m-%d %H:%M', mark=TRUE)

for (var in tmp$root[]){
  
  unplug_hourtime<- format(as.datetime(var$unplug_hourTime$`$date`), format = '%Y-%m-%d %H:%M', mark=TRUE)
  oid<- var$`_id`
  user_day_code <- var$user_day_code
  idunplug_station <- as.numeric(var$idunplug_station)
  idplug_station <- as.numeric(var$idplug_station)
  idunplug_base<- as.numeric(var$idunplug_base)
  idplug_base <- as.numeric(var$idplug_base)
  travel_time <- as.numeric(var$travel_time)
  user_type_code <- as.numeric(var$user_type)
  age_range_code <- as.numeric(var$ageRange)
  zip_code <- var$zip_code
  
}

res <-  data.frame(oid, user_day_code, idplug_base, user_type_code, idunplug_base, 
                   travel_time, idunplug_station, age_range_code, idplug_station, unplug_hourtime, zip_code)
total<- rbind(total,res)

write.csv(total, file = "201704.csv",row.names=FALSE)

rm(tmp)

head(total)
# 
# 
# tmp <- readLines("/home/carlos/Downloads/201811_Usage_Bicimad.json")
# #tmp <- paste(tmp, collapse = " ")
# kk <- fromJSON(tmp)