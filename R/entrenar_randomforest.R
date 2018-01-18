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

df <- read_info("input_modelo_2018_1.csv","historia", 1000,strings_as_factors=FALSE)
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



# Task, Learner, metodo de sampleo --------------------------------------------------------------

for(c in 1:ncol(df)){
  if(typeof(df[,c])=="character"){df[,c]<-as.factor(df[,c])}
  
}
df[,"clase"]<-as.factor(df[,"clase"])

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
#str(df)


rf_new <- setHyperPars(learner = randomforest_learner, par.vals = rf_tune$x)
train_task <- makeClassifTask(data = df, target = "clase" ,fixup.data = "no")
rf_model <- train(rf_new, train_task)

# Predigo test ----------------------------------------------

for(c in 1:ncol(test)){
  if(typeof(test[,c])=="character"){test[,c]<-as.factor(test[,c])}
  
}
test[,"clase"]<-as.factor(test[,"clase"])


predict_task <- makeClassifTask(data =  test, target = "clase",fixup.data = "no")
predict_test <- predict(rf_model, predict_task)

#df$Cod_Limite_Compra[which(is.na(df$Cod_Limite_Compra))]

perf_measures <- c(acc, auc)
performance(predict_test)

var_importance <- getFeatureImportance(rf_model)
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

