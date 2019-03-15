library(rjson)
library(dplyr)
library(plyr)

#Encabezado del csv que voy a guardar
write.table(data.frame('oid', 'geo_type', 'longitude', 'latitude', 'type', 
                       'address', 'speed', 'secondsfromstart'), 'movimientos_coordenadas2018_dic.csv'  , append= T, sep=';', col.names=FALSE )



f<- function(var) {
 
  for (feature in var$track$features[]){
    oid<- var$`_id`
    geo_type<-feature$geometry$type
    latitude<-feature$geometry$coordinates[[1]]
    longitude<-feature$geometry$coordinates[[2]]
    type<- feature$type
    address<-feature$properties$var
    speed<-feature$properties$speed
    secondsfromstart<-feature$properties$secondsfromstart
    
    write.table(data.frame(oid, geo_type, latitude, longitude, type, 
                           address, speed, secondsfromstart), 'movimientos_coordenadas2018_dic.csv'  , append= T, sep=';', col.names=FALSE )
    
  }
}


kk <- readLines("C:/Users/Xseed/Desktop/Bicimad/201812aa")
kk= paste(kk, collapse="")
tmp <- fromJSON(kk)
rm(kk)
ldply(tmp$root[], f)

kk <- readLines("C:/Users/Xseed/Desktop/Bicimad/201812ab")
kk= paste(kk, collapse="")
tmp <- fromJSON(kk)
rm(kk)
ldply(tmp$root[], f)

kk <- readLines("C:/Users/Xseed/Desktop/Bicimad/201812ac")
kk= paste(kk, collapse="")
tmp <- fromJSON(kk)
rm(kk)
ldply(tmp$root[], f)


