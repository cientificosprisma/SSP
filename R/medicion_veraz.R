# Análisis de AUC y KS de Veraz

# Setup -------------------------------------------------------------------
library(dplyr)

source("/home/Compartida_CD_GI/d_visa_scoring/scripts/basicos.R")
source("/home/Compartida_CD_GI/d_visa_scoring/scripts/funciones.R")


# Importo clase y score ---------------------------------------------------

query<- paste0("select score_riesgo, clase_veraz from d_cientificos_datos.score_veraz_clase")

score <- get_query(query = query , "TD")

score$Score_Riesgo = score$Score_Riesgo/1000
score <- score %>% filter(Score_Riesgo>0)
score$Score_Riesgo_Mod <- 1-score$Score_Riesgo


ks2(score$Score_Riesgo_Mod, score$clase_veraz)

fastAUC(score$Score_Riesgo_Mod, score$clase_veraz)
