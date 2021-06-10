-- spm2.sql <plan_name>
SELECT signature, sql_handle, plan_name, enabled, accepted, fixed, origin
  FROM dba_sql_plan_baselines WHERE plan_name = '&1';
-- spm1.sql <sql_handle>
SELECT signature, sql_handle, plan_name, enabled, accepted, fixed, origin
  FROM dba_sql_plan_baselines WHERE sql_handle = '&1';
