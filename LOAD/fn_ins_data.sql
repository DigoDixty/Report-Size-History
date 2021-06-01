---- == ---- == ---- == ---- == ---- == ---- == ---- == ---- ==
-- LOAD DATA FOR "NEW" OLDERS OBJECTS
---- == ---- == ---- == ---- == ---- == ---- == ---- == ---- ==
INSERT INTO admin.size_tables_hist

(oid, schemaname, tablename_orig, tablename, partitionrangeend, dt_obj_created, reloptions, active)

SELECT   
     C.oid
    ,N.nspname AS schemaname
    ,C.relname AS tablename_orig
    ,CASE WHEN relname LIKE '%1_prt%' 
          THEN SUBSTRING(relname, 0, position('1_prt' IN relname) -1 ) 
          ELSE tablename 
          END tablename
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
                AND schemaname IN ('adhoc')
                ORDER BY partitionrangeend DESC
            ) sr_prt
ON N.nspname =  sr_prt.schemaname
AND C.relname =  sr_prt.partitiontablename

LEFT JOIN pg_stat_operations st -- get when the object was created
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
