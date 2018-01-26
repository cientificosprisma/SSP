replace procedure d_cientificos_datos.sp_vs_scoring(periodo integer)
begin

declare v_anio smallint;
declare v_mes smallint;

declare v_banco smallint;
declare v_index smallint;
declare v_max smallint;

set v_anio =(sel trunc(:periodo/100.00));
set v_mes= (sel  :periodo mod 100 );





------------------------------------------------------ ITERO POR CADA BANCO -----------------------------------------------------------------------------

set v_index=0;
	---- seteo la cantidad de iteraciones
	set v_max= (select count(distinct cod_banco) from p_views.banco);
	
	delete from D_CIENTIFICOS_DATOS.vs_iteracion_banco_exclude;
	
	del from D_CIENTIFICOS_DATOS.vs_iteracion_banco;
	
	insert into D_CIENTIFICOS_DATOS.vs_iteracion_banco
	sel distinct cod_banco from p_views.banco;
	
	---- Seteo la primer base, tabla a procesar
	select top 1 cod_banco into v_banco  from D_CIENTIFICOS_DATOS.vs_iteracion_banco_v order by cod_banco;
	
    while v_index < v_max 
    do
		
		-----Llamado al stored procedure a iterar entre tablas
		call d_cientificos_datos.sp_vs_universo_inicial(v_anio,v_anio,v_banco);
		call d_cientificos_datos.sp_VS_aux_cta(periodo,v_banco );
		call d_cientificos_datos.sp_VS_tend_lc(periodo, v_banco);
		call d_cientificos_datos.sp_VS_tend_sc(periodo, v_banco);
		call d_cientificos_datos.sp_VS_Var_bancos(periodo, v_banco);
		call d_cientificos_datos.sp_VS_input_modelo(periodo, v_banco);
    	----- incremento del indice
		set v_index=v_index+1;
		----- Exclusión de la tabla ya procesada
		insert into D_CIENTIFICOS_DATOS.vs_iteracion_banco_exclude
		values(v_banco);
		----- Asignación de la próxima base, tabla a procesar
    	select top 1 cod_banco into v_banco  from D_CIENTIFICOS_DATOS.vs_iteracion_banco_v A order by cod_banco
		where not exists 
			(sel 1 from D_CIENTIFICOS_DATOS.vs_iteracion_banco_exclude_v as E
			where E.cod_banco=A.cod_banco);
    
	end while;






end;