;
---- == ---- == ---- == ---- == ---- == ---- == ---- == ---- ==
-- CHECK IF SOME TABLE WAS DROPPED
---- == ---- == ---- == ---- == ---- == ---- == ---- == ---- ==
UPDATE admin.size_tables_hist T1 SET active = 'f'
LEFT JOIN pg_class C 
ON t1.oid = C.oid
AND C.relname = T1.tablename_orig
WHERE C.oid IS NULL
---- == ---- == ---- == ---- == ---- == ---- == ---- == ---- ==