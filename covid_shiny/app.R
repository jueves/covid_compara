library(shiny)
library(tidyverse)
library(lubridate)
library(jsonlite)

ui <- fluidPage(

    titlePanel("Evolución de casos activos"),
    
    sidebarLayout(
        mainPanel(
            plotOutput("distPlot")
        ),
        sidebarPanel(
            selectInput("unit",
                        "Unidad de medida",
                        choices=c(#"Casos activos por Km²"),
                                 "Casos activos por cada 100.000 hab",
                                 "Casos activos totales")
                        ),
            selectizeInput(
                inputId = "locations",
                label = "Municipio",
                choices = c(),
                multiple=TRUE,
                selected=c("LA PALMA - ALL", "La Laguna")
                )
            )
    ),

    HTML("<p>Evolución del número absoluto de casos activos de SARS-CoV-2.</p>
    <p>Este proyecto se encuentra en desarrollo y los resultados mostrados pueden ser incorrectos.
    <a href=\"https://github.com/jueves/covid_compara\">Más información.</a></p>
<p>Fuentes:<br>
         <a href=\"https://grafcan1.maps.arcgis.com/apps/opsdashboard/index.html#/156eddd4d6fa4ff1987468d1fd70efb6\">Grafcan</a><br>
         <a href=\"https://datos.canarias.es/catalogos/general/dataset/datos-epidemiologicos-covid-19\">Canarias Datos Abiertos</a></p>")
)

server <- function(input, output, session) {
    data <- read.csv("https://github.com/jueves/covid_canarias_data/raw/main/data/cv19_asignacion_agrupados_collected.csv")
    
    # Get full island data
    data$fecha_datos <- dmy(data$fecha_datos)
    data %>%
        filter(!str_detect(municipio, "- ALL")) %>%
        group_by(fecha_datos, isla) %>%
        summarise(fecha_datos, isla,
                  poblacion=sum(poblacion),
                  cv19_activos=sum(cv19_activos, na.rm=TRUE),
                  cv19_total_casos=sum(cv19_total_casos, na.rm=TRUE),
                  cv19_fallecidos=sum(cv19_fallecidos, na.rm=TRUE),
                  cv19_curados=sum(cv19_curados, na.rm=TRUE),
                  municipio = paste(isla, "- ALL")) -> data_isla_ALL
    
    data <- bind_rows(data, data_isla_ALL)
    
    data$isla <- factor(data$isla)
    data$municipio <- factor(data$municipio)
    
    # Get default municipio levels
    default_municipios_string <- c("LA PALMA - ALL", "La Laguna")
    default_municipios_boolean <- as.character(data$municipio) %in% default_municipios_string
    default_municipios_factor <- unique(data$municipio[default_municipios_boolean])
    
    # Update selectize input
    updateSelectizeInput(
        session, "locations", choices = levels(data$municipio),
        selected = default_municipios_factor
    )
    
    
    # Set colors
    my_colors <- c("#ff5454", "#428bca")
    names(my_colors) <- c("La Laguna", "LA PALMA - ALL")
    
    # Plot data
    output$distPlot <- renderPlot({
        data <- filter(data, municipio %in% input$locations)
        
        if (input$unit == "Casos activos totales") {
            ggplot(data, aes(fecha_datos, cv19_activos, color=municipio))+geom_line()+
                labs(title="Casos activos totales")#+
                #scale_color_manual(name="municipio", values=my_colors)
        } else if (input$unit == "Casos activos por Km²") {
            data %>%
                mutate(area=sapply(municipio, function(location) metadata[[location]]$area )) %>%
                mutate(activos_por_km2 = cv19_activos/area) %>%
                ggplot(aes(fecha_datos, activos_por_km2, color=municipio))+geom_line()+
                labs(title="Casos activos por Km²")+
                scale_color_manual(name="municipio", values=my_colors)
        } else if (input$unit == "Casos activos por cada 100.000 hab") {
            data %>%
                #mutate(population=sapply(municipio, function(location) metadata[[location]]$population)) %>%
                mutate(activos_por_100000hab = cv19_activos*100000/poblacion) %>%
                ggplot(aes(fecha_datos, activos_por_100000hab, color=municipio))+geom_line()+
                labs(title="Casos activos por cada 100.000 habitantes")#+
                #scale_color_manual(name="municipio", values=my_colors)
        }
    })
}

shinyApp(ui = ui, server = server)
