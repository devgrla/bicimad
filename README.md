# BiciMAD
Proyecto para visualización de datos de bicimad.

Aprovechamos la ocasión, para insertar los datos limpios y tranformados en la base de datos que nos obligan armar para el TFM. Por eso puede que en algun archivo exista código con tal fin. En la mayoría de los casos, está comentado para que no vuelva a ejecutarse.

Hay 3 carpetas dentro del repositorio.
- **dat** que contiene los archivos con los datos utilizados para el análisis tanto en R como en Python.
- **R** que contiene los scripts y markdowns de R.
- **Python** que contiene los notebook del análisis realizado en Python

## Python

Se analizan varias fuentes de datos por separado. Se encuentran los siguientes archivos:

* **Calidad del aire - Madrid** . Analiza los datos de la contaminación de Madrid en el período 2015-2018. Los datos fueron obtenidos desde el catálogo de datos abiertos.
* **Clima Madrid** .  Se obtienen los datos desde el 2015 a principios de febrero 2019, a través de la Api de la AEMET. Esos datos están descargados en un archivo en la carpeta dat. De todas formas se puede consultar la API para cualquier periodo y utilizar esos datos en el análisis (Está explicado en el notebook).
* **Estaciones Bicimad en tiempo real** . Se obtiene la información del estado de las situaciones de Bicimad en tiempo real (mediante API) y se visualiza en mapa cada una diferenciandose según la disponibilidad que tengan en ese momento. Además se aprovecha esa información para guardar en BD las estaciones y su información general.
* **Usos por día** . Se analiza según los datos obtenidos del catalogo abierto de madrid, los usos de las biciletas según distintos criterios, en el periodo 2015- 2018. Se guarda además la información en la base de datos.
* **Accidentes Bicicletas**
Se obtienen los datos de los accidentes con implicaciones de bicicletas. El archivo fue obtenido desde el catálogo de datos abiertos. Se hace una limpieza de la información y un analisis visual de los datos. Tomamos los archivos del 2016, 2017 y 2018 y los unimos en un archivo maestro. 
* **Bicis usos vs clima**
Se obtienen los datos del uso del sistema Bicimad, los cuales cuentan con fecha por día, tipo de usuario (Abonado anual/Abonado ocasional) y cantidades de uso por tipo de usuario. Adicionalmente se realiza un cruce con la base de datos del clima para identificar posibles relaciones entre la lluvia y la temperatura con el uso de las bicicletas.

## R

* **Calidad del aire**. Analiza los datos de la contaminación de Madrid en el periodo 2015-2018. Los datos fueron obtenidos desde el catálogo de datos abiertos.
Hay dos archivos. _"Calidad del aire.rmd"_ donde se puede visualizar el código y un archivo llamado _"Calidad del aire.html"_ donde ya se visualiza el markdown ejecutado en formato Html. Para visualizar el resultado, se recomienda ir directo al archivo html ya que el markdown tarda un poco en completar de ejecutarse, debido a varios calculos que realiza.

* **Estaciones bicimad en tiempo real**. Dentro de la carpeta R, existe una carpeta llamada "estacionesbicimad" que contiene un markdown integrado con una aplicación shiny ("_estaciones_tiempo_real.Rmd_") para mostrar de forma interactiva la disponibilidad de bicicletas y la información de las estaciones en tiempo real, utilizando una API con tal fin.

* **Mapa de ocupacion de estaciones**.  Dentro de la carpeta R, se generó un markdown integrado con una aplicación de shiny (archivo llamado _Mapa de ocupacion de estaciones.Rmd_ para mostrar de forma interactiva la disponibilidad de bicicletas según el dia y la hora que desee el usuario, utilizando para ello un json. (en este markdown, no se pusieron tildes en las palabras ya que fallaba al ejecutarla en otro ordenador, esto era a pesar de ser un cometario.

* **Estaciones_estado_201811(Mapa de calor)**. Dentro de la carpeta R, se generó un markdown integrado con una aplicación de shiny para mostrar (_Llamado Estaciones_estado_201811(Mapa de calor).Rmd_) de forma interactiva la disponibilidad de bicicletas a través de un mapa de calor. Usa la misma base de datos que el markdown anterior. 

* **Informe_uso_bicimad_markdown** Dentro de la carpeta R se ingresó un informe sobre el comportamiento de la demanda del sistema de Bicimad en relación a dos tipos de usuarios, los abonados anuales y los abonados ocasionales. Se representa las distribuciones de la demanda por año, por meses y días de la semana. Adicionalmente se cruza con la base de datos del clima para identificar relaciones entre el uso del sistema y la lluvia y la temperatura. El archivo esta en formato Markdown y html.

* **Accidentes**
Se obtienen los datos de los accidentes con implicaciones de bicicletas. El archivo fue obtenido desde el catálogo de datos abiertos. Se hace una limpieza de la información y un analisis visual de los datos. Hay dos archivos. _"Accidentes.rmd"_ donde se puede visualizar el código y un archivo llamado _"Accidentes.html"_ donde ya se visualiza el markdown ejecutado en formato Html.

## data
