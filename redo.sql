--redo generation amount per hour and per second.Similar with myredo.sql but more accurate.
col TIME2 for a16
col MB for a12
col MBPS for a12
alter session set nls_date_format='yyyymmdd hh24:mi';




select * from (
select a.instance_number,to_char(sn.BEGIN_INTERVAL_TIME,'yyyymmdd hh24:mi') Time, round((a.value-lag(value) over (order by a.snap_id))/1000000,2) "DB_TIME(s)"
FROM dba_hist_snapshot sn, dba_hist_sys_time_model a
where
   a.stat_name='DB time' and a.instance_number=1 and sn.instance_number=1 and a.snap_id(+)=sn.snap_id
union all
select a.instance_number,to_char(sn.BEGIN_INTERVAL_TIME,'yyyymmdd hh24:mi') Time,round((a.value-lag(value) over (order by a.snap_id))/1000000,2) "DB_TIME(s)"
FROM dba_hist_snapshot sn, dba_hist_sys_time_model a
where
a.stat_name='DB time' and a.instance_number=2 and sn.instance_number=2 and a.snap_id(+)=sn.snap_id
union all
select a.instance_number,to_char(sn.BEGIN_INTERVAL_TIME,'yyyymmdd hh24:mi') Time, round((a.value-lag(value) over (order by a.snap_id))/1000000,2) "DB_TIME(s)"
FROM dba_hist_snapshot sn,dba_hist_sys_time_model a
where
a.stat_name='DB time' and a.instance_number=3 and sn.instance_number=3 and a.snap_id(+)=sn.snap_id
) order by instance_number,Time;


SELECT TIME2,MB,MBPS FROM
(select 
        decode(grouping(time1),1,'all',time1) as time1,decode(grouping(time2),1,time1 || ' total: ',time2) as time2,
        to_char(trunc(SUM(MB)/1024 / 1024,2)) || '    '  AS MB,
        decode(GROUPING(TIME2),1,NULL,round(SUM(MBPS) / 1024 / 1024 / 3600,2)) AS MBPS FROM(
            select to_char(FIRST_TIME,'yyyymmdd') as time1 ,to_char(FIRST_TIME,'yyyymmdd-hh24') as time2,
                   BLOCKS * BLOCK_SIZE as MB,
                   BLOCKS * BLOCK_SIZE as MBPS 
            from v$archived_log where dest_id = 1
                                  and FIRST_TIME >= sysdate - 7) 
GROUP BY ROLLUP(TIME1,TIME2)) 
WHERE TIME1 <> 'all'
/


set linesize 500
COL MEMBER FOR A60
COL FIRST_CHANGE# FOR 9999999999999999
COL NEXT_CHANGE# FOR 9999999999999999
col "REDO_SIZE" for a9
SELECT	V1.GROUP#, 
	V1.THREAD#,
	SEQUENCE#,
	FIRST_CHANGE#,
	NEXT_CHANGE#,
	V1.STATUS,
	V1.ARCHIVED,
	lpad(round(V1.BYTES/1024/1024) || 'M',9) as "REDO_SIZE",
	MEMBER
FROM V$LOG V1, V$LOGFILE V2
WHERE V1.GROUP# = V2.GROUP#
ORDER BY 1,2;

col "DATE" for a20
select a.f_time "DATE",
       a.thread#,
       ceil(sum(a.blocks * a.block_size) / 1024 / 1024 / 1024) "ARCHIVELOGS PER DAY(G)",
       ceil(sum(a.blocks * a.block_size) / 1024 / 1024 / 24) "ARCHIVELOGS PER HOUR(M)"
  from (select distinct sequence#,
                        thread#,
                        blocks,
                        block_size,
                        to_char(first_time, 'yyyy/mm/dd') f_time
          from v$archived_log) a
 group by a.f_time, a.thread#
 order by 1;
