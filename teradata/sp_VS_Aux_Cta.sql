CREATE PROCEDURE d_cientificos_datos.sp_VS_aux_cta(cod_mes SMALLINT, cod_banco SMALLINT)
BEGIN


	DELETE FROM d_cientificos_datos.VS_aux_cta WHERE cod_mes = :cod_mes AND cod_banco = :cod_banco;

INSERT INTO d_cientificos_datos.VS_aux_cta 
SELECT
--bt_segmento_cuentas
a.Ano,
a.Mes,
a.Cod_Mes,
a.Nro_Cuenta,
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

-- 30
h.pago_minimo_impago_30 AS pago_minimo_impago_30_mas_1,
i.pago_minimo_impago_30 AS pago_minimo_impago_30_mas_2,
j.pago_minimo_impago_30 AS pago_minimo_impago_30_mas_3,
k.pago_minimo_impago_30 AS pago_minimo_impago_30_mas_4,
l.pago_minimo_impago_30 AS pago_minimo_impago_30_mas_5,
m.pago_minimo_impago_30 AS pago_minimo_impago_30_mas_6,
n.pago_minimo_impago_30 AS pago_minimo_impago_30_mas_7,
o.pago_minimo_impago_30 AS pago_minimo_impago_30_mas_8,
p.pago_minimo_impago_30 AS pago_minimo_impago_30_mas_9,
q.pago_minimo_impago_30 AS pago_minimo_impago_30_mas_10,
r.pago_minimo_impago_30 AS pago_minimo_impago_30_mas_11,
s.pago_minimo_impago_30 AS pago_minimo_impago_30_mas_12,

-- 60
h.pago_minimo_impago_60 AS pago_minimo_impago_60_mas_1,
i.pago_minimo_impago_60 AS pago_minimo_impago_60_mas_2,
j.pago_minimo_impago_60 AS pago_minimo_impago_60_mas_3,
k.pago_minimo_impago_60 AS pago_minimo_impago_60_mas_4,
l.pago_minimo_impago_60 AS pago_minimo_impago_60_mas_5,
m.pago_minimo_impago_60 AS pago_minimo_impago_60_mas_6,
n.pago_minimo_impago_60 AS pago_minimo_impago_60_mas_7,
o.pago_minimo_impago_60 AS pago_minimo_impago_60_mas_8,
p.pago_minimo_impago_60 AS pago_minimo_impago_60_mas_9,
q.pago_minimo_impago_60 AS pago_minimo_impago_60_mas_10,
r.pago_minimo_impago_60 AS pago_minimo_impago_60_mas_11,
s.pago_minimo_impago_60 AS pago_minimo_impago_60_mas_12,

--Marca de pagos minimos impagos posteriores: 30 y 60

-- 30
CASE WHEN h.pago_minimo_impago_30 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_30_mas_1,
CASE WHEN i.pago_minimo_impago_30 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_30_mas_2,
CASE WHEN j.pago_minimo_impago_30 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_30_mas_3,
CASE WHEN k.pago_minimo_impago_30 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_30_mas_4,
CASE WHEN l.pago_minimo_impago_30 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_30_mas_5,
CASE WHEN m.pago_minimo_impago_30 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_30_mas_6,
CASE WHEN n.pago_minimo_impago_30 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_30_mas_7,
CASE WHEN o.pago_minimo_impago_30 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_30_mas_8,
CASE WHEN p.pago_minimo_impago_30 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_30_mas_9,
CASE WHEN q.pago_minimo_impago_30 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_30_mas_10,
CASE WHEN r.pago_minimo_impago_30 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_30_mas_11,
CASE WHEN s.pago_minimo_impago_30 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_30_mas_12,

