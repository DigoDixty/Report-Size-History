

SELECT *
from (
SELECT max_partition, min_partition, qtd, A.schemaname, A.tablename, tipo_prt
-- ,tab_col.count as particoes_coletadas, tab_col.pg_size_pretty AS tam_doq_foi_coletado
-- ,case when tab_col.schemaname is null THEN '' else 'prob vacuum freeze' end st_vacuum
,case 
	WHEN max_partition NOT LIKE '%/%' AND LENGTH(max_partition) = 10 AND max_partition <> '1::numeric'
	THEN  
		CASE when max_partition::DATE <= NOW()::DATE - INTERVAL '3 MONTHS' THEN 'MAIS DE 3 MESES SEM NOVA PARTICAO' 
		when max_partition::DATE > NOW()::DATE - INTERVAL '3 MONTHS' THEN 'PARTIÇÔES RECENTES'
		else '' end END st_carga
FROM (
	select p.schemaname, p.tablename, case when COALESCE(p.partitionlistvalues,'') <> '' then 'LIST' end tipo_prt, count(1) as qtd, 
	MIN(COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(p.partitionlistvalues,'::timestamp without time zone',''),'''',''),'::character varying',''),'::date',''),'')) min_partition,
	MAX(COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(p.partitionlistvalues,'::timestamp without time zone',''),'''',''),'::character varying',''),'::date',''),'')) max_partition

	FROM pg_tables t 
	JOIN pg_partitions p
	on p.partitiontablename = t.tablename
	AND p.schemaname = t.schemaname
	AND p.partitionisdefault <> 't'
	group by 1, 2, 3
	UNION
	select p.schemaname, p.tablename, case when COALESCE(p.partitionrangestart,'') <> '' then 'RANGE' end,count(1) as qtd
	,MIN(COALESCE(p.partitionrangestart,'')) min_partition
	,MAX(COALESCE(REPLACE(REPLACE(REPLACE(REPLACE(p.partitionrangeend,'::timestamp without time zone',''),'''',''),'::character varying',''),'::date',''),'')) max_partition

	FROM pg_tables t 
	JOIN pg_partitions p
	on p.partitiontablename = t.tablename
	AND p.schemaname = t.schemaname
	AND P.partitionisdefault <> 't'
--	WHERE p.tablename = 'dw_f_app_tim_live_vda_resp'
	group by 1, 2, 3
) A
WHERE A.min_partition <> '' 
) A
WHERE st_carga <> ''
ORDER BY 1 ASC
