-- 检查无统计信息/统计信息过期/统计信息过旧的表

prompt last_analyzed < 7 and last_analyzed is null and stale_stats = 'YES' 
set linesize 600
SELECT /*+ NO_MERGE */
       s.owner, s.table_name, s.stale_stats , to_char(s.last_analyzed,'YYYY/MM/DD HH24:MI:SS') as last_analyzed_time
  FROM dba_tab_statistics s,
       dba_tables t
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN ('ANONYMOUS','APEX_030200','FLOWS_FILES','APEX_040000','APEX_SSO','APPQOSSYS','CTXSYS','DBSNMP','DIP','EXFSYS','FLOWS_FILES','MDSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','OWBSYS','SI_INFORMTN_SCHEMA','SQLTXADMIN','SQLTXPLAIN','SYS','SYSMAN','SYSTEM','TRCANLZR','WMSYS','XDB','XS$NULL','PERFSTAT','STDBYPERF')
   AND (s.last_analyzed IS NULL or  s.stale_stats = 'YES' or s.last_analyzed < sysdate -7)
   AND s.table_name NOT LIKE 'BIN%'
   AND NOT (s.table_name LIKE '%TEMP' OR s.table_name LIKE '%_TEMP_%')
   AND t.owner = s.owner
   AND t.table_name = s.table_name
   AND t.temporary = 'N'
   AND NOT EXISTS (
SELECT NULL
  FROM dba_external_tables e
 WHERE e.owner = s.owner
   AND e.table_name = s.table_name
)
 ORDER BY
       s.owner, s.table_name;

prompt 

