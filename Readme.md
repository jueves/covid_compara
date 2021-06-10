# Readme
This project consist on a Shiny app that aims to compare the evolution of the SARS-CoV-2 epidemic between diferent locations in Canary Islands.

Data up to 23/05/2021 has been manually collected from [Grafcan dashboard](https://grafcan1.maps.arcgis.com/apps/opsdashboard/index.html#/156eddd4d6fa4ff1987468d1fd70efb6). Only two locations have been manually collected and many daily measures are missing.

Data after 23/05/2021 is automatically downloaded from [Canarias Datos Abiertos](https://datos.canarias.es/catalogos/general/dataset/datos-epidemiologicos-covid-19).

## Daily active cases
Daily active cases in the original dataset from Canarias Datos Abiertos doesn't save a history, just the present day value, so [a parallel project](https://github.com/jueves/covid_canarias_data) has been developed to download and store these daily measurements.

## To do
* Integrate new data from Canarias Datos Abiertos.
* Make more areas available.
* Extract historic active cases from [individual cases](https://datos.canarias.es/catalogos/general/dataset/datos-epidemiologicos-covid-19/resource/3b5b2d84-fe9d-42eb-91eb-54f0cb3cb4cc) in order to get full data, at least from February 2021 onwards.
