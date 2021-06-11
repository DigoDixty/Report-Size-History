--== UPDATE LIST OF DROPED OLDERS TABLES ==--
UPDATE admin.size_tables_hist T1
SET active = 'f'
WHERE active = 't'
AND NOT exists (select 1 from pg_class C
                WHERE t1.oid = C.oid
                AND C.relname = T1.tablename_orig
                );

--== Delete objects to new colect ==--
DELETE FROM admin.tb_drop_check ch
WHERE EXISTS (  SELECT 1
                FROM admin.size_tables_hist hist
                WHERE ch.schemaname = hist.schemaname AND ch.tablename_orig = hist.tablename_orig
                AND INFO = 'CHECK'
                );

--== Reload new objetos to check ==--
INSERT INTO admin.tb_drop_check (info, schemaname, tablename, tablename_orig, partitionrank, script_test, drop_cmd, script_cmd, count_rows )
SELECT
 'CHECK',schemaname,tablename, tablename_orig, partitionrank
,'UPDATE admin.tb_drop_check SET info = ''DONE'', count_rows = (SELECT 1 FROM ' || schemaname ||'.'|| tablename_orig || ' LIMIT 1), dt_colected = now() WHERE schemaname = '''|| schemaname ||''' and tablename_orig = '''|| tablename_orig ||''';' script_cmd
,drop_cmd
,'SELECT 1, '''|| schemaname ||'.'|| tablename_orig ||''' FROM ' || schemaname ||'.'|| tablename_orig || ' LIMIT 1;' script_test
,0 AS count_rows
--,*
FROM
(
SELECT
'ALTER TABLE ' || hist.schemaname ||'.'|| hist.tablename || ' DROP PARTITION FOR (RANK('||p.partitionrank||'));' drop_cmd
,hist.oid, p.partitionrank
,hist.schemaname, hist.tablename, hist.tablename_orig, hist.pretty_relation_size
,hist.pretty_total_relation_size, substring(hist.partitionrangeend,2,10) as partitionrangeend
FROM admin.size_tables_hist hist
INNER JOIN pg_partitions p
ON p.partitiontablename = hist.tablename_orig
AND hist.schemaname = p.schemaname
WHERE 1 = 1
AND (hist.relation_size > 0 or hist.total_relation_size > 0)
AND relation_size  = 0
AND hist.partitionrangeend <> ''
AND hist.partitionrangeend < '2021-01-01'
AND hist.schemaname in ('adhoc', 'aux')
AND hist.active = 't'
AND NOT EXISTS (SELECT 1 FROM admin.tb_drop_check ch WHERE ch.schemaname = hist.schemaname AND ch.tablename_orig = hist.tablename_orig)
) A
ORDER BY schemaname, tablename, partitionrank DESC;

-- #psql -d warehouse -c "SELECT script_test FROM admin.tb_drop_check WHERE INFO = 'CHECK' ORDER BY schemaname, tablename, partitionrank DESC" -t >> query_count.sql

