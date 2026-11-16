install.packages(c(
  "RcamelsCL",
  "dplyr",
  "lubridate",
  "readr",
  "ggplot2",
  "zoo"
))

library(RcamelsCL)
library (zoo)

# Estación Río Liucura en Liucura
codigo <- 9416001

# Descargar registros diarios
datos <- RcamelsCL::getData(
  x = codigo,
  tscale = "daily",
  from = as.Date("1984-01-01"),
  to = as.Date("2019-12-31")
)

head(datos)

library(dplyr)
library(lubridate)
library(readr)
library(ggplot2)
library(zoo)

# =========================================
# 1. Extraer la variable de caudal observado
# =========================================

stopifnot("Qobs_m3s_day" %in% colnames(datos))

caudal_diario <- tibble(
  fecha = as.Date(zoo::index(datos)),
  Q_obs_m3s = as.numeric(datos[, "Qobs_m3s_day"])
)

# Asegurar todas las fechas del período
calendario <- tibble(
  fecha = seq.Date(
    as.Date("1984-01-01"),
    as.Date("2019-12-31"),
    by = "day"
  )
)

caudal_diario <- calendario %>%
  left_join(caudal_diario, by = "fecha") %>%
  mutate(
    Q_obs_m3s = if_else(
      !is.finite(Q_obs_m3s) | Q_obs_m3s < 0,
      NA_real_,
      Q_obs_m3s
    )
  )

# =========================================
# 2. Calcular caudales medios mensuales
# =========================================

# Exigir que el mes tenga 100 % de días válidos
# Para una exploración, se puede evaluar 0.90
umbral_cobertura <- 1

caudal_mensual <- caudal_diario %>%
  mutate(fecha_mes = floor_date(fecha, "month")) %>%
  group_by(fecha_mes) %>%
  summarise(
    dias_total = n(),
    dias_validos = sum(!is.na(Q_obs_m3s)),
    media_disponible = if (all(is.na(Q_obs_m3s))) {
      NA_real_
    } else {
      mean(Q_obs_m3s, na.rm = TRUE)
    },
    .groups = "drop"
  ) %>%
  mutate(
    cobertura = dias_validos / dias_total,
    Q_obs_m3s = if_else(
      cobertura >= umbral_cobertura,
      media_disponible,
      NA_real_
    )
  )

# =========================================
# 3. Revisar disponibilidad de información
# =========================================

resumen <- caudal_mensual %>%
  summarise(
    meses_totales = n(),
    meses_validos = sum(!is.na(Q_obs_m3s)),
    meses_faltantes = sum(is.na(Q_obs_m3s)),
    porcentaje_valido = 100 * meses_validos / meses_totales
  )

print(resumen)

# =========================================
# 4. Guardar archivos para Quarto
# =========================================

dir.create(
  "datos/observados",
  recursive = TRUE,
  showWarnings = FALSE
)

# Archivo principal compatible con el Quarto
caudal_quarto <- caudal_mensual %>%
  transmute(
    fecha = as.Date(fecha_mes),
    Q_obs_m3s
  )

write_csv(
  caudal_quarto,
  "datos/observados/caudal_dga.csv",
  na = ""
)

# Archivo auxiliar para revisar meses incompletos
write_csv(
  caudal_mensual,
  "datos/observados/control_caudal_camels.csv"
)

# =========================================
# 5. Primera visualización exploratoria
# =========================================

ggplot(
  caudal_quarto,
  aes(x = fecha, y = Q_obs_m3s)
) +
  geom_line(color = "#28789B", linewidth = 0.5) +
  labs(
    title = "Caudal medio mensual del río Liucura",
    subtitle = "Estación 9416001 | CAMELS-CL",
    x = "Año",
    y = "Caudal medio mensual (m³/s)",
    caption = "Fuente: CAMELS-CL / DGA"
  ) +
  theme_minimal(base_size = 12)
