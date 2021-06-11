---- == ---- == ---- == ---- == ---- == ---- == ---- == ---- ==
-- LOAD DATA FOR "NEW" OLDERS OBJECTS
---- == ---- == ---- == ---- == ---- == ---- == ---- == ---- ==
INSERT INTO admin.size_tables_hist

(oid, schemaname, tablename_orig, tablename, partitionrangeend, dt_obj_created, reloptions, active)

SELECT   
     C.oid
    ,N.nspname AS schemaname
    ,C.relname AS tablename_orig
    ,sr_prt.tablename AS tablename
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
                AND partitionrangeend < NOW() - INTERVAL '6 months'
                AND partitionisdefault <> 't'
                -- AND schemaname IN ('adhoc') -- CHANGE FOR ALL SCHEMAS
                ORDER BY partitionrangeend DESC
            ) sr_prt
ON N.nspname =  sr_prt.schemaname
AND C.relname =  sr_prt.partitiontablename

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
                  );
