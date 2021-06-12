library(tidyverse)
library(lubridate)

# Get La Laguna dataset
read.csv("data/manual - la_laguna.csv") %>%
  mutate(isla="TENERIFE",
         municipio="La Laguna",
         poblacion=158911) -> old_la_laguna

# Get La Palma dataset
read.csv("data/manual - la_palma.csv") %>%
  select(fecha, casos_activos) %>%
  mutate(isla="LA PALMA",
         municipio="LA PALMA - ALL",
         poblacion=82671) -> old_la_palma

# Merge and export datasets
bind_rows(old_la_laguna, old_la_palma) %>%
  rename(fecha_datos=fecha, cv19_activos=casos_activos) %>%
  mutate(fecha_datos=format(dmy(fecha_datos), "%d/%m/%Y"),
         cv19_total_casos=NA,
         cv19_fallecidos=NA,
         cv19_curados=NA) %>%
  write_csv("data/cv19_asignacion_agrupados_manual.csv", na="")
