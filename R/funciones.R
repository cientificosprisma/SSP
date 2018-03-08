## En este script se encuentran distintas funciones de uso general

# Funcion para ejecutar queries -------------------------------------------

get_query <- function(query, db){
  if (tolower(db) == "teradata" | tolower(db) == "td"){
    
    # ejecuto query
    options( java.parameters = "-Xmx8g" )
    library(RJDBC)
    library(teradataR)
    
    # Basicos
    source("/home/Compartida_CD_GI/d_visa_scoring/scripts/basicos.R")
    
    #Definimos la conexion
    drv <- JDBC("com.teradata.jdbc.TeraDriver",paste0(dir_compartida,"terajdbc4.jar:",dir_compartida,"tdgssconfig.jar"))
    con <- tdConnect("192.168.51.2/CHARSET=UTF8,TMODE=TERA,SESSIONS= 1 ", uid = usuarioTeradata, pwd = contrasenaTeradata, dType ="jdbc")
    
    ## Importamos archivo
    result <- dbGetQuery(con, query)
    
  } else{
    
    if (tolower(db) == "hadoop" | tolower(db) == "hive" | tolower(db) == "hdp"){
      # ejecuto query
    }
    
    else{
      print("db no reconocida")
    } 
  }
  
  return(result)
  
}


# Funciones para guardar mapeo y luego mapear factores ----------------------------------------------
save_mapping <- function(df){
  col_idx <- c()
  
  for (i in 1:ncol(df)){
    
    if (typeof(df[,i])=="character"){
      col_idx <- c(col_idx,i)
    }
  }
  
  for (i in col_idx){
    assign(paste0("col_key_",i),sort(unique(df[,i])))
    len <- length(get(paste0("col_key_",i)))
    vector <- 1:len
    key_value <- data.frame(key = get(paste0("col_key_",i)), value = vector)
    col_name <- colnames(df)[i]
    colnames(key_value)[1] <- col_name
    saveRDS(key_value, paste0(dir_configuracion_columnas, col_name,".RDS"))
    }
}

map_factors <- function(df){
  library(dplyr)
  col_idx <- c()
  
  for (i in 1:ncol(df)){
    
    if (typeof(df[,i])=="character"){
      col_idx <- c(col_idx,i)
    }
  }
  
  for (i in col_idx){
    col_name <- colnames(df)[i]
    if(file.exists(paste0(dir_configuracion_columnas, col_name,".RDS"))){
      assign(paste0(col_name,"_value"), readRDS(paste0(dir_configuracion_columnas, col_name,".RDS")))
      suppressMessages(df <- df %>% left_join(y = get(paste0(col_name,"_value"))))
      df[,col_name] <- df[,"value"]
      df$value <- NULL
} else{
      df[,i] <- 9999
    }
  }
  return(df)
}

# Funcion que genera la matriz para xgboost -------------------------------

get_xgboost_matrix <- function(df, entrenamiento=FALSE){

  # partition es == 1 si se splitea en train y test y partition == 2 si se splitea en train, test y calibration
    
    library(data.table)
    library(stringr)
    dt <- as.data.table(df)
    
    ## Me quedo con los is.na(clase) == FALSE
   
     if(entrenamiento){
    dt <- dt[is.na(clase) == FALSE]
    }
    
    colnames(dt) <- str_replace(colnames(dt),"\\$","__")
    
    dt <- dt[,lapply(.SD,as.numeric)] %>% as.matrix
    
    dt <- as.data.frame(dt)
    if(entrenamiento){
    dt$clase <- as.factor(dt$clase)
    }
    
    return(dt)

}


# Funcion que arma split entre train, test y calibration ------------------

