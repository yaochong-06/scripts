set linesize 200
set pages 300
col object_name for a30

SELECT a.session_id, s.SERIAL#,a.oracle_username, a.os_user_name, s.machine, b.object_name FROM v$locked_object a, all_objects b, v$session s
WHERE a.object_id = b.object_id and a.SESSION_ID=s.SID
/

