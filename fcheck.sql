--Show datafile status
set line 200
col member for a90
col ts#        format 9999
     col tablespace format a20
     col file       format a52
     select t.ts#, t.name "tablespace", d.file#, d.name "file", d.status, d.enabled, d.bytes/1024/1024 "SIZE(M)"
     from v$tablespace t, v$datafile d
     where t.ts#=d.ts#
union all
     select t.ts#, t.name "tablespace", d.file#, d.name "file", d.status, d.enabled, d.bytes/1024/1024 "SIZE(M)"
     from v$tablespace t, v$tempfile d
     where t.ts#=d.ts#
     order by 1, 4; 

select * from gv$log order by INST_ID,GROUP#;
select * from gv$logfile order by INST_ID,GROUP#;
