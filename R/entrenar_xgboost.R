rm(list=ls())
gc()


## Script para entrenar xgboost


# Setup -------------------------------------------------------------------

library(mlr)
library(dplyr)
library(mlrMBO)

set.seed(12112016)

source("/home/Compartida_CD_GI/d_visa_scoring/scripts/basicos.R")
source("/home/Compartida_CD_GI/d_visa_scoring/scripts/funciones.R")

cod_mes = 201801
tipo_clase = 2

if (tipo_clase == 1){
  path <- dir_performance_modelos_pruebas_tipo_clase_1
} else{
  path <- dir_performance_modelos_pruebas_tipo_clase_2
}

# Importamos archivo ------------------------------------------------------

tbl = paste0("input_modelo_historia_g",tipo_clase,".csv")

df <- read_info(tbl,"historia")

df <- df %>% select(-c(clase_cp_1, clase_cp_2, clase_lp_1, clase_lp_2))
df <- df %>% rename(clase = clase_veraz)

# Partimos en train y test ------------------------------------------------
df <- get_train_test(df)

gc()

train <- df[[1]]
train_rows <- nrow(train)

test <- df[[2]]

rm(df)

df <- rbind(train, test)

rm(train)
rm(test)
gc()

df <- map_factors(df)
df <- get_xgboost_matrix(df)
gc()

# Task, Learner, metodo de sampleo --------------------------------------------------------------

task = makeClassifTask(data = df, target = "clase")

train_inds = seq(1:train_rows)
test_inds = seq((train_rows+1),nrow(df))

sampling_method = makeFixedHoldoutInstance(train_inds, test_inds, nrow(df))

# Armo learner y sus parametros
xgboost_learner <- makeLearner("classif.xgboost", predict.type = "prob")

xgboost_learner$par.vals <- list(
  booster = "gbtree",
  nthread = 6)

xgboost_params <- makeParamSet(
  makeIntegerParam("nrounds",lower=200,upper=750, default = 350),
  makeNumericParam("eta", lower = -7, upper = -5, default = -6, trafo = function(x) 2^x),
  makeIntegerParam("max_depth",lower=3,upper=20, default = 12),
  makeNumericParam("subsample", lower = 0.3, upper = 1, default = 0.8),
  makeNumericParam("colsample_bytree",lower = 0.3,upper = 1, default = 0.8))


# Setting control object for MBO optimization  - Bayesian optimization (aka model based optimization)
mbo_control <- makeMBOControl(save.on.disk.at = c(10,25,45),save.file.path = paste0(path,"xgboost_parametros_", cod_mes, ".RData"))

# Extends an MBO control object with infill criteria and infill optimizer options
mbo_control <- setMBOControlTermination(mbo_control, iters = 50)

# Defining surrogate learner
surrogate_lrn <- makeLearner("regr.km", predict.type = "se")

# Create control object for hyperparameter tuning with MBO
tune_control = mlr:::makeTuneControlMBO(learner = surrogate_lrn, mbo.control = mbo_control)

# Tuneo parametros --------------------------------------------------------
xg_tune <-
  tuneParams(
    learner = xgboost_learner,
    task = task,
    resampling = sampling_method,
    measures = auc,
    par.set = xgboost_params,
    control = tune_control,
    show.info = TRUE
  )

opt_results <- as.data.frame(xg_tune$opt.path)
write.csv(opt_results, paste0(path,"xgboost_pruebas_completas_", cod_mes,".csv"), row.names = FALSE)

# Elijo los mejores parametros y entreno--------------------------------------------

xg_new <- setHyperPars(learner = xgboost_learner, par.vals = xg_tune$x)
train_task <- makeClassifTask(data = df[train_inds,], target = "clase")
xg_model <- train(xg_new, train_task)

# Predigo test ----------------------------------------------

predict_task <- makeClassifTask(data =  df[test_inds,], target = "clase")
predict_test <- predict(xg_model, predict_task)


# Calculo metricas de performance -----------------------------------------

# obtengo predicciones y observaciones
predictions = predict_test$data$prob.1
observations = predict_test$data$truth

# obtengo acc y auc
perf_measures <- list("acc" = acc, "auc" = auc)
measures <- performance(predict_test, measures = perf_measures)

# obtengo ks, para ello le paso el tpr y fpr para distintos puntos de corte
d = generateThreshVsPerfData(predict_test, measures = list(fpr, tpr))
measures[3] <- ks(d$data$tpr,d$data$fpr)
names(measures)[3] <- "ks"

# guardo resultados

write.csv(measures, paste0(path,"xgboost_best_measures_", cod_mes,".csv"), row.names = FALSE)

# obtengo variable importance
var_importance <- getFeatureImportance(xg_model)
var_importance <- as.data.frame(t(var_importance$res))

write.csv(var_importance, paste0(dir_performance_modelos_pruebas,"xgboost_var_importance_", cod_mes,".csv"), row.names = FALSE)



