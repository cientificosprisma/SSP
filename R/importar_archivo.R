# Este script sirve para levantar la historia o escribir

rm(list = ls())
gc()

# Importar el archivo

library(dplyr)
library(data.table)

source("/home/Compartida_CD_GI/d_visa_scoring/scripts/basicos.R")
source("/home/Compartida_CD_GI/d_visa_scoring/scripts/funciones.R")

query<- "select * from d_cientificos_datos.vs_input_modelo_v"

input_modelo <- get_query(query = query , "TD")

fwrite(input_modelo, paste0(dir_info_historia,"input_modelo_",year,"_",month))