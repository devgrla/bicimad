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






