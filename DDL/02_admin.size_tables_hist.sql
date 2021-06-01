-- Table: admin.size_tables_hist
-- DROP TABLE admin.size_tables_hist;
CREATE TABLE admin.size_tables_hist
(
  oid OID,
  schemaname TEXT,
  tablename TEXT,
  tablename_orig TEXT,
  relation_size BIGINT,
  pretty_relation_size TEXT,
  total_relation_size BIGINT,
  pretty_total_relation_size TEXT,
  usestatus TEXT,
  partitionrangeend TEXT,
  reloptions TEXT[],
  active BOOLEAN,
  last_updated TIMESTAMP WITH TIME ZONE, 
  dt_obj_created TIMESTAMP WITH TIME ZONE
)
WITH (APPENDONLY=true, COMPRESSLEVEL=1, ORIENTATION=ROW, COMPRESSTYPE=quicklz, 
  OIDS=FALSE
)
DISTRIBUTED BY (OID);
ALTER TABLE admin.size_tables_hist
  OWNER TO gpadmin;
GRANT ALL ON TABLE admin.size_tables_hist TO gpadmin;
