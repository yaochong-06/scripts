with t1 as(
select time_dp , 24*60*60*(time_dp - lag(time_dp) over (order by time_dp)) timediff,
  scn - lag(scn) over(order by time_dp) scndiff
from smon_scn_time
)
select time_dp , timediff, scndiff,
       trunc(scndiff/timediff) rate_per_sec
from t1
order by 1
/

col first_change# format 99999999999999999999
col next_change# format 99999999999999999999
select  thread#,  first_time, next_time, first_change# ,next_change#, sequence#,
   next_change#-first_change# diff, round ((next_change#-first_change#)/(next_time-first_time)/24/60/60) rt
from (
select thread#, first_time, first_change#,next_time,  next_change#, sequence#,dest_id from v$archived_log
where next_time > sysdate-30 and dest_id=1
order by next_time
)
where first_time != next_time
order by  first_time, thread#
/

