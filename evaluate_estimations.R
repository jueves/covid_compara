library(tidyverse)
library(lubridate)

data_grouped <- read.csv("https://github.com/jueves/covid_canarias_data/raw/main/data/cv19_asignacion_agrupados_collected.csv")
                #read.csv("https://github.com/jueves/covid_canarias_data/raw/main/data/cv19_asignacion_agrupados.csv")
data_grouped$fecha_datos <- dmy(data_grouped$fecha_datos)

data_manual <- read.csv("data/cv19_asignacion_agrupados_manual.csv")
data_manual$fecha_datos <- dmy(data_manual$fecha_datos)

data_estimated <- read.csv("data/cv19_asignacion_agrupados_estimated.csv")
data_estimated$fecha_datos <- dmy(data_estimated$fecha_datos)

data_all <- bind_rows(list(downloaded=data_grouped, estimated=data_estimated,
                           manual=data_manual), .id="data_origin")

# Check for duplicated measurements
data_all %>%
  group_by(fecha_datos, municipio, data_origin) %>%
  count() %>%
  filter(n>1)

# Plot
data_all %>%
  filter(as.character(municipio)=="La Laguna") %>%
  ggplot(aes(fecha_datos, cv19_activos, color=data_origin))+geom_line()+
        labs(title="Active cases in La Laguna")
