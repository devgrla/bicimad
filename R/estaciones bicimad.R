library(rjson)
library(plyr)

library(ggmap)

register_google("AIzaSyCjQ7z4QwZUU7l1U8iBJ6ASX_srvbdZfNk", write = TRUE)

stations <- readLines('https://rbdata.emtmadrid.es:8443/BiciMad/get_stations/WEB.SERV.gaston@gutrade.io/1326B978-2486-479C-B76E-15C4838F9345')
stations <- paste(stations, collapse = " ")
stations <- fromJSON(stations)
stations <- stations['data']
stations<- fromJSON(stations[[1]])
stations<- ldply(stations$stations, as.data.frame) #Tomo una lista y la convierto a dataframe

stations$latitude <- as.numeric(as.character(stations$latitude))
stations$longitude <- as.numeric(as.character(stations$longitude))
stations$ocupacion <- (stations$dock_bikes / stations$total_bases) * 100

unizar <- geocode('Teatro Amaya, Madrid, España', 
                  source = "google")

map.unizar <- get_map(location = as.numeric(unizar),
                      color = "color",
                      maptype = "roadmap",
                      scale = 2,
                      zoom = 13)

ggmap(map.unizar) + geom_point(aes(x = longitude, y = latitude),
                               data = stations, colour = 'red',
                               size = 2)

get_status <- function(ocupacion){
  if(ocupacion> 75){
    return ('Disponibilidad > 75%')
  } else if (ocupacion > 50 & ocupacion < 75 ){
    return('Disponibilidad 50-75%')
  } else if (ocupacion > 25 & ocupacion < 50 ){
    return('Disponibilidad 25-50%')
  } else{
    return('Disponibilidad < 25%')
  }
}


stations$estado_estacion <- ''

for (i in 1:nrow(stations)) {
  n <- get_status(stations[i,14])
  print(n)
  stations$estado_estacion[i] <- n
}


ggmap(map.unizar) + geom_point(aes(x = longitude, y = latitude,colour=estado_estacion),
                               data = stations,
                               size = 2)
