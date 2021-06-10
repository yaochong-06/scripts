column sqlt_sql_text	heading SQL_TEXT format a100 word_wrap

select 
	sql_id,
    child_number ch#,
	plan_hash_value plan, 
    executions exec,
	trunc(rows_processed/decode(executions,0,1,executions)) "rows/exec",
	trunc(elapsed_time/decode(executions,0,1,executions)/10000) "ela_tm(cs)/exec",
	trunc(buffer_gets/decode(executions,0,1,executions)) "gets/exec",
	trunc(disk_reads/decode(executions,0,1,executions)) "reads/exec",
	sql_text sqlt_sql_text
from 
	v$sql 
where 
	lower(sql_text) like lower('%&1%')
	and	hash_value != (select sql_hash_value from v$session where sid = (select sid from v$mystat where rownum = 1))
	order by 6
/