-- 60
CASE WHEN h.pago_minimo_impago_60 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_60_mas_1,
CASE WHEN i.pago_minimo_impago_60 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_60_mas_2,
CASE WHEN j.pago_minimo_impago_60 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_60_mas_3,
CASE WHEN k.pago_minimo_impago_60 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_60_mas_4,
CASE WHEN l.pago_minimo_impago_60 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_60_mas_5,
CASE WHEN m.pago_minimo_impago_60 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_60_mas_6,
CASE WHEN n.pago_minimo_impago_60 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_60_mas_7,
CASE WHEN o.pago_minimo_impago_60 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_60_mas_8,
CASE WHEN p.pago_minimo_impago_60 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_60_mas_9,
CASE WHEN q.pago_minimo_impago_60 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_60_mas_10,
CASE WHEN r.pago_minimo_impago_60 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_60_mas_11,
CASE WHEN s.pago_minimo_impago_60 > 100 THEN 1 ELSE 0 END AS marca_pago_minimo_impago_60_mas_12,

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

--------- Armado de clase

-- Criterio de corto plazo


CASE WHEN (marca_pago_minimo_impago_30_mas_1 + marca_pago_minimo_impago_30_mas_2 + marca_pago_minimo_impago_30_mas_3 + marca_pago_minimo_impago_30_mas_4) >= 2 THEN 1 ELSE 0 END AS clase_cp_1,


CASE WHEN (marca_pago_minimo_impago_30_mas_1 + marca_pago_minimo_impago_30_mas_2 + marca_pago_minimo_impago_30_mas_3 + marca_pago_minimo_impago_30_mas_4 + marca_pago_minimo_impago_30_mas_5 + marca_pago_minimo_impago_30_mas_6) >= 2
				THEN 1 ELSE 0 END AS clase_cp_2,
				
-- Criterio de largo plazo:


CASE WHEN 
(marca_pago_minimo_impago_30_mas_1 + marca_pago_minimo_impago_30_mas_2 + marca_pago_minimo_impago_30_mas_3 + marca_pago_minimo_impago_30_mas_4 + marca_pago_minimo_impago_30_mas_5 + marca_pago_minimo_impago_30_mas_6 +
marca_pago_minimo_impago_30_mas_7 + marca_pago_minimo_impago_30_mas_8 + marca_pago_minimo_impago_30_mas_9 + marca_pago_minimo_impago_30_mas_10 ) >= 3 
OR
( marca_pago_minimo_impago_60_mas_2 + marca_pago_minimo_impago_60_mas_3 + marca_pago_minimo_impago_60_mas_4 + marca_pago_minimo_impago_60_mas_5 + marca_pago_minimo_impago_60_mas_6 +
marca_pago_minimo_impago_60_mas_7 + marca_pago_minimo_impago_60_mas_8 + marca_pago_minimo_impago_60_mas_9 + marca_pago_minimo_impago_60_mas_10 /*+ marca_pago_minimo_impago_60_mas_11 + marca_pago_minimo_impago_60_mas_12*/) >= 1
THEN 1 ELSE 0 END AS clase_lp_1,


CASE WHEN 
(marca_pago_minimo_impago_30_mas_1 + marca_pago_minimo_impago_30_mas_2 + marca_pago_minimo_impago_30_mas_3 + marca_pago_minimo_impago_30_mas_4 + marca_pago_minimo_impago_30_mas_5 + marca_pago_minimo_impago_30_mas_6 +
marca_pago_minimo_impago_30_mas_7 + marca_pago_minimo_impago_30_mas_8 + marca_pago_minimo_impago_30_mas_9 + marca_pago_minimo_impago_30_mas_10 + marca_pago_minimo_impago_30_mas_11 + marca_pago_minimo_impago_30_mas_12) >= 3 
OR
 ( marca_pago_minimo_impago_60_mas_2 + marca_pago_minimo_impago_60_mas_3 + marca_pago_minimo_impago_60_mas_4 + marca_pago_minimo_impago_60_mas_5 + marca_pago_minimo_impago_60_mas_6 +
marca_pago_minimo_impago_60_mas_7 + marca_pago_minimo_impago_60_mas_8 + marca_pago_minimo_impago_60_mas_9 + marca_pago_minimo_impago_60_mas_10 + marca_pago_minimo_impago_60_mas_11 + marca_pago_minimo_impago_60_mas_12) >= 1
THEN 1 ELSE 0 END AS clase_lp_2,

-- Criterio de Veraz: extraído de 82 - VISA Scoring Services - Actualización, pág. 4





