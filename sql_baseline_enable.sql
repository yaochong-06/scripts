-- evolue the baseline with verify off
-- @sql_baseline_enable.sql <sql_handle> <plan_name>
-- Sidney Chen(Nov/09)
--

var pbsts varcahr2(1000)
exec :pbsts := dbms_spm.evolve_sql_plan_baseline
('&1',
 '&2',
 VERIFY=>'NO',
 COMMIT=>'YES');
