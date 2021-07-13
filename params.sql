set linesize 500
col name for a40
col value for a12
col ksppdesc for a70
select 
ksppinm as name,
ksppstvl as value,
case when ksppinm = '_optim_peek_user_binds' and ksppstvl <> 'TRUE' then 'Recommended to set to default value <TRUE>, Peep through statistical information histogram binding variables'
     when ksppinm = '_undo_autotune' and ksppstvl = 'TRUE' then '_undo_autotune recommended to set to <FALSE>, default value is TRUE Doc 1574714.1' 
     when ksppinm = '_optimizer_adaptive_cursor_sharing' and ksppstvl <> 'TRUE' then 'Recommend to set to <TRUE> to solves the execution plan remains unchanged after binding variable peeping issue'
     when ksppinm = '_optimzer_adaptive_extended_cursor_sharing' and ksppstvl <> 'UDO' then 'should be set to <UDO> to solves the problem that the execution plan remains unchanged after binding variable peeping issue'
     when ksppinm = '_optimizer_extended_cursor_sharing_rel' and  ksppstvl <> 'SIMPLE' then 'Should be set to <SIMPLE> to solves the problem that the execution plan remains unchanged after binding variable peeping issue'
     when ksppinm = 'optimizer_index_caching' and ksppstvl <> 0 then 'optimizer_index_caching should set to <0>, default value is 0'
     when ksppinm = 'optimizer_index_cost_adj' and ksppstvl <> 100 then 'optimizer_index_cost_adj should set to <100>, default value is 100'
     when ksppinm = '_serial_direct_read' and ksppstvl <> 'auto' then '_serial_direct_read recommend to set to <auto>, Only when the table is small can we consider setting it to never'
     when ksppinm = '_gc_policy_time' and ksppstvl <> 0 then '_gc_policy_time recommend to set to <0> to global close DRM'
     when ksppinm = '_gc_undo_affinity' and ksppstvl = 'TRUE' then '_gc_undo_affinity recommend to set to <FALSE> to global close DRM'
     when ksppinm = '_memory_imm_mode_without_autosga' and ksppstvl = 'TRUE' then 'If Necessary Can be set to <FALSE> to avoid Memory Competition'
     when ksppinm = 'parallel_force_local' and ksppstvl <> 'TRUE' then 'Recommed to set to <TRUE> to Avoid GC issue except IB network'
     when ksppinm = '_PX_use_large_pool' and ksppstvl = 'FALSE' then 'Recommed to set to <TRUE> to use large pool'
     when ksppinm = 'optimizer_adaptive_plans' and ksppstvl = 'TRUE' then '12c new features,default <TRUE>, recommed to set to <FALSE>'
     when ksppinm = 'adaptive_adaptive_statistics' and ksppstvl = 'TRUE' then '12.2 default <FALSE>, recommed to set to <FALSE>'
     when ksppinm = '_cursor_obsolete_threshold' and ksppstvl > 1024 then '12.2 default value 8192, this can cause high version count issue,set <1024>' 
     when ksppinm = '_b_tree_bitmap_plans' and ksppstvl = 'TRUE' then 'In some cases, the session level can be set to <FALSE>' 
     when ksppinm = 'optimizer_dynamic_sampling' and ksppstvl <> 2 then 'Set default value <2>'
     when ksppinm = '_use_single_log_writer' and ksppstvl <> 'TRUE' then '12c new features recommed to set to <TRUE>'
     when ksppinm = '_use_adaptive_log_file_sync' and ksppstvl ='TRUE' then 'The parameters of 11.2.0.3 and above are true by default, which may affect the log synchronization performance. Recommended that the Production Database make the following adjustments DOC 1462942.1 '
     when ksppinm = '_datafile_write_errors_crash_instance' and ksppstvl = 'TRUE' then  'Recommed to set to False, Instance Crashes After IO Error Doc 2453717.1'
