library(lubridate)
library(ggplot2)
library(reshape2)


biciusos <- read.table("bicis_usos_acumulado por día.csv",sep=";",header = TRUE)

#Exploramos el dataframe
dim(biciusos)

rbind(head(biciusos),tail(biciusos))

summary(biciusos)

str(biciusos)

biciusos$X<-NULL

co.biciusos<- biciusos# Se genera copia de la tabla

#Se reasignan nombre a las columnas.
colnames(co.biciusos)<- c('fecha','abo_anual', 'abo_ocas','total_abo',
                         'usoanual_acum','usoocas_acum', 'usototal_acum'   )

#Confirmamos la buena reasignación de nombres 
colnames(co.biciusos)



#Inspeccionamos la tabla: la media, la mediana, la mínima, la máxima de la tabla y sus 
#columnas.
summary(co.biciusos)

#La columna 'fecha' se encuentra en formato Factor, por lo cual Generamos conversión a
# formato caracter y luego a date

co.biciusos$fecha<-as.Date(as.character(dmy(co.biciusos$fecha)))

#Ahora extraemos de la fecha el año y el mes, y creamos columnas nuevas para cada dato
#nuevo

co.biciusos$ano<- year(co.biciusos$fecha)
co.biciusos$mes<- month(co.biciusos$fecha, label = TRUE)
co.biciusos$dia_semana<- wday(co.biciusos$fecha, label=TRUE)

#Con las columnas nuevas ya determinadas, procedemos a eliminar columnas que no nos
#aportaban mayor análisis
co.biciusos$usoanual_acum<-co.biciusos$usoocas_acum<-co.biciusos$usototal_acum<-NULL

#####################################GRAFICAS######################################

#Consultamos nuevamente los datos para mayor claridad en las gráficas
rbind(head(co.biciusos),tail(co.biciusos))


#Boxplot para ver la distribución de la demanda total por año

boxplot(co.biciusos$total_abo~co.biciusos$ano , xlab = 'Año', 
        ylab = 'Cantidad Usos', col = c(123,124,125,126,127), main='Distribución de la demanda total por año',
        ylim=c(500,18000) )
abline(h = mean(co.biciusos$total_abo), col = "red")

#Boxplot sobre la distribución de la Demanda ocasionada por el Usuario de Abono ocasional.
boxplot(co.biciusos$abo_ocas~co.biciusos$ano , xlab = 'Año', 
        ylab = 'Cantidad Usos', col = c(100,107,110,120,130), main='Distribución de la demanda Usuario Ocasional por año',
        ylim=c(0,800) )
abline(h = mean(co.biciusos$abo_ocas), col = "red")


#Histograma para analizar la distribución de la demanda de abonados anuales del sistema.
hist(co.biciusos$abo_anual, main = "Distribución de la demanda 'Abonados Anuales' 2014-2018",
     xlab = "Cantidad de Uso", ylab = "Frecuencia de Uso",
     col = "violetred1")



#Histograma para analizar la distribución de la demanda de abonados ocasionales del sistema.
hist(co.biciusos$abo_ocas, main = "Distribución de la demanda 'Abonados Ocasionales",
     xlab = "Cantidad de Uso", ylab = "Frecuencia de Uso",
     col = "chartreuse")


#Con el fin de exprimir un poco los datos vamos a aplicar un melt para analizar otra 
#perspectiva de los usos por usuario. Para esto crearemos una segunda tabla llamada
#'co.biciusosmelt'.
#'
head(co.biciusosmelt<-melt(co.biciusos,id.vars = c('fecha','total_abo','ano','mes','dia_semana' )))

#Reasignamos nonmbre a la nueva columna generada por la función Melt.
names(co.biciusosmelt)[6]<-'tipo_usuario'

#Para visualizar la diferencia en las escalas con la función melt aplicada, visualizamos una gráfica tipo
#Bartplot donde aplicamos la Media de uso por tipo de usuario. 
tmp<-tapply(co.biciusosmelt$value,co.biciusosmelt$tipo_usuario, mean)
tmp
barplot(tmp, main = "Media de uso por tipo de Usuario",
        ylab = "Media de Uso (veces)", xlab = "Tipo de usuario",
        col = "darkgoldenrod1")


#Balplot por la columna variable
barplot(table(co.biciusosmelt$tipo_usuario))#No está saliendo bien, sale la misma cantidad para ambos usuarios
#Esta barplot sí sale bien, lo que dice es que siempre(todos los días) hubo uso de ambos tipos de usuarios.
#Es decir, la frecuencia de la variable categórica TIPO DE USUARIO


