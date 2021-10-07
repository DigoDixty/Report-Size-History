-- Table: admin.size_tables_adhoc

-- DROP TABLE admin.size_tables_adhoc;

CREATE TABLE admin.size_tables_adhoc
(
  oid oid,
  schemaname text,
  tablename text,
  tablename_orig text,
  relation_size bigint,
  pretty_relation_size text,
  total_relation_size bigint,
  pretty_total_relation_size text,
  usestatus text,
  partitionrangeend text,
  reloptions text[],
  active boolean,
  last_updated timestamp with time zone,
  dt_obj_created timestamp with time zone
)
WITH (APPENDONLY=true, COMPRESSLEVEL=1, ORIENTATION=row, COMPRESSTYPE=quicklz, 
  OIDS=FALSE
)
DISTRIBUTED BY (oid);
