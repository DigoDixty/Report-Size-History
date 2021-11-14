SELECT 
'SELECT MIN('||col||'), MAX('||col||'), COUNT(1) AS QTD, 
'''|| A.schemaname ||'.'|| p.partitiontablename||''' AS TABLE
FROM ' || A.schemaname ||'.'|| p.partitiontablename || ';',
*
FROM 
    (
    SELECT DISTINCT 
        na.nspname AS schemaname, cl.relname AS tablename, 
        SUBSTRING(replace(REPLACE(pg_get_partition_def(att.attrelid, true),'PARTITION BY LIST(',''),'PARTITION BY RANGE(',''),0,
        POSITION( ')' IN replace(REPLACE(pg_get_partition_def(att.attrelid, true),'PARTITION BY LIST(',''),'PARTITION BY RANGE(',''))) col
    FROM pg_attribute att
    JOIN pg_class cl ON cl.oid=att.attrelid
    JOIN pg_namespace na ON na.oid=cl.relnamespace
    WHERE 
        na.nspname = 'schema' AND cl.relname IN('tablename')
    )A
JOIN pg_partitions p
ON p.tablename = A.tablename
AND p.schemaname = A.schemaname
WHERE p.partitionisdefault = 't'
