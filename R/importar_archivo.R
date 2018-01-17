# Este script importa el archivo para predecir el mes corriente y lo escribe
rm(list = ls())
gc()

# Importar archivo --------------------------------------------------------

library(dplyr)
library(data.table)

source("/home/Compartida_CD_GI/d_visa_scoring/scripts/basicos.R")
source("/home/Compartida_CD_GI/d_visa_scoring/scripts/funciones.R")

args <- commandArgs(trailingOnly=TRUE)
cod_banco <- args[1]
cod_mes <- args[2]

query<- paste0("select * from d_cientificos_datos.vs_input_modelo_v where cod_banco = ", cod_banco, " and cod_mes = ", cod_mes)

input_modelo <- get_query(query = query , "TD")

# Escribir archivo --------------------------------------------------------

fwrite(input_modelo, paste0(dir_info_actual,"input_modelo_",cod_banco,"_",cod_mes,".csv"))
