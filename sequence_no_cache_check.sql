-- 检查数据库是否存在没有配置缓存的序列
SELECT
s.SEQUENCE_OWNER,SEQUENCE_NAME,CACHE_SIZE
from dba_sequences s
where
s.sequence_owner not in ('ANONYMOUS','APEX_030200','APEX_040000','APEX_040200','DVSYS','LBACSYS','OJVMSYS','APEX_SSO','APPQOSSYS','CTXSYS','DBSNMP','DIP','EXFSYS','FLOWS_FILES','MDSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS','ORDSYS','OUTLN','OWBSYS','SI_INFORMTN_SCHEMA','SQLTXADMIN','SQLTXPLAIN','SYS','SYSMAN','SYSTEM','TRCANLZR','WMSYS','XDB','XS$NULL','PERFSTAT','STDBYPERF')
and s.max_value > 0
and s.CACHE_SIZE < 100;
