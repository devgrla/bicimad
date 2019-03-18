library(rjson)
library(dplyr)
library(plyr)

#Encabezado del csv que voy a guardar
write.table(data.frame('oid', 'geo_type', 'longitude', 'latitude', 'type', 
                       'address', 'speed', 'secondsfromstart'), 'movimientos_coordenadas2019_ene.csv'  , append= T, sep=';', col.names=FALSE )



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
                           address, speed, secondsfromstart), 'movimientos_coordenadas2019_ene.csv'  , append= T, sep=';', col.names=FALSE )
    
  }
}


kk <- readLines("C:/Users/Xseed/Google Drive/EAE/TFM - Datos y documentos/Datos y descripción/Datos/BiciMad/Movimientos Sin procesar/xaa.json")
kk= paste(kk, collapse="")
tmp <- fromJSON(kk)
rm(kk)
ldply(tmp$root[], f)

kk <- readLines("C:/Users/Xseed/Google Drive/EAE/TFM - Datos y documentos/Datos y descripción/Datos/BiciMad/Movimientos Sin procesar/xab.json")
kk= paste(kk, collapse="")
tmp <- fromJSON(kk)
rm(kk)
ldply(tmp$root[], f)

kk <- readLines("C:/Users/Xseed/Google Drive/EAE/TFM - Datos y documentos/Datos y descripción/Datos/BiciMad/Movimientos Sin procesar/xac.json")
kk= paste(kk, collapse="")
tmp <- fromJSON(kk)
rm(kk)
ldply(tmp$root[], f)