get_train_test<-function(df,factor_sample=0.75,calibration_flag=FALSE, undersampling = T){
  library(dplyr)
  
  #se usa como train el último mes
  train<- df %>% filter(Cod_Mes!=max(df$Cod_Mes))
  
  if (undersampling == T){
    
    train_class_1 <- train %>% filter(clase == 1)
    rows_train_class_1 <- nrow(train_class_1)
    
    train_class_0 <- train %>% filter(clase == 0)
    train_class_0 <- train_class_0[sample(nrow(train_class_0), rows_train_class_1),]
    
    train <- rbind(train_class_0,train_class_1)
    
  }
  
  
  
  #se usa como test y calibración los meses anteriores al último
  test <- df %>% filter(Cod_Mes==max(df$Cod_Mes))
  results <- list(train,test)
  
  
  if(calibration_flag){
    
    split_sample<-round(nrow(test)*factor_sample)
    #shuffle
    test<-sample_n(test,nrow(test))
    #Se crea calibracion 
    calibration<-test[(split_sample+1):nrow(test),]
    #Se crea Test
    test<-test[1:split_sample,]
    
    results <- list(train,test,calibration)
    
  }
  
  return(results)
}


# Funcion que lee info historia o actual ----------------------------------

read_info <- function(filename, type, n_rows = -1L,strings_as_factors=FALSE ){
  
  library(data.table)
  col_classes <- readRDS(paste0(dir_configuracion_columnas,"col_classes.RDS"))
  
  # type puede ser "actual" o "historia"
  if (tolower(type) == "actual"){
    df <- fread(paste0(dir_info_actual,filename), colClasses = col_classes, nrows = n_rows, stringsAsFactors = strings_as_factors, data.table = FALSE)
  } else{
    if (tolower(type) == "historia"){
      df <- fread(paste0(dir_info_historia,filename), colClasses = col_classes, nrows = n_rows, stringsAsFactors = strings_as_factors, data.table = FALSE)
    } else{
      print("Parametro incorrecto!")
    } 
  }
  return(df)
}

ks <- function(tpr, fpr){
  # se podria agregar el plot
  
  #this code builds on ROCR library by taking the max delt
  #between cumulative bad and good rates being plotted by
  #ROCR see https://cran.r-project.org/doc/contrib/Sharma-CreditScoring.pdf
  ks = max(tpr-fpr)
  return(ks)
  
}


ks2 <- function(prd,act){
  library(ROCR)
  pred<-prediction(prd,act)
  perf <- performance(pred,"tpr","fpr")
  
  #this code builds on ROCR library by taking the max delt
  #between cumulative bad and good rates being plotted by
  #ROCR see https://cran.r-project.org/doc/contrib/Sharma-CreditScoring.pdf
  ks=max(attr(perf,'y.values')[[1]]-attr(perf,'x.values')[[1]])
  plot(perf,main=paste0(' KS=',round(ks*100,1),'%'))
  lines(x = c(0,1),y=c(0,1))
  ks
}



actualiza_lks<-function(df,factor_list){
  
  #actualiza lookups
  
  for(i in 1:length(factor_list)){
    
    
    col<-factor_list[i]
    idx_col<-grep(paste0("^",col,"$"),colnames(df))
    vec_factores<-levels(df[,idx_col])
    
    vec_factores<-c(vec_factores,"__NAs__")
    lk_act<-data.frame(id_factores=vec_factores,stringsAsFactors = FALSE)
    lk_act<-lk_act %>% filter(id_factores!="")
    col_nom<-colnames(df)[idx_col]
    colnames(lk_act)<-col_nom
    #fwrite(lk_act,file = paste0(dir_configuracion_columnas,"lookup_",colnames(df)[idx_col],".csv"), row.names = FALSE)
    lk<-fread(paste0(dir_configuracion_columnas,"lookup_",col_nom,".csv"))
    lk_merge<-unique(rbind(lk_act,lk))
    fwrite(lk_merge,file = paste0(dir_configuracion_columnas,"lookup_",col_nom,".csv"), row.names = FALSE)
    assign(paste0("lk_",col_nom)  ,lk_merge)
    
    
  }
  
}



add_na_elem<-function(a){
 return( c(a,"__NAs__"))
  
}

