set linesize 3000
set pages 1000
col machine for a20
col object_name for a20
col username for a15
col locked_mode for 9999
col kill_command for a35
col event for a28
col sql_text for a90
SELECT S.SID,
       S.MACHINE,
       O.OBJECT_NAME,
       L.ORACLE_USERNAME as username,
       L.LOCKED_MODE,
       'ALTER SYSTEM KILL SESSION ''' || S.SID || ', ' || S.SERIAL# ||
       ''';' AS KILL_COMMAND,
       s.sql_exec_start,
       s.event,
       q.sql_text
  FROM V$LOCKED_OBJECT L, V$SESSION S, dba_OBJECTS O, v$sql q
 WHERE L.SESSION_ID = S.SID
   AND L.OBJECT_ID = O.OBJECT_ID
   and s.SQL_ID = q.SQL_ID
   and s.SQL_HASH_VALUE = q.HASH_VALUE
   and o.object_name = upper('&obname');



--select *
--  from gv$lock
-- where id1 in (select object_id
--                from dba_objects
--                where owner = 'BD_WAREHOUSE'
--                  and object_name = 'OPS_CH_USER_STAFF_DETAIL');

