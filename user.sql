col TEMP_TABLESPACE for a15
col "DBA Privs?" for a10
col ACCOUNT_STATUS for a14
col LCOUNT for 999
col PROFILE for a12

set linesize 400
select distinct
        a.username,
        a.default_tablespace,
        a.temporary_tablespace as temp_tablespace,
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
('SYSTEM','OWBSYS','XS$NULL','FLOWS_FILES','WMSYS','DIP','XDB','SYS','ANONYMOUS','SCOTT','QMONITOR','ORDPLUGINS',
'OUTLN','ORDSYS','SI_INFORMTN_SCHEMA','ORDDATA','OJVMSYS','SPATIAL_WFS_ADMIN_USR','MDSYS','LBACSYS','SPATIAL_CSW_ADMIN_USR',
'DVSYS','DBSNMP','APEX_PUBLIC_USER','APPQOSSYS','APEX_040200','ORACLE_OCM','AUDSYS','CTXSYS','MDDATA',
'APEX_030200','EXFSYS','MGMT_VIEW','OLAPSYS','SYSMAN','OWBSYS_AUDIT','WH_SYNC','GSMADMIN_INTERNAL')
order by created
/

col grantee for a25

select grantee, granted_role, admin_option, default_role from dba_role_privs where upper(grantee) like upper('%&1%');

select grantee, privilege, admin_option from dba_sys_privs where upper(grantee) like upper('%&1%');

select grantee, owner, table_name, privilege from dba_tab_privs where upper(grantee) like upper('%&1%');
select grantee, owner, table_name, privilege 
from dba_tab_privs
where table_name = :table_name;
set head off feedback off
select 'grant '||granted_role||' to '||grantee||decode(admin_option, 'YES', ' WITH ADMIN OPTION;',';') cmd from dba_role_privs where upper(grantee) like upper('%&1%');
select 'grant '||privilege||' to '||grantee||decode(admin_option, 'YES', ' WITH ADMIN OPTION;',';') cmd from dba_sys_privs where upper(grantee) like upper('%&1%');
select 'grant '||privilege||' on '||owner||'.'||table_name||' to '||grantee||decode(grantable, 'YES', ' WITH GRANT OPTION;',';') cmd from dba_tab_privs where upper(grantee) like upper('%&1%');
set head on feedback on
