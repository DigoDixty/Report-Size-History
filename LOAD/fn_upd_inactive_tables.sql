;
---- == ---- == ---- == ---- == ---- == ---- == ---- == ---- ==
-- CHECK IF SOME TABLE WAS DROPPED
---- == ---- == ---- == ---- == ---- == ---- == ---- == ---- ==
UPDATE admin.size_tables_hist T1 
SET active = 'f'
WHERE active = 't'
AND NOT exists (select 1 from pg_class C 
		WHERE t1.oid = C.oid
		AND C.relname = T1.tablename_orig
		);
---- == ---- == ---- == ---- == ---- == ---- == ---- == ---- ==