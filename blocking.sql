
col event for a30
col status for a10
col blkses for 99999
col username for a13
col module for a30
col program for a40
col machine for a25
col state for a20
col cmd for a23
col sql_id for a20
set linesize 1000
set pages 1000
select s.inst_id,s.sid,s.event,s.state,s.status,s.blocking_instance blkinst,s.blocking_session blkses,s.prev_sql_id,
s.last_call_et lcet,s.wait_time_micro/1000000 wtsec,s.sql_id,s.username,c.command_name cmd,s.row_wait_obj#,s.module,s.program,s.machine
from gv$session s,gv$sqlcommand c
where s.type='USER'
and s.inst_id=c.inst_id
---and s.event not like 'SQL*Net%'
and s.command=c.command_type
order by s.username,s.sql_id,s.module,s.program;
