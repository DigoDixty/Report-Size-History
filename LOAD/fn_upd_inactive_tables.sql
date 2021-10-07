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
/*
---- == ---- == ---- == ---- == ---- == ---- == ---- == ---- ==
-- REMOVE DUPLICADES OID
---- == ---- == ---- == ---- == ---- == ---- == ---- == ---- ==
DELETE FROM admin.size_tables_hist hist
-- SELECT * FROM admin.size_tables_hist hist
WHERE EXISTS (	SELECT 1 
				FROM (	SELECT oid, COUNT(1) 
						FROM admin.size_tables_hist 
						GROUP BY oid HAVING COUNT(1) > 1 
					 ) gp 
					WHERE gp.oid = hist.oid ) 
;
---- == ---- == ---- == ---- == ---- == ---- == ---- == ---- ==
-- REMOVE DUPLICADES OID
---- == ---- == ---- == ---- == ---- == ---- == ---- == ---- ==
DELETE 
FROM admin.size_tables_hist
WHERE partitionrangeend like '%bigint'
	OR partitionrangeend like '%character%'
	OR partitionrangeend like '%text%'
*/