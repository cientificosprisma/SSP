rm(list=ls())
gc()


## Script para entrenar xgboost


# Setup -------------------------------------------------------------------

library(mlr)
library(dplyr)
library(mlrMBO)
library(xgboost)

set.seed(12112016)

source("/home/Compartida_CD_GI/d_visa_scoring/scripts/basicos.R")
source("/home/Compartida_CD_GI/d_visa_scoring/scripts/funciones.R")

args <- commandArgs(trailingOnly=TRUE)
cod_mes <- args[1]
#tipo_clase <- args[3]

# Importamos archivo ------------------------------------------------------
# prueba cod_mes<-202001

df_tc1 <- read_info(paste0("input_modelo_",cod_mes, "_1.csv"),"actual")
df_tc2 <- read_info(paste0("input_modelo_",cod_mes, "_2.csv"),"actual")


df_tc1 <- map_factors(df_tc1)
df_tc1 <- get_xgboost_matrix(df_tc1)


df_tc2 <- map_factors(df_tc2)
df_tc2 <- get_xgboost_matrix(df_tc2)

#-----------Genero la matriz del xgboost
dt_tc1<-as.data.table(df_tc1)
dtMatrix_tc1 <- dt_tc1[,lapply(.SD,as.numeric)] %>% as.matrix
ddt_tc1 <- xgb.DMatrix(data = dtMatrix_tc1)

dt_tc2<-as.data.table(df_tc2)
dtMatrix_tc2 <- dt_tc2[,lapply(.SD,as.numeric)] %>% as.matrix
ddt_tc2 <- xgb.DMatrix(data = dtMatrix_tc2)

# Cargo y extraigo Xgboost

modelName_tc1 <- paste0("xgboost_g1",)
xgModel_tc1 <- readRDS(paste0(fuentes.modelos.actual,modelName_tc1,".RDS"))
xgModel_tc1 <- getLearnerModel(xgModel_tc1)

modelName_tc2 <- paste0("xgboost_g1",)
xgModel_tc2 <- readRDS(paste0(fuentes.modelos.actual,modelName_tc2,".RDS"))
xgModel_tc2 <- getLearnerModel(xgModel_tc2)

# Cargo vectores

periodo_tc1 <- dt_tc1[,unique(periodo_liquid_base)]
cuentas_tc1 <- dt_tc1[,nro_cuenta]
codEstadoCuenta_tc1 <- dt_tc1[,Cod_Estado_Cuenta]

periodo_tc2 <- dt_tc2[,unique(periodo_liquid_base)]
cuentas_tc2 <- dt_tc2[,nro_cuenta]
codEstadoCuenta_tc2 <- dt_tc2[,Cod_Estado_Cuenta]

# Predigo

xgPredict_tc1 <- predict(xgModel_tc1, ddt_tc1)
xgPredict_tc2 <- predict(xgModel_tc2, ddt_tc2)

# Guardo Resultados

results_tc1 <- data.frame(score = xgPredict_tc1$data$prob.1)
results_tc1$nro_cuenta <- cuentas_tc1
results_tc1$cod_banco <- banco_tc1
results_tc1$periodo_prediccion <- periodo_tc1
fwrite(results_tc1,paste0(resultados.predicciones,paste0("resultado_g1.csv")))

results_tc2 <- data.frame(score = xgPredict_tc2$data$prob.1)
results_tc2$nro_cuenta <- cuentas_tc2
results_tc2$cod_banco <- banco_tc2
results_tc2$periodo_prediccion <- periodo_tc2
fwrite(results_tc2,paste0(resultados.predicciones,paste0("resultado_g2.csv")))

rm(list=ls())
gc()