-- Al momento de calcular el score no presente atraso, y en los siguientes 12 meses, en algún momento, deja de pagar dos pagos mínimos consecutivos, o;
CASE WHEN 
((marca_pago_minimo_impago_30 + marca_pago_minimo_impago_30_menos_1 + marca_pago_minimo_impago_30_menos_2 + marca_pago_minimo_impago_30_menos_3 + marca_pago_minimo_impago_30_menos_4 + marca_pago_minimo_impago_30_menos_5) = 0
AND 
 ( marca_pago_minimo_impago_60_mas_2 + marca_pago_minimo_impago_60_mas_3 + marca_pago_minimo_impago_60_mas_4 + marca_pago_minimo_impago_60_mas_5 + marca_pago_minimo_impago_60_mas_6 +
marca_pago_minimo_impago_60_mas_7 + marca_pago_minimo_impago_60_mas_8 + marca_pago_minimo_impago_60_mas_9 + marca_pago_minimo_impago_60_mas_10 + marca_pago_minimo_impago_60_mas_11 + marca_pago_minimo_impago_60_mas_12) >= 1)

OR
-- Al momento de calcular el score presenta al menos un pago mínimo impago, y en los siguientes 12 meses tiene, en algún momento, tres o más pagos mínimos impagos.
((marca_pago_minimo_impago_30 + marca_pago_minimo_impago_30_menos_1 + marca_pago_minimo_impago_30_menos_2 + marca_pago_minimo_impago_30_menos_3 + marca_pago_minimo_impago_30_menos_4 + marca_pago_minimo_impago_30_menos_5) >= 1
AND 
(marca_pago_minimo_impago_30_mas_1 + marca_pago_minimo_impago_30_mas_2 + marca_pago_minimo_impago_30_mas_3 + marca_pago_minimo_impago_30_mas_4 + marca_pago_minimo_impago_30_mas_5 + marca_pago_minimo_impago_30_mas_6 +
marca_pago_minimo_impago_30_mas_7 + marca_pago_minimo_impago_30_mas_8 + marca_pago_minimo_impago_30_mas_9 + marca_pago_minimo_impago_30_mas_10 + marca_pago_minimo_impago_30_mas_11 + marca_pago_minimo_impago_30_mas_12)>= 3 ) 
THEN 1 ELSE 0 END AS clase_veraz

FROM
(SELECT * FROM p_access_tool.bt_segmento_cuentas
WHERE cod_mes = :cod_mes AND cod_banco = :cod_banco) AS A
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

-- Joins para ver deuda posterior
LEFT JOIN
p_views.deuda_cuenta h
ON 
a.nro_cuenta = h.nro_cuenta
AND
a.ano *100 + a.mes = 
CASE WHEN h.mes - 1 = 0 THEN (h.ano - 1) * 100 + 12 ELSE h.ano *100 + h.mes - 1 END 
AND
a.ciclo_liquidacion = h.ciclo_liquidacion

LEFT JOIN
p_views.deuda_cuenta i
ON 
a.nro_cuenta = i.nro_cuenta
AND
a.ano *100 + a.mes = 
CASE WHEN i.mes - 2 = 0 THEN (i.ano - 1) * 100 + 12 
	 WHEN i.mes - 2 = -1 THEN (i.ano - 1) * 100 + 11
		ELSE i.ano *100 + i.mes - 2 END 
AND
a.ciclo_liquidacion = i.ciclo_liquidacion
LEFT JOIN
p_views.deuda_cuenta j
ON 
a.nro_cuenta = j.nro_cuenta
AND
a.ano *100 + a.mes = 
CASE WHEN j.mes - 3 = 0 THEN (j.ano - 1) * 100 + 12 
 WHEN j.mes - 3 = -1 THEN (j.ano - 1) * 100 + 11
 WHEN j.mes - 3 = -2 THEN (j.ano - 1) * 100 + 10
ELSE j.ano *100 + j.mes - 3 END 
AND
a.ciclo_liquidacion = j.ciclo_liquidacion