a_factor<-function(df,lista_col,orden=FALSE){
  for(i in 1:length(lista_col)){
    col<-lista_col[i]
    idx_col<-grep(paste0("^",col,"$"),colnames(df))
    df[,idx_col]<-factor(df[,idx_col],ordered = orden)
  }
  return(df)
}

obtener_factores_faltantes<-function(train,df_completo,factor_list){
  library(data.table)
  list_dfs<-c()
  max<-0
  longitud  <- c()
  for(i in 1:length(factor_list)){
    col<-factor_list[i]
    idx_col<-grep(paste0("^",col,"$"),colnames(df))
    factor_dif<-c(levels(df[,idx_col])[!( levels(df[,idx_col])%in% unique(train[,idx_col])  )])
    factor_dif<-add_na_elem(factor_dif)
    assign(paste0("factor_dif_",col),factor_dif)
    list_dfs<-c(list_dfs,paste0("factor_dif_",col))
    # longitud <- c(longitud, length(factor_dif))
    max<-ifelse(max<length(factor_dif),length(factor_dif),max)
  }
  
  # which(longitud == max(longitud))
  df_aux <- as.data.table(df[1:max,])
  
  for (c in 1:length(factor_list) ){
    col<-factor_list[c]
    idx_col<-grep(paste0("^",col,"$"),colnames(df))
    df_aux[,idx_col] <- get(paste0("factor_dif_",col))
    
  }
  df_aux$clase<-'0'
  return(as.data.frame(df_aux))
}

