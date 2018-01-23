REPLACE PROCEDURE d_cientificos_datos.sp_VS_var_bancos_hist(cod_mes SMALLINT, cod_banco SMALLINT)

BEGIN
-- Inserto en tabla intermedia
DELETE FROM d_cientificos_datos.VS_Prop_morosos_hist;
INSERT INTO d_cientificos_datos.VS_Prop_morosos_hist
SELECT
	A.cod_banco, 
	B.ano,
	B.mes,
	(B.ano*100+B.mes) AS Cod_mes,
	CASE WHEN COUNT(B.nro_cuenta) >0 THEN SUM(CASE WHEN B.Pago_Minimo_Impago_30 > 100 THEN 1 ELSE 0 END) / COUNT(B.nro_cuenta) ELSE 0 END AS Prop_morosos_30
FROM (SEL DISTINCT A.cod_banco, A.nro_cuenta 
 		FROM p_views.cuenta_hist AS A
 		LEFT JOIN p_views.cuenta_ultima_instancia AS B
 		ON A.nro_cuenta=B.nro_cuenta
 		AND A.id_carga=B.id_carga
 		WHERE A.cod_banco = :cod_banco
 		) AS A
LEFT JOIN p_views.deuda_cuenta AS B
	ON a.nro_cuenta=B.nro_cuenta
WHERE B.ano*100+B.mes = :cod_mes AND A.cod_banco = :cod_banco
GROUP BY 1,2,3,4;

COLLECT STAT ON d_cientificos_datos.VS_Prop_morosos_hist COLUMN Ano;
COLLECT STAT ON d_cientificos_datos.VS_Prop_morosos_hist COLUMN Cod_Banco;
COLLECT STAT ON d_cientificos_datos.VS_Prop_morosos_hist COLUMN Cod_mes;
COLLECT STAT ON d_cientificos_datos.VS_Prop_morosos_hist COLUMN Mes;
COLLECT STAT ON d_cientificos_datos.VS_Prop_morosos_hist COLUMN Prop_morosos_30;
COLLECT STAT ON d_cientificos_datos.VS_Prop_morosos_hist INDEX IDX;

---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
INSERT INTO d_cientificos_datos.VS_var_bancos_hist
SELECT 
		A.nro_cuenta, 
		A.cod_mes, 
		A.cod_banco,
		B.Prop_morosos_30 AS Prom_morosos_30_AA,
		CASE WHEN ( CASE WHEN (B.Prop_morosos_30-C.Prop_morosos_30) IS NOT NULL THEN 1 ELSE 0 END +
										CASE WHEN (C.Prop_morosos_30-D.Prop_morosos_30) IS NOT NULL THEN 1 ELSE 0 END +
											CASE WHEN (D.Prop_morosos_30-E.Prop_morosos_30) IS NOT NULL THEN 1 ELSE 0 END +
												CASE WHEN (E.Prop_morosos_30-F.Prop_morosos_30) IS NOT NULL THEN 1 ELSE 0 END) <> 0 THEN 
		(CASE WHEN C.Prop_morosos_30<>0 THEN (B.Prop_morosos_30-C.Prop_morosos_30)/C.Prop_morosos_30 ELSE 0 END +
			CASE WHEN D.Prop_morosos_30<>0 THEN (C.Prop_morosos_30-D.Prop_morosos_30)/D.Prop_morosos_30 ELSE 0 END +
				CASE WHEN E.Prop_morosos_30<>0 THEN (D.Prop_morosos_30-E.Prop_morosos_30)/E.Prop_morosos_30 ELSE 0 END +
					CASE WHEN F.Prop_morosos_30<>0 THEN (E.Prop_morosos_30-F.Prop_morosos_30)/F.Prop_morosos_30 ELSE 0 END )/
		( CASE WHEN (B.Prop_morosos_30-C.Prop_morosos_30) IS NOT NULL THEN 1 ELSE 0 END +
			CASE WHEN (C.Prop_morosos_30-D.Prop_morosos_30) IS NOT NULL THEN 1 ELSE 0 END +
				CASE WHEN (D.Prop_morosos_30-E.Prop_morosos_30) IS NOT NULL THEN 1 ELSE 0 END +
					CASE WHEN (E.Prop_morosos_30-F.Prop_morosos_30) IS NOT NULL THEN 1 ELSE 0 END) ELSE 0 END AS prom_dif_morosos_30
					
FROM d_cientificos_datos.VS_aux_cta_hist AS A

LEFT JOIN d_cientificos_datos.VS_Prop_morosos_hist AS B
	ON A.cod_banco=B.cod_banco
	AND B.cod_mes=A.cod_mes-100

LEFT JOIN d_cientificos_datos.VS_Prop_morosos_hist AS C
	ON B.cod_banco=C.cod_banco
	AND C.cod_mes= CASE WHEN B.mes=1 THEN B.cod_mes-89 ELSE B.cod_mes-1 END

LEFT JOIN d_cientificos_datos.VS_Prop_morosos_hist AS D
	ON C.cod_banco=D.cod_banco
	AND D.cod_mes= CASE WHEN C.mes=1 THEN C.cod_mes-89 ELSE C.cod_mes-1 END	
	
LEFT JOIN d_cientificos_datos.VS_Prop_morosos_hist AS E
	ON D.cod_banco=E.cod_banco
	AND E.cod_mes= CASE WHEN D.mes=1 THEN D.cod_mes-89 ELSE D.cod_mes-1 END		

LEFT JOIN d_cientificos_datos.VS_Prop_morosos_hist AS F
	ON E.cod_banco=F.cod_banco
	AND F.cod_mes= CASE WHEN E.mes=1 THEN E.cod_mes-89 ELSE E.cod_mes-1 END
	WHERE A.cod_banco = :cod_banco AND A.cod_mes = :cod_mes;
	
	
COLLECT STAT ON d_cientificos_datos.VS_var_bancos_hist COLUMN Cod_Banco;
COLLECT STAT ON d_cientificos_datos.VS_var_bancos_hist COLUMN Cod_Mes;
COLLECT STAT ON d_cientificos_datos.VS_var_bancos_hist COLUMN Nro_Cuenta;
COLLECT STAT ON d_cientificos_datos.VS_var_bancos_hist COLUMN prom_dif_morosos_30;
COLLECT STAT ON d_cientificos_datos.VS_var_bancos_hist COLUMN Prom_morosos_30_AA;
COLLECT STAT ON d_cientificos_datos.VS_var_bancos_hist INDEX (Nro_Cuenta);
COLLECT STAT ON d_cientificos_datos.VS_var_bancos_hist INDEX idx_cuenta_mes;

END;