LEFT JOIN
p_views.deuda_cuenta k
ON 
a.nro_cuenta = k.nro_cuenta
AND
a.ano *100 + a.mes = 
CASE WHEN k.mes - 4 = 0 THEN (k.ano - 1) * 100 + 12 
 WHEN k.mes - 4 = -1 THEN (k.ano - 1) * 100 + 11
 WHEN k.mes - 4 = -2 THEN (k.ano - 1) * 100 + 10
 WHEN k.mes - 4 = -3 THEN (k.ano - 1) * 100 + 9
ELSE k.ano *100 + k.mes - 4 END 
AND
a.ciclo_liquidacion = k.ciclo_liquidacion

LEFT JOIN
p_views.deuda_cuenta l
ON 
a.nro_cuenta = l.nro_cuenta
AND
a.ano *100 + a.mes = 
CASE WHEN l.mes - 5 = 0 THEN (l.ano - 1) * 100 + 12 
 WHEN l.mes - 5 = -1 THEN (l.ano - 1) * 100 + 11
 WHEN l.mes - 5 = -2 THEN (l.ano - 1) * 100 + 10
 WHEN l.mes - 5 = -3 THEN (l.ano - 1) * 100 + 9
 WHEN l.mes - 5 = -4 THEN (l.ano - 1) * 100 + 8
ELSE l.ano *100 + l.mes - 5 END 
AND
a.ciclo_liquidacion = l.ciclo_liquidacion

LEFT JOIN
p_views.deuda_cuenta m
ON 
a.nro_cuenta = m.nro_cuenta
AND
a.ano *100 + a.mes = 
CASE WHEN m.mes - 6 = 0 THEN (m.ano - 1) * 100 + 12 
 WHEN m.mes - 6 = -1 THEN (m.ano - 1) * 100 + 11
 WHEN m.mes - 6 = -2 THEN (m.ano - 1) * 100 + 10
 WHEN m.mes - 6 = -3 THEN (m.ano - 1) * 100 + 9
 WHEN m.mes - 6 = -4 THEN (m.ano - 1) * 100 + 8
 WHEN m.mes - 6 = -5 THEN (m.ano - 1) * 100 + 7
ELSE m.ano *100 + m.mes - 6 END 
AND
a.ciclo_liquidacion = m.ciclo_liquidacion

LEFT JOIN
p_views.deuda_cuenta n
ON 
a.nro_cuenta = n.nro_cuenta
AND
a.ano *100 + a.mes = 
CASE WHEN n.mes - 7 = 0 THEN (n.ano - 1) * 100 + 12 
 WHEN n.mes - 7 = -1 THEN (n.ano - 1) * 100 + 11
 WHEN n.mes - 7 = -2 THEN (n.ano - 1) * 100 + 10
 WHEN n.mes - 7 = -3 THEN (n.ano - 1) * 100 + 9
 WHEN n.mes - 7 = -4 THEN (n.ano - 1) * 100 + 8
 WHEN n.mes - 7 = -5 THEN (n.ano - 1) * 100 + 7
 WHEN n.mes - 7 = -6 THEN (n.ano - 1) * 100 + 6
ELSE n.ano *100 + n.mes - 7 END 
AND
a.ciclo_liquidacion = n.ciclo_liquidacion

LEFT JOIN
p_views.deuda_cuenta o
ON 
a.nro_cuenta = o.nro_cuenta
AND
a.ano *100 + a.mes = 
CASE WHEN o.mes - 8 = 0 THEN (o.ano - 1) * 100 + 12 
 WHEN o.mes - 8 = -1 THEN (o.ano - 1) * 100 + 11
 WHEN o.mes - 8 = -2 THEN (o.ano - 1) * 100 + 10
 WHEN o.mes - 8 = -3 THEN (o.ano - 1) * 100 + 9
 WHEN o.mes - 8 = -4 THEN (o.ano - 1) * 100 + 8
 WHEN o.mes - 8 = -5 THEN (o.ano - 1) * 100 + 7
 WHEN o.mes - 8 = -6 THEN (o.ano - 1) * 100 + 6
 WHEN o.mes - 8 = -7 THEN (o.ano - 1) * 100 + 5
ELSE o.ano *100 + o.mes - 8 END 
AND
a.ciclo_liquidacion = o.ciclo_liquidacion

