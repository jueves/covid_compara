library(tidyverse)
library(lubridate)

# Load datasets
data_grouped <- read.csv("https://github.com/jueves/covid_canarias_data/raw/main/data/cv19_asignacion_agrupados.csv")
data_ungrouped <- read.csv("https://opendata.sitcan.es/upload/sanidad/cv19_municipio-asignacion_casos.csv")
old_la_palma <- read.csv("data/prueba_la_palma - la_palma.csv")
old_la_laguna <- read.csv("data/prueba_la_palma - la_laguna.csv")

data_grouped$fecha_datos <- dmy(data_grouped$fecha_datos)

# Transform La Laguna data
names(old_la_laguna) <- c("fecha_datos", "cv19_activos")
old_la_laguna$fecha_datos <- dmy(old_la_laguna$fecha_datos)
old_la_laguna["isla"] <- "TENERIFE"
old_la_laguna["municipio"] <- "La Laguna"
old_la_laguna["poblacion"] <- 158911
old_la_laguna["cv19_total_casos"] <- NA
old_la_laguna["cv19_fallecidos"] <- NA
old_la_laguna["cv19_curados"] <- NA

# Transform La Palma data
old_la_palma <- old_la_palma[c("fecha", "casos_activos")]
names(old_la_palma) <- c("fecha_datos", "cv19_activos")
old_la_palma$fecha_datos <- dmy(old_la_palma$fecha_datos)
old_la_palma["isla"] <- "LA PALMA"
old_la_palma["municipio"] <- "LA PALMA - ALL"
old_la_palma["poblacion"] <- 82671
old_la_palma["cv19_total_casos"] <- NA
old_la_palma["cv19_fallecidos"] <- NA
old_la_palma["cv19_curados"] <- NA


#data <- bind_rows(old_la_laguna, old_la_palma, data_grouped)


# Transform estimated active cases
source("estimate_active_cases.R")
estimated_actives <- estimate_actives(data=data_ungrouped, metadata_source=data_grouped)

# Actual estimation doesnt get correct values for the first month
estimated_actives %>% filter(fecha_datos>dmy("1/2/2021"))

# data <- bind_rows(old_la_laguna, old_la_palma, estimated_actives, data_grouped)


bind_rows(old_la_laguna, old_la_palma, estimated_actives, data_grouped) %>%
  distinct() %>% # data_grouped may already have entries from the other dataframes
  mutate(fecha_datos=format(fecha_datos, "%d/%m/%Y")) %>%
  write_csv("data/cv19_asignacion_agrupados_merged.csv", na="")

# data$fecha_datos <- format(data$fecha_datos, "%d/%m/%Y")
# write_csv(data, "data/cv19_asignacion_agrupados_merged.csv", na="")
