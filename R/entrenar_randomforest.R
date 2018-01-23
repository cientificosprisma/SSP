rm(list=ls())
gc()



############

## Script para entrenar randomforest


# Setup -------------------------------------------------------------------

library(mlr)
library(dplyr)
library(mlrMBO)
library(ranger)
library(data.table)

set.seed(12112016)

source("/home/Compartida_CD_GI/d_visa_scoring/scripts/basicos.R")
source("/home/Compartida_CD_GI/d_visa_scoring/scripts/funciones.R")

# Importamos archivo ------------------------------------------------------
df <- read_info("input_modelo_historia.csv","historia", 2000000,strings_as_factors=FALSE)
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

factores_nominales<-as.list(fread(paste0(dir_configuracion_columnas,"factores_nominales.csv"),header = FALSE))
factores_ordinales<-as.list(fread(paste0(dir_configuracion_columnas,"factores_ordinales.csv"),header = FALSE))
factores<-as.list(c(factores_nominales,factores_ordinales))

actualiza_lks(df,factores)
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



############## Se cambian los tipo de datos que corresponden a factores




df<-a_factor(df,lista_col =factores_nominales ,orden = FALSE)
df<-a_factor(df,lista_col =factores_ordinales ,orden = TRUE)





# BUSQUEDA DE MEJORES HIPERPARAMETROS -------------------------------------



  ## Task, Learner, metodo de sampleo --------------------------------------------------------------

#df$Cod_Tipo_Cuenta <- as.factor(as.character(df$Cod_Tipo_Cuenta))
task = makeClassifTask(data = df, target = "clase", fixup.data = "no")

train_inds = seq(1:train_rows)
test_inds = seq((train_rows+1),nrow(df))

sampling_method = makeFixedHoldoutInstance(train_inds, test_inds, nrow(df))

# Armo learner y sus parametros


randomforest_learner <- makeLearner("classif.ranger", predict.type = "prob",fix.factors.prediction = TRUE)

randomforest_learner$par.vals<- list(num.threads =6 )



#randomforest_learner$par.set
randomforest_params <- makeParamSet(
  makeIntegerParam("num.trees",lower=400,upper=600),
  makeIntegerParam("mtry", lower = 10, upper = 30, default = 15)
  )

des = generateDesign(n = 20, par.set = randomforest_params)

# Setting control object for MBO optimization  - Bayesian optimization (aka model based optimization)
 mbo_control <- makeMBOControl(save.on.disk.at = c(10,25,30,40),save.file.path = paste0(dir_performance_modelos_pruebas,"randomforest_parametros_",cod_mes,".RData"))
#mbo_control <- makeMBOControl()
# Extends an MBO control object with infill criteria and infill optimizer options
mbo_control <- setMBOControlTermination(mbo_control, iters = 40)

# Defining surrogate learner
surrogate_lrn <- makeLearner("regr.km", predict.type = "se")
clase = df[train_inds,"clase"]
nuggets = 1e-8*var(clase)

surrogate_lrn <- setHyperPars(learner = surrogate_lrn, par.vals = list(nugget=nuggets))

# Create control object for hyperparameter tuning with MBO
tune_control = mlr:::makeTuneControlMBO(learner = surrogate_lrn, mbo.control = mbo_control, mbo.design = des)

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


faltantes_train<-obtener_factores_faltantes(train,df,factores_nominales)
train<-rbind(train,faltantes_train)

train<-lookupea_factores(train,factores)
test<-lookupea_factores(test,factores)

####


train<-a_factor(train,lista_col =factores_nominales ,orden = FALSE)
train<-a_factor(train,lista_col =factores_ordinales ,orden = TRUE)






rf_new <- setHyperPars(learner = randomforest_learner, par.vals = rf_tune$x)
train_task <- makeClassifTask(data = train, target = "clase" ,fixup.data = "no")
rf_model <- train(rf_new, train_task)

# Predigo test ----------------------------------------------

test<-a_factor(test,lista_col =factores_nominales ,orden = FALSE)
test<-a_factor(test,lista_col =factores_ordinales ,orden = TRUE)

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



