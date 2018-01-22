rm(list=ls())
gc()



############

## Script para entrenar randomforest


# Setup -------------------------------------------------------------------

library(mlr)
library(dplyr)
library(mlrMBO)
library(ranger)

set.seed(12112016)

source("/home/Compartida_CD_GI/d_visa_scoring/scripts/basicos.R")
source("/home/Compartida_CD_GI/d_visa_scoring/scripts/funciones.R")

# Importamos archivo ------------------------------------------------------

df <- read_info("input_modelo_2018_1.csv","historia", 10000,strings_as_factors=FALSE)
df <- df %>% select(-c(clase_cp_1, clase_cp_2, clase_lp_1, clase_lp_2))
df <- df %>% rename(clase = clase_veraz)
df[is.na(df)]<-(-99999)
df[,"Cod_Mes"]<-as.integer(df[,"Cod_Mes"])

###### CREAR FUNCION #####
library(data.table)
library(stringr)
dt <- as.data.table(df)

dt <- dt[is.na(clase) == FALSE]

colnames(dt) <- str_replace(colnames(dt),"\\$","__")

df <- as.data.frame(dt)
na_row<-df[1,] 
for(i in 1:ncol(na_row)){if(typeof(na_row[,i])!="character"){na_row[,i]<-(-99999)}}
for(i in 1:ncol(na_row)){if(typeof(na_row[,i])=="character"){na_row[,i]<-("__NAs__")}}
df<-rbind(df,na_row)

actualiza_lks(df)
#######

# Partimos en train y test ------------------------------------------------
df <- get_train_test(df)

gc()

train <- df[[1]]
train_rows <- nrow(train)

test <- df[[2]]

rm(df)

df <- rbind(train, test)

#rm(train)
#rm(test)
gc()



############## Lookups y Mapeos

df<-lookupea_factores(df)
for(c in 1:ncol(df)){
  if(typeof(df[,c])=="character"){df[,c]<-as.factor(df[,c])}
  
}
df[,"clase"]<-as.factor(df[,"clase"])






##############

# Task, Learner, metodo de sampleo --------------------------------------------------------------

#df$Cod_Tipo_Cuenta <- as.factor(as.character(df$Cod_Tipo_Cuenta))
task = makeClassifTask(data = df, target = "clase", fixup.data = "no")

train_inds = seq(1:train_rows)
test_inds = seq((train_rows+1),nrow(df))

sampling_method = makeFixedHoldoutInstance(train_inds, test_inds, nrow(df))

# Armo learner y sus parametros


randomforest_learner <- makeLearner("classif.ranger", predict.type = "prob",fix.factors.prediction = TRUE)

randomforest_learner$par.vals<- list(num.threads =12 )



#randomforest_learner$par.set
randomforest_params <- makeParamSet(
  makeIntegerParam("num.trees",lower=400,upper=600),
  makeIntegerParam("mtry", lower = 10, upper = 30, default = 15)
  )


# Setting control object for MBO optimization  - Bayesian optimization (aka model based optimization)
# mbo_control <- makeMBOControl(save.on.disk.at = c(10,25,50,75,99),save.file.path = paste0(dir_performance_modelos_pruebas,"randomforest_parametros_",cod_mes,".RData"))
mbo_control <- makeMBOControl()
# Extends an MBO control object with infill criteria and infill optimizer options
mbo_control <- setMBOControlTermination(mbo_control, iters = 5)

# Defining surrogate learner
surrogate_lrn <- makeLearner("regr.km", predict.type = "se")

# Create control object for hyperparameter tuning with MBO
tune_control = mlr:::makeTuneControlMBO(learner = surrogate_lrn, mbo.control = mbo_control)

# Tuneo parametros --------------------------------------------------------
rf_tune <-
  tuneParams(
    learner = randomforest_learner,
    task = task,
    resampling = sampling_method,
    measures = auc,
    par.set = randomforest_params,
    control = tune_control,
    show.info = TRUE
  )

opt_results <- as.data.frame(rf_tune$opt.path)
cod_mes<-max(df$Cod_Mes)

#str(df)

write.csv(opt_results, paste0(dir_performance_modelos_pruebas,"randomforest_", cod_mes,".csv"), row.names = FALSE)

# Elijo los mejores parametros y entreno--------------------------------------------

