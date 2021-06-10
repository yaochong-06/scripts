--Show the procedures that are cached in the library cache
col owner for a15
col name for a30
col type for a20
select owner,name,type,executions,pins,locks from v$db_object_cache where locks > 0 and pins > 0 and type='PROCEDURE';