LEFT JOIN
p_views.deuda_cuenta p
ON 
a.nro_cuenta = p.nro_cuenta
AND
a.ano *100 + a.mes = 
CASE WHEN p.mes - 9 = 0 THEN (p.ano - 1) * 100 + 12 
 WHEN p.mes - 9 = -1 THEN (p.ano - 1) * 100 + 11
 WHEN p.mes - 9 = -2 THEN (p.ano - 1) * 100 + 10
 WHEN p.mes - 9 = -3 THEN (p.ano - 1) * 100 + 9
 WHEN p.mes - 9 = -4 THEN (p.ano - 1) * 100 + 8
 WHEN p.mes - 9 = -5 THEN (p.ano - 1) * 100 + 7
 WHEN p.mes - 9 = -6 THEN (p.ano - 1) * 100 + 6
 WHEN p.mes - 9 = -7 THEN (p.ano - 1) * 100 + 5
 WHEN p.mes - 9 = -8 THEN (p.ano - 1) * 100 + 4
ELSE p.ano *100 + p.mes - 9 END 
AND
a.ciclo_liquidacion = p.ciclo_liquidacion

LEFT JOIN
p_views.deuda_cuenta q
ON 
a.nro_cuenta = q.nro_cuenta
AND
a.ano *100 + a.mes = 
CASE WHEN q.mes - 10 = 0 THEN (q.ano - 1) * 100 + 12 
 WHEN q.mes - 10 = -1 THEN (q.ano - 1) * 100 + 11
 WHEN q.mes - 10 = -2 THEN (q.ano - 1) * 100 + 10
 WHEN q.mes - 10 = -3 THEN (q.ano - 1) * 100 + 9
 WHEN q.mes - 10 = -4 THEN (q.ano - 1) * 100 + 8
 WHEN q.mes - 10 = -5 THEN (q.ano - 1) * 100 + 7
 WHEN q.mes - 10 = -6 THEN (q.ano - 1) * 100 + 6
 WHEN q.mes - 10 = -7 THEN (q.ano - 1) * 100 + 5
 WHEN q.mes - 10 = -8 THEN (q.ano - 1) * 100 + 4
  WHEN q.mes - 10 = -9 THEN (q.ano - 1) * 100 + 3
ELSE q.ano *100 + q.mes - 10 END 
AND
a.ciclo_liquidacion = q.ciclo_liquidacion

LEFT JOIN
p_views.deuda_cuenta r
ON 
a.nro_cuenta = r.nro_cuenta
AND
a.ano *100 + a.mes = 
CASE 
WHEN r.mes - 11 = 0 THEN (r.ano - 1) * 100 + 12 
WHEN r.mes - 11 = -1 THEN (r.ano - 1) * 100 + 11
 WHEN r.mes - 11 = -2 THEN (r.ano - 1) * 100 + 10
 WHEN r.mes - 11 = -3 THEN (r.ano - 1) * 100 + 9
 WHEN r.mes - 11 = -4 THEN (r.ano - 1) * 100 + 8
 WHEN r.mes - 11 = -5 THEN (r.ano - 1) * 100 + 7
 WHEN r.mes - 11 = -6 THEN (r.ano - 1) * 100 + 6
 WHEN r.mes - 11 = -7 THEN (r.ano - 1) * 100 + 5
 WHEN r.mes - 11 = -8 THEN (r.ano - 1) * 100 + 4
  WHEN r.mes - 11 = -9 THEN (r.ano - 1) * 100 + 3
  WHEN r.mes - 11 = -10 THEN (r.ano - 1) * 100 + 2
ELSE r.ano *100 + r.mes - 11 END 
AND
a.ciclo_liquidacion = r.ciclo_liquidacion

LEFT JOIN
p_views.deuda_cuenta s
ON 
a.nro_cuenta = s.nro_cuenta
AND
a.ano *100 + a.mes = (s.ano - 1) *100 + s.mes

LEFT JOIN d_cientificos_datos.indice_inflacion AS INFL
	ON A.cod_mes=INFL.anio*100+INFL.mes;
	
COLLECT STAT ON d_cientificos_datos.VS_aux_cta INDEX (Nro_Cuenta);

END;
