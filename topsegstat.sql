col segstat_statistic_name head STATISTIC_NAME for a35

with stats_sum as ( select statistic_name, sum(value) sum_value from v$segment_statistics where lower(statistic_name) like lower('%&1%') group by statistic_name)
SELECT * FROM (
  SELECT
        owner,
        object_name,
        object_type,
        a.statistic_name segstat_statistic_name,
        value,
        value/sum_value*100 perc
  FROM
        v$segment_statistics a, stats_sum b
  WHERE
        lower(a.statistic_name) LIKE lower('%&1%')
        and a.statistic_name = b.statistic_name
   order by value desc
)
WHERE rownum <= 11
/
