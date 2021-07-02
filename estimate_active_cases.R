library(tidyverse)
library(lubridate)

# Load data
data_ungrouped <- read.csv("https://opendata.sitcan.es/upload/sanidad/cv19_municipio-asignacion_casos.csv")
data_grouped <- read.csv("https://github.com/jueves/covid_canarias_data/raw/main/data/cv19_asignacion_agrupados.csv")

# Create dataframe with metadata
data_grouped %>%
  group_by(municipio, isla) %>%
  summarise(municipio, poblacion=mean(poblacion), isla) %>%
  distinct() %>%
  mutate(municipio=as.character(municipio),
         isla=as.character(isla))-> municipios_metadata

# Set as date
data_ungrouped$fecha_datos <- dmy(data_ungrouped$fecha_datos)
data_ungrouped$fecha_caso <- dmy(data_ungrouped$fecha_caso)
data_ungrouped$fecha_fallecido <- dmy(data_ungrouped$fecha_fallecido)
data_ungrouped$fecha_curado <- dmy(data_ungrouped$fecha_curado)

# Create a single end date for each case
end_date <- c()
for (i in 1:nrow(data_ungrouped)){
  posible_dates <- as.Date(c(data_ungrouped$fecha_fallecido[i], data_ungrouped$fecha_curado[i], today()+1),
                           origin="1970-01-01")
  end_date <- append(end_date, min(posible_dates, na.rm=TRUE))
}

data_ungrouped['fecha_final'] <- end_date

# Create date-municipio-active_cases_counter dataframe
municipio_list <- c()
fecha_list <- c()
for (i in 1:nrow(data_ungrouped)){
  num_days <- as.numeric(data_ungrouped$fecha_final[i] - data_ungrouped$fecha_caso[i])
  if (num_days < 0){
    num_days <- 0
  }
  case_dates <- seq(data_ungrouped$fecha_caso[i], by = "day", length.out = num_days)
  case_municipio <- rep(as.character(data_ungrouped$municipio[i]), num_days)
  
  municipio_list <- append(municipio_list, case_municipio)
  fecha_list <- append(fecha_list, case_dates)
}
data.frame(fecha=fecha_list, municipio=municipio_list) %>%
  group_by(fecha, municipio) %>%
  count() -> data_estimated

# Add isla and poblacion for each estimation
isla_list <- c()
poblacion_list <- c()
for (i in 1:nrow(data_estimated)){
  selection_vector <- municipios_metadata$municipio == data_estimated$municipio[i]
  if (as.character(data_estimated$municipio[i]) == "SIN ESPECIFICAR"){
    selected_isla <- NA
    selected_poblacion <- NA
  } else {
    selected_isla <- municipios_metadata$isla[selection_vector]
    selected_poblacion <- municipios_metadata$poblacion[selection_vector]
  }
  isla_list <- append(isla_list, selected_isla)
  poblacion_list <- append(poblacion_list,selected_poblacion)
}
data_estimated['isla'] <- isla_list
data_estimated['poblacion'] <- poblacion_list

# Add missing columns
data_estimated %>%
  mutate(cv19_total_casos=NA, cv19_fallecidos=NA, cv19_curados=NA) %>%
  rename(cv19_activos=n, fecha_datos=fecha) -> data_estimated

# Get isla-ALL
data_estimated %>%
  filter(!str_detect(municipio, "- ALL")) %>%
  group_by(fecha_datos, isla) %>%
  summarise(fecha_datos, isla,
            poblacion=sum(poblacion),
            cv19_activos=sum(cv19_activos, na.rm=TRUE),
            cv19_total_casos=sum(cv19_total_casos, na.rm=TRUE),
            cv19_fallecidos=sum(cv19_fallecidos, na.rm=TRUE),
            cv19_curados=sum(cv19_curados, na.rm=TRUE),
            municipio = paste(isla, "- ALL")) -> data_isla_ALL

data_estimated <- bind_rows(data_estimated, data_isla_ALL)

data_estimated$isla <- factor(data_estimated$isla)
data_estimated$municipio <- factor(data_estimated$municipio)

# Export data
data_estimated %>%
  filter(fecha_datos>dmy("1/2/2021")) %>%
  mutate(fecha_datos=format(fecha_datos, "%d/%m/%Y")) %>%
  write.csv("data/cv19_asignacion_agrupados_estimated.csv", row.names = FALSE)