#Gráfica para poder ver la relación entre la demanda de abo anuales y abo ocasionales
plot(co.biciusos$abo_anual,co.biciusos$abo_ocas)
g1 <- ggplot(co.biciusos, aes(x=abo_anual, y=abo_ocas))
g1 + geom_point(aes(size=abo_anual,color=abo_anual))+
  labs(title = 'Relación entre demande de usuario anual y ocasional', y='Abonado ocasional',
       x='Abonado Anual')


ggplot(co.biciusosmelt, aes(x=ano, y=value, colour=tipo_usuario )) + geom_col()+ facet_grid(~ano)

ggplot(co.biciusosmelt, aes(x = dia_semana, y = value, colour = variable)) + geom_()

#Grafica sobre el comportamiento de la demanda por día, por mes por tipo de usuario
gg1<-ggplot(co.biciusosmelt )+
  geom_point(aes(x=dia_semana, y= value, color= tipo_usuario))+
  geom_smooth(aes(x=dia_semana, y= value))
gg1 + facet_wrap(~mes,ncol = 6) +
  labs(title="Comportamiento de la demanda por usuario 2014-2018", 
       x="Día de la semana/Mes", y="Cantidad de usos")       

#Grafica sobre el comportamiento de la demanda anual por mes por tipo de usuario
gg2<-ggplot(co.biciusosmelt )+
  geom_point(aes(x=ano, y= value, color= tipo_usuario))+
  geom_smooth(aes(x=ano, y= value))
gg2 + facet_wrap(~mes,ncol = 6) +
  labs(title="Comportamiento de la demanda por usuario Anual 2014-2018", 
       x="Año", y="Cantidad de usos")  


#Ahora vamos a cruzar la tabla de 'co.bicisusos' con una tabla del clima.

#Realizamos la importación de los datos los cuales están en formato .csv

clima <- read.table("all_weather_data.csv",sep=",",header = TRUE)

#Procedemos a la inspección de rutina de los datos

dim(clima)

rbind(head(clima),tail(clima))

summary(clima)

str(clima)

#Como primera medida vamos a eliminar las columnas que no necesitamos y verificamos luego
#con Head()

clima$X<-clima$hour_temp_max<-clima$hour_temp_min<-clima$temp_max<-clima$temp_min<-NULL
clima$wind_speed<-clima$wind_speed_max<-NULL
head(clima)


#La idea es cruzar los datos de usos con la lluvia, columna 'precipitation' y la temperatura
#media, columna 'temp_media, así podremos ver si existe relación entre estas dos variable y el
#uso del sistema. Para esto vamos a convertir la clase de dato de la columna 'fecha' la cual 
#viene en formato 'factor' a 'Date'.

clima$date<-as.Date(as.character(clima$date, 'y%/m%/%d'))

str(clima)

#El cruce de las dos trablas las haremos con la función MERGE. Crearemos una tabla nueva
#llamada 'usoclima' .En este caso son tablas donde la columna con la fecha tiene distintos 
#nombres, además en la tabla 'clima' solo aparece información desde 2015, motivo por el cual 
#especificaremos en la sentencia las columnas por el cual se hace el cruce, y desecharemos 
#las fechas antes de 2015 en la tabla de 'Usos'.

usoclima<- merge(co.biciusos, clima, by.x = 'fecha', by.y = 'date')

usoclima2<- merge(co.biciusosmelt, clima, by.x = 'fecha', by.y = 'date')
#Corroboramos la nueva tabla 'usoclima'
head(usoclima)
head(usoclima2)
#Relación del uso en abonados anuales con la temperatura
gg3<-ggplot(usoclima, aes(x=temp_media, y=abo_anual, color='red'))+
  geom_point()+geom_smooth(method="lm", color='blue')+
  labs(title="Uso abonados anuales vs temperatura 2014-2018", 
       x="Temperatura Media", y="Cantidad Usos")
gg3

#Relación del uso en abonados ocasionales con la temperatura
gg4<-ggplot(usoclima, aes(x=temp_media, y=abo_ocas))+
  geom_point( color='blue')+geom_smooth(method="lm", color='red')+
  labs(title="Uso abonados ocasionales vs Temperatura 2014-2018", 
       x="Temperatura Media", y="Cantidad Usos")
gg4

#Relación entre la lluvia y el uso del sistema por ussuarios
gg5<-ggplot(usoclima2, aes(x=precipitation, y=value, color=tipo_usuario))+
  geom_point()+geom_smooth(method="lm", color= 'purple4')+
  labs(title="Uso del sistema vs LLuvia 2014-2018", 
       x="Precipitación", y="Cantidad de usos")
gg5
