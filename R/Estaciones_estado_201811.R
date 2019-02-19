library(rjson)
library(dplyr)
library(plyr)

kk <- readLines("data/Bicimad_Stations_201811.json", encoding='ISO-8859-1')
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

prueba<-data.frame(total)

#ponemos formato a fecha

prueba$id <- strptime(prueba$id,format='%Y-%m-%dT%H:%M:%S')

#Generamos columna hora

prueba$hora <- format(prueba$id, "%X")

#Generamos columna fecha

prueba$fecha <- format(prueba$id, "%x")

#porcentaje de disponibilidad

prueba$porcentaje_bicis <- (prueba$dock_bikes/prueba$total_bases)*100

prueba$latitude <- as.numeric(as.character(prueba$latitude))
prueba$longitude <- as.numeric(as.character(prueba$longitude))

#########################

# cargamos libreria
library("ggmap")

# descargamos el mapa de Chile desde Google
register_google("AIzaSyCjQ7z4QwZUU7l1U8iBJ6ASX_srvbdZfNk", write = TRUE)
map <- get_map(location = 'Madrid', zoom = 13, maptype = "terrain")

# pintamos los puntos de nuestro data frame en el mapa
biciMAD <- ggmap(map) + geom_point(data=prueba, aes(x=longitude, y=latitude, colour=porcentaje_bicis),
                                   alpha = 0.6, show.legend = FALSE, size=4)


# generamos el mapa
biciMAD


ciudad <- get_map("Madrid, España", zoom=13)
p      <- ggmap(ciudad)
p      <- p+stat_density2d(aes(x = longitude, y = latitude, fill=porcentaje_bicis), 
                           data=prueba,geom="polygon", alpha=0.2)
p + scale_fill_gradient(low = "yellow", high = "red")

