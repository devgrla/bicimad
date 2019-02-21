#importar datos

ac_2018 <- read.delim("dat/AccidentesBicicletas_2018.csv", sep = ";", header = TRUE)
ac <- ac_2018
summary(ac)
typeof(ac)
library(reshape2)

library(ggplot2)

#eliminamos las columnas que creemos que no son necesarios (aportan poca informacion)

colnames(ac)
ac[c(8,9,11,13,15:16,19)] <- list(NULL)

#modificamos los nombres de los campos restantes
colnames(ac) <- c("fecha","hora","dia_semana","distrito","lugar_accidente","Numero_accidente","n_parte","cpfa_lluvia","cpfa_seco","cpsv.mojada","cpsv_grava_suelta","cpsv_hielo","n_victimas","tipo_accidente","tipo_vehiculo","tipo_persona","sexo","lesividad","edad")

#cosas a cambiar
  #Fecha
  #Rango.Horario
  #tramo.edad

#Cambiamos las fechas al formato fechas
ac$fecha <- as.Date(ac$fecha, "%d/%m/%Y")

#agregamos la columna mes y ponemos el mes en cuestion.

ac$mes <- format(ac$fecha, "%b") 

#agregamos la columna mes y ponemos el dia en cuestion.

ac$dia <- format(ac$fecha, "%d") 
tail(ac)


#Rango.Horario

  #quitamos los de
head(ac)

  #quitamos los "A" y la hora despues

ac$hora <- gsub("DE ", "",ac$hora)
ac$hora <- gsub("A [0-9]+:[0-9]+$", "",ac$hora)
ac$hora <- gsub(" ", "",ac$hora)
head(ac)

#Cambiamos tramo.edad (solo el primero)

ac$edad <- gsub("DE ", "",ac$edad)
ac$edad <- gsub("A [0-9][0-9] AÑOS", "",ac$edad)
ac$edad <- gsub("A [0-9][0-9] ANOS", "",ac$edad)
ac$edad <- gsub(" ", "",ac$edad)
data(ac)

colnames(ac)

y$nv_medias <- ac[ac$n_victimas] 
y <- ac[ac$n_victimas<14]
y <- ac[ac$n_victimas< 14,]
yhead(y)
ac[y]

ggplot(data=y, aes(x=distrito, y=n_victimas, fill=sexo)) + 
  geom_bar(stat="identity", position="dodge")



