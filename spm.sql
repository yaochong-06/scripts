SELECT signature, sql_handle, plan_name, enabled, accepted, fixed, origin
  FROM dba_sql_plan_baselines WHERE plan_name = '&plan_name';


SELECT signature, sql_handle, plan_name, enabled, accepted, fixed, origin
  FROM dba_sql_plan_baselines WHERE sql_handle = '&sql_handle';
-- evolue the baseline with verify off
-- @sql_baseline_enable.sql <sql_handle> <plan_name>
-- Sidney Chen(Nov/09)
--

var pbsts varcahr2(1000)
exec :pbsts := dbms_spm.evolve_sql_plan_baseline
('&sql_handle',
 '&plan_name',
 VERIFY=>'NO',
 COMMIT=>'YES');
-- evolue the baseline with verify on
-- @sql_baseline_enable2.sql <sql_handle>
-- Sidney Chen(Nov/09)
--

SELECT dbms_spm.evolve_sql_plan_baseline(
         sql_handle => '&sql_handle',
         plan_name  => '',
         time_limit => 10,
         verify     => 'yes',
         commit     => 'yes'
       )
FROM dual;
-- sql_baseline.sql <sql_id_to_load> <plan_hash_value> <sql_handle> <old_plan_name_to_drop>
-- Sidney Chen(Nov 3)

SELECT signature, sql_handle, plan_name, enabled, accepted, fixed, origin
  FROM dba_sql_plan_baselines WHERE sql_handle = '&1';

SET SERVEROUTPUT ON

DECLARE
  ret PLS_INTEGER;
BEGIN
  ret := dbms_spm.load_plans_from_cursor_cache(
           sql_id          => '&sql_id',
           plan_hash_value => '&plan_hash_value',
           sql_handle      => '&sql_handle'
         );
  dbms_output.put_line(ret || ' SQL plan baseline(s) created');
  ret := dbms_spm.drop_sql_plan_baseline(
           sql_handle => '&1',
           plan_name  => '&4'
         );
  dbms_output.put_line(ret || ' SQL plan baseline(s) dropped');
END;
/
