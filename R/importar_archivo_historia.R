# Este script importa la historia para entrenar el modelo

rm(list = ls())
gc()

# Importo el archivo -----------------------------------------------------

library(dplyr)
library(data.table)

source("/home/Compartida_CD_GI/d_visa_scoring/scripts/basicos.R")
source("/home/Compartida_CD_GI/d_visa_scoring/scripts/funciones.R")

<<<<<<< HEAD
query<- paste0("select * from d_cientificos_datos.vs_input_modelo_hist_v where tipo_clase=1")
=======
args <- commandArgs(trailingOnly=TRUE)
cod_banco <- args[1]
cod_mes <- args[2]

print(args)

query<- paste0("select * from d_cientificos_datos.vs_input_modelo_v")
>>>>>>> 5f327afa7cec2f6d193b63906b35e91245a325b3

input_modelo <- get_query(query = query , "TD")

# Escribo el archivo ------------------------------------------------------

fwrite(input_modelo, paste0(dir_info_historia,"input_modelo_historia.csv"))

