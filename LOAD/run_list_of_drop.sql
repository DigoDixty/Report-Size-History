--- === SELECT LIST PARA APAGAR OBJETOS === ---
SELECT distinct drop_cmd
FROM (
    SELECT drop_cmd,
        count_rows,
        schemaname ||'.'||tablename_orig,
        schemaname,
        tablename,
        partitionrank,
        script_cmd

    FROM admin.tb_drop_check ch
    WHERE info = 'DONE' and count_rows is null
    AND EXISTS (
                SELECT 1 FROM admin.size_tables_hist hist
                WHERE active = 't'
                AND ch.schemaname = hist.schemaname
                AND ch.tablename_orig = hist.tablename_orig
                )
    ) A
ORDER BY schemaname, tablename, partitionrank DESC;
