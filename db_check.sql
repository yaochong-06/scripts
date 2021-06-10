select dbid, name, created, log_mode, checkpoint_change#, open_mode, force_logging, flashback_on from v$database;

Promp VALID Objects

select owner, object_type, object_name, status from dba_objects where status <> 'VALID' order by 1,2,3;
select owner, index_name, status from dba_indexes where status = 'UNUSABLE' order by 1, 2, 3;
--select 'alter ' || object_type || ' ' || owner || '.' ||  object_name || ' compile;' from dba_objects where status <> 'VALID' order by 1,2,3;
--EXEC DBMS_UTILITY.compile_schema(schema => user);
