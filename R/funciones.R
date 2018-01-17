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