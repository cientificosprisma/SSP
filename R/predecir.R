# Este script genera la prediccion

rm(list = ls())
gc()


# Setup -------------------------------------------------------------------

library(dplyr)
library(data.table)
library(mlr)

source("/home/Compartida_CD_GI/d_visa_scoring/scripts/basicos.R")
source("/home/Compartida_CD_GI/d_visa_scoring/scripts/funciones.R")

args <- commandArgs(trailingOnly=TRUE)
cod_banco <- args[1]
cod_mes <- args[2]
tipo_clase <- args[3]


# Importamos archivo ------------------------------------------------------

df_predecir <- fread(paste0(dir_info_actual,"input_modelo_",cod_banco,"_",cod_mes, "_",tipo_clase,".csv"))


# Preprocesamiento --------------------------------------------------------
### FALTA COMPLETAR: aca hay que transformar los tipos de datos, elegir las columnas y renombrar la clase de clase_veraz a clase

if (tipo_clase == 1){
  df_predecir <- preprocesar_tipo_1(df)
} else{
  df_predecir <- preprocesar_tipo_2(df)
}


# Cargo modelo ------------------------------------------------------------

modelo <- readRDS(paste0(dir_modelos_actual,"modelo_tipo_clase_",tipo_clase,".RDS"))
modelo <- getLearnerModel(modelo)


# Predigo, armo tabla de resultados y escribo --------------------------------------

predictions <- predict(modelo, df_predecir)

results <- data.frame(score = predictions$data$prob.1)
results$nro_cuenta <- df_predecir$nro_cuenta
results$cod_banco <- df_predecir$cod_banco
results$cod_mes <- df_predecir$cod_mes
results$tipo_clase <- df_predecir$tipo_clase
results$ciclo_liquidacion <- df_predecir$ciclo_liquidacion

fwrite(results,paste0(dir_predicciones,"resultados_",cod_banco,"_",cod_mes,"_",tipo_clase,".csv"))



