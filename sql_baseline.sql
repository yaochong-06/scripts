-- sql_baseline.sql <sql_id_to_load> <plan_hash_value> <sql_handle> <old_plan_name_to_drop>
-- Sidney Chen(Nov 3)

SELECT signature, sql_handle, plan_name, enabled, accepted, fixed, origin
  FROM dba_sql_plan_baselines WHERE sql_handle = '&1';

SET SERVEROUTPUT ON

DECLARE
  ret PLS_INTEGER;
BEGIN
  ret := dbms_spm.load_plans_from_cursor_cache(
           sql_id          => '&2',
           plan_hash_value => '&3',
           sql_handle      => '&1'
         );
  dbms_output.put_line(ret || ' SQL plan baseline(s) created');
  ret := dbms_spm.drop_sql_plan_baseline(
           sql_handle => '&1',
           plan_name  => '&4'
         );
  dbms_output.put_line(ret || ' SQL plan baseline(s) dropped');
END;
/
SET SERVEROUTPUT OFF

SELECT signature, sql_handle, plan_name, enabled, accepted, fixed, origin
  FROM dba_sql_plan_baselines WHERE sql_handle = '&1';

