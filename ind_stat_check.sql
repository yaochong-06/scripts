-- 检查无统计信息/统计信息过期/统计信息过旧的索引
-- 数据库存在无统计信息/统计信息过期/统计信息过旧的索引，SQL解析时CBO无法生成正确的执行计划，极大影响数据库性能
SELECT /*+ NO_MERGE */
       s.owner, s.table_name, s.index_name, s.stale_stats, to_char(s.last_analyzed,'YYYY/MM/DD HH24:MI:SS') as last_analyzed_time
  FROM dba_ind_statistics s,
       dba_indexes t
 WHERE s.OBJECT_TYPE = 'INDEX'
   AND s.owner NOT IN ('ANONYMOUS','APEX_030200','APEX_040000','APEX_SSO','APPQOSSYS','CTXSYS','DBSNMP','DIP','EXFSYS','FLOWS_FILES','MDSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','OWBSYS','SI_INFORMTN_SCHEMA','SQLTXADMIN','SQLTXPLAIN','SYS','SYSMAN','SYSTEM','TRCANLZR','WMSYS','XDB','XS$NULL','PERFSTAT','STDBYPERF')
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
