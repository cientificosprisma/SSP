replace procedure d_cientificos_datos.sp_vs_universo_inicial(anio smallint, mes smallint)
begin


del from d_cientificos_datos.vs_universo_inicial_0
where anio=:anio and mes=:mes ;

insert into d_cientificos_datos.vs_universo_inicial_0 
sel a.nro_cuenta ,
:anio as anio,
:mes as mes,
:anio *100 + :mes as periodo,
cast( current_date as date) as fecha_proceso,
--- validacion_tipo_cuenta:
case when Cod_Tipo_Cuenta not IN ('C', 'L', 'P', 'S') then 1 else 0 end as validacion_tipo_cuenta,
--- validacion_estado_cuenta: Que el estado de la cuenta sea 10 u 11
case when cod_estado_cuenta not in ('10','11') then 1 else 0 end as validacion_estado_cuenta,
--- validacion_banco_adherido_score: que la cuenta pertenezca a uno de los bancos del scoring (opcional)
case when b.cod_banco is null then 1 else 0 end as validacion_banco_adherido_score,
--- validacion_antiguedad_meses: que la cuenta tenga al menos un mes de antiguedad 
case when  (:anio *12 + :mes) - ( extract(year from fecha_apertura_real)*12+ extract(month from fecha_apertura_real)) <1 then 1 else 0 end as validacion_antiguedad_meses,
--- validacion_cuenta_activa: que en los últimos 6 meses tenga consumos, saldo o pagos
case when ( sum(saldo_pesos+saldo_dolares)>0 or sum(pago_total_liquid_anterior)>0 or sum(compra_pesos+compra_dolares)>0 ) then 0 else 1 end as validacion_cuenta_activa,
--- validacion_tarjeta_habilitada: que tenga al menos una tarjeta habilitada
case when (count(nro_tarjeta))>0 then 0 else 1 end as validacion_tarjeta_habilitada,
--- cuenta_a_scorear: Flag final que determina en base a las condiciones anteriores si la cuenta puede pasar por el proceso de scoring
case when (validacion_tipo_cuenta+validacion_estado_cuenta+validacion_antiguedad_meses+validacion_banco_adherido_score+validacion_cuenta_activa+validacion_tarjeta_habilitada)>0 then 0 else 1 end as cuenta_a_scorear
from p_views.cuenta a
left join  d_cientificos_datos.vs_banco_scoring b
on a.cod_banco=b.cod_banco
left join p_views.liquidacion_cuenta c
on c.nro_cuenta=a.nro_cuenta
and (c.ano *100 + c.mes) between  case when :mes<=5 then  (:anio *100 + :mes)-93 else  (:anio *100 + :mes)-5 end      and (:anio *100 + :mes)
left join p_views.tarjeta t
on t.nro_cuenta=a.nro_cuenta
and cod_inhabilitacion_tarjeta=''
and cod_estado_tarjeta='20'
group by 1,2,3,4,5,6,7,8,9
;

del from d_cientificos_datos.vs_universo_inicial_a_procesar 
where anio=:anio and mes=:mes ;

insert into d_cientificos_datos.vs_universo_inicial_a_procesar 
sel * from d_cientificos_datos.vs_universo_inicial_0 
where anio=:anio and mes=:mes 
and cuenta_a_scorear=1;

del from d_cientificos_datos.vs_universo_inicial_excluidos
where anio=:anio and mes=:mes ;

insert into d_cientificos_datos.vs_universo_inicial_excluidos
sel * from d_cientificos_datos.vs_universo_inicial_0 
where anio=:anio and mes=:mes 
and cuenta_a_scorear=0;

------------------------------------------------------------------------------ LUEGO SE CALCULARAN LOS CODIGOS DE ERROR PARA LAS CUENTAS EXCLUIDAS ----------------------------------------------------------------------------



end


