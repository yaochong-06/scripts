set linesize 3000
set pages 300
col owner for a12
col table_name for a20
col index_name for a20
col column_name for a20
col QUERY_Q for a80
set feedback off

prompt index not used since instance startup...
alter session set nls_date_format ='yyyy-mm-dd hh24:mi:ss';
SELECT X.OWNER,
       X.TABLE_NAME,
       X.INDEX_NAME,
       SS.CREATED,
       C.COLUMN_POSITION,
       C.COLUMN_NAME,
       S.BYTES / 1024 / 1024 M,
       q'[select count(*),count(distinct ]' || C.COLUMN_NAME ||
       q'[) from ]' || X.OWNER || '.' || X.TABLE_NAME || q'[;]' AS QUERY_Q
  FROM (SELECT A.OWNER, A.TABLE_NAME, A.INDEX_NAME
          FROM DBA_INDEXES A
         WHERE A.OWNER IN (SELECT USERNAME
                             FROM DBA_USERS
                            WHERE USERNAME not in('SYSTEM','WMSYS','XDB','SYS','SCOTT','QMONITOR','OUTLN','ORDSYS','ORDDATA','OJVMSYS','MDSYS','LBACSYS','DVSYS',
                       'DBSNMP','APEX_040200','AUDSYS','CTXSYS','APEX_030200','EXFSYS','OLAPSYS','SYSMAN','WH_SYNC','GSMADMIN_INTERNAL'))
           AND (A.OWNER, A.INDEX_NAME) NOT IN
               (SELECT /*+unnest*/
                 B.OBJECT_OWNER, B.OBJECT_NAME
                  FROM GV$SQL A, GV$SQL_PLAN B
                 WHERE A.SQL_ID = B.SQL_ID
                   AND A.CHILD_NUMBER = B.CHILD_NUMBER
                   AND B.OBJECT_OWNER IN
                       (SELECT USERNAME
                          FROM DBA_USERS
                         WHERE USERNAME not in ('SYSTEM','WMSYS','XDB','SYS','SCOTT','QMONITOR','OUTLN','ORDSYS','ORDDATA','OJVMSYS','MDSYS','LBACSYS','DVSYS',
                       'DBSNMP','APEX_040200','AUDSYS','CTXSYS','APEX_030200','EXFSYS','OLAPSYS','SYSMAN','WH_SYNC','GSMADMIN_INTERNAL'))
                   AND B.OBJECT_TYPE LIKE '%INDEX%'
                   AND B.TIMESTAMP > (select min(startup_time) from gv$instance))
           AND A.TABLE_NAME NOT LIKE 'SYS%'
           AND A.UNIQUENESS <> 'UNIQUE') X
 INNER JOIN DBA_IND_COLUMNS C
    ON C.INDEX_OWNER = X.OWNER
   AND C.INDEX_NAME = X.INDEX_NAME
   AND C.TABLE_NAME = X.TABLE_NAME
 INNER JOIN DBA_SEGMENTS S
    ON S.SEGMENT_NAME = C.TABLE_NAME
   AND S.OWNER = C.INDEX_OWNER
   -- AND S.BYTES   > 10
 INNER JOIN DBA_OBJECTS SS ON SS.OBJECT_NAME = X.INDEX_NAME 
 ORDER BY 1, 2, 3, 4
/

set linesize 300
col owner for a20
col index_name for a25
col table_name for a25
select
    u.name owner,
    io.name index_name,
    t.name table_name,
    decode(bitand(i.flags, 65536), 0, 'NO', 'YES') monitoring,
    decode(bitand(ou.flags, 1), 0, 'NO', 'YES') used,
    ou.start_monitoring,
    ou.end_monitoring
from sys.user$ u, sys.obj$ io, sys.obj$ t, sys.ind$ i, sys.object_usage ou
where
    i.obj# = ou.obj#
    and io.obj# = ou.obj#
    and t.obj# = i.bo#
    and u.user# = io.owner#
    and lower(u.name) like '%' || lower('&username') || '%'
    and lower(t.name) like '%' || lower('&table_name') || '%';
