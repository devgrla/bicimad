library(jsonlite)
library(plyr)
library(DT)
library(ggmap)

res <- fromJSON('https://rbdata.emtmadrid.es:8443/BiciMad/get_stations/WEB.SERV.gaston@gutrade.io/1326B978-2486-479C-B76E-15C4838F9345')

stations<- fromJSON(res$data)$stations

#Elimino algunas columnas del dataframe y le cambio el nombre a las columnas
stations$light <- NULL
stations$activate <- NULL
stations$no_available <- NULL
colnames(stations) <- c('id', 'latitud', 'longitud', 'nombre', 'numero', 'direccion', 'total_bases', 'total_disponibles', 'total_ocupadas', 'reservas')
stations$latitud <- as.numeric(as.character(stations$latitud))
stations$longitud <- as.numeric(as.character(stations$longitud))
stations$ocupacion <- (stations$total_disponibles / stations$total_bases) * 100

get_status <- function(x){
  ocupacion<- as.numeric(x[11])
  if(ocupacion> 75){
    return ('75% o más')
  } else if (ocupacion > 50 & ocupacion < 75 ){
    return('51% - 75%')
  } else if (ocupacion > 25 & ocupacion < 50 ){
    return('26% - 50%')
  } else{
    return('25% o menos')
  }
}

stations$estado_estacion <- apply(stations, 1, get_status) 

# Define UI for random distribution app ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Estaciones bicimad en tiempo real"),

  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      selectInput(inputId = "station",
                  label = "Seleccionar estación:",
                  choices = stations$nombre,
                  multiple = TRUE),
      
      checkboxGroupInput(inputId = "selected_var",
                         label = "Seleccionar atributos de estación:",
                         choices = names(stations),
                         selected = c("nombre", "direccion"))
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: tabsets
      tabsetPanel(type = "tabs",
                  tabPanel("Mapa", 
                           br(),
                           p("Los colores de las estaciones dependen de la disponibilidad de bicicletas que tengan, según los siguientes criterios"),
                           plotOutput("stationsMap", width = 1000, height = 800),
                           br(),
                           p("Información sobre la disponibilidad de bicicletas según las estaciones seleccionadas:"),
                           br(),
                           tableOutput("tablaMapa")
                           ),
                  tabPanel("Información estación", DT::dataTableOutput("tablaEstaciones")))
      )
      
    )
  )

# Define server logic for random distribution app ----
server <- function(input, output) {
  
  output$stationsMap <- renderPlot({
    
    if(length(input$station) > 0)
      tmp<- stations[stations$nombre %in% input$station,]
    else
      tmp<-stations
    
    unizar <- geocode('Teatro Amaya, Madrid, España', 
                      source = "google")
    
    map.unizar <- get_map(location = as.numeric(unizar),
                          color = "color",
                          maptype = "roadmap",
                          scale = 4,
                          zoom = 13)
    
    ggmap(map.unizar, legend = "topleft") + geom_point(aes(x = longitud, y = latitud,colour=estado_estacion), alpha = .7,
                                   data = tmp,
                                   size = 6)   +  theme(legend.position = "top",
                                                      legend.title = element_blank(),
                                                      legend.text = element_text(size = 14),
                                                      legend.spacing.x = unit(0.5, "lines"),
                                                      legend.key = element_rect(colour = "transparent", fill = alpha("red", 0))) + 
                                              scale_color_manual(values=c('#ab0000','#ff6600','#3333ff','#009933')) 
  })
  
  output$tablaMapa <- renderTable({
    if(length(input$station) > 0)
      tmp<- stations[stations$nombre %in% input$station,]
    else
      tmp<-stations
    tmp[, c("nombre", "total_disponibles", "total_bases")]
  })
  

  output$tablaEstaciones <- DT::renderDataTable({
    req(length(input$selected_var) > 1)
    if(length(input$station) > 0)
      tmp<- stations[stations$nombre %in% input$station,]
    else
      tmp<-stations
    DT::datatable(data = tmp[, input$selected_var], options = list(pageLength = 10, searching = FALSE, drop=FALSE,paging = FALSE))
  })
  
}

# Create Shiny app ----
shinyApp(ui, server)