;
---- == ---- == ---- == ---- == ---- == ---- == ---- == ---- ==
-- MAKE SURE THAT NO RICKS TO TAKE WRONG RANK TO DROP PARTITION
---- == ---- == ---- == ---- == ---- == ---- == ---- == ---- ==
DELETE FROM admin.tb_drop_check ch
WHERE tablename IN (
select distinct tablename
	from admin.size_tables_hist T1 
	WHERE NOT exists (	select 1 from pg_class C 
				WHERE t1.oid = C.oid
				AND C.relname = T1.tablename_orig
				)
)
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
		)
;



---- == ---- == ---- == ---- == ---- == ---- == ---- == ---- ==