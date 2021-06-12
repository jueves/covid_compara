library(tidyverse)
library(lubridate)

data_grouped <- read.csv("https://github.com/jueves/covid_canarias_data/raw/main/data/cv19_asignacion_agrupados.csv")
data_grouped$fecha_datos <- dmy(data_grouped$fecha_datos)

data_manual <- read.csv("data/cv19_asignacion_agrupados_manual.csv")
data_manual$fecha_datos <- dmy(data_manual$fecha_datos)

estimated_actives <- read.csv("data/cv19_asignacion_agrupados_estimated.csv")
estimated_actives$fecha_datos <- dmy(estimated_actives$fecha_datos)

data_all <- bind_rows(list(downloaded=data_grouped, estimated=estimated_actives, manual=data_manual), .id="id")

data_all %>%
  group_by(fecha_datos, municipio) %>%
  count() %>%
  filter(n>1)

data_all %>%
  filter(as.character(municipio)=="La Laguna") %>%
  rename(data_origin=id) %>%
  ggplot(aes(fecha_datos, cv19_activos, color=data_origin))+geom_line()+labs(title="Active cases in La Laguna")