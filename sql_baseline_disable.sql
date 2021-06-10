--
-- @sql_baseline_enable.sql <sql_handle> <plan_name>
-- Sidney Chen(Nov/09)
--

var pbsts varchar2(1000);
exec :pbsts := dbms_spm.ALTER_SQL_PLAN_BASELINE
( '&1',
  '&2',
  ATTRIBUTE_NAME => 'ENABLED',
  ATTRIBUTE_VALUE => 'NO');
