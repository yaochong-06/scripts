col window_name for A20
col resource_plan for A30
col schedule_owner for A20
col last_start_date for A35
col next_start_date for A35
col enable for A5

select client_name,status from dba_autotask_task;
select window_name,autotask_status from dba_autotask_window_clients;
select window_name,repeat_interval from dba_scheduler_windows where enabled='TRUE';
select window_name, job_name, job_start_time from (select * from dba_autotask_job_history where client_name='auto optimizer stats collection' order by window_start_time desc) where rownum<4;
select window_name,window_next_time from dba_autotask_window_clients; 