col partition_name for A20
col SUBPARTITION_NAME for a20
SELECT *
  FROM (SELECT *
          FROM (SELECT *
                  FROM (SELECT U.NAME OWNER,
                               O.NAME TABLE_NAME,
                               NULL PARTITION_NAME,
                               NULL SUBPARTITION_NAME,
                               M.INSERTS,
                               M.UPDATES,
                               M.DELETES,
                               M.TIMESTAMP,
                               DECODE(BITAND(M.FLAGS, 1), 1, 'YES', 'NO') TRUNCATED,
                               M.DROP_SEGMENTS
                          FROM SYS.MON_MODS_ALL$ M,
                               SYS.OBJ$          O,
                               SYS.TAB$          T,
                               SYS.USER$         U
                         WHERE O.OBJ# = M.OBJ#
                           AND O.OBJ# = T.OBJ#
                           AND O.OWNER# = U.USER#
                        UNION ALL
                        SELECT U.NAME,
                               O.NAME,
                               O.SUBNAME,
                               NULL,
                               M.INSERTS,
                               M.UPDATES,
                               M.DELETES,
                               M.TIMESTAMP,
                               DECODE(BITAND(M.FLAGS, 1), 1, 'YES', 'NO'),
                               M.DROP_SEGMENTS
                          FROM SYS.MON_MODS_ALL$ M, SYS.OBJ$ O, SYS.USER$ U
                         WHERE O.OWNER# = U.USER#
                           AND O.OBJ# = M.OBJ#
                           AND O.TYPE# = 19
                        UNION ALL
                        SELECT U.NAME,
                               O.NAME,
                               O2.SUBNAME,
                               O.SUBNAME,
                               M.INSERTS,
                               M.UPDATES,
                               M.DELETES,
                               M.TIMESTAMP,
                               DECODE(BITAND(M.FLAGS, 1), 1, 'YES', 'NO'),
                               M.DROP_SEGMENTS
                          FROM SYS.MON_MODS_ALL$ M,
                               SYS.OBJ$          O,
                               SYS.TABSUBPART$   TSP,
                               SYS.OBJ$          O2,
                               SYS.USER$         U
                         WHERE O.OBJ# = M.OBJ#
                           AND O.OWNER# = U.USER#
                           AND O.OBJ# = TSP.OBJ#
                           AND O2.OBJ# = TSP.POBJ#)
                 WHERE OWNER NOT IN ('ANONYMOUS','APEX_030200','APEX_040000','APEX_SSO','APPQOSSYS','CTXSYS','DBSNMP','DIP','EXFSYS','FLOWS_FILES','MDSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','OWBSYS','SI_INFORMTN_SCHEMA','SQLTXADMIN','SQLTXPLAIN','SYS','SYSMAN','SYSTEM','TRCANLZR','WMSYS','XDB','XS$NULL','PERFSTAT','STDBYPERF') 
                UNION ALL
                SELECT *
                  FROM (SELECT U.NAME OWNER,
                               O.NAME TABLE_NAME,
                               NULL PARTITION_NAME,
                               NULL SUBPARTITION_NAME,
                               M.INSERTS,
                               M.UPDATES,
                               M.DELETES,
                               M.TIMESTAMP,
                               DECODE(BITAND(M.FLAGS, 1), 1, 'YES', 'NO') TRUNCATED,
                               M.DROP_SEGMENTS
                          FROM SYS.MON_MODS$ M,
                               SYS.OBJ$      O,
                               SYS.TAB$      T,
                               SYS.USER$     U
                         WHERE O.OBJ# = M.OBJ#
                           AND O.OBJ# = T.OBJ#
                           AND O.OWNER# = U.USER#
                        UNION ALL
                        SELECT U.NAME,
                               O.NAME,
                               O.SUBNAME,
                               NULL,
                               M.INSERTS,
                               M.UPDATES,
                               M.DELETES,
                               M.TIMESTAMP,
                               DECODE(BITAND(M.FLAGS, 1), 1, 'YES', 'NO'),
                               M.DROP_SEGMENTS
                          FROM SYS.MON_MODS$ M, SYS.OBJ$ O, SYS.USER$ U
                         WHERE O.OWNER# = U.USER#
                           AND O.OBJ# = M.OBJ#
                           AND O.TYPE# = 19
                        UNION ALL
                        SELECT U.NAME,
                               O.NAME,
                               O2.SUBNAME,
                               O.SUBNAME,
                               M.INSERTS,
                               M.UPDATES,
                               M.DELETES,
                               M.TIMESTAMP,
                               DECODE(BITAND(M.FLAGS, 1), 1, 'YES', 'NO'),
                               M.DROP_SEGMENTS
                          FROM SYS.MON_MODS$   M,
                               SYS.OBJ$        O,
                               SYS.TABSUBPART$ TSP,
                               SYS.OBJ$        O2,
                               SYS.USER$       U
                         WHERE O.OBJ# = M.OBJ#
                           AND O.OWNER# = U.USER#
                           AND O.OBJ# = TSP.OBJ#
                           AND O2.OBJ# = TSP.POBJ#)
                 WHERE OWNER NOT IN ('ANONYMOUS','APEX_030200','APEX_040000','APEX_SSO','APPQOSSYS','CTXSYS','DBSNMP','DIP','EXFSYS','FLOWS_FILES','MDSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','OWBSYS','SI_INFORMTN_SCHEMA','SQLTXADMIN','SQLTXPLAIN','SYS','SYSMAN','SYSTEM','TRCANLZR','WMSYS','XDB','XS$NULL','PERFSTAT','STDBYPERF'))
         ORDER BY INSERTS DESC)
 WHERE ROWNUM <= 50;



prompt table statistics are locked

select owner,table_name,stattype_locked
from dba_tab_statistics
where owner not in ('SYSTEM','OWBSYS','FLOWS_FILES','WMSYS','XDB','SYS','SCOTT','QMONITOR','OUTLN','ORDSYS','ORDDATA','OJVMSYS','MDSYS','LBACSYS','DVSYS',
                    'DBSNMP','APPQOSSYS','APEX_040200','AUDSYS','CTXSYS','APEX_030200','EXFSYS','OLAPSYS','SYSMAN','WH_SYNC','GSMADMIN_INTERNAL')
and stattype_locked is not null 
/

prompt expired Index Statistics
-- 检查无统计信息/统计信息过期/统计信息过旧的索引
-- 数据库存在无统计信息/统计信息过期/统计信息过旧的索引，SQL解析时CBO无法生成正确的执行计划，极大影响数据库性能
SELECT /*+ NO_MERGE */
       s.owner, s.table_name, s.index_name, s.stale_stats, to_char(s.last_analyzed,'YYYY/MM/DD HH24:MI:SS') as last_analyzed_time
  FROM dba_ind_statistics s,
       dba_indexes t
 WHERE s.OBJECT_TYPE = 'INDEX'
   AND s.owner NOT IN ('ANONYMOUS','APEX_030200','APEX_040000','APEX_SSO','APPQOSSYS','CTXSYS','DBSNMP','DIP','EXFSYS','FLOWS_FIL
ES','FLOWS_FILES','MDSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','OWBSYS','SI_INFORMTN_SCHEMA','SQLTXADMIN','SQLTXPLAIN
','SYS','SYSMAN','SYSTEM','TRCANLZR','WMSYS','XDB','XS$NULL','PERFSTAT','STDBYPERF')
   AND (s.last_analyzed IS NULL or  s.stale_stats = 'YES' or s.last_analyzed < sysdate -7)
   AND s.table_name NOT LIKE 'BIN%'
   AND NOT (s.table_name LIKE '%TEMP' OR s.table_name LIKE '%_TEMP_%' )
   AND t.owner = s.owner
   AND t.index_name = s.INDEX_NAME
   AND t.table_name = s.table_name
   AND t.temporary = 'N'
   and t.index_type != 'LOB'
   AND NOT EXISTS (
SELECT NULL
  FROM dba_external_tables e
 WHERE e.owner = s.owner
   AND e.table_name = s.table_name
)
 ORDER BY
       s.owner, s.table_name;



-- 检查是否存在收集了统计信息的临时表
SELECT /*+ NO_MERGE */
       s.owner, s.table_name
  FROM dba_tab_statistics s,
       dba_tables t
 WHERE s.object_type = 'TABLE'
   AND s.owner NOT IN ('ANONYMOUS','APEX_030200','APEX_040000','APEX_SSO','APPQOSSYS','CTXSYS','DBSNMP','DIP','EXFSYS','FLOWS_FILES','MDSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','OWBSYS','SI_INFORMTN_SCHEMA','SQLTXADMIN','SQLTXPLAIN','SYS','SYSMAN','SYSTEM','TRCANLZR','WMSYS','XDB','XS$NULL','PERFSTAT','STDBYPERF')
   AND s.last_analyzed IS NOT NULL
   /*AND s.stale_stats = 'YES'*/
   AND (s.table_name LIKE '%TEMP' OR s.table_name LIKE '%_TEMP_%' )
   AND s.table_name NOT LIKE 'BIN%'
   AND t.owner = s.owner
   AND t.table_name = s.table_name
   AND NOT EXISTS (
SELECT NULL
  FROM dba_external_tables e
 WHERE e.owner = s.owner
   AND e.table_name = s.table_name
)
 ORDER BY
       s.owner, s.table_name;
