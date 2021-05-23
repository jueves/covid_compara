# Readme
This project consist on a Shiny app that aims to compare the evolution of the SARS-CoV-2 epidemic between diferent locations in Canary Islands.

Data is collected from [Grafcan dashboard](https://grafcan1.maps.arcgis.com/apps/opsdashboard/index.html#/156eddd4d6fa4ff1987468d1fd70efb6) and is currently stored on [Google Sheets](https://docs.google.com/spreadsheets/d/1aXRIP2MnSBIIi5-kPnmawnCAXJZNiNuJy0WD4Zb0HvM)

## Lack of data history
As 23/05/2021 it looks like data from Canarias Datos Abiertos only covers the current day. Therefore a python script to download and merge new occurrences has been developed.

# To do
* Integrate with data sources from [Canarias Datos Abiertos](https://datos.canarias.es/catalogos/general/dataset/datos-epidemiologicos-covid-19)