## Script que arma directorios

# Directorios -------------------------------------------------------------

# Directorio donde está el jdbc de Teradata
dir_compartida <- "/home/Compartida_CD_GI/";

# Carpeta del proyecto
dir_proyecto <- "/home/Compartida_CD_GI/d_visa_scoring"

# Scripts
dir_scripts <- "/home/Compartida_CD_GI/d_visa_scoring/scripts/"

# Fuentes
dir_fuentes <- "/home/Compartida_CD_GI/d_visa_scoring/fuentes/"
dir_info_historia <- paste0(dir_fuentes,"info_historia/")
dir_info_actual <- paste0(dir_fuentes,"info_actual/")
dir_modelos <- paste0(dir_fuentes,"modelos/")
dir_modelos_historia <- paste0(dir_modelos,"historia/")
dir_modelos_actual <- paste0(dir_modelos,"actual/")
dir_configuracion <- paste0(dir_fuentes,"configuracion/")
dir_configuracion_columnas <- paste0(dir_configuracion,"columnas/")
dir_configuracion_parametros <- paste0(dir_configuracion,"parametros/")
dir_configuracion_periodos <- paste0(dir_configuracion,"periodos/")
dir_configuracion_otros <- paste0(dir_configuracion,"otros/")

# Resultados
dir_resultados <- "/home/Compartida_CD_GI/d_visa_scoring/resultados/"
dir_logs <- paste0(dir_resultados,"logs/")
dir_performance <- paste0(dir_resultados,"performance/")
dir_performance_graficos <- paste0(dir_performance,"graficos/")
dir_performance_modelos_finales <- paste0(dir_performance,"modelos/finales/")
dir_performance_modelos_pruebas <- paste0(dir_performance,"modelos/pruebas/")
dir_predicciones <- paste0(dir_resultados,"predicciones/")


# Configuraciones ---------------------------------------------------------

# Usuario y contrasena

pass <- read.csv(paste0(dir_configuracion_otros,"pass.csv"))
usuarioTeradata <- as.character(pass$usuario)
contrasenaTeradata <- as.character(pass$contrasena)

## Fecha
year <- as.numeric(format(Sys.Date(), "%Y"))
month <- as.numeric(format(Sys.Date(), "%m"))
