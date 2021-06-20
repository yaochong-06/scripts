--Show the info of a session that hold the lock
set linesize 300
col spid format 99999
col os_user_name format a20
col object_name format a30
col oracle_username format a15
col locked_mode format a25
col SID_AND_SERIAL# for a25
col MACHINE for a15
col OBJECT_NAME for a15
select p.spid,
       a.object_name,
       s.sid || ',' || s.serial# as SID_AND_SERIAL#,
       s.SQL_HASH_VALUE,
       l.oracle_username,
       l.os_user_name,
       s.machine,
       s.sql_id,
       decode(locked_mode,2,'sub share',3,'sub exclusive',4,'share',5,'share/sub exclusive',6,'exclusive',null) locked_mode
from v$process p,v$session s, v$locked_object l,dba_objects a 
where p.addr=s.paddr 
and s.process=l.process 
and a.object_id=l.object_id
and s.sid = l.session_id
/


col b_res for a20
col b_username a20
col program for a20
col machine for a20
col service_name for a20
col b_prev_sql_id for a20
col w_username for a20
col w_sql_id for a13
col w_prev_sql_id for a13
set linesize 3000
/* I-AM-YUNQU-BUILTIN-SQL */select
    b.type || '-' || b.id1 ||'-'|| b.id2 || case when b.type = 'TM' then (select '(' || owner || '.' || object_name || ')' from dba_objects where object_id = b.id1) else '' end as b_res,
    s1.sid || ','|| s1.serial# || '@' || s1.inst_id as b_blocker,
    (select count(*) from gv$lock t where t.type=b.type and t.id1 = b.id1 and t.id2 = b.id2 and request > 0) b_blocked_cnt,
    b.request b_request,
    b.lmode b_lmode,
    s1.username b_username,
    s1.sql_id b_sql_id,
    s1.machine,
    s1.program,
    s1.module,
    s1.service_name,
    s1.prev_sql_id b_prev_sql_id,
    b.ctime as b_ctime,
    s2.sid || ','|| s2.serial# || '@' || s2.inst_id as w_waiter,
    w.request w_request,
    w.lmode w_lmode,
    s2.username w_username,
    s2.sql_id w_sql_id,
    s2.prev_sql_id w_prev_sql_id,
    w.ctime as w_ctime
from
    gv$lock b,
    gv$lock w,
    gv$session s1,
    gv$session s2
where
    b.block > 0
and w.request > 0
and b.id1 = w.id1
and b.id2 = w.id2
and b.type = w.type
and b.inst_id = s1.inst_id
and b.sid = s1.sid
and w.inst_id = s2.inst_id
and w.sid = s2.sid
and b.type in ('TM','TX')
order by
    b_res,
    w_ctime desc;
