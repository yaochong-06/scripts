--------------------------------------------------------------------------------
--
-- File name:   ashtop.sql
-- Purpose:     Display top ASH time (count of ASH samples) grouped by your
--              specified dimensions
--              
-- Author:      Tanel Poder
-- Copyright:   (c) http://blog.tanelpoder.com
--              
-- Usage:       
--     @ashtop <grouping_cols> <filters> <fromtime> <totime>
--
-- Example:
--     @ashtop username,sql_id session_type='FOREGROUND' sysdate-1/24 sysdate
--
-- Other:
--     This script uses only the in-memory V$ACTIVE_SESSION_HISTORY, use
--     @dashtop.sql for accessiong the DBA_HIST_ACTIVE_SESS_HISTORY archive
--              
--------------------------------------------------------------------------------
prompt ON CPU User I/O Network Commit Application Concurrency Cluster Configuration Administrative System I/O Scheduler Queueing Other Others for Wait_class%

set linesize 300
col MACHINE for a25
col sql_text for a12
col "AAS" for 999
col sql_id for a13
col "Active%" for a7
col Sessions for 999
col COMMAND for a8
col "Wait_class%" for a75

with tmp as 
    (select 1 value,
	a.inst_id as instance_id,
	a.SESSION_ID || ',' || a.SESSION_SERIAL# || '@'|| a.inst_id SESSION_ID,
round((cast(a.sample_time as date)-a.sql_exec_start)*24*3600) SQL_ELAPSED_TIME,
	(select username from dba_users u where u.user_id = a.user_id) username,
	a.machine,
	a.program,
	--status,
	case a.SQL_OPCODE
	when 1 then 'CREATE TABLE'
	when 2 then 'INSERT'
	when 3 then 'SELECT'
	when 6 then 'UPDATE'
	when 7 then 'DELETE'
	when 9 then 'CREATE INDEX'
	when 11 then 'ALTER INDEX'
	when 15 then 'ALTER INDEX' else 'Others' end command,
	case when a.SQL_ID is null then 'Null' when a.SQL_ID is not null then a.sql_id end as SQL_ID,
	a.SQL_PLAN_HASH_VALUE,
	nvl(a.event, 'ON CPU') event,
	nvl(a.wait_class, 'ON CPU') wait_class,
	a.module,
	a.action,
    case when top_level_sql_id <> sql_id then top_level_sql_id
         when top_level_sql_id = sql_id then null end as top_level_sql_id,
	(select name from V$ACTIVE_SERVICES s where s.NAME_HASH = a.SERVICE_HASH) SERVICE_NAME,
(select sql_text from gv$sql s where s.sql_id = a.sql_id and rownum = 1) sql_text
   from gv$active_session_history a
where a.SAMPLE_TIME between (sysdate - 1/24) and sysdate)
select x.* from (
SELECT
sql_id,
lpad(round(100.0 * COUNT(*) / (select count(*) from gv$active_session_history a
where a.SAMPLE_TIME between (sysdate - 1/24) and sysdate) , 2 ) || '%', 6,' ') as "Active%",
CAST (round( 10.0 * COUNT(*) / (select count(*) from gv$active_session_history a
where a.SAMPLE_TIME between (sysdate - 1/24) and sysdate) , 2 ) AS REAL ) as "AAS",
lpad(ROUND(100.0 * sum(case when WAIT_CLASS = 'ON CPU' then 1 else 0 end)/count(*)) || '%',5,' ') ||
lpad(ROUND(100.0 * sum(case when WAIT_CLASS = 'User I/O' then 1 else 0 end)/count(*)) || '%',5,' ') ||
lpad(ROUND(100.0 * sum(case when WAIT_CLASS = 'Network' then 1 else 0 end)/count(*)) || '%',5,' ') ||
lpad(ROUND(100.0 * sum(case when WAIT_CLASS = 'Commit' then 1 else 0 end)/count(*)) || '%',5,' ') ||
lpad(ROUND(100.0 * sum(case when WAIT_CLASS = 'Application' then 1 else 0 end)/count(*)) || '%',5,' ') ||
lpad(ROUND(100.0 * sum(case when WAIT_CLASS = 'Concurrency' then 1 else 0 end)/count(*)) || '%',5,' ') ||
lpad(ROUND(100.0 * sum(case when WAIT_CLASS = 'Cluster' then 1 else 0 end)/count(*)) || '%',5,' ') ||
lpad(ROUND(100.0 * sum(case when WAIT_CLASS = 'Configuration' then 1 else 0 end)/count(*)) || '%',5,' ')||
lpad(ROUND(100.0 * sum(case when WAIT_CLASS = 'Administrative' then 1 else 0 end)/count(*)) || '%',5,' ') ||
lpad(ROUND(100.0 * sum(case when WAIT_CLASS = 'System I/O' then 1 else 0 end)/count(*)) || '%',5,' ') ||
lpad(ROUND(100.0 * sum(case when WAIT_CLASS = 'Scheduler' then 1 else 0 end)/count(*)) || '%',5,' ') ||
lpad(ROUND(100.0 * sum(case when WAIT_CLASS = 'Queueing' then 1 else 0 end)/count(*)) || '%',5,' ') ||
lpad(ROUND(100.0 * sum(case when WAIT_CLASS = 'Other' then 1 else 0 end)/count(*)) || '%',5,' ') ||
lpad(ROUND(100.0 * sum(case when WAIT_CLASS not in ('ON CPU','Other','Application','Configuration','Cluster','Administrative','Concurrency','Commit','Networ
k','User I/O','System I/O','Scheduler','Queueing') then 1 else 0 end)/count(*)) || '%',5,' ')
as "Wait_class%",
-- substr(max(sql_text),0,10) as sql_text,
max(command) as command,
max(machine) as machine,
max(top_level_sql_id) as procedure_sql_id
FROM tmp GROUP BY sql_id ORDER BY COUNT (*) DESC
) x where rownum <  10;
