
library(readr)
library(dplyr)
library(lubridate)
library(ggplot2)

# Leer como texto para conservar ceros iniciales
leer_dga <- function(archivo) {
  read_csv(
    file.path("datos/originales", archivo),
    col_types = cols(.default = col_character()),
    show_col_types = FALSE
  ) %>%
    mutate(across(where(is.character), trimws))
}
 getwd()
# Calidad de agua
calidad <- leer_dga("calidad_agua_historico_9.txt")

# Estación Liucura
calidad_liucura <- calidad %>%
  filter(`COD. ESTACIÓN` == "09416001-4") %>%
  transmute(
    fecha = dmy(`FECHA MEDICION`),
    parametro = PARAMETRO,
    valor = parse_number(VALOR),
    calidad = CALIDAD
  )

# Nitrato y nitrito en Quelhue
nitrogeno_quelhue <- calidad %>%
  filter(
    `COD. ESTACIÓN` == "09418001-5",
    PARAMETRO %in% c("Nitrato", "Nitrito")
  ) %>%
  transmute(
    fecha = dmy(`FECHA MEDICION`),
    parametro = PARAMETRO,
    valor = parse_number(VALOR),
    calidad = CALIDAD
  )

# Sedimentos rutinarios del Trancura
rutinario <- leer_dga(
  "sedimentos_muestreo_rutinario_historico_9.txt"
) %>%
  filter(`CODIGO ESTACION` == "09414001") %>%
  transmute(
    fecha = make_date(
      as.integer(`Año`),
      as.integer(Mes),
      as.integer(`Día`)
    ),
    concentracion_mg_L = parse_number(`Concentración`),
    tipo = "Rutinario"
  )

# Sedimentos integrados del Trancura
integrado <- leer_dga(
  "sedimentos_muestreo_integrado_historico_9.txt"
) %>%
  filter(`CODIGO ESTACION` == "09414001") %>%
  transmute(
    fecha = dmy(Fecha),
    concentracion_mg_L =
      parse_number(`Concentración_Ponderada_Diaria`),
    tipo = "Integrado"
  )

# Guardar tablas procesadas
dir.create(
  "datos/observados",
  recursive = TRUE,
  showWarnings = FALSE
)

write_csv(calidad_liucura,
          "datos/observados/calidad_liucura.csv")

write_csv(nitrogeno_quelhue,
          "datos/observados/nitrogeno_quelhue.csv")

write_csv(rutinario,
          "datos/observados/sedimentos_trancura_rutinario.csv")

write_csv(integrado,
          "datos/observados/sedimentos_trancura_integrado.csv")

# Resumen de disponibilidad sedimentométrica
bind_rows(rutinario, integrado) %>%
  group_by(tipo) %>%
  summarise(
    registros = n(),
    inicio = min(fecha, na.rm = TRUE),
    fin = max(fecha, na.rm = TRUE),
    .groups = "drop"
  )

