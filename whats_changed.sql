

select    sql_id,
    plan_hash_value,
    executions_delta,
    elp_time_per_exec,
    cpu_time_per_exec,
    rows_per_exec,
    lio_per_exec,
    disk_per_exec
from
(   select
    base.*,
    count(*) over (partition by sql_id) cnt,
    max(elp_time_per_exec) over (partition by sql_id) max_elp_time_per_exec
from
(   select
        x.sql_id,
        x.plan_hash_value,
        sum(x.executions_delta) executions_delta,
        round(sum(x.elapsed_time_delta)/decode(sum(x.executions_delta),0,1,sum(x.executions_delta))/1000000, 1) elp_time_per_exec,
        round(sum(x.cpu_time_delta)/decode(sum(x.executions_delta),0,1,sum(x.executions_delta))/1000000, 1) cpu_time_per_exec,
        round(sum(x.rows_processed_delta)/decode(sum(x.executions_delta),0,1,sum(x.executions_delta)), 1) rows_per_exec,
        trunc(sum(x.buffer_gets_delta)/decode(sum(x.executions_delta),0,1,sum(x.executions_delta))) lio_per_exec,
        trunc(sum(x.disk_reads_delta)/decode(sum(x.executions_delta),0,1,sum(x.executions_delta))) disk_per_exec,
        x.PARSING_SCHEMA_NAME
    from
        dba_hist_sqlstat x,
        dba_hist_snapshot s
    where
        s.instance_number=x.instance_number
    and s.snap_id = x.snap_id
    --and s.begin_interval_time >
    group by x.sql_id, x.plan_hash_value,x.PARSING_SCHEMA_NAME
    ) base )
where PARSING_SCHEMA_NAME = '&username'
and max_elp_time_per_exec > 1
and cnt > 1
order by max_elp_time_per_exec, elp_time_per_exec
/


----------------------------------------------------------------------------------------
--
-- File name:   whats_changed.sql
--
-- Purpose:     Find statements that have significantly different elapsed time than before.
-
-- Author:      Kerry Osborne
--
-- Usage:       This scripts prompts for four values.
--
--              days_ago: how long ago was the change made that you wish to evaluate
--                        (this could easily be changed to a snap_id for more precision)
--
--              min_stddev: the minimum "normalized" standard deviation between plans
--                          (the default is 2 - which means twice as fast/slow)
--
--              min_etime:  only include statements that have an avg. etime > this value
--                          (the default is .1 second)
--
--
--              faster_slower: a flag to indicate if you want only Faster or Slower SQL
--                             (the default is both - use S% for slower and F% for faster)
--
-- Description: This scripts attempts to find statements with significantly different
--              average elapsed times per execution. It uses AWR data and computes a
--              normalized standard deviation between the average elapsed time per
--              execution before and after the date specified by the days_ago parameter.
--
--              The ouput includes the following:
--
--              SQL_ID - the sql_id of a statement that is in the shared pool (v$sqlarea)
--
--              EXECS - the total number of executions in the AWR tables
--
--              AVG_ETIME_BEFORE - the average elapsed time per execution before the REFERENCE_TIME
--
--              AVG_ETIME_AFTER - the average elapsed time per execution after  the REFERENCE_TIME
--
--              NORM_STDDEV - this is a normalized standard deviation (i.e. how many times slower/faster is it now)
--
-- See http://kerryosborne.oracle-guy.com for additional information.
----------------------------------------------------------------------------------------

accept days_ago -
       prompt 'Enter Days ago: ' -
       default '1'

set lines 155
col execs for 999,999,999
col before_etime for 999,990.99
col after_etime for 999,990.99
col before_avg_etime for 999,990.99 head AVG_ETIME_BEFORE
col after_avg_etime for 999,990.99 head AVG_ETIME_AFTER
col min_etime for 999,990.99
col max_etime for 999,990.99
col avg_etime for 999,990.999
col avg_lio for 999,999,990.9
col norm_stddev for 999,990.9999
col begin_interval_time for a30
col node for 99999
break on plan_hash_value on startup_time skip 1
select * from (
select sql_id, execs, before_avg_etime, after_avg_etime, norm_stddev,
       case when to_number(before_avg_etime) < to_number(after_avg_etime) then 'Slower' else 'Faster' end result
-- select *
from (
select sql_id, sum(execs) execs, sum(before_execs) before_execs, sum(after_execs) after_execs,
       sum(before_avg_etime) before_avg_etime, sum(after_avg_etime) after_avg_etime,
       min(avg_etime) min_etime, max(avg_etime) max_etime, stddev_etime/min(avg_etime) norm_stddev,
       case when sum(before_avg_etime) > sum(after_avg_etime) then 'Slower' else 'Faster' end better_or_worse
from (
select sql_id,
       period_flag,
       execs,
       avg_etime,
       stddev_etime,
       case when period_flag = 'Before' then execs else 0 end before_execs,
       case when period_flag = 'Before' then avg_etime else 0 end before_avg_etime,
       case when period_flag = 'After' then execs else 0 end after_execs,
       case when period_flag = 'After' then avg_etime else 0 end after_avg_etime
from (
select sql_id, period_flag, execs, avg_etime,
stddev(avg_etime) over (partition by sql_id) stddev_etime
from (
select sql_id, period_flag, sum(execs) execs, sum(etime)/sum(decode(execs,0,1,execs)) avg_etime from (
select sql_id, 'Before' period_flag,
nvl(executions_delta,0) execs,
(elapsed_time_delta)/1000000 etime
-- sum((buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta))) avg_lio
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
where ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number
and executions_delta > 0
and elapsed_time_delta > 0
and ss.begin_interval_time <= sysdate-&&days_ago
union
select sql_id, 'After' period_flag,
nvl(executions_delta,0) execs,
(elapsed_time_delta)/1000000 etime
-- (elapsed_time_delta)/decode(nvl(executions_delta,0),0,1,executions_delta)/1000000 avg_etime
-- sum((buffer_gets_delta/decode(nvl(buffer_gets_delta,0),0,1,executions_delta))) avg_lio
from DBA_HIST_SQLSTAT S, DBA_HIST_SNAPSHOT SS
where ss.snap_id = S.snap_id
and ss.instance_number = S.instance_number
and executions_delta > 0
and elapsed_time_delta > 0
and ss.begin_interval_time > sysdate-&&days_ago
)
group by sql_id, period_flag
)
)
)
group by sql_id, stddev_etime
)
where norm_stddev > nvl(to_number('&min_stddev'),2)
and max_etime > nvl(to_number('&min_etime'),.1)
)
where result like nvl('&Faster_Slower',result)
order by norm_stddev
/

prompt Plan Changed

/* I-AM-YUNQU-BUILTIN-SQL */
select sql_id,
       round(max(elapsed_time/decode(executions,0,1,executions))/min(elapsed_time/decode(executions,0,1,executions))) DIFF,
      min(inst_id) INST_ID
from
  gv$sql
where elapsed_time > 0 
  and parsing_schema_name not in ('SYS', 'YUNQU')
group by sql_id
having count(distinct plan_hash_value) > 1
   and round(max(elapsed_time/decode(executions,0,1,executions))/min(elapsed_time/decode(executions,0,1,executions))) > 100;
