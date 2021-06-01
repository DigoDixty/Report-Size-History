---====---
-- REPORT DE SELECT DA TABELA size_tables_hist

SELECT      schemaname
    ,SUM(qtd)
    ,pg_size_pretty(CAST(SUM(sum_relation_size) AS BIGINT))
    ,pg_size_pretty(CAST(SUM(sum_total_relation_size) AS BIGINT))

FROM (    
        SELECT 
        schemaname, tablename, schemaname||'.'||tablename
        ,COUNT(1) qtd
        ,pg_size_pretty(CAST(SUM(relation_size) AS BIGINT))
        ,SUM(relation_size) AS sum_relation_size
        ,pg_size_pretty(CAST(SUM(total_relation_size) AS BIGINT))
        ,SUM(total_relation_size) AS sum_total_relation_size
        FROM(
            SELECT substring(partitionrangeend,2,10) DT
            ,*
            FROM admin.size_tables_hist
            WHERE 1 = 1
            AND (relation_size > 0 OR total_relation_size > 0)
            AND partitionrangeend <> ''
            and active = 't'
            ) A
        WHERE CAST(DT AS DATE) < NOW() - INTERVAL '6 months'
        GROUP BY 1, 2, 3
        ORDER BY 4 ASC, 6 DESC
    ) A

GROUP BY 1
ORDER BY 1