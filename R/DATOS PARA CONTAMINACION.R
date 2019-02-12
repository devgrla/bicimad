library(reshape2)
library(tidyr)
library(json)
data2018 <- read.csv("../dat/calidadaire2018.csv", encoding = 'UTF-8', sep=';')
head(data2018)

data2018.copy <- data2018
data2018.copy$PROVINCIA <- NULL
data2018.copy$MUNICIPIO <- NULL
data2018.copy$PUNTO_MUESTREO <- NULL

estaciones_utilizar <- c(24,35,48,49,58)
magnitudes_interes <- c(1,6,8,9,10,14)

data2018.copy <- data2018.copy[data2018.copy$ESTACION %in% estaciones_utilizar,]
data2018.copy <- data2018.copy[data2018.copy$MAGNITUD %in% magnitudes_interes,]

data2018.copy <- melt(data2018.copy, id.vars = c('ESTACION', 'MAGNITUD', 'ANO', 'MES'), na.rm = TRUE)


get_date_from_columns <- function(year, month, day){
  m <-regexpr("[0-9]+", day, perl=TRUE)
  day<- regmatches(day, m)
  as.Date(paste(year, month, day, sep='-'))
}

convert_to_only_letters <- function(variable){
  m <-regexpr("[A-Z]+", variable, perl=TRUE)
  letter<- regmatches(variable, m)
  letter
}

data2018.copy$fecha <- get_date_from_columns(data2018.copy$ANO, data2018.copy$MES, data2018.copy$variable) 
data2018.copy <- data2018.copy[!is.na(data2018.copy$fecha),]
data2018.copy$variable <- as.character(convert_to_only_letters(data2018.copy$variable))


data2018_formatted_D = data2018.copy[data2018.copy$variable == 'D',]
data2018_formatted_V = data2018.copy[data2018.copy$variable == 'V',]

data2018.copy = merge(data2018_formatted_D,data2018_formatted_V, by=c('fecha','MAGNITUD', 'ESTACION'))
data2018.copy = data2018.copy[data2018.copy$value.y == 'V',] #Me quedo solo con las filas que tienen valor valido

data2018.copy$variable.y<-NULL
data2018.copy$value.y<-NULL
data2018.copy$MES.y<-NULL
data2018.copy$ANO.y<-NULL
data2018.copy$variable.x<-NULL

colnames(data2018.copy) <- c('fecha', 'magnitud', 'estacion', 'ano', 'mes', 'medicion')
data2018.copy$medicion <- as.numeric(data2018.copy$medicion)

#Magnitud y estacion la convierto a texto
data2018.copy[data2018.copy$estacion == 49,]$estacion <- 'Retiro'
data2018.copy[data2018.copy$estacion == 35,]$estacion <- 'Plaza del carmen'
data2018.copy[data2018.copy$estacion == 48,]$estacion <- 'Castellana'
data2018.copy[data2018.copy$estacion == 58,]$estacion <- 'El Pardo'
data2018.copy[data2018.copy$estacion == 24,]$estacion <- 'Casa de Campo'

data2018.copy[data2018.copy$magnitud == 1,]$magnitud <- 'Dioxido de Azufre SO2'
data2018.copy[data2018.copy$magnitud == 6,]$magnitud <- 'Monoxido de carbono CO'
data2018.copy[data2018.copy$magnitud == 8,]$magnitud <- 'Dioxido de nitrogeno NO2'
data2018.copy[data2018.copy$magnitud == 9,]$magnitud <- 'PM 2.5'
data2018.copy[data2018.copy$magnitud == 10,]$magnitud <-'PM10'
data2018.copy[data2018.copy$magnitud == 14,]$magnitud <-'Ozono3'
# transform(tasa.paro, tasa.paro = unemployed / active)
# 
# head(data2)
