REPLACE PROCEDURE d_cientificos_datos.sp_VS_tend_lc(cod_mes SMALLINT, cod_banco SMALLINT)
BEGIN
--------------------------------------------------------------------------------------------------------------------------------
-----------Creacion de tablas con Variables de Tendencias (Liquidacion_cuenta)----------------------
--------------------------------------------------------------------------------------------------------------------------------
DELETE FROM d_cientificos_datos.VS_tend_lc WHERE cod_mes = :cod_mes AND cod_banco = :cod_banco;

--------------------------------------------------------------------------------------------------------------------------------
-----------Creacion de tablas con Variables de Tendencias (Liquidacion_cuenta)----------------------
--------------------------------------------------------------------------------------------------------------------------------
INSERT INTO d_cientificos_datos.VS_tend_lc
SELECT 
A.nro_cuenta,
A.cod_mes,
A.cod_banco,
CASE WHEN (CASE WHEN A.Intereses_Punitorios_Total-SCH1.Intereses_Punitorios_Total IS NOT NULL THEN 1 ELSE 0 END +
							CASE WHEN SCH1.Intereses_Punitorios_Total-SCH2.Intereses_Punitorios_Total IS NOT NULL THEN 1 ELSE 0 END +
								CASE WHEN SCH2.Intereses_Punitorios_Total-SCH3.Intereses_Punitorios_Total IS NOT NULL THEN 1 ELSE 0 END +
									CASE WHEN SCH3.Intereses_Punitorios_Total-SCH4.Intereses_Punitorios_Total IS NOT NULL THEN 1 ELSE 0 END )=0 THEN NULL ELSE
(CASE WHEN SCH1.Intereses_Punitorios_Total >0 THEN  (A.Intereses_Punitorios_Total-SCH1.Intereses_Punitorios_Total)/SCH1.Intereses_Punitorios_Total ELSE 0 END+
	CASE WHEN SCH2.Intereses_Punitorios_Total>0 THEN (SCH1.Intereses_Punitorios_Total-SCH2.Intereses_Punitorios_Total)/SCH2.Intereses_Punitorios_Total ELSE 0 END+
		CASE WHEN SCH3.Intereses_Punitorios_Total>0 THEN (SCH2.Intereses_Punitorios_Total-SCH3.Intereses_Punitorios_Total)/SCH3.Intereses_Punitorios_Total ELSE 0 END+
			CASE WHEN SCH4.Intereses_Punitorios_Total>0 THEN (SCH3.Intereses_Punitorios_Total-SCH4.Intereses_Punitorios_Total)/SCH4.Intereses_Punitorios_Total ELSE 0 END)/
			   (CASE WHEN A.Intereses_Punitorios_Total-SCH1.Intereses_Punitorios_Total IS NOT NULL THEN 1 ELSE 0 END +
					CASE WHEN SCH1.Intereses_Punitorios_Total-SCH2.Intereses_Punitorios_Total IS NOT NULL THEN 1 ELSE 0 END +
						CASE WHEN SCH2.Intereses_Punitorios_Total-SCH3.Intereses_Punitorios_Total IS NOT NULL THEN 1 ELSE 0 END +
							CASE WHEN SCH3.Intereses_Punitorios_Total-SCH4.Intereses_Punitorios_Total IS NOT NULL THEN 1 ELSE 0 END ) END AS Prom_Dif_IntPun,

CASE WHEN (CASE WHEN A.Monto_IVA_Pesos-SCH1.Monto_IVA_Pesos IS NOT NULL THEN 1 ELSE 0 END +
							  CASE WHEN SCH1.Monto_IVA_Pesos-SCH2.Monto_IVA_Pesos IS NOT NULL THEN 1 ELSE 0 END +
								CASE WHEN SCH2.Monto_IVA_Pesos-SCH3.Monto_IVA_Pesos IS NOT NULL THEN 1 ELSE 0 END +
									CASE WHEN SCH3.Monto_IVA_Pesos-SCH4.Monto_IVA_Pesos IS NOT NULL THEN 1 ELSE 0 END)=0 THEN NULL ELSE		
									
(CASE WHEN SCH1.Monto_IVA_Pesos>0 THEN (A.Monto_IVA_Pesos-SCH1.Monto_IVA_Pesos)/SCH1.Monto_IVA_Pesos ELSE 0 END +
	CASE WHEN SCH2.Monto_IVA_Pesos>0 THEN (SCH1.Monto_IVA_Pesos-SCH2.Monto_IVA_Pesos)/SCH2.Monto_IVA_Pesos ELSE 0 END+
		CASE WHEN SCH3.Monto_IVA_Pesos >0 THEN (SCH2.Monto_IVA_Pesos-SCH3.Monto_IVA_Pesos)/SCH3.Monto_IVA_Pesos ELSE 0 END+ 
			CASE WHEN SCH4.Monto_IVA_Pesos>0 THEN (SCH3.Monto_IVA_Pesos-SCH4.Monto_IVA_Pesos)/SCH4.Monto_IVA_Pesos ELSE 0 END) /
			
			(CASE WHEN A.Monto_IVA_Pesos-SCH1.Monto_IVA_Pesos IS NOT NULL THEN 1 ELSE 0 END +
				CASE WHEN SCH1.Monto_IVA_Pesos-SCH2.Monto_IVA_Pesos IS NOT NULL THEN 1 ELSE 0 END +
					CASE WHEN SCH2.Monto_IVA_Pesos-SCH3.Monto_IVA_Pesos IS NOT NULL THEN 1 ELSE 0 END +
						CASE WHEN SCH3.Monto_IVA_Pesos-SCH4.Monto_IVA_Pesos IS NOT NULL THEN 1 ELSE 0 END) END AS Prom_Dif_IVA,

