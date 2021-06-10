select
    sql_id,child_number,plan_hash_value,
    is_bind_aware BA,is_bind_sensitive BS,
    is_reoptimizable "ReOpt?",
    is_resolved_adaptive_plan "RAP?",
    executions,elapsed_time/1000000/executions tpe,
    px_servers_executions/executions pxpe
from v$sql
where lower(sql_text) like lower('%&1%')
and sql_text not like '%sql_id%'
/
