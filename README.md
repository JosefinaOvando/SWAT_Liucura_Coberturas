# Evaluación de coberturas del suelo mediante SWAT+: cuenca del río Liucura

## Descripción

Este proyecto analiza la influencia de tres productos de cobertura del suelo (CONAF, MapBiomas 2024 y CLDynamic 2018) sobre la respuesta ecohidrológica simulada mediante SWAT+ en la cuenca del río Liucura, Región de La Araucanía, Chile.

El análisis compara tres variables: caudal medio mensual, transporte de sedimentos y exportación de nitratos. Además, se evalúa el desempeño de las simulaciones hidrológicas utilizando datos de caudal observado de CAMELS-CL.

## Datos utilizados

- **SWAT+:** resultados mensuales para tres escenarios de cobertura del suelo.
- **CAMELS-CL:** caudales observados en la estación Río Liucura en Liucura (9416001).
- **DGA:** registros históricos de nitratos del río Pucón en Balseadero Quelhue y sedimentos del río Trancura antes del río Llafenco.

Las simulaciones consideran el período 1979–2019, con cinco años de calentamiento del modelo.

## Metodología

El análisis fue desarrollado en R y Quarto. Se comparan las respuestas mensuales, anuales y estacionales de los tres escenarios, y se evalúa la correspondencia entre los caudales simulados y observados mediante NSE, RMSE y PBIAS.

Los registros regionales de calidad de agua y sedimentos se utilizan como información complementaria, no como validación directa del modelo del Liucura.

## Reproducibilidad

El análisis se encuentra en el archivo `Analisis_SWAT_Liucura_actualizado.qmd`.

Los archivos de entrada están organizados en `datos/`, mientras que las tablas generadas se guardan en `resultados/`.

Para reproducir el informe, se requiere R, Quarto y los paquetes utilizados en el documento.

Para generar el informe HTML:

`quarto render Analisis_SWAT_Liucura_actualizado.qmd --to html`

Para generar el informe PDF:

`quarto render Analisis_SWAT_Liucura_actualizado.qmd --to pdf`

## Autora

Josefina Ovando León  
Ingeniería Forestal — Pontificia Universidad Católica de Chile  
Proyecto académico de análisis y visualización de datos ambientales.