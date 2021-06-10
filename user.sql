set linesize 400
set pages 100
col ACCOUNT_STATUS for a16
col username for a25
col created for a8
col default_Tablespace for a20
col temp_tablespace for a16
col PROFILE for a13
select distinct 
	a.username, 
	a.default_tablespace, 
	a.temporary_tablespace as temp_tablespace, 
	a.user_id,
	to_char(a.created,'yyyymmdd') as created,
	a.profile,
	a.account_status,
        b.lcount,
        sum(round(s.bytes/1024/1024/1024)) over(partition by s.owner) as USER_SEGMENT_GB
from 
	dba_users a, user$ b, dba_segments s
where a.user_id = b.USER# 
and a.username = s.owner
and a.username not in 
('SYSTEM','OWBSYS','XS$NULL',
'FLOWS_FILES','WMSYS','DIP',
'XDB','SYS','ANONYMOUS',
'SCOTT','QMONITOR','ORDPLUGINS',
'OUTLN','ORDSYS','SI_INFORMTN_SCHEMA',
'ORDDATA','OJVMSYS','SPATIAL_WFS_ADMIN_USR',
'MDSYS','LBACSYS','SPATIAL_CSW_ADMIN_USR',
'DVSYS','DBSNMP','APEX_PUBLIC_USER',
'APPQOSSYS','APEX_040200','ORACLE_OCM',
'AUDSYS','CTXSYS','MDDATA',
'APEX_030200','EXFSYS','MGMT_VIEW',
'OLAPSYS','SYSMAN','OWBSYS_AUDIT',
'WH_SYNC','GSMADMIN_INTERNAL')
order by created
/
