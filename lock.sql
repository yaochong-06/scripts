--Display the current locks
col kaddr heading 'lock|address'
col sid heading 'session id' format 9999999 
col sp_id for a10
col type heading 'lock|type' format a6
col id1 heading 'id1' format a36
col id2 heading 'id2' format 99999999
col lmode heading 'lock mode' format 99999999
col request heading 'req mode' format 99999999
col blocking_sid format 999999 heading 'blocked | sessid'
set verify off
select /*+ rule */a.kaddr,a.sid as sid,to_char(d.spid) as sp_id,a.type,decode(a.type,'TM',E.OBJECT_NAME,A.ID1) as id1 ,a.id2,
  a.lmode,a.request,a.block,b.sid blocking_sid
from v$lock a,(
  select * from v$lock
  where request > 0
  and type not in ('MR','AE','TO')
) b,v$session c,v$process d,dba_objects e
where a.id1 = b.id1(+) and a.id2 = b.id2(+)
and a.id1 = e.object_id(+)
and a.lmode > 0
and a.type not in ('MR','AE','TO')
and a.sid = c.sid
and c.paddr = d.addr 
/ 
--Show the info of a session that hold the lock
col spid format 99999
col os_user_name format a20
col object_name format a30
col oracle_username format a15
col locked_mode format a25

select p.spid,a.object_name,s.sid,s.serial#,s.SQL_HASH_VALUE,l.oracle_username,l.os_user_name ,
		decode(locked_mode,2,'sub share',3,'sub exclusive',4,'share',5,'share/sub exclusive',6,'exclusive',null) locked_mode
from v$process p,v$session s, v$locked_object l,all_objects a 
where 
p.addr=s.paddr 
and 
s.process=l.process 
and 
a.object_id=l.object_id
and
s.sid = l.session_id
;
select sql_text from v$sql where hash_value in (select sql_hash_value from v$session where sid in (select session_id from v$locked_object));

select 'kill -9 '||spid from v$process where addr in (select paddr from v$session where sid in ( select session_id from v$locked_object));
