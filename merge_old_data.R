library(tidyverse)
library(lubridate)

new_data <- read.csv("data/cv19_asignacion_agrupados.csv")
old_la_palma <- read.csv("data/prueba_la_palma - la_palma.csv")
old_la_laguna <- read.csv("data/prueba_la_palma - la_laguna.csv")

new_data$fecha_datos <- dmy(new_data$fecha_datos)

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


data <- bind_rows(old_la_laguna, old_la_palma, new_data)

data$fecha_datos <- format(data$fecha_datos, "%d/%m/%Y")
write_csv(data, "data/cv19_asignacion_agrupados_merged.csv", na="")

# Transform estimated active cases
source("estimate_active_cases.R")
estimated_actives <- estimate_actives(read.csv("data/cv19_asignacion.csv"))