end as advice
--,ksppdesc 
from x$ksppi x, x$ksppcv y 
where x.indx = y.indx 
and ksppinm in 
('_kcfis_storageidx_diag_mode',
'__db_cache_size',
'_memory_imm_mode_without_autosga',
'_small_table_threshold',
'_very_large_object_threshold',
'_kcfis_storageidx_disabled',
'_serial_direct_read',
'_very_large_object_threshold',
'_max_outstanding_log_writes',
'_use_single_log_writer',
'_datafile_write_errors_crash_instance',
'_use_adaptive_log_file_sync',
'_undo_autotune',
'_optim_peek_user_binds',
'_optimizer_use_feedback',
'_optimizer_adaptive_cursor_sharing',
'_optimizer_extended_cursor_sharing',
'_optimizer_extended_cursor_sharing_rel',
'optimizer_index_caching',
'optimizer_index_cost_adj',
'db_file_multiblock_read_count',
'optimizer_dynamic_sampling',
'_cleanup_rollback_entries',
'_cursor_obsolete_threshold',
'_b_tree_bitmap_plans',
'optimizer_mode',
'_gc_policy_time',
'_gc_undo_affinity',
'optimizer_adaptive_plans',
'_PX_use_large_pool',
'parallel_force_local',
'_cursor_obsolete_threshold'
)
union all
select 
name,
value,
case when name = 'open_cursors' and (value < 300 or value > 1000) then 'open_cursors recommend to set to more than <300>, 1000 is enough'
     when name = 'control_file_record_keep_time' and value <= 7 then 'control_file_record_keep_time recommend to set to <15>, 30 is enough,Doc 47322.1' 
     when name = 'cursor_sharing' and value <> 'EXACT' then 'Recommend to set to <EXACT>, <FORCE> Forcing SQL that does not use binding variables into binding variables' 
     when name = 'audit_trail' and value <> 'NONE' then 'If necessary set value to <NONE> to close Audit'
     when name = 'sesssion_cached_cursors' and value > 100 then 'No need to set too large, Set the maximum number of closed cursors that can be cached in each session.'
     when name = 'deferred_segment_creation' and value <> 'FALSE' then '<TRUE> will result in the failure to export an empty table ,Mos 1216282.1'
     when name = 'enable_ddl_logging' and value <> 'TRUE' then '<TRUE> enable alert log records DDL statements'
     when name = 'undo_retention' and value < 1800 then 'Recommend to set to 10800 and set a large enough undo tablespace'
     when name = 'statistics_level' and value <> 'TYPICAL' then 'Recommend to set it to the default value <TYPICAL>'
     when name = 'result_cache_mode' and value <> 'MANUAL' then 'Recommend to set to <MANUAL>'
     when name = 'result_cache_max_size' and value <> 0 then 'Recommend to set to <0>'
     when name = 'memory_target' and value <> 0 then 'Recommend to set to <0> to close AMM'
     when name = 'memory_max_target' and value <> 0 then 'Recommend to set to <0> to close AMM'
     when name = 'db_files' and value < 5000 then 'Recommend to set to more than <5000>'
     when name = 'processes' and value < 5000 then 'Recommend to set to more than <5000>'
     when name = 'job_queue_processes' and value < 1000 then 'Recommend to set to more than <1000>'
     when name = 'sga_target' and value = 0 then 'Recommend to set the same value with sga_max_size'
     when name = 'sga_max_size' and value < 100 then 'According to the business and system memory settings'
     when name = 'db_cache_size' and value = 0 then 'Recommend to set a minimum value'
     when name = 'shared_pool_size' and value = 0 then 'Recommend to set a minimum value'
     when name = 'pga_aggregate_target' and value < 100 then 'According to the business and system memory settings'
     when name = 'fast_start_parallel_rollback' and value = 'FALSE' then '<FALSE> means Parallel rollback is disabled, <LOW> Limits the maximum degree of parallelism to 2 * CPU_COUNT'
end as adivce 
from v$parameter 
where name in (
'open_cursors',
'control_file_record_keep_time',
'cursor_sharing',
'audit_trail',
'session_cached_cursors',
'deferred_segment_creation',
'enable_ddl_logging',
'undo_retention',
'statistics_level',
'result_cache_mode',
'result_cache_max_size',
'job_queue_processes',
'processes',
'db_files',
'shared_pool_size',
'db_cache_size',
'pga_aggregate_target',
'sga_target',
'sga_max_size',
'memory_target',
'memory_max_target',
'fast_start_parallel_rollback'
)
order by name;
--optimizer_adaptive_features=false
--_optimizer_inmemory_access_path=0

--sql plan directivce
--_sql_plan_directive_mgmt_control=0
--_optimizer_dsdir_usage_control=0

