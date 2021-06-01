CREATE OR REPLACE FUNCTION admin.fn_drop_old_empt_table()
  RETURNS integer AS
$BODY$ 

DECLARE

   v_tb         TEXT    := ''; 
   v_prt_tb     TEXT    := ''; 
   v_rank       INT     :=  0; 
   v_size       BIGINT  :=  0; 
   v_tt_size    BIGINT  :=  0; 
   i            INTEGER :=  0;
   v_check      INTEGER :=  0;
   v_cmd        TEXT    := ''; 
   v_oid        OID;

BEGIN
-- fn_update_size_table()
-- Just to confirm if exist and object to collect size.
    i := (
          SELECT COUNT(1) 
          FROM (SELECT 1 
                FROM admin.size_tables_hist hist
                WHERE 1 = 1
                AND   (hist.relation_size > 0 OR hist.total_relation_size > 0)
                AND   relation_size  = 0
                AND   hist.active = 't' 
                AND   hist.partitionrangeend <> ''
                AND   hist.partitionrangeend < '2021-01-01'
                AND   hist.schemaname = 'adhoc'
                AND   hist.active = 't'
                LIMIT 10
                ) A
          ); 

-- Get OID of object to collect size.
    FOR v_oid IN    SELECT oid 
                    FROM admin.size_tables_hist hist
                    WHERE 1 = 1
                    AND   (hist.relation_size > 0 OR hist.total_relation_size > 0)
                    AND   relation_size  = 0
                    AND   hist.active = 't' 
                    AND   hist.partitionrangeend <> ''
                    AND   hist.partitionrangeend < '2021-01-01'
                    AND   hist.schemaname = 'adhoc'
                    AND   hist.active = 't'
                    ORDER BY schemaname, tablename, partitionrangeend
                    LIMIT 10
    LOOP

    i := i - 1;

    v_cmd := ('v_oid: % - missing: %', v_oid, i);
    RAISE NOTICE '%', v_cmd;
      	
    v_tb :=  ( 
             SELECT schemaname || '.' || tablename 
             FROM admin.size_tables_hist 
             WHERE OID = v_oid 
           );

    v_prt_tb := ( 
                 SELECT tablename_orig
                 FROM admin.size_tables_hist 
                 WHERE OID = v_oid 
              );
          


    v_rank := ( 
             SELECT partitionrank 
             FROM pg_partitions p
             WHERE p.partitiontablename = (
                                            SELECT hist.tablename_orig
                                            FROM admin.size_tables_hist hist
                                            WHERE OID = v_oid LIMIT 1
                                          )
            );

    v_cmd := 'SELECT 1 FROM % LIMIT 10;', v_prt_tb;
    RAISE NOTICE '%', v_cmd;


    v_cmd := 'ALTER TABLE % DROP PARTITION FOR (RANK(%));', v_tb, v_rank;
    RAISE NOTICE '%', v_cmd;
    --ALTER TABLE v_tb DROP PARTITION FOR (RANK(v_rank));
    
    v_check := 0;
      
    END LOOP;

    ---- UPDATE active status
    UPDATE admin.size_tables_hist T1 SET active = 'f'
    WHERE NOT exists (select 1 from pg_class C 
    WHERE t1.oid = C.oid
    AND C.relname = T1.tablename_orig
    )
    and T1.active = 't'
    ;
  
   RETURN i;
END ; 
$BODY$
  LANGUAGE plpgsql VOLATILE;
ALTER FUNCTION admin.fn_drop_old_empt_table()
  OWNER TO gpadmin;

-- select admin.fn_drop_old_empt_table()