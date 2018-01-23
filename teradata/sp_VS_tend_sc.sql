REPLACE PROCEDURE d_cientificos_datos.sp_VS_tend_sc(cod_mes SMALLINT, cod_banco SMALLINT)

BEGIN
--------------------------------------------------------------------------------------------------------------------------------
-----------Creacion de tablas con Variables de Tendencias (segmento_cuenta------)----------------------
--------------------------------------------------------------------------------------------------------------------------------

DELETE FROM d_cientificos_datos.VS_tend_sc WHERE cod_mes = :cod_mes AND cod_banco = :cod_banco;

INSERT INTO d_cientificos_datos.VS_tend_sc
SELECT 
A.nro_cuenta,
A.cod_mes,
A.cod_banco,
CASE WHEN (CASE WHEN A.Pago_Minimo_Impago_30-SCH1.Pago_Minimo_Impago_30 IS NOT NULL THEN 1 ELSE 0 END +
							CASE WHEN SCH1.Pago_Minimo_Impago_30-SCH2.Pago_Minimo_Impago_30 IS NOT NULL THEN 1 ELSE 0 END +
								CASE WHEN SCH2.Pago_Minimo_Impago_30-SCH3.Pago_Minimo_Impago_30 IS NOT NULL THEN 1 ELSE 0 END +
									CASE WHEN SCH3.Pago_Minimo_Impago_30-SCH4.Pago_Minimo_Impago_30 IS NOT NULL THEN 1 ELSE 0 END)=0 THEN NULL ELSE
(CASE WHEN SCH1.Pago_Minimo_Impago_30 >0 THEN (A.Pago_Minimo_Impago_30-SCH1.Pago_Minimo_Impago_30)/SCH1.Pago_Minimo_Impago_30 ELSE 0 END+
	CASE WHEN  SCH2.Pago_Minimo_Impago_30 >0 THEN(SCH1.Pago_Minimo_Impago_30-SCH2.Pago_Minimo_Impago_30)/SCH2.Pago_Minimo_Impago_30 ELSE 0 END+
		CASE WHEN  SCH3.Pago_Minimo_Impago_30 >0 THEN(SCH2.Pago_Minimo_Impago_30-SCH3.Pago_Minimo_Impago_30)/SCH3.Pago_Minimo_Impago_30 ELSE 0 END+
			CASE WHEN  SCH4.Pago_Minimo_Impago_30 >0 THEN(SCH3.Pago_Minimo_Impago_30-SCH4.Pago_Minimo_Impago_30)/SCH4.Pago_Minimo_Impago_30 ELSE 0 END)/
			(CASE WHEN  A.Pago_Minimo_Impago_30-SCH1.Pago_Minimo_Impago_30 IS NOT NULL THEN 1 ELSE 0 END +
				CASE WHEN SCH1.Pago_Minimo_Impago_30-SCH2.Pago_Minimo_Impago_30 IS NOT NULL THEN 1 ELSE 0 END +
					CASE WHEN SCH2.Pago_Minimo_Impago_30-SCH3.Pago_Minimo_Impago_30 IS NOT NULL THEN 1 ELSE 0 END +
						CASE WHEN SCH3.Pago_Minimo_Impago_30-SCH4.Pago_Minimo_Impago_30 IS NOT NULL THEN 1 ELSE 0 END) END AS Prom_Dif_PMI_30,

CASE WHEN (CASE WHEN A.Score_Financiacion-SCH1.Score_Financiacion IS NOT NULL THEN 1 ELSE 0 END +
							CASE WHEN SCH1.Score_Financiacion-SCH2.Score_Financiacion IS NOT NULL THEN 1 ELSE 0 END +
								CASE WHEN SCH2.Score_Financiacion-SCH3.Score_Financiacion IS NOT NULL THEN 1 ELSE 0 END +
									CASE WHEN SCH3.Score_Financiacion-SCH4.Score_Financiacion IS NOT NULL THEN 1 ELSE 0 END)=0 THEN NULL ELSE		
(CASE WHEN SCH1.Score_Financiacion>0 THEN (A.Score_Financiacion-SCH1.Score_Financiacion)/SCH1.Score_Financiacion ELSE 0 END +
	CASE WHEN  SCH2.Score_Financiacion>0 THEN(SCH1.Score_Financiacion-SCH2.Score_Financiacion)/SCH2.Score_Financiacion ELSE 0 END+
		CASE WHEN  SCH3.Score_Financiacion>0 THEN(SCH2.Score_Financiacion-SCH3.Score_Financiacion)/SCH3.Score_Financiacion ELSE 0 END+
			CASE WHEN  SCH4.Score_Financiacion >0 THEN(SCH3.Score_Financiacion-SCH4.Score_Financiacion)/SCH4.Score_Financiacion ELSE 0 END)/
			(CASE WHEN A.Score_Financiacion-SCH1.Score_Financiacion IS NOT NULL THEN 1 ELSE 0 END +
				CASE WHEN SCH1.Score_Financiacion-SCH2.Score_Financiacion IS NOT NULL THEN 1 ELSE 0 END +
					CASE WHEN SCH2.Score_Financiacion-SCH3.Score_Financiacion IS NOT NULL THEN 1 ELSE 0 END +
						CASE WHEN SCH3.Score_Financiacion-SCH4.Score_Financiacion IS NOT NULL THEN 1 ELSE 0 END) END  AS Prom_Dif_ScoFinan
       											
FROM d_cientificos_datos.VS_aux_cta AS A

LEFT JOIN p_access_tool.bt_segmento_cuentas_hist AS SCH1
	ON A.nro_cuenta=SCH1.nro_cuenta
	AND (SCH1.ano*100+SCH1.mes)=CASE WHEN A.mes=1 THEN A.cod_mes-89 ELSE A.cod_mes-1 END
	
LEFT JOIN p_access_tool.bt_segmento_cuentas_hist AS SCH2
	ON SCH1.nro_cuenta=SCH2.nro_cuenta
	AND (SCH2.ano*100+SCH2.mes)= CASE WHEN SCH1.mes=1 THEN (SCH1.ano*100+SCH1.mes)-89 ELSE (SCH1.ano*100+SCH1.mes)-1 END
	
LEFT JOIN p_access_tool.bt_segmento_cuentas_hist AS SCH3
	ON SCH2.nro_cuenta=SCH3.nro_cuenta
	AND (SCH3.ano*100+SCH3.mes) =CASE WHEN SCH2.mes=1 THEN (SCH2.ano*100+SCH2.mes)-89 ELSE (SCH2.ano*100+SCH2.mes)-1 END
	
LEFT JOIN p_access_tool.bt_segmento_cuentas_hist AS SCH4
	ON SCH3.nro_cuenta=SCH4.nro_cuenta
	AND (SCH4.ano*100+SCH4.mes)= CASE WHEN SCH3.mes=1 THEN (SCH3.ano*100+SCH3.mes)-89 ELSE (SCH3.ano*100+SCH3.mes)-1 END

	WHERE SCH1.cod_mes = :cod_mes AND SCH1.cod_banco = :cod_banco;

COLLECT STAT ON d_cientificos_datos.VS_tend_sc COLUMN Nro_Cuenta;
COLLECT STAT ON d_cientificos_datos.VS_tend_sc COLUMN Prom_Dif_PMI_30;
COLLECT STAT ON d_cientificos_datos.VS_tend_sc COLUMN Prom_Dif_ScoFinan;
COLLECT STAT ON d_cientificos_datos.VS_tend_sc INDEX (Nro_Cuenta);
COLLECT STAT ON d_cientificos_datos.VS_tend_sc INDEX idx_cuenta_mes;

END;


