import pandas as pd
# Set URLs
names_list = [
  {
    "url":"https://opendata.sitcan.es/upload/sanidad/cv19_municipio-asignacion_casos_municipios.csv",
    "file_name":"data/cv19_asignacion_agrupados.csv"},
  {
    "url":"https://opendata.sitcan.es/upload/sanidad/cv19_municipio-residencia_casos.csv",
    "file_name":"data/cv19_residencia.csv"
  },
  {
    "url":"https://opendata.sitcan.es/upload/sanidad/cv19_municipio-asignacion_casos.csv",
    "file_name":"data/cv19_asignacion.csv"
  }
]

# Update function
def update_data(url, file_name):
  # Get data
  data_old = pd.read_csv(file_name)
  data_new = pd.read_csv(url)
  
  # Merge data
  data = pd.concat([data_old, data_new])
  data = data.drop_duplicates()
  
  # Save data
  data.to_csv(file_name, index=False)
  
for dataset in names_list:
 update_data(dataset["url"], dataset["file_name"])


url = names_list[0]['url']
file_name = names_list[0]['file_name']
