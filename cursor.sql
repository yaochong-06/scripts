set linesize 400
set pages 50
set long 99999
set verify off feedback off
var hash_value varchar2(20)
var sql_id varchar2(20)
var child_number number;

begin
  :sql_id := '&sql_id';
end;
/

col sql_id              new_value sql_id        noprint;
col child_number        new_value child_number  noprint ;

select distinct sql_id, child_number from v$sql_plan where sql_id = :sql_id;

begin
        :sql_id         := '&&sql_id';
        :child_number   := &&child_number;
end;
/

SELECT * FROM table(DBMS_XPLAN.DISPLAY_CURSOR(:sql_id, :child_number,'advanced -projection'));

set verify on feedback on
col sql_id print
col child_number print 



col sql_id for A15
col time for A22
select  instance_number,
	(select max(to_char(begin_interval_time,'yyyy-mm-dd hh24:mi:ss')) time from dba_hist_snapshot where snap_id = x.snap_id) snap_time,
	sql_id,
	plan_hash_value plan,
	executions_delta exec_delta,
	trunc(ELAPSED_TIME_DELTA/decode(executions_delta,0,1,executions_delta)/1000000) "avg(s)",
	trunc(CPU_TIME_DELTA/decode(executions_delta,0,1,executions_delta)/1000000) "avg_cpu(s)",
	trunc(rows_processed_delta/decode(executions_delta,0,1,executions_delta)) "avg_rows_exec",
	trunc(buffer_gets_delta/decode(executions_delta,0,1,executions_delta)) "avg_cr_exec",
	trunc(disk_reads_delta/decode(executions_delta,0,1,executions_delta)) "avg_reads_exe"
from
	dba_hist_sqlstat x
where x.sql_id = :sql_id 
order by x.snap_id;


col sql_id for a13
col sql_text for a10
col sql_child_number head CH# for 999
col LAST_LOAD_TIME for a20
col PARSING_SCHEMA_NAME for a20
select
    sql_id,
    child_number ch#,
    plan_hash_value plan,
    PARSING_SCHEMA_NAME,
    LAST_LOAD_TIME,
    ELAPSED_TIME,
    cpu_time,
    APPLICATION_WAIT_TIME,
    CONCURRENCY_WAIT_TIME,
    CLUSTER_WAIT_TIME,
    USER_IO_WAIT_TIME,
    PLSQL_EXEC_TIME,
    JAVA_EXEC_TIME,
    ROWS_PROCESSED,
    executions exec,
    buffer_gets,
	round(rows_processed/decode(executions,0,1,executions)) "rows/exec",
	trunc(elapsed_time/decode(executions,0,1,executions)/10000) "ela_tm(cs)/exec",
	trunc(cpu_time/decode(executions,0,1,executions)/10000) "cpu_tm(cs)/exec",
	trunc(buffer_gets/decode(executions,0,1,executions)) "gets/exec",
	trunc(disk_reads/decode(executions,0,1,executions)) "reads/exec",
    substr(SQL_TEXT,0,10) as sql_text
from
    v$sql
where
    sql_id = :sql_id
order by 6
/

