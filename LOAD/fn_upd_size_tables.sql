-- Function: admin.fn_update_size_table()
-- DROP FUNCTION admin.fn_update_size_table();

CREATE OR REPLACE FUNCTION admin.fn_update_size_table()
  
  RETURNS INTEGER AS

$BODY$ 

DECLARE

   v_tb    TEXT := ''; 
   v_size  BIGINT := 0; 
   v_tt_size  BIGINT := 0; 
   i INTEGER := 0;
   v_oid OID;

BEGIN
-- fn_update_size_table()
-- Just to confirm if exist and object to collect size.
    i := (
          SELECT COUNT(1) 
          FROM (SELECT 1 
                FROM admin.size_tables_hist 
                WHERE active = 't' 
                AND relation_size IS NULL 
                LIMIT 1000
                ) A
          ); 

-- Get OID of object to collect size.
    FOR v_oid IN  SELECT oid 
                  FROM admin.size_tables_hist 
                  WHERE active = 't' 
                  AND relation_size IS NULL 
                  ORDER BY schemaname, tablename_orig
                  LIMIT 1000
    LOOP

      i := i - 1;
      raise notice 'v_oid: % - missing: %', v_oid, i;
      	
      v_tb := ( 
                SELECT schemaname || '.' || tablename_orig 
                FROM admin.size_tables_hist 
                WHERE OID = v_oid 
              );
              
      v_size := (SELECT pg_relation_size(v_oid));
      v_tt_size := (SELECT pg_total_relation_size(v_oid));

      raise notice 'table: %, size: %, total size: %', v_tb, v_size, v_tt_size;
      UPDATE admin.size_tables_hist
      SET relation_size = v_size
        , total_relation_size = v_tt_size
      WHERE OID = v_oid; 
    
    END LOOP;

    UPDATE admin.size_tables_hist c 
    SET pretty_relation_size = pg_size_pretty(relation_size)
      , pretty_total_relation_size = pg_size_pretty(total_relation_size)
      , last_updated = NOW()
    WHERE pretty_total_relation_size IS NULL;
  
   RETURN i;
END ; 
$BODY$
  LANGUAGE plpgsql VOLATILE;

ALTER FUNCTION admin.fn_update_size_table()
  OWNER TO gpadmin;
