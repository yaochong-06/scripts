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
