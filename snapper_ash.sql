prompt Sampling SID SQL_ID ,Average Active Sessions for last 60 minutes, taking snapshots...

col sid format 999999
col serial# format 999999
col spid format 999999
col username format a12
col terminal format a15
col machine format a18
set linesize 1000
col program format a20
col spid format a10
col sql_text format a120
col sql_text1 format a125
col event for a25
col seconds for a5
col sql_id for a18
col p1 for 999999999999
set verify off
SET TERMOUT OFF
COLUMN run_sql NEW_VALUE run_sql
select decode(substr(value,1,2),
              '9.',
'snapper_ash11',
'10',
'snapper_ash11',
'11',
'snapper_ash11',
'12',
'snapper_ash19',
'19',
'snapper_ash19'
              ) run_sql
  from v$parameter 
where name='optimizer_features_enable'
/
SET TERMOUT ON
@&run_sql
