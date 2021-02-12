library(shiny)
library(tidyverse)
library(readODS)
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
                        choices=c("Casos activos totales",
                                  "Casos activos por Km²",
                                  "Casos activos por cada 100.000 hab")),
            checkboxGroupInput("locations",
                               "Lugares",
                               choices=c("la_palma",
                                         "la_laguna"),
                               selected=c("la_palma",
                                          "la_laguna"))
        )
    ),
    HTML("<a href=\"https://github.com/jueves/covid_compara\">Código del proyecto</a></li>
          <br><a href=\"https://grafcan1.maps.arcgis.com/apps/opsdashboard/index.html#/156eddd4d6fa4ff1987468d1fd70efb6\">Origen de los datos</a>"),
)

server <- function(input, output) {
    base_url <- "https://docs.google.com/spreadsheets/d/1aXRIP2MnSBIIi5-kPnmawnCAXJZNiNuJy0WD4Zb0HvM/gviz/tq?tqx=out:csv&sheet="
    data_lp <- read.csv(paste0(base_url, "la_palma"))
    data_lgn <- read.csv(paste0(base_url, "la_laguna"))
    metadata <- fromJSON("https://github.com/jueves/covid_compara/raw/main/metadata.json")

    data_lp %>%
        mutate(fecha=dmy(fecha)) %>%
        mutate(lugar="la_palma") %>%
        select(fecha, casos_activos, hospitalizados, lugar) -> data_lp

    data_lgn %>%
        mutate(fecha=dmy(fecha)) %>%
        mutate(lugar="la_laguna") %>%
        mutate(hospitalizados = NA) %>%
        select(fecha, casos_activos, hospitalizados, lugar) -> data_lgn

    data <- bind_rows(data_lp, data_lgn)

    # Set colors
    my_colors <- c("#ff5454", "#428bca")
    names(my_colors) <- c("la_laguna", "la_palma")
    
    output$distPlot <- renderPlot({
        data <- filter(data, lugar %in% input$locations)
        
        if (input$unit == "Casos activos totales") {
            ggplot(data, aes(fecha, casos_activos, color=lugar))+geom_line()+
                labs(title="Casos activos totales")+
                scale_color_manual(name="lugar", values=my_colors)
        } else if (input$unit == "Casos activos por Km²") {
            data %>%
                mutate(area=sapply(lugar, function(location) metadata[[location]]$area )) %>%
                mutate(activos_por_km2 = casos_activos/area) %>%
                ggplot(aes(fecha, activos_por_km2, color=lugar))+geom_line()+
                labs(title="Casos activos por Km²")+
                scale_color_manual(name="lugar", values=my_colors)
        } else if (input$unit == "Casos activos por cada 100.000 hab") {
            data %>%
                mutate(population=sapply(lugar, function(location) metadata[[location]]$population)) %>%
                mutate(activos_por_100000hab = casos_activos*100000/population) %>%
                ggplot(aes(fecha, activos_por_100000hab, color=lugar))+geom_line()+
                labs(title="Casos activos por cada 100.000 habitantes")+
                scale_color_manual(name="lugar", values=my_colors)
        }
    })
}

shinyApp(ui = ui, server = server)
