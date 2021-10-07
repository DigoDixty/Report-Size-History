create temporary table t as
(

SELECT A.schemaname, A.tablename
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
WHERE st_carga = 'MAIS DE 3 MESES SEM NOVA PARTICAO'
ORDER BY 1 ASC
)

truncate table admin.size_tables_hist;
INSERT INTO admin.size_tables_hist (oid, schemaname, tablename_orig, tablename, partitionlistvalues, partitionrange, dt_obj_created, reloptions, active)

SELECT   
     C.oid
    ,N.nspname AS schemaname
    ,C.relname AS tablename_orig
    ,sr_prt.tablename AS tablename
    ,partitionlistvalues
    ,partitionrangeend
    ,st.statime AS created
    ,reloptions
    ,'t'
    
FROM pg_class C 

LEFT JOIN pg_namespace N 
ON N.oid = C.relnamespace

INNER JOIN (    SELECT * 
                FROM pg_partitions 
                WHERE 1 = 1
                AND partitionisdefault <> 't'
                AND schemaname IN ('adhoc', 'aux', 'fact', 'reports') -- CHANGE FOR ALL SCHEMAS
                ORDER BY partitionrangeend DESC
            ) sr_prt
ON N.nspname =  sr_prt.schemaname
AND C.relname =  sr_prt.partitiontablename

INNER JOIN t
ON sr_prt.schemaname =  t.schemaname
AND sr_prt.tablename =  t.tablename

LEFT JOIN pg_stat_operations st -- GET WHEN THE OBJECT WAS CREATED
ON st.objname = sr_prt.partitiontablename
AND st.schemaname = N.nspname
AND st.actionname = 'CREATE'

WHERE NOT EXISTS ( 
                   SELECT 1 
                   FROM admin.size_tables_hist hist 
                   WHERE hist.oid = C.oid 
                   AND hist.tablename_orig = C.relname 
                   AND hist.active = 't'
                  )
;


select * from admin.size_tables_hist

;

