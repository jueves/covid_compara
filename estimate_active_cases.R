library(tidyverse)
library(lubridate)

get_metadata <- function(data){
  data %>%
    group_by(municipio, isla) %>%
    summarise(municipio, poblacion=mean(poblacion), isla) %>%
    distinct() -> municipios_metadata
  
  municipios_metadata$municipio <- as.character(municipios_metadata$municipio)
  municipios_metadata$isla <-as.character(municipios_metadata$isla)
  return(municipios_metadata)
}

estimate_actives <- function(data, metadata_source){
  data$fecha_datos <- dmy(data$fecha_datos)
  data$fecha_caso <- dmy(data$fecha_caso)
  data$fecha_fallecido <- dmy(data$fecha_fallecido)
  data$fecha_curado <- dmy(data$fecha_curado)
  
  # Create date/municipio counter
  number_of_days = 150
  days_template <- seq(as.Date("2021/01/01"), by = "day", length.out = number_of_days)
  days_list <- c()
  municipios_list <- c()
  for (municipio in unique(data$municipio)){
    days_list <- append(days_list, days_template)
    municipios_list <- append(municipios_list, rep(municipio, number_of_days))
  }
  
  counter_df <- data.frame(fecha=days_list, municipio=municipios_list, cv19_activos=0)
  
  # Create a single end date for each case
  end_date <- c()
  for (i in 1:nrow(data)){
    posible_dates <- as.Date(c(data$fecha_fallecido[i], data$fecha_curado[i], today()+1),
                             origin="1970-01-01")
    end_date <- append(end_date, min(posible_dates, na.rm=TRUE))
  }
  
  data['fecha_final'] <- end_date
  
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
    count() -> counter_df
  
  # Add isla and poblacion for each estimation
  metadata_source %>%
    group_by(municipio, isla) %>%
    summarise(municipio, poblacion=mean(poblacion), isla) %>%
    distinct() -> municipios_metadata
  
  municipios_metadata$municipio <- as.character(municipios_metadata$municipio)
  municipios_metadata$isla <-as.character(municipios_metadata$isla)
  
  #municipios_metada <- get_metadata(metadata)
  
  isla_list <- c()
  poblacion_list <- c()
  errores <- c()
  for (i in 1:nrow(counter_df)){
    selection_vector <- municipios_metadata$municipio == counter_df$municipio[i]
    if (as.character(counter_df$municipio[i]) == "SIN ESPECIFICAR"){
      selected_isla <- NA
      selected_poblacion <- NA
    } else {
      selected_isla <- municipios_metadata$isla[selection_vector]
      selected_poblacion <- municipios_metadata$poblacion[selection_vector]
    }
    isla_list <- append(isla_list, selected_isla)
    poblacion_list <- append(poblacion_list,selected_poblacion)
  }
  counter_df['isla'] <- isla_list
  counter_df['poblacion'] <- poblacion_list
  
  # Add missing columns
  counter_df %>%
    mutate(cv19_total_casos=NA, cv19_fallecidos=NA, cv19_curados=NA) %>%
    rename(cv19_activos=n, fecha_datos=fecha) -> counter_df
  return(counter_df)
}