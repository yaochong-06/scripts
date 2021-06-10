--1) Run this query to find the objects with timestamp issue
--
--set pagesize 10000
         column d_name format a20
         column p_name format a20
         SELECT
              do.obj# d_obj,
              do.name d_name,
              do.type# d_type,
              po.obj# p_obj,
              po.name p_name,
              to_char(p_timestamp,'DD-MON-YYYY HH24:MI:SS') "P_Timestamp",
              to_char(po.stime ,'DD-MON-YYYY HH24:MI:SS') "STIME",
              decode(sign(po.stime-p_timestamp),0,'SAME','*DIFFER*') X
         FROM sys.obj$ do, sys.dependency$ d, sys.obj$ po
         WHERE P_OBJ#=po.obj#(+)
         AND D_OBJ#=do.obj#
         AND do.status=1 /*dependent is valid*/
         AND po.status=1 /*parent is valid*/
         AND po.stime!=p_timestamp /*parent timestamp not match*/
         ORDER BY 2,1;

--2) For d_type = 1 INDEX         alter index <name> rebuild;
--       d_type = 2 TABLE         alter table <name> upgrade;
--       d_type = 4 VIEW          alter view <name> compile;
--       d_type = 5 SYNONYM       alter synonym <name> compile;
--       d_type = 7 PROCEDUR      alter procedure <name> compile; 
--       d_type = 8 FUNCTION      alter function <name> compile;
--       d_type = 9 PACKAGE       alter package <name> compile;
--       d_type = 11 PACKAGE BODY alter package <name> compile body;
--       d_type = 12 TRIGGER      alter trigger <name> compile;
--       d_type = 13 TYPE         alter session set events '10826 trace name context forever, level 1';     alter type <name> compile;  alter session set events '10826 trace name context off'; 
--

--select 'alter  '||b.object_type||' '||b.owner||'.'||a.d_name||' compile;',a.* from (
--SELECT do.obj# d_obj,
--       do.name d_name,
--       do.type# d_type,
--       po.obj# p_obj,
--       po.name p_name,
--       to_char(p_timestamp, 'DD-MON-YYYY HH24:MI:SS') "P_Timestamp",
--       to_char(po.stime, 'DD-MON-YYYY HH24:MI:SS') "STIME",
--       decode(sign(po.stime - p_timestamp), 0, 'SAME', '*DIFFER*') X
--  FROM sys.obj$ do, sys.dependency$ d, sys.obj$ po
-- WHERE P_OBJ# = po.obj#(+)
--   AND D_OBJ# = do.obj#
--   AND do.status = 1 /*dependent is valid*/
--   AND po.status = 1 /*parent is valid*/
--   AND po.stime != p_timestamp /*parent timestamp not match*/
--   --and po.obj#=465199     ---被依赖的object_id(被调用，相当于与父对象)
-- ORDER BY 2, 1) a,dba_objects b where a.d_obj=b.object_id
