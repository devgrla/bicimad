library(lubridate)
library(reshape2)
library(ggplot2)

datos_uso_bici <- read.table("data/bicis_usos_acumulado por día.csv", sep=';' ,header = TRUE)
head(datos_uso_bici)

summary(datos_uso_bici)
str(datos_uso_bici)

colnames(datos_uso_bici) <- c("fecha","abono_anual", "abono_ocasional", "total", "anual_acumulado", "ocasional_acumulado", "total_acumulado")
head(datos_uso_bici)

datos_uso_bici$anual_acumulado<-NULL
datos_uso_bici$ocasional_acumulado <-NULL
datos_uso_bici$total_acumulado <- NULL

datos_uso_bici$mes <- month(dmy(datos_uso_bici$fecha))
datos_uso_bici$ano <- year(dmy(datos_uso_bici$fecha))
datos_uso_bici$dia_semana <- wday(dmy(datos_uso_bici$fecha), label = FALSE)
head(datos_uso_bici)

#Dia que mas se usaron las bicicletas de la historia.
head(datos_uso_bici[order(-datos_uso_bici$total),],1)

boxplot(datos_uso_bici$total ~ datos_uso_bici$mes, col = "gray",
        main = "Uso de bicicletas por mes")

#En junio y Julio hay datos raros. Los busco.
datos_uso_bici[datos_uso_bici$mes==6 & datos_uso_bici$total<500,]
#Son de los primeros meses. Están bien.

#Busco un dato muy alto que hay en abril
datos_uso_bici[datos_uso_bici$mes==4 & datos_uso_bici$total,]

media_mes<-tapply(datos_uso_bici$total, datos_uso_bici$mes, mean, na.rm = TRUE)
media_mes_anual<-tapply(datos_uso_bici$abono_anual, datos_uso_bici$mes, mean, na.rm = TRUE)
media_mes_ocasional<-tapply(datos_uso_bici$abono_ocasional, datos_uso_bici$mes, mean, na.rm = TRUE)

barplot(media_mes_ocasional, main = "Media de uso ocasional por mes")
barplot(media_mes_anual, main = "Media de uso anual por mes")

media_dia <- tapply(datos_uso_bici$abono_ocasional, datos_uso_bici$dia_semana , mean)
barplot(media_dia, main = "Media de uso ocasional por dia de la semana")

media_dia <- tapply(datos_uso_bici$abono_anual, datos_uso_bici$dia_semana , mean)
barplot(media_dia, main = "Media de uso anual por dia de la semana")

total_ano<-tapply(datos_uso_bici$total, datos_uso_bici$ano, sum)
barplot(total_ano, main = "Uso total por ano")

#Quiero graficar lo mismo de arriba pero en un mismo grafico
head(datos_uso_bici)
tmp_largo<- melt(datos_uso_bici, id.vars = c("fecha", "ano", "mes", "dia_semana"))
colnames(tmp_largo) <- c("fecha","ano", "mes", "dia_semana", "tipo", "usos")

p<-ggplot(data=tmp_largo, aes(x=mes, y=usos, fill=tipo)) + geom_bar(stat="summary") + theme_minimal()

p
# ggplot(tmp_largo, aes(x= total)) + geom_histogram()  + 
#   facet_grid(~ ano)
