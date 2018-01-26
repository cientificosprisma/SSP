
REPLACE PROCEDURE d_cientificos_datos.sp_VS_aux_cta(cod_mes INTEGER, cod_banco SMALLINT)
BEGIN


DELETE FROM d_cientificos_datos.VS_aux_cta WHERE cod_mes = :cod_mes AND cod_banco = :cod_banco;

INSERT INTO d_cientificos_datos.VS_aux_cta 
SELECT
--bt_segmento_cuentas
ui.Anio as ano,
ui.Mes,
ui.periodo as Cod_Mes,
ui.Nro_Cuenta,
Denominacion_Cuenta_Host,
Nro_Identificacion_Titular,
Cod_Tipo_Identificacion_Host,
Nro_Identificacion_Host,
a.Cod_Banco,
a.Cod_Sucursal,
Cod_Tipo_Cuenta,
Cod_Estado_Cuenta,
a.Ciclo_Liquidacion,
Fecha_Apertura,
Antiguedad_Meses,
Cod_Limite_Compra,
Limite_Compra,
Limite_Compra_a_$,
Codigo_Postal4,
Nombre_Localidad,
Cod_Region_Geografica_Host,
Cod_Grupo_Afinidad,
Agrupamiento,
Cod_Producto,
Cod_SubProducto_1,
Cod_SubProducto_2,
a.Cod_Modelo_Liquidacion,
Cod_Tipo_Tarjeta,
BIN_Producto,
Cod_Empresa,
Segmento_Credito,
Cod_Sexo_Host,
Fecha_Nacimiento_Host,
Marca_Preembozado,
Cant_Titu_Habil_Est20_22,
Cant_Adic_Habil_Est20_22,
Cant_Titu_Habil_Est20_22_EMV,
Cant_Adic_Habil_Est20_22_EMV,
Cant_Compra_50_Cuotas,
Monto_Disponible_Compra_1_Pago,
Monto_Disponible_Compra_Cuotas,
Factor_Limite_Cuotas,
Marca_Limite_Unificado,
Promedio_Consu_Trim,
Promedio_Consu_Sem,
Promedio_Consu_Anio,
Rango_Limite_Compra,
Rango_Antiguedad,
a.Saldo_Pesos,
a.Saldo_Dolares,
Saldo_Total_a_$,
Cant_Compra_Pesos,
Importe_Compra_Pesos,
Cant_Compra_Dolares,
Importe_Compra_Dolares,
Cant_Compra_Total,
Importe_Compra_Total_a_$,
Cant_Adelanto_Pesos,
Importe_Adelanto_Pesos,
Cant_Adelanto_Dolares,
Importe_Adelanto_Dolares,
Cant_Adelanto_Total,
Importe_Adelanto_Total_a_$,
Cant_DA_Pesos,
Importe_DA_Pesos,
Cant_DA_Dolares,
Importe_DA_Dolares,
Cant_DA_Total,
Importe_DA_Total_a_$,
Cantidad_Consumo_Promedio_Trim,
Importe_Consumo_Promedio_Trim,
Cantidad_Consumo_Promedio_Sem,
Importe_Consumo_Promedio_Sem,
Cantidad_Consumo_Promedio_Anio,
Importe_Consumo_Promedio_Anio,
Cantidad_DA_Promedio_Trim,
Importe_DA_Promedio_Trim,
Cantidad_DA_Promedio_Sem,
Importe_DA_Promedio_Sem,
Cantidad_DA_Promedio_Anio,
Importe_DA_Promedio_Anio,
a.Pago_Minimo_Total,
a.Pago_Total_Liquid_Anterior,
a.Pago_Total_Dolares_Liq_Ant,
a.Pago_Minimo_Impago_30,
a.Pago_Minimo_Impago_60,
a.Pago_Minimo_Impago_90,
a.Pago_Minimo_Impago_120,
a.Pago_Minimo_Impago_150,
a.Pago_Minimo_Impago_180,
a.Pago_Minimo_Impago_210,
a.Pago_Minimo_Impago_240,
a.Pago_Minimo_Impago_270,
a.Pago_Minimo_Impago_300,
a.Pago_Minimo_Impago_330,
a.Pago_Minimo_Impago_360,
a.Pago_Minimo_Impago_Mas_360,
Score_Riesgo,
Score_Consumo,
Score_Financiacion,
Rango_Score_Riesgo,
Rango_Utiliza_LC_Trim,
Rango_Utiliza_LC_Sem,
Rango_Utiliza_LC_Anio,
Rango_Rel_Pagos_Saldos_Trim,
Rango_Rel_Pagos_Saldos_Sem,
Rango_Rel_Pagos_Saldos_Anio,
Utiliza_LC_Trim,
Utiliza_LC_Sem,
Utiliza_LC_Anio,
Rel_Pagos_Saldos_Trim,
Rel_Pagos_Saldos_Sem,
Rel_Pagos_Saldos_Anio,
--liquidacion_cuenta
Nro_Liquidacion,
Fecha_Vencimiento,
Compra_Pesos,
Pago_Minimo_Dolares,
Intereses_Financiacion_Pesos,
Intereses_Punitorios_Total,
Compra_Dolares,
Intereses_Punitorios_Dolares,
Adelantos_Pesos,
Adelantos_Dolares,
Monto_IVA_Pesos,
Monto_IVA_Dolares,
Monto_Exceso_Limite_Compra,
Monto_Cuotas_Pendiente_Pesos,
Monto_Cuotas_Pendiente_Dolares,
Monto_Creditos_Pesos,
Monto_Creditos_Dolares,
Monto_IVA_Reducido_Pesos,
Monto_IVA_Reducido_Dolares,
Marca_Incluye_Resumen_Limpio,
Compra_Pesos_Estad,
Compra_Dolares_Estad,
Adelantos_Pesos_Estad,
Adelantos_Dolares_Estad,
Saldo_Financiacion_Pesos,
Saldo_Financiacion_Dolares,
Intereses_Financiacion_Dolares,
Monto_Consumo_Pend_Seg_Pesos,
Monto_Consumo_Pend_Seg_Dolar,
Monto_Adelanto_Pend_Seg_Pesos,
Monto_Adelanto_Pend_Seg_Dolar,
Monto_Banco_Seguro,
Interes_Ant_Pesos,
Interes_Ant_Dolares,
Interes_Punitorio_Ant_Pesos,
Interes_Punitorio_Ant_Dolares,
Adelanto_Pesos_Periodo,
Adelanto_Dolares_Periodo,
Consumo_Pesos_Periodo,
Consumo_Dolares_Periodo,
Fecha_Liquidacion_Estad,

