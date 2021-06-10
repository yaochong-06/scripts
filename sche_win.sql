col window_name for A20
col resource_plan for A30
col schedule_owner for A20
col last_start_date for A35
col next_start_date for A35
col enable for A5
select window_name, resource_plan, schedule_owner,last_start_date, next_start_date,enabled from dba_scheduler_windows;
