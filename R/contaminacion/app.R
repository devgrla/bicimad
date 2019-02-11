#La parte UI donde van los textos, sliders, inputs. 
#Sale una linea roja.
#https://github.com/rstudio/shiny-examples/tree/master/051-movie-explorer
library(shiny)

# Define UI for app that draws a histogram ----
ui <- fluidPage(
  
  # App title ----
  titlePanel("Hola Shiny!"),
  
  # Sidebar layout with input and output definitions ----
  sidebarLayout(
    
    # Sidebar panel for inputs ----
    sidebarPanel(
      
      # Input: Slider for the number of bins ----
      sliderInput(inputId = "bins",
                  label = "Número de bins:",
                  min = 1,
                  max = 100,
                  value = 30),
      
      uiOutput("interaction_slider"),
      # Input: Numeric entry for number of obs to view ----
      numericInput(inputId = "rowsq",
                   label = "numero de filas de tabla",
                   value = 10)
      
    ),
    
    # Main panel for displaying outputs ----
    mainPanel(
      
      # Output: tabsets
      tabsetPanel(type = "tabs",
                  tabPanel("Grafica", plotOutput(outputId = "distPlot")),
                  tabPanel("Tabla Iris", tableOutput("tablaIris")))
    )
  )
)

# Define server logic required to draw a histogram ----
server <- function(input, output) {
  
  # Histogram of the Old Faithful Geyser Data ----
  # with requested number of bins
  # This expression that generates a histogram is wrapped in a call
  # to renderPlot to indicate that:
  #
  # 1. It is "reactive" and therefore should be automatically
  #    re-executed when inputs (input$bins) change
  # 2. Its output type is a plot
  output$distPlot <- renderPlot({
    
    x    <- faithful$waiting
    bins <- seq(min(x), max(x), length.out = input$bins + 1)
    
    hist(x, breaks = bins, col = "#75AADB", border = "white",
         xlab = "Tiempo de espera a siguiente erupción (en minutos)",
         main = "Tiempos de espera (Histograma")
    abline(v=input$interaction_slider, col="red")
    
    
  })
  
  output$tablaIris <- renderTable({
    head(iris, input$rowsq)
  })
  
  output$interaction_slider <- renderUI({
    
    sliderInput("interaction_slider","Valor para linea", min= min(faithful$waiting),
                max   = max(faithful$waiting),
                value = 50)
    
  })
  
}

# Create Shiny app ----
shinyApp(ui = ui, server = server)