##### Completo clase train
dif_sexo<-c(sexo=levels(df$Cod_Sexo_Host)[!( levels(df$Cod_Sexo_Host)%in% unique(train$Cod_Sexo_Host)  )])
dif_sexo<-add_na_elem(dif_sexo)
#colnames(dif_sexo)<-"sexo"
dif_Segmento_Credito<-c( levels(df$Segmento_Credito)[!( levels(df$Segmento_Credito) %in% unique(train$Segmento_Credito) )])
dif_Segmento_Credito<-add_na_elem(dif_Segmento_Credito)
#colnames(dif_Segmento_Credito)<-"Seg_Credito"
dif_Cod_Tipo_Tarjeta<-c(levels(df$Cod_Tipo_Tarjeta)[!(  levels(df$Cod_Tipo_Tarjeta) %in% unique(train$Cod_Tipo_Tarjeta))])
dif_Cod_Tipo_Tarjeta<-add_na_elem(dif_Cod_Tipo_Tarjeta)
#colnames(dif_Cod_Tipo_Tarjeta)<-"Tipo_Tarjeta"
dif_Cod_Region_Geografica_Host<-c(v1=levels(df$Cod_Region_Geografica_Host)[!(  levels(df$Cod_Region_Geografica_Host) %in% unique(train$Cod_Region_Geografica_Host))])
dif_Cod_Region_Geografica_Host<-add_na_elem(dif_Cod_Region_Geografica_Host)
#colnames(dif_Cod_Region_Geografica_Host)<-"Region_Geografica"
dif_Cod_Limite_Compra<-c(v1=levels(df$Cod_Limite_Compra)[!(  levels(df$Cod_Limite_Compra) %in% unique(train$Cod_Limite_Compra))])
dif_Cod_Limite_Compra<-add_na_elem(dif_Cod_Limite_Compra)
#colnames(dif_Cod_Limite_Compra)<-"Cod_Limite"
dif_Cod_Tipo_Identificacion_Host<-c(v1=levels(df$Cod_Tipo_Identificacion_Host)[!(  levels(df$Cod_Tipo_Identificacion_Host) %in% unique(train$Cod_Tipo_Identificacion_Host))])
dif_Cod_Tipo_Identificacion_Host<-add_na_elem(dif_Cod_Tipo_Identificacion_Host)
#colnames(dif_Cod_Tipo_Identificacion_Host)<-"Tipo_Identificacion"
dif_Cod_Tipo_Cuenta<-c(v1=levels(df$Cod_Tipo_Cuenta)[!(  levels(df$Cod_Tipo_Cuenta) %in% unique(train$Cod_Tipo_Cuenta))])
dif_Cod_Tipo_Cuenta<-add_na_elem(dif_Cod_Tipo_Cuenta)
#colnames(dif_Cod_Tipo_Cuenta)<-"Tipo_Cuenta"

library(data.table)
faltantes_train<-data.table(na_row,dif_Segmento_Credito,dif_Cod_Region_Geografica_Host,dif_Cod_Tipo_Tarjeta,dif_sexo,dif_Cod_Limite_Compra,dif_Cod_Tipo_Identificacion_Host,dif_Cod_Tipo_Cuenta,keep.rownames = TRUE)   
faltantes_train<-as.data.frame(faltantes_train)
faltantes_train<-faltantes_train %>% mutate(Cod_Sexo_Host=dif_sexo,Segmento_Credito=dif_Segmento_Credito,Cod_Tipo_Tarjeta=dif_Cod_Tipo_Tarjeta,Cod_Region_Geografica_Host=dif_Cod_Region_Geografica_Host, Cod_Limite_Compra=dif_Cod_Limite_Compra,Cod_Tipo_Identificacion_Host=dif_Cod_Tipo_Identificacion_Host,Cod_Tipo_Cuenta=dif_Cod_Tipo_Cuenta,clase=0) %>% 
  select(-c(dif_Cod_Tipo_Cuenta,dif_Cod_Region_Geografica_Host,dif_sexo,dif_Cod_Tipo_Identificacion_Host,dif_Segmento_Credito,dif_Cod_Tipo_Tarjeta,dif_Cod_Limite_Compra,rn))

for(i in 1:ncol(na_row)){if(class(faltantes_train[,i])!="character" & colnames(faltantes_train[,i])!="clase"){faltantes_train[,i]<-(-99999)}}

train<-rbind(train,faltantes_train)

train<-lookupea_factores(train)
test<-lookupea_factores(test)

####
unique(test$clase)

for(c in 1:ncol(train)){
  if(typeof(train[,c])=="character"){train[,c]<-as.factor(train[,c])}
  
}
train[,"clase"]<-as.factor(train[,"clase"])






rf_new <- setHyperPars(learner = randomforest_learner, par.vals = rf_tune$x)
train_task <- makeClassifTask(data = train, target = "clase" ,fixup.data = "no")
rf_model <- train(rf_new, train_task)

# Predigo test ----------------------------------------------

for(c in 1:ncol(test)){
  if(typeof(test[,c])=="character"){test[,c]<-as.factor(test[,c])}
  
}
test[,"clase"]<-as.factor(test[,"clase"])

#levels(df$Cod_Tipo_Cuenta)
#levels(train$Cod_Tipo_Cuenta)


predict_task <- makeClassifTask(data =  test, target = "clase",fixup.data = "no")

predict_test <- predict(rf_model, predict_task)

#df$Cod_Limite_Compra[which(is.na(df$Cod_Limite_Compra))]

# obtengo acc y auc
perf_measures <- list("acc" = acc, "auc" = auc)
measures <- performance(predict_test, measures = perf_measures)


# obtengo ks, para ello le paso el tpr y fpr para distintos puntos de corte
d = generateThreshVsPerfData(predict_test, measures = list(fpr, tpr))
measures[3] <- ks(d$data$tpr,d$data$fpr)
names(measures)[3] <- "ks"

# guardo resultados

write.csv(measures, paste0(dir_performance_modelos_pruebas,"ranger_measures_", cod_mes,".csv"), row.names = FALSE)

# obtengo variable importance
#var_importance <- getFeatureImportance(rf_model)
#var_importance <- as.data.frame(t(var_importance$res))

#write.csv(var_importance, paste0(dir_performance_modelos_pruebas,"xgboost_var_importance_", cod_mes,".csv"), row.names = FALSE)



