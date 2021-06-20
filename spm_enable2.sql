-- evolue the baseline with verify on
-- @sql_baseline_enable2.sql <sql_handle>
-- Sidney Chen(Nov/09)
--

SELECT dbms_spm.evolve_sql_plan_baseline(
         sql_handle => '&1',
         plan_name  => '',
         time_limit => 10,
         verify     => 'yes',
         commit     => 'yes'
       )
FROM dual;
