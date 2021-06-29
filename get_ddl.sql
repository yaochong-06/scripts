--Show DDL of procedure or view
prompt Show DDL of procedure, view,table, index or synonym
set long 10000
set timing off
set feedback off
set verify off
set linesize 300
set pages 0
var object_name varchar2(200)
begin
  :object_name := upper('&object_name');
end;
/

prompt show the owner object_type information...
select 'OWNER        ','OBJECT_TYPE  ' from dual
union all
select '-------------','-------------' from dual
union all
select owner,object_type from dba_objects where object_name = :object_name;
set feedback off

select text from dba_source where name = :object_name
/
select text from dba_views where view_name = :object_name
/
select view_definition from v$fixed_View_definition where view_name = :object_name
/

select QUERY from dba_mviews where mview_name = :object_name
/
select * from dba_synonyms where synonym_name = :object_name
/

exec dbms_metadata.set_transform_param( dbms_metadata.session_transform,'SQLTERMINATOR', TRUE);

prompt t
select
dbms_metadata.get_ddl(
case when object_type like 'PACKAGE%' then 'PACKAGE' 
when object_type like 'DATABASE LINK' then 'DB_LINK' 
when object_type like 'MATERIALIZED VIEW' then 'MATERIALIZED_VIEW' 
when object_type = 'INDEX' then 'INDEX'
else object_type end, object_name, owner) as "TABLE_DDL" 
from 
	dba_objects 
where 
	object_name = :object_name 
AND object_type not like '%PARTITION'
/


column cons_column_name heading COLUMN_NAME format a30

prompt Show constraints of the table...
col owner for a20
col table_name for a20
col constraint_name for a20
col constraint_type for a20
col r_constraint_name for a10
col column_name for a20

select
     co.owner,
     co.table_name,
     co.constraint_name,
     co.constraint_type,
     co.r_constraint_name,
     cc.column_name          cons_column_name,
     cc.position,
     co.status,
     co.validated
from
     dba_constraints co,
     dba_cons_columns cc
where
    co.owner              = cc.owner
and co.table_name         = cc.table_name
and co.constraint_name    = cc.constraint_name
and co.table_name = :object_name
order by
     owner,
     table_name,
     constraint_type,
     constraint_name,
     position,
     column_name
/
prompt show constraint for the table  ...
select case 
	when co.constraint_type <> 'R' then dbms_metadata.get_ddl('CONSTRAINT',co.constraint_name,co.owner) 
	when co.constraint_type = 'R' then dbms_metadata.get_ddl('REF_CONSTRAINT',co.constraint_name,co.owner) end as text
from
     dba_constraints co,
     dba_cons_columns cc
where
    co.owner              = cc.owner
and co.table_name         = cc.table_name
and co.constraint_name    = cc.constraint_name
and co.table_name = :object_name
order by
     co.owner,
     co.table_name,
     co.constraint_type,
     co.constraint_name
/

select 'grant '||privilege||' on '||owner||'.'||table_name||' to '||grantee||decode(grantable, 'YES', ' WITH GRANT OPTION;',';') cmd
from dba_tab_privs
where table_name = :object_name
/

col schema_user format a10
col what format a50
select job, next_date, failures, broken, schema_user, what from dba_jobs;





select s.text
from dba_triggers t, dba_source s
where
t.owner = s.owner
and t.trigger_name = s.name
and t.table_name = upper(:object_name);

set feedback on
set timing on