------------------------------------------------------------------- Variables nuevas -------------------------------------------------------------------------
-- Efecto inflacion ----------------------

-- 1: ajustar variables de monto y de limite
Limite_Compra_a_$/inflacion_acumulada AS Limite_Compra_a_$_infl,
Monto_Disponible_Compra_1_Pago/inflacion_acumulada AS Monto_Disponible_Compra_1_Pago_infl,
Monto_Disponible_Compra_Cuotas/inflacion_acumulada AS Monto_Disponible_Compra_Cuotas_infl,
Promedio_Consu_Trim/inflacion_acumulada AS Promedio_Consu_Trim_infl,
Promedio_Consu_Sem/inflacion_acumulada AS Promedio_Consu_Sem_infl,
Promedio_Consu_Anio/inflacion_acumulada AS Promedio_Consu_Anio_infl,
a.Saldo_Pesos/inflacion_acumulada AS Saldo_Pesos_infl,
Saldo_Total_a_$/inflacion_acumulada AS Saldo_Total_a_$_infl,
Importe_Compra_Pesos/inflacion_acumulada AS Importe_Compra_Pesos_infl,
Importe_Compra_Total_a_$/inflacion_acumulada AS Importe_Compra_Total_a_$_infl,
Importe_Consumo_Promedio_Trim/inflacion_acumulada AS Importe_Consumo_Promedio_Trim_infl,
Importe_Consumo_Promedio_Sem/inflacion_acumulada AS Importe_Consumo_Promedio_Sem_infl,
Importe_Consumo_Promedio_Anio/inflacion_acumulada AS Importe_Consumo_Promedio_Anio_infl,
a.Pago_Minimo_Total/inflacion_acumulada AS Pago_Minimo_Total_infl,