lookupea_factores<- function(X,factor_list){
  
  for(i in 1:length(factor_list)){
    col_nom<-factor_list[i]
    lk<-fread(paste0(dir_configuracion_columnas,"lookup_",col_nom,".csv"))
    assign(paste0("lk_",col_nom)  ,lk)
  }
  X<- a_factor(X,lista_col =factor_list ,orden = FALSE)
  
  
  #LEFT JOIN Cod_Tipo_Identificacion_Host
  col_name<-colnames(lk_Cod_Tipo_Identificacion_Host)
  lk_Cod_Tipo_Identificacion_Host<-cbind(lk_Cod_Tipo_Identificacion_Host,lk_Cod_Tipo_Identificacion_Host)
  colnames(lk_Cod_Tipo_Identificacion_Host)<-c(col_name,"desc")
  X<- X %>% left_join(lk_Cod_Tipo_Identificacion_Host)
  X<-X %>% mutate(Cod_Tipo_Identificacion_Host=desc) %>% select(-desc)
  
  #LEFT JOIN Cod_Banco
  col_name<-colnames(lk_Cod_Banco)
  lk_Cod_Banco<-cbind(lk_Cod_Banco,lk_Cod_Banco)
  colnames(lk_Cod_Banco)<-c(col_name,"desc")
  X<- X %>% left_join(lk_Cod_Banco)
  X<-X %>% mutate(Cod_Banco=desc) %>% select(-desc)
  
  #LEFT JOIN lk_Cod_Tipo_Cuenta
  col_name<-colnames(lk_Cod_Tipo_Cuenta)
  lk_Cod_Tipo_Cuenta<-cbind(lk_Cod_Tipo_Cuenta,lk_Cod_Tipo_Cuenta)
  colnames(lk_Cod_Tipo_Cuenta)<-c(col_name,"desc")
  X<- X %>% left_join(lk_Cod_Tipo_Cuenta)
  X<-X %>% mutate(Cod_Tipo_Cuenta=desc) %>% select(-desc)
  
  
  #LEFT JOIN Cod_Estado_Cuenta
  col_name<-colnames(lk_Cod_Estado_Cuenta)
  lk_Cod_Estado_Cuenta<-cbind(lk_Cod_Estado_Cuenta,lk_Cod_Estado_Cuenta)
  colnames(lk_Cod_Estado_Cuenta)<-c(col_name,"desc")
  X<- X %>% left_join(lk_Cod_Estado_Cuenta)
  X<-X %>% mutate(Cod_Estado_Cuenta=desc) %>% select(-desc)
  
  #LEFT JOIN Ciclo_Liquidacion
  col_name<-colnames(lk_Ciclo_Liquidacion)
  lk_Ciclo_Liquidacion<-cbind(lk_Ciclo_Liquidacion,lk_Ciclo_Liquidacion)
  colnames(lk_Ciclo_Liquidacion)<-c(col_name,"desc")
  X<- X %>% left_join(lk_Ciclo_Liquidacion)
  X<-X %>% mutate(Ciclo_Liquidacion=desc) %>% select(-desc)
  
  #LEFT JOIN Cod_Limite_Compra
  col_name<-colnames(lk_Cod_Limite_Compra)
  lk_Cod_Limite_Compra<-cbind(lk_Cod_Limite_Compra,lk_Cod_Limite_Compra)
  colnames(lk_Cod_Limite_Compra)<-c(col_name,"desc")
  X<- X %>% left_join(lk_Cod_Limite_Compra)
  X<-X %>% mutate(Cod_Limite_Compra=desc) %>% select(-desc)
  
  #LEFT JOIN Cod_Region_Geografica_Host
  col_name<-colnames(lk_Cod_Region_Geografica_Host)
  lk_Cod_Region_Geografica_Host<-cbind(lk_Cod_Region_Geografica_Host,lk_Cod_Region_Geografica_Host)
  colnames(lk_Cod_Region_Geografica_Host)<-c(col_name,"desc")
  X<- X %>% left_join(lk_Cod_Region_Geografica_Host)
  X<-X %>% mutate(Cod_Region_Geografica_Host=desc) %>% select(-desc)
  
  #LEFT JOIN Cod_Grupo_Afinidad
  col_name<-colnames(lk_Cod_Grupo_Afinidad)
  lk_Cod_Grupo_Afinidad<-cbind(lk_Cod_Grupo_Afinidad,lk_Cod_Grupo_Afinidad)
  colnames(lk_Cod_Grupo_Afinidad)<-c(col_name,"desc")
  X<- X %>% left_join(lk_Cod_Grupo_Afinidad)
  X<-X %>% mutate(Cod_Grupo_Afinidad=desc) %>% select(-desc)
  
  #LEFT JOIN Cod_SubProducto_1
  col_name<-colnames(lk_Cod_SubProducto_1)
  lk_Cod_SubProducto_1<-cbind(lk_Cod_SubProducto_1,lk_Cod_SubProducto_1)
  colnames(lk_Cod_SubProducto_1)<-c(col_name,"desc")
  X<- X %>% left_join(lk_Cod_SubProducto_1)
  X<-X %>% mutate(Cod_SubProducto_1=desc) %>% select(-desc)
  
  #LEFT JOIN lk_Cod_SubProducto_2
  col_name<-colnames(lk_Cod_SubProducto_2)
  lk_Cod_SubProducto_2<-cbind(lk_Cod_SubProducto_2,lk_Cod_SubProducto_2)
  colnames(lk_Cod_SubProducto_2)<-c(col_name,"desc")
  X<- X %>% left_join(lk_Cod_SubProducto_2)
  X<-X %>% mutate(Cod_SubProducto_2=desc) %>% select(-desc)
  
  #LEFT JOIN Cod_Modelo_Liquidacion
  col_name<-colnames(lk_Cod_Modelo_Liquidacion)
  lk_Cod_Modelo_Liquidacion<-cbind(lk_Cod_Modelo_Liquidacion,lk_Cod_Modelo_Liquidacion)
  colnames(lk_Cod_Modelo_Liquidacion)<-c(col_name,"desc")
  X<- X %>% left_join(lk_Cod_Modelo_Liquidacion)
  X<-X %>% mutate(Cod_Modelo_Liquidacion=desc) %>% select(-desc)
  
  #LEFT JOIN Cod_Tipo_Tarjeta
  col_name<-colnames(lk_Cod_Tipo_Tarjeta)
  lk_Cod_Tipo_Tarjeta<-cbind(lk_Cod_Tipo_Tarjeta,lk_Cod_Tipo_Tarjeta)
  colnames(lk_Cod_Tipo_Tarjeta)<-c(col_name,"desc")
  X<- X %>% left_join(lk_Cod_Tipo_Tarjeta)
  X<-X %>% mutate(Cod_Tipo_Tarjeta=desc) %>% select(-desc)
  
  #LEFT JOIN Segmento_Credito
  col_name<-colnames(lk_Segmento_Credito)
  lk_Segmento_Credito<-cbind(lk_Segmento_Credito,lk_Segmento_Credito)
  colnames(lk_Segmento_Credito)<-c(col_name,"desc")
  X<- X %>% left_join(lk_Segmento_Credito)
  X<-X %>% mutate(Segmento_Credito=desc) %>% select(-desc)
  
  #LEFT JOIN Cod_Sexo_Host
  col_name<-colnames(lk_Cod_Sexo_Host)
  lk_Cod_Sexo_Host<-cbind(lk_Cod_Sexo_Host,lk_Cod_Sexo_Host)
  colnames(lk_Cod_Sexo_Host)<-c(col_name,"desc")
  X<- X %>% left_join(lk_Cod_Sexo_Host)
  X<-X %>% mutate(Cod_Sexo_Host=desc) %>% select(-desc)
  
  #LEFT JOIN Marca_Limite_Unificado
  col_name<-colnames(lk_Marca_Limite_Unificado)
  lk_Marca_Limite_Unificado<-cbind(lk_Marca_Limite_Unificado,lk_Marca_Limite_Unificado)
  colnames(lk_Marca_Limite_Unificado)<-c(col_name,"desc")
  X<- X %>% left_join(lk_Marca_Limite_Unificado)
  X<-X %>% mutate(Marca_Limite_Unificado=desc) %>% select(-desc)
  
  #LEFT JOIN marca_pago_minimo_impago_30
  col_name<-colnames(lk_marca_pago_minimo_impago_30)
  lk_marca_pago_minimo_impago_30<-cbind(lk_marca_pago_minimo_impago_30,lk_marca_pago_minimo_impago_30)
  colnames(lk_marca_pago_minimo_impago_30)<-c(col_name,"desc")
  X<- X %>% left_join(lk_marca_pago_minimo_impago_30)
  X<-X %>% mutate(marca_pago_minimo_impago_30=desc) %>% select(-desc)
  
  #LEFT JOIN marca_pago_minimo_impago_30_menos_1
  col_name<-colnames(lk_marca_pago_minimo_impago_30_menos_1)
  lk_marca_pago_minimo_impago_30_menos_1<-cbind(lk_marca_pago_minimo_impago_30_menos_1,lk_marca_pago_minimo_impago_30_menos_1)
  colnames(lk_marca_pago_minimo_impago_30_menos_1)<-c(col_name,"desc")
  X<- X %>% left_join(lk_marca_pago_minimo_impago_30_menos_1)
  X<-X %>% mutate(marca_pago_minimo_impago_30_menos_1=desc) %>% select(-desc)
  
  #LEFT JOIN marca_pago_minimo_impago_30_menos_2
  col_name<-colnames(lk_marca_pago_minimo_impago_30_menos_2)
  lk_marca_pago_minimo_impago_30_menos_2<-cbind(lk_marca_pago_minimo_impago_30_menos_2,lk_marca_pago_minimo_impago_30_menos_2)
  colnames(lk_marca_pago_minimo_impago_30_menos_2)<-c(col_name,"desc")
  X<- X %>% left_join(lk_marca_pago_minimo_impago_30_menos_2)
  X<-X %>% mutate(marca_pago_minimo_impago_30_menos_2=desc) %>% select(-desc)
  
  #LEFT JOIN marca_pago_minimo_impago_30_menos_3
  col_name<-colnames(lk_marca_pago_minimo_impago_30_menos_3)
  lk_marca_pago_minimo_impago_30_menos_3<-cbind(lk_marca_pago_minimo_impago_30_menos_3,lk_marca_pago_minimo_impago_30_menos_3)
  colnames(lk_marca_pago_minimo_impago_30_menos_3)<-c(col_name,"desc")
  X<- X %>% left_join(lk_marca_pago_minimo_impago_30_menos_3)
  X<-X %>% mutate(marca_pago_minimo_impago_30_menos_3=desc) %>% select(-desc)
  
  #LEFT JOIN marca_pago_minimo_impago_30_menos_4
  col_name<-colnames(lk_marca_pago_minimo_impago_30_menos_4)
  lk_marca_pago_minimo_impago_30_menos_4<-cbind(lk_marca_pago_minimo_impago_30_menos_4,lk_marca_pago_minimo_impago_30_menos_4)
  colnames(lk_marca_pago_minimo_impago_30_menos_4)<-c(col_name,"desc")
  X<- X %>% left_join(lk_marca_pago_minimo_impago_30_menos_4)
  X<-X %>% mutate(marca_pago_minimo_impago_30_menos_4=desc) %>% select(-desc)
  
  #LEFT JOIN marca_pago_minimo_impago_30_menos_5
  col_name<-colnames(lk_marca_pago_minimo_impago_30_menos_5)
  lk_marca_pago_minimo_impago_30_menos_5<-cbind(lk_marca_pago_minimo_impago_30_menos_5,lk_marca_pago_minimo_impago_30_menos_5)
  colnames(lk_marca_pago_minimo_impago_30_menos_5)<-c(col_name,"desc")
  X<- X %>% left_join(lk_marca_pago_minimo_impago_30_menos_5)
  X<-X %>% mutate(marca_pago_minimo_impago_30_menos_5=desc) %>% select(-desc)
  
  #LEFT JOIN clase
  col_name<-colnames(lk_clase)
  lk_clase<-cbind(lk_clase,lk_clase)
  colnames(lk_clase)<-c(col_name,"desc")
  X<- X %>% left_join(lk_clase)
  X<-X %>% mutate(clase=desc) %>% select(-desc)
  
  #LEFT JOIN Rango_Limite_Compra
  col_name<-colnames(lk_Rango_Limite_Compra)
  lk_Rango_Limite_Compra<-cbind(lk_Rango_Limite_Compra,lk_Rango_Limite_Compra)
  colnames(lk_Rango_Limite_Compra)<-c(col_name,"desc")
  X<- X %>% left_join(lk_Rango_Limite_Compra)
  X<-X %>% mutate(Rango_Limite_Compra=desc) %>% select(-desc)
  
  #LEFT JOIN Rango_Antiguedad
  col_name<-colnames(lk_Rango_Antiguedad)
  lk_Rango_Antiguedad<-cbind(lk_Rango_Antiguedad,lk_Rango_Antiguedad)
  colnames(lk_Rango_Antiguedad)<-c(col_name,"desc")
  X<- X %>% left_join(lk_Rango_Antiguedad)
  X<-X %>% mutate(Rango_Antiguedad=desc) %>% select(-desc)
  
  #LEFT JOIN Rango_Utiliza_LC_Trim
  col_name<-colnames(lk_Rango_Utiliza_LC_Trim)
  lk_Rango_Utiliza_LC_Trim<-cbind(lk_Rango_Utiliza_LC_Trim,lk_Rango_Utiliza_LC_Trim)
  colnames(lk_Rango_Utiliza_LC_Trim)<-c(col_name,"desc")
  X<- X %>% left_join(lk_Rango_Utiliza_LC_Trim)
  X<-X %>% mutate(Rango_Utiliza_LC_Trim=desc) %>% select(-desc)
  
  #LEFT JOIN Rango_Utiliza_LC_Sem
  col_name<-colnames(lk_Rango_Utiliza_LC_Sem)
  lk_Rango_Utiliza_LC_Sem<-cbind(lk_Rango_Utiliza_LC_Sem,lk_Rango_Utiliza_LC_Sem)
  colnames(lk_Rango_Utiliza_LC_Sem)<-c(col_name,"desc")
  X<- X %>% left_join(lk_Rango_Utiliza_LC_Sem)
  X<-X %>% mutate(Rango_Utiliza_LC_Sem=desc) %>% select(-desc)
  
  #LEFT JOIN Rango_Utiliza_LC_Anio
  col_name<-colnames(lk_Rango_Utiliza_LC_Anio)
  lk_Rango_Utiliza_LC_Anio<-cbind(lk_Rango_Utiliza_LC_Anio,lk_Rango_Utiliza_LC_Anio)
  colnames(lk_Rango_Utiliza_LC_Anio)<-c(col_name,"desc")
  X<- X %>% left_join(lk_Rango_Utiliza_LC_Anio)
  X<-X %>% mutate(Rango_Utiliza_LC_Anio=desc) %>% select(-desc)
  
  #LEFT JOIN Rango_Rel_Pagos_Saldos_Trim
  col_name<-colnames(lk_Rango_Rel_Pagos_Saldos_Trim)
  lk_Rango_Rel_Pagos_Saldos_Trim<-cbind(lk_Rango_Rel_Pagos_Saldos_Trim,lk_Rango_Rel_Pagos_Saldos_Trim)
  colnames(lk_Rango_Rel_Pagos_Saldos_Trim)<-c(col_name,"desc")
  X<- X %>% left_join(lk_Rango_Rel_Pagos_Saldos_Trim)
  X<-X %>% mutate(Rango_Rel_Pagos_Saldos_Trim=desc) %>% select(-desc)
  
  #LEFT JOIN Rango_Rel_Pagos_Saldos_Sem
  col_name<-colnames(lk_Rango_Rel_Pagos_Saldos_Sem)
  lk_Rango_Rel_Pagos_Saldos_Sem<-cbind(lk_Rango_Rel_Pagos_Saldos_Sem,lk_Rango_Rel_Pagos_Saldos_Sem)
  colnames(lk_Rango_Rel_Pagos_Saldos_Sem)<-c(col_name,"desc")
  X<- X %>% left_join(lk_Rango_Rel_Pagos_Saldos_Sem)
  X<-X %>% mutate(Rango_Rel_Pagos_Saldos_Sem=desc) %>% select(-desc)
  
  
  #LEFT JOIN Rango_Rel_Pagos_Saldos_Anio
  col_name<-colnames(lk_Rango_Rel_Pagos_Saldos_Anio)
  lk_Rango_Rel_Pagos_Saldos_Anio<-cbind(lk_Rango_Rel_Pagos_Saldos_Anio,lk_Rango_Rel_Pagos_Saldos_Anio)
  colnames(lk_Rango_Rel_Pagos_Saldos_Anio)<-c(col_name,"desc")
  X<- X %>% left_join(lk_Rango_Rel_Pagos_Saldos_Anio)
  X<-X %>% mutate(Rango_Rel_Pagos_Saldos_Anio=desc) %>% select(-desc)
  
  
  X[is.na(X)]<-"__NAs__"
  return(X)
}
<<<<<<< HEAD
add_na_elem<-function(a){
 return( c(a,"__NAs__"))
  
}

# Funcion que calcula el AUC dadas las proba y clase
fastAUC <- function(probs, class) {
  x <- probs
  y <- class
  x1 = x[y==1]; n1 = length(x1); 
  x2 = x[y==0]; n2 = length(x2);
  r = rank(c(x1,x2))  
  auc = (sum(r[1:n1]) - n1*(n1+1)/2) / n1 / n2
  return(auc)
}
=======
>>>>>>> fa49fb77ed90c85148d2de3e3d475d77d76483c6
