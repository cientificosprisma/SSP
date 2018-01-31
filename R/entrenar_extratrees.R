rm(list=ls())
gc()

############

## Script para entrenar extraTrees

# Setup -------------------------------------------------------------------

library(mlr)
library(dplyr)
library(mlrMBO)
library(ranger)
library(data.table)

set.seed(12112016)

source("/home/Compartida_CD_GI/d_visa_scoring/scripts/basicos.R")
source("/home/Compartida_CD_GI/d_visa_scoring/scripts/funciones.R")

cod_mes = 201801

### Importamos archivo ------------------------------------------------------
df <- read_info("input_modelo_historia_g2.csv","historia", 10000,strings_as_factors=FALSE)
excluded_factors <- c("Cod_Tipo_Identificacion_Host", "Cod_Banco", "Cod_Estado_Cuenta","Cod_Limite_Compra",
                      "Cod_Region_Geografica_Host", "Cod_Grupo_Afinidad", "Cod_Modelo_Liquidacion")

df <- df %>% select(-c(clase_cp_1, clase_cp_2, clase_lp_1, clase_lp_2))

df <- df %>% select(setdiff(colnames(df),excluded_factors))

df <- df %>% rename(clase = clase_veraz)
df <- map_factors(df)
df[is.na(df)]<-(-99999)
df$clase <- as.factor(df$clase)
colnames(dt) <- str_replace(colnames(dt),"\\$","__")

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

## Task, Learner, metodo de sampleo --------------------------------------------------------------

#df$Cod_Tipo_Cuenta <- as.factor(as.character(df$Cod_Tipo_Cuenta))
task = makeClassifTask(data = df, target = "clase", fixup.data = "no")

train_inds = seq(1:train_rows)
test_inds = seq((train_rows+1),nrow(df))

sampling_method = makeFixedHoldoutInstance(train_inds, test_inds, nrow(df))

# Armo learner y sus parametros

extratrees_learner <- makeLearner("classif.extraTrees", predict.type = "prob",fix.factors.prediction = TRUE)

extratrees_learner$par.vals<- list(numThreads =6 )

mtry_min = round(0.2*length(colnames(df)))
mtry_max = round(0.9*length(colnames(df)))

#extratrees_learner$par.set
extratrees_params <- makeParamSet(
  makeIntegerParam("ntree",lower=200,upper=600),
  makeIntegerParam("mtry", lower = mtry_min, upper = mtry_max),
  makeIntegerParam("numRandomCuts", lower = 1, upper = 5)
)

des = generateDesign(n = 20, par.set = extratrees_params)

# Setting control object for MBO optimization  - Bayesian optimization (aka model based optimization)
#mbo_control <- makeMBOControl(save.on.disk.at = c(10,25,30,40),save.file.path = paste0(dir_performance_modelos_pruebas,"extratrees_parametros_",cod_mes,".RData"))
mbo_control <- makeMBOControl()
# Extends an MBO control object with infill criteria and infill optimizer options
mbo_control <- setMBOControlTermination(mbo_control, iters = 20)

# Defining surrogate learner
surrogate_lrn <- makeLearner("regr.km", predict.type = "se")
clase = df[train_inds,"clase"]
nuggets = 1e-8*var(clase)

surrogate_lrn <- setHyperPars(learner = surrogate_lrn, par.vals = list(nugget=nuggets))

# Create control object for hyperparameter tuning with MBO
tune_control = mlr:::makeTuneControlMBO(learner = surrogate_lrn, mbo.control = mbo_control, mbo.design = des)

# Tuneo parametros --------------------------------------------------------
et_tune <-
  tuneParams(
    learner = extratrees_learner,
    task = task,
    resampling = sampling_method,
    measures = auc,
    par.set = extratrees_params,
    control = tune_control,
    show.info = TRUE
  )

opt_results <- as.data.frame(et_tune$opt.path)

#str(df)

write.csv(opt_results, paste0(dir_performance_modelos_pruebas,"extratrees.csv"), row.names = FALSE)

# Elijo los mejores parametros y entreno--------------------------------------------

et_new <- setHyperPars(learner = extratrees_learner, par.vals = et_tune$x)
train_task <- makeClassifTask(data = train, target = "clase" ,fixup.data = "no")
et_model <- train(et_new, train_task)

# Predigo test ----------------------------------------------

predict_task <- makeClassifTask(data =  test, target = "clase",fixup.data = "no")

predict_test <- predict(et_model, predict_task)

# obtengo acc y auc
perf_measures <- list("acc" = acc, "auc" = auc)
measures <- performance(predict_test, measures = perf_measures)

# obtengo ks, para ello le paso el tpr y fpr para distintos puntos de corte
d = generateThreshVsPerfData(predict_test, measures = list(fpr, tpr))
measures[3] <- ks(d$data$tpr,d$data$fpr)
names(measures)[3] <- "ks"

# guardo resultados
write.csv(measures, paste0(dir_performance_modelos_pruebas,"extratrees_measures_", cod_mes,".csv"), row.names = FALSE)
