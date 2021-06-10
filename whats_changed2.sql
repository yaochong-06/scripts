col sql_id for A15
col executions_delta for 99999999
col elp_time_per_exec for 99999999
col cpu_time_per_execfor 99999999
col rows_per_execfor 99999999
col lio_per_exec for 999999999
col disk_per_exec for 99999999

select
    sql_id,
    plan_hash_value,
    executions_delta,
    elp_time_per_exec,
    cpu_time_per_exec,
    rows_per_exec,
    lio_per_exec,
    disk_per_exec
from
(
select
    base.*,
    count(*) over (partition by sql_id) cnt,
    max(elp_time_per_exec) over (partition by sql_id) max_elp_time_per_exec
from
(
    select
        x.sql_id,
        x.plan_hash_value,
        sum(x.executions_delta) executions_delta,
        round(sum(x.elapsed_time_delta)/decode(sum(x.executions_delta),0,1,sum(x.executions_delta))/1000000, 1) elp_time_per_exec,
        round(sum(x.cpu_time_delta)/decode(sum(x.executions_delta),0,1,sum(x.executions_delta))/1000000, 1) cpu_time_per_exec,
        round(sum(x.rows_processed_delta)/decode(sum(x.executions_delta),0,1,sum(x.executions_delta)), 1) rows_per_exec,
        trunc(sum(x.buffer_gets_delta)/decode(sum(x.executions_delta),0,1,sum(x.executions_delta))) lio_per_exec,
        trunc(sum(x.disk_reads_delta)/decode(sum(x.executions_delta),0,1,sum(x.executions_delta))) disk_per_exec
    from
        dba_hist_sqlstat x,
        dba_hist_snapshot s
    where
        s.instance_number=x.instance_number
    and s.snap_id = x.snap_id
    and s.begin_interval_time > sysdate - nvl(to_number('&Days'),7)
    group by x.sql_id, x.plan_hash_value
    ) base
)
where
    max_elp_time_per_exec > nvl(to_number('&elp_time_per_exec'), 0.1)
and cnt > 1
order by max_elp_time_per_exec, elp_time_per_exec
/