-- 2: ratio entre limite ajustado por inflacion y monto consumido sin ajustar por inflacion

CASE WHEN Limite_Compra_a_$_infl = 0 THEN 0 ELSE  Importe_Compra_Total_a_$/Limite_Compra_a_$_infl END AS Ratio_Importe_sobre_LimiteInf,

-- 1: importe y cantidad de consumo promedio por tarjeta
CASE WHEN (Cant_Titu_Habil_Est20_22+Cant_Adic_Habil_Est20_22+	Cant_Titu_Habil_Est20_22_EMV+	Cant_Adic_Habil_Est20_22_EMV)=0 THEN 0 ELSE Importe_Compra_Total_a_$_infl/(Cant_Titu_Habil_Est20_22+Cant_Adic_Habil_Est20_22+	Cant_Titu_Habil_Est20_22_EMV+	Cant_Adic_Habil_Est20_22_EMV) END AS Prom_Importe_total_x_tarjeta ,
CASE WHEN (Cant_Titu_Habil_Est20_22+Cant_Adic_Habil_Est20_22+	Cant_Titu_Habil_Est20_22_EMV+	Cant_Adic_Habil_Est20_22_EMV)=0 THEN 0 ELSE Cant_Compra_Total/(Cant_Titu_Habil_Est20_22+Cant_Adic_Habil_Est20_22+	Cant_Titu_Habil_Est20_22_EMV+	Cant_Adic_Habil_Est20_22_EMV) END  AS Prom_cant_tx_x_tarjeta ,


-- Pagos minimos impagos previos: 30 y 60

-- 30
c.pago_minimo_impago_30 AS pago_minimo_impago_30_menos_1,
d.pago_minimo_impago_30 AS pago_minimo_impago_30_menos_2,
e.pago_minimo_impago_30 AS pago_minimo_impago_30_menos_3,
f.pago_minimo_impago_30 AS pago_minimo_impago_30_menos_4,
g.pago_minimo_impago_30 AS pago_minimo_impago_30_menos_5,

-- 60
c.pago_minimo_impago_60 AS pago_minimo_impago_60_menos_1,
d.pago_minimo_impago_60 AS pago_minimo_impago_60_menos_2,
e.pago_minimo_impago_60 AS pago_minimo_impago_60_menos_3,
f.pago_minimo_impago_60 AS pago_minimo_impago_60_menos_4,
g.pago_minimo_impago_60 AS pago_minimo_impago_60_menos_5,

-- Marca de pagos mínimo impagos previos (30) y actual
CASE WHEN a.pago_minimo_impago_30 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_30,
CASE WHEN c.pago_minimo_impago_30 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_30_menos_1,
CASE WHEN d.pago_minimo_impago_30 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_30_menos_2,
CASE WHEN e.pago_minimo_impago_30 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_30_menos_3,
CASE WHEN f.pago_minimo_impago_30 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_30_menos_4,
CASE WHEN g.pago_minimo_impago_30 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_30_menos_5,

--Pagos minimos impagos posteriores: 30 y 60 


--------- Gastos e intereses agregados
-- Gastos
-- Se podrían agregar extracciones, no se hizo para no involucrar otra tabla

Importe_Compra_Pesos + Importe_DA_Pesos + Importe_Adelanto_Pesos AS consumos_agregados_pesos,
Importe_Compra_Dolares + Importe_DA_Dolares + Importe_Adelanto_Dolares AS consumos_agregados_dolares,
Importe_Compra_Total_a_$ + Importe_DA_Total_a_$ + Importe_Adelanto_Total_a_$ AS consumos_agregados_a_pesos,

-- Intereses
---- Ver si intereses_punitorios_total incluye dolares o no

Intereses_Financiacion_Pesos + Intereses_Punitorios_Total AS intereses_pesos,
Intereses_Financiacion_Dolares + Intereses_Punitorios_Dolares AS intereses_dolares,
--clasificacion de cuentas en tipo de clase
case when (marca_pago_minimo_impago_30 + marca_pago_minimo_impago_30_menos_1 + marca_pago_minimo_impago_30_menos_2 + marca_pago_minimo_impago_30_menos_3 + marca_pago_minimo_impago_30_menos_4 + marca_pago_minimo_impago_30_menos_5) = 0 then 1 else 2 end AS clase_veraz

