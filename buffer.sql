rem     Purpose:       List blocks per object in buffer, by buffer pool
rem
rem     Notes:
rem     This has to be run by SYS because the 'working data set' is
rem     only present as an X$ internal, and the column of the buffer
rem     header that we need is not exposed in the v$bh view
rem
rem     Objects are only reported if they have a signficant number of
rem     blocks in the buffer.  The code here is set to show object
rem     which have 5 times the number of latches active in the
rem     working set with most latches.
rem
rem     There is one oddity - the obj number stored in the x$bh is
rem     the dataobj#, not the obj$# - so some objects (e.g. tables in
rem     clusters) will generate spurious figures where the count is
rem     multiplied up by the number of objects in the data object.
rem
rem     Objects owned by SYS have been omitted (owner# > 0)
rem
rem     The various X$ tables and columns are undocumented, so the code
rem     is written on a best-guess basis, but the results seems to be
rem     as expected.


clear breaks
clear columns
break on pool_name skip 1 on report 
compute sum of blocks on report
compute sum of blocks on pool_name
column pool_name format a9
column object_name format a20
column sub_name format a20
column OBJECT_TYPE for a12
column username for a16
column blocks format 999,999
set pagesize 60
set timing off
set linesize 500
select
        /*+ ordered */
        bp.name as pool_name,
        u.username as username,
        ob.name as object_name,
        ob.subname as sub_name,
        decode(ob.type#,
         0,'NEXT OBJECT',1,'INDEX',2,'TABLE',3, 'CLUSTER',4,'VIEW',5, 'SYNONYM', 
         6,'SEQUENCE',7, 'PROCEDURE',8, 'FUNCTION',9, 'PACKAGE',11, 'PACKAGE BODY',12, 'TRIGGER',13, 'TYPE',
         14,'TYPE BODY',19, 'TABLE PARTITION', 20, 'INDEX PARTITION', 21, 'LOB',
         22,'LIBRARY', 23, 'DIRECTORY', 24, 'QUEUE',28, 'JAVA SOURCE', 29, 'JAVA CLASS', 30,'JAVA RESOURCE',
         32,'INDEXTYPE',33, 'OPERATOR',34,'TABLE SUBPARTITION',35,'INDEX SUBPARTITION',40,'LOB PARTITION', 41, 'LOB SUBPARTITION',
         43, 'DIMENSION',
         44, 'CONTEXT', 46, 'RULE SET', 47, 'RESOURCE PLAN',
         48, 'CONSUMER GROUP',
         51, 'SUBSCRIPTION', 52, 'LOCATION',
         55, 'XML SCHEMA', 56, 'JAVA DATA',
         57, 'SECURITY PROFILE', 59, 'RULE',
         60, 'CAPTURE', 61, 'APPLY',
         62, 'EVALUATION CONTEXT',
         66, 'JOB', 67, 'PROGRAM', 68, 'JOB CLASS', 69, 'WINDOW',
         72, 'WINDOW GROUP', 74, 'SCHEDULE', 79, 'CHAIN',
         81, 'FILE GROUP',
        'UNDEFINED') object_type,
        sum(bh.ct) as blocks,
        round((sum(bh.ct)*(select value from v$parameter where name = 'db_block_size' and rownum = 1))/1024/1024,2) as size_mb
from
        (
        select
               set_ds,
               obj,
               count(*) ct
        from
               x$bh
        group by
               set_ds,
               obj
        )                      bh,
        obj$                   ob,
        x$kcbwds               ws,
        v$buffer_pool          bp,
        dba_users              u
where
        ob.dataobj# = bh.obj
and     ob.owner#   = u.user_id
and     bh.set_ds   = ws.addr
and     ws.set_id between bp.lo_setid and bp.hi_setid
and     bp.buffers != 0        --  Eliminate any pools not in use
and     u.username not in('SYS','SYSTEM','WMSYS','XDB',
                       'QMONITOR','OUTLN','ORDSYS','ORDDATA','OJVMSYS','MDSYS','LBACSYS','DVSYS',
                       'DBSNMP','APEX_040200','AUDSYS','CTXSYS','APEX_030200','EXFSYS','OLAPSYS','SYSMAN','WH_SYNC','GSMADMIN_INTERNAL')
group by u.username,bp.name, ob.name,ob.type#,ob.subname
order by blocks desc, bp.name, ob.name, ob.subname;

prompt Buffer Pool Information
select name, block_size, buffers from v$buffer_pool;

prompt buffer_pool_working_data_sets
select set_id,cnum_set,set_latch,nxt_repl,prv_repl,nxt_replax, prv_replax,cnum_repl,anum_repl, dbwr_num from x$kcbwds;
