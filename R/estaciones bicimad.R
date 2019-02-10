library(rjson)

stations <- readLines('https://rbdata.emtmadrid.es:8443/BiciMad/get_stations/WEB.SERV.gaston@gutrade.io/1326B978-2486-479C-B76E-15C4838F9345')
stations <- paste(stations, collapse = " ")
stations <- fromJSON(stations)
stations <- stations['data']
tmp<- fromJSON(stations[[1]])


all_stations <- (tmp[1]$stations) #Lista de estaciones

#Como convierto esto a un dataframe?