CASE WHEN (CASE WHEN A.Intereses_Financiacion_Pesos-SCH1.Intereses_Financiacion_Pesos IS NOT NULL THEN 1 ELSE 0 END +
							CASE WHEN SCH1.Intereses_Financiacion_Pesos-SCH2.Intereses_Financiacion_Pesos IS NOT NULL THEN 1 ELSE 0 END +
								CASE WHEN SCH2.Intereses_Financiacion_Pesos-SCH3.Intereses_Financiacion_Pesos IS NOT NULL THEN 1 ELSE 0 END +
									CASE WHEN SCH3.Intereses_Financiacion_Pesos-SCH4.Intereses_Financiacion_Pesos IS NOT NULL THEN 1 ELSE 0 END)=0 THEN NULL ELSE 			
(CASE WHEN SCH1.Intereses_Financiacion_Pesos>0 THEN(A.Intereses_Financiacion_Pesos-SCH1.Intereses_Financiacion_Pesos)/SCH1.Intereses_Financiacion_Pesos ELSE 0 END +
	CASE WHEN SCH2.Intereses_Financiacion_Pesos>0 THEN (SCH1.Intereses_Financiacion_Pesos-SCH2.Intereses_Financiacion_Pesos)/SCH2.Intereses_Financiacion_Pesos ELSE 0 END+
		CASE WHEN SCH3.Intereses_Financiacion_Pesos>0 THEN (SCH2.Intereses_Financiacion_Pesos-SCH3.Intereses_Financiacion_Pesos)/SCH3.Intereses_Financiacion_Pesos ELSE 0 END+
			CASE WHEN SCH4.Intereses_Financiacion_Pesos>0 THEN (SCH3.Intereses_Financiacion_Pesos-SCH4.Intereses_Financiacion_Pesos)/SCH4.Intereses_Financiacion_Pesos ELSE 0 END)/
			(CASE WHEN A.Intereses_Financiacion_Pesos-SCH1.Intereses_Financiacion_Pesos IS NOT NULL THEN 1 ELSE 0 END +
				CASE WHEN SCH1.Intereses_Financiacion_Pesos-SCH2.Intereses_Financiacion_Pesos IS NOT NULL THEN 1 ELSE 0 END +
					CASE WHEN SCH2.Intereses_Financiacion_Pesos-SCH3.Intereses_Financiacion_Pesos IS NOT NULL THEN 1 ELSE 0 END +
						CASE WHEN SCH3.Intereses_Financiacion_Pesos-SCH4.Intereses_Financiacion_Pesos IS NOT NULL THEN 1 ELSE 0 END) END  AS Prom_Dif_IntFin
											
FROM d_cientificos_datos.VS_aux_cta AS A

LEFT JOIN p_views.liquidacion_cuenta AS SCH1
	ON A.nro_cuenta=SCH1.nro_cuenta
	AND (SCH1.ano*100+SCH1.mes)=CASE WHEN A.mes=1 THEN A.cod_mes-89 ELSE A.cod_mes-1 END
	
LEFT JOIN p_views.liquidacion_cuenta AS SCH2
	ON SCH1.nro_cuenta=SCH2.nro_cuenta
	AND (SCH2.ano*100+SCH2.mes)= CASE WHEN SCH1.mes=1 THEN (SCH1.ano*100+SCH1.mes)-89 ELSE (SCH1.ano*100+SCH1.mes)-1 END
	
LEFT JOIN p_views.liquidacion_cuenta AS SCH3
	ON SCH2.nro_cuenta=SCH3.nro_cuenta
	AND (SCH3.ano*100+SCH3.mes) =CASE WHEN SCH2.mes=1 THEN (SCH2.ano*100+SCH2.mes)-89 ELSE (SCH2.ano*100+SCH2.mes)-1 END
	
LEFT JOIN p_views.liquidacion_cuenta AS SCH4
	ON SCH3.nro_cuenta=SCH4.nro_cuenta
	AND (SCH4.ano*100+SCH4.mes)= CASE WHEN SCH3.mes=1 THEN (SCH3.ano*100+SCH3.mes)-89 ELSE (SCH3.ano*100+SCH3.mes)-1 END
       
       WHERE A.cod_mes = :cod_mes AND A.cod_banco = :cod_banco ;



COLLECT STAT ON d_cientificos_datos.VS_tend_lc COLUMN Nro_Cuenta;
COLLECT STAT ON d_cientificos_datos.VS_tend_lc COLUMN Prom_Dif_IntFin;
COLLECT STAT ON d_cientificos_datos.VS_tend_lc COLUMN Prom_Dif_IntPun;
COLLECT STAT ON d_cientificos_datos.VS_tend_lc COLUMN Prom_Dif_IVA;
COLLECT STAT ON d_cientificos_datos.VS_tend_lc INDEX (Nro_Cuenta);
COLLECT STAT ON d_cientificos_datos.VS_tend_lc INDEX idx_cuenta_mes;


END;