FROM
d_cientificos_datos.vs_universo_inicial_a_procesar_v UI
LEFT JOIN
p_access_tool.bt_segmento_cuentas A
on A.cod_mes = UI.periodo AND A.cod_banco = UI.cod_banco
and A.nro_cuenta=UI.nro_cuenta
LEFT JOIN
p_views.liquidacion_cuenta b
ON 
a.nro_cuenta = b.nro_cuenta
AND
a.cod_mes = b.ano *100 + b.mes
AND
a.ciclo_liquidacion = b.ciclo_liquidacion

-- Joins para ver deuda anterior 

LEFT JOIN
p_views.deuda_cuenta c
ON 
a.nro_cuenta = c.nro_cuenta
AND
a.ano *100 + a.mes = CASE WHEN c.mes + 1 = 13 THEN (c.ano + 1) *100 + 1 ELSE c.ano *100 + c.mes + 1 END 
AND
a.ciclo_liquidacion = c.ciclo_liquidacion
LEFT JOIN
p_views.deuda_cuenta d
ON 
a.nro_cuenta = d.nro_cuenta
AND
a.ano *100 + a.mes = CASE WHEN d.mes + 2 = 13 THEN (d.ano + 1) *100 + 1
						  WHEN d.mes + 2 = 14 THEN (d.ano + 1) *100 + 2
						  ELSE d.ano *100 + d.mes + 2 END 
AND
a.ciclo_liquidacion = d.ciclo_liquidacion
LEFT JOIN
p_views.deuda_cuenta e
ON 
a.nro_cuenta = e.nro_cuenta
AND
a.ano *100 + a.mes = CASE WHEN e.mes + 3 = 13 THEN (e.ano + 1) *100 + 1
						  WHEN e.mes + 3 = 14 THEN (e.ano + 1) *100 + 2
						  WHEN e.mes + 3 = 15 THEN (e.ano + 1) *100 + 3
						  ELSE e.ano *100 + e.mes + 3 END 
AND
a.ciclo_liquidacion = e.ciclo_liquidacion
LEFT JOIN
p_views.deuda_cuenta f
ON 
a.nro_cuenta = f.nro_cuenta
AND
a.ano *100 + a.mes = CASE WHEN f.mes + 4 = 13 THEN (f.ano + 1) *100 + 1
						  WHEN f.mes + 4 = 14 THEN (f.ano + 1) *100 + 2
						  WHEN f.mes + 4 = 15 THEN (f.ano + 1) *100 + 3
						  WHEN f.mes + 4 = 16 THEN (f.ano + 1) *100 + 4
						  ELSE f.ano *100 + f.mes + 4 END 
AND
a.ciclo_liquidacion = f.ciclo_liquidacion
LEFT JOIN
p_views.deuda_cuenta g
ON 
a.nro_cuenta = g.nro_cuenta
AND
a.ano *100 + a.mes = CASE WHEN g.mes + 5 = 13 THEN (g.ano + 1) *100 + 1
						  WHEN g.mes + 5 = 14 THEN (g.ano + 1) *100 + 2
						  WHEN g.mes + 5 = 15 THEN (g.ano + 1) *100 + 3
						  WHEN g.mes + 5 = 16 THEN (g.ano + 1) *100 + 4
						  WHEN g.mes + 5 = 17 THEN (g.ano + 1) *100 + 5
						  ELSE g.ano *100 + g.mes + 5 END 
AND
a.ciclo_liquidacion = g.ciclo_liquidacion


LEFT JOIN d_cientificos_datos.indice_inflacion AS INFL
	ON A.cod_mes=INFL.anio*100+INFL.mes
WHERE
UI.periodo=:cod_mes
AND UI.cod_banco=:cod_banco
	;
	
COLLECT STAT ON d_cientificos_datos.VS_aux_cta INDEX (Nro_Cuenta);
COLLECT STAT ON d_cientificos_datos.VS_aux_cta INDEX idx_cuenta_mes;
COLLECT STAT ON d_cientificos_datos.VS_aux_cta INDEX idx_mes;

END;