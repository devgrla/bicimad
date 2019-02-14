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
* **Usos por día** . Se analiza según los datos obtenidos del catalogo abierto de madrid, los usos de las biciletas según distintos criterios, en el periodo 2015- 2018.
* **Accidentes con implicaciones de bicicleta 2018 - Madrid**
Se obtienen los datos de los accidentes con implicaciones de bicicletas. En la tabla miden el numero de victimas, la edad, el sexo, el distrito, la dirección y algunas condiciones climaticas y del estado del suelo. El archivo fue obtenido desde el catálogo de datos abiertos.
* **Bicis usos vs clima**
Se obtienen los datos del uso del sistema Bicimad, los cuales cuentan con fecha por día, tipo de usuario (Abonado anual/Abonado ocasional) y cantidades de uso por tipo de usuario. Adicionalmente se realiza un cruce con la base de datos del clima para identificar posibles relaciones entre la lluvia y la temperatura con el uso de las bicicletas.

## R




## data
