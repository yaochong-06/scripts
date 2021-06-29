col TEMP_TBS for a10
col "DBA Privs?" for a10
col ACCOUNT_STATUS for a14
col DEFAULT_TABLESPACE for a18
col username for a12
col LCOUNT for 999
col PROFILE for a12

set linesize 400
select distinct
        a.username,
        a.default_tablespace,
        a.temporary_tablespace as temp_tbs,
        a.user_id,
        to_char(a.created,'yyyymmdd') as created,
        a.profile,
        a.account_status,
        b.lcount,
        sum(round(s.bytes/1024/1024/1024)) over(partition by s.owner) as USER_SEGMENT_GB,
        case when p.GRANTED_ROLE = 'DBA' then 'Yes' else 'No' end as "DBA Privs?"
from
        dba_users a, user$ b, dba_segments s ,dba_role_privs p
where a.user_id = b.USER#
and a.username = s.owner
and p.grantee = a.username
and a.username not in
('SYSTEM','OWBSYS','XS$NULL','FLOWS_FILES','WMSYS','DIP','XDB','SYS','ANONYMOUS','QMONITOR','ORDPLUGINS',
'OUTLN','ORDSYS','SI_INFORMTN_SCHEMA','ORDDATA','OJVMSYS','SPATIAL_WFS_ADMIN_USR','MDSYS','LBACSYS','SPATIAL_CSW_ADMIN_USR',
'DVSYS','DBSNMP','APEX_PUBLIC_USER','APPQOSSYS','APEX_040200','ORACLE_OCM','AUDSYS','CTXSYS','MDDATA',
'APEX_030200','EXFSYS','MGMT_VIEW','OLAPSYS','SYSMAN','OWBSYS_AUDIT','WH_SYNC','GSMADMIN_INTERNAL')
order by created
/

col grantee for a25
set serveroutput on
set feedback off
set head off
set timing off
set verify off
set linesize 500
undefine username
var username varchar2(100);
var owner varchar2(100);
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
begin
  :username := upper('&username');
end;
/

prompt ***************
prompt Current User DBA_ROLE_PRIVS
prompt ***************
select 'grant '||granted_role||' to '||grantee||decode(admin_option, 'YES', ' WITH ADMIN OPTION;',';') cmd 
from dba_role_privs where upper(grantee) like upper(:username);
prompt ***************
prompt Current User dba_sys_privs
prompt ***************
select 'grant '||privilege||' to '||grantee||decode(admin_option, 'YES', ' WITH ADMIN OPTION;',';') cmd 
from dba_sys_privs where upper(grantee) like upper(:username);
prompt ***************
prompt Current User dba_tab_privs
prompt ***************
select 'grant '||privilege||' on '||owner||'.'||table_name||' to '||grantee||decode(grantable, 'YES', ' WITH GRANT OPTION;',';') cmd 
from dba_tab_privs where upper(grantee) like upper(:username);

set head on feedback on


