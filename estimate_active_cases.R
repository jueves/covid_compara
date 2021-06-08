library(tidyverse)
library(lubridate)

estimate_actives <- funcion(data){
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
  base_data <- data.frame(fecha=fecha_list, municipio=municipio_list)
  base_data %>%
    group_by(fecha, municipio) %>%
    count() -> counter_df
  
  # Add isla
  municipios_isla_dic <- as.character(unique(counter_df$municipio))
  names(municipios_isla_dic) <- as.character(unique(counter_df$municipio))
  
  municipio_isla_df <- data_asign  %>% group_by(isla, municipio) %>% count()
  
  municipio_isla_df$municipio <- as.character(municipio_isla_df$municipio)
  municipio_isla_df$isla <-as.character(municipio_isla_df$isla)
  
  for (i in 1:nrow(municipio_isla_df)){
    municipio <- municipio_isla_df$municipio[i]
    isla <- municipio_isla_df$isla[i]
    
    municipios_isla_dic[municipio] <- isla
  }
  
  isla_list <- c()
  for (i in 1:nrow(counter_df)){
    isla_list <- append(isla_list, municipios_isla_dic[counter_df$municipio[i]])
  }
  
  counter_df['isla'] <- isla_list
  return(counter_df)
}