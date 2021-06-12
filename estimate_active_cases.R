library(tidyverse)
library(lubridate)

# Load data
data <- read.csv("https://opendata.sitcan.es/upload/sanidad/cv19_municipio-asignacion_casos.csv")
data_grouped <- read.csv("https://github.com/jueves/covid_canarias_data/raw/main/data/cv19_asignacion_agrupados.csv")

# Create dataframe with metadata
data_grouped %>%
  group_by(municipio, isla) %>%
  summarise(municipio, poblacion=mean(poblacion), isla) %>%
  distinct() %>%
  mutate(municipio=as.character(municipio),
         isla=as.character(isla))-> municipios_metadata

# Set as date
data$fecha_datos <- dmy(data$fecha_datos)
data$fecha_caso <- dmy(data$fecha_caso)
data$fecha_fallecido <- dmy(data$fecha_fallecido)
data$fecha_curado <- dmy(data$fecha_curado)

# Create a single end date for each case
end_date <- c()
for (i in 1:nrow(data)){
  posible_dates <- as.Date(c(data$fecha_fallecido[i], data$fecha_curado[i], today()+1),
                           origin="1970-01-01")
  end_date <- append(end_date, min(posible_dates, na.rm=TRUE))
}

data['fecha_final'] <- end_date

# Create date-municipio-active_cases_counter dataframe
municipio_list <- c()
fecha_list <- c()
for (i in 1:nrow(data)){
  num_days <- as.numeric(data$fecha_final[i] - data$fecha_caso[i])
  if (num_days < 0){
    num_days <- 0
  }
  case_dates <- seq(data$fecha_caso[i], by = "day", length.out = num_days)
  case_municipio <- rep(as.character(data$municipio[i]), num_days)
  
  municipio_list <- append(municipio_list, case_municipio)
  fecha_list <- append(fecha_list, case_dates)
}
data.frame(fecha=fecha_list, municipio=municipio_list) %>%
  group_by(fecha, municipio) %>%
  count() -> estimated_actives

# Add isla and poblacion for each estimation
isla_list <- c()
poblacion_list <- c()
for (i in 1:nrow(estimated_actives)){
  selection_vector <- municipios_metadata$municipio == estimated_actives$municipio[i]
  if (as.character(estimated_actives$municipio[i]) == "SIN ESPECIFICAR"){
    selected_isla <- NA
    selected_poblacion <- NA
  } else {
    selected_isla <- municipios_metadata$isla[selection_vector]
    selected_poblacion <- municipios_metadata$poblacion[selection_vector]
  }
  isla_list <- append(isla_list, selected_isla)
  poblacion_list <- append(poblacion_list,selected_poblacion)
}
estimated_actives['isla'] <- isla_list
estimated_actives['poblacion'] <- poblacion_list

# Add missing columns
estimated_actives %>%
  mutate(cv19_total_casos=NA, cv19_fallecidos=NA, cv19_curados=NA) %>%
  rename(cv19_activos=n, fecha_datos=fecha) -> estimated_actives

# Export data
estimated_actives %>%
  filter(fecha_datos>dmy("1/2/2021")) %>%
  mutate(fecha_datos=format(fecha_datos, "%d/%m/%Y")) %>%
  write.csv("data/cv19_asignacion_agrupados_estimated.csv", row.names = FALSE)