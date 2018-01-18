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

# Importamos archivo ------------------------------------------------------

df <- read_info("input_modelo_2018_1.csv","historia", 1000)

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

# Task, Learner, metodo de sampleo --------------------------------------------------------------

task = makeClassifTask(data = df, target = "clase")

train_inds = seq(1:train_rows)
test_inds = seq((train_rows+1),nrow(df))

sampling_method = makeFixedHoldoutInstance(train_inds, test_inds, nrow(df))

# Armo learner y sus parametros
xgboost_learner <- makeLearner("classif.xgboost", predict.type = "prob")

xgboost_learner$par.vals <- list(
  booster = "gbtree",
  nthread = 12)

xgboost_params <- makeParamSet(
  makeIntegerParam("nrounds",lower=200,upper=750, default = 350),
  makeNumericParam("eta", lower = -7, upper = -5, default = -6, trafo = function(x) 2^x),
  makeIntegerParam("max_depth",lower=3,upper=20, default = 12),
  makeNumericParam("subsample", lower = 0.3, upper = 1, default = 0.8),
  makeNumericParam("colsample_bytree",lower = 0.3,upper = 1, default = 0.8))


# Setting control object for MBO optimization  - Bayesian optimization (aka model based optimization)
# mbo_control <- makeMBOControl(save.on.disk.at = c(10,25,50,75,99),save.file.path = paste0(dir_performance_modelos_pruebas,"parametros_",cod_mes,".RData"))
mbo_control <- makeMBOControl()
# Extends an MBO control object with infill criteria and infill optimizer options
mbo_control <- setMBOControlTermination(mbo_control, iters = 5)

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

opt_results <- as.data.frame(xgTune$opt.path)
write.csv(opt_results, paste0(dir_performance_modelos_pruebas,"xgboost_", cod_mes,".csv"), row.names = FALSE)

# Elijo los mejores parametros y entreno--------------------------------------------

xg_new <- setHyperPars(learner = xgboost_learner, par.vals = xg_tune$x)
train_task <- makeClassifTask(data = df[train_inds,], target = "clase")
xg_model <- train(xg_new, train_task)

# Predigo test ----------------------------------------------

predict_task <- makeClassifTask(data =  df[test_inds,], target = "clase")
predict_test <- predict(xg_model, predict_task)



perf_measures <- c(acc, auc)
performance(predict_test,lift)

var_importance <- getFeatureImportance(xgModel)
View(as.data.frame(t(var_importance$res)))

# Variables más importantes
# Pago_Minimo_Impago_30
# Intereses_Punitorios_Total
# Score_Riesgo
# Monto_IVA_Pesos
# Score_Financiacion
# marca_pago_minimo_impago_30
# Intereses_Financiacion_Pesos


# Genero auc y ks ---------------------------------------------------------

predictTask <- makeClassifTask(data =  df[test.inds,], target = "clase_veraz")
predictTest <- predict(xgModel, predictTask)

performance(predictTest, measures = list(auc))
prd = predictTest$data$prob.1
act = predictTest$data$truth

# ojo que oculta la funcion performance de mlr

library(ROCR)
pred<-prediction(prd,act)
perf <- performance(pred,"tpr","fpr")

#this code builds on ROCR library by taking the max delt
#between cumulative bad and good rates being plotted by
#ROCR see https://cran.r-project.org/doc/contrib/Sharma-CreditScoring.pdf
ks=max(attr(perf,'y.values')[[1]]-attr(perf,'x.values')[[1]])
plot(perf,main=paste0(' KS=',round(ks*100,1),'%'))
lines(x = c(0,1),y=c(0,1))
print(ks);





scoreTest <- data.frame(y = predictTest$data$truth, x = predictTest$data$prob.1)
scoreCalibration <- data.frame(y = predictCalibration$data$truth, x = predictCalibration$data$prob.1)




# Guardo modelos ------------------------------
saveRDS(logitModel,paste0(fuentes.modelos.actual,"modelo_calibracion_",banco,".RDS"))

saveRDS(logitModel,paste0(fuentes.modelos.historia,"modelo_calibracion_",banco,"_",year,"_",month,".RDS"))       

saveRDS(xgModel,paste0(fuentes.modelos.actual,"modelo_",banco,".RDS"))

saveRDS(xgModel,paste0(fuentes.modelos.historia,"modelo_",banco,"_",year,"_",month,".RDS"))       



