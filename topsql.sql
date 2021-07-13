set linesize 1000
set pages 1000
col username for a30
col FIRST_LOAD_TIME for a25
SELECT * FROM (SELECT 
 A.PARSING_SCHEMA_NAME as username,
 A.SQL_ID,
 A.PLAN_HASH_VALUE AS PLAN_HASH_VALUE,
 ROUND(A.BUFFER_GETS / EXECUTIONS) AS LOGICAL_READ,
 A.BUFFER_GETS,
 A.EXECUTIONS,
 (round(to_number(a.last_active_time-to_date(a.FIRST_LOAD_TIME,'yyyy-mm-dd/hh24:mi:ss')),0)+ 1) AS last_day,
  round(a.EXECUTIONS / (round(to_number(a.last_active_time-to_date(a.FIRST_LOAD_TIME,'yyyy-mm-dd/hh24:mi:ss')),0)+ 1)) AS exe_per_day,
-- A.SQL_FULLTEXT AS SQL,
 A.FIRST_LOAD_TIME,
 A.LAST_LOAD_TIME,
 A.LAST_ACTIVE_TIME
  FROM V$SQLAREA A,
       (SELECT DISTINCT SQL_ID, SQL_PLAN_HASH_VALUE
          FROM V$ACTIVE_SESSION_HISTORY
         WHERE SAMPLE_TIME > &BEGIN_SAMPLE_TIME
           AND SAMPLE_TIME <  SYSDATE) B
 WHERE A.SQL_ID = B.SQL_ID
   AND A.PLAN_HASH_VALUE = B.SQL_PLAN_HASH_VALUE
   AND A.BUFFER_GETS > 10000 
   AND round(a.EXECUTIONS / (round(to_number(a.last_active_time-to_date(a.FIRST_LOAD_TIME,'yyyy-mm-dd/hh24:mi:ss')),0)+ 1)) > 1 
   AND ROUND(A.BUFFER_GETS / EXECUTIONS) > &PER_BUFFER_GETS
 ORDER BY ROUND(A.BUFFER_GETS / EXECUTIONS) DESC, 
	  round(a.EXECUTIONS / (round(to_number(a.last_active_time-to_date(a.FIRST_LOAD_TIME,'yyyy-mm-dd/hh24:mi:ss')),0)+ 1)) DESC
) WHERE EXE_PER_DAY > 24 * 6;

/*检查数据库中逻辑读，物理读过高的SQL */ 

col start_time for a30
SELECT sql_id,round(buff_exec) * exec_times gets_total,round( buff_exec ) gets_exec,round(disk_exec) disk_exec,exec_times,start_time,end_time FROM
(
SELECT
	sql_id,
	avg( buffer_gets_exec ) buff_exec,
	avg( disk_reads_exec ) disk_exec,
	sum( executions_total ) exec_times,
	min( begin_interval_time ) start_time,
	max( begin_interval_time ) end_time 
FROM
	(
	SELECT
		begin_interval_time,
		sql_id,
		buffer_gets_total,
		disk_reads_total,
		executions_total,
		round(
		buffer_gets_total / nvl( executions_total, 1 )) buffer_gets_exec,
		round(
		disk_reads_total / nvl( executions_total, 1 )) disk_reads_exec 
	FROM
		dba_hist_sqlstat s,
		dba_hist_snapshot n 
	WHERE
		s.snap_id = n.snap_id 
		AND executions_total > 0 
		AND parsing_schema_name NOT IN (
			'ANONYMOUS','APEX_030200','APEX_040000','APEX_SSO',
			'APPQOSSYS','CTXSYS','DBSNMP','DIP','EXFSYS','FLOWS_FILES',
			'MDSYS','OLAPSYS','ORACLE_OCM','ORDDATA','ORDPLUGINS',
			'ORDSYS','OUTLN','OWBSYS','SI_INFORMTN_SCHEMA','SQLTXADMIN',
			'SQLTXPLAIN','SYS','SYSMAN','SYSTEM','TRCANLZR','WMSYS','XDB',
			'XS$NULL','PERFSTAT',
			'STDBYPERF') 
		AND ( round( buffer_gets_total / nvl( executions_total, 1 ) ) > 99999 OR round( disk_reads_total / nvl( executions_total, 1 )) > 9999 ) 
			AND executions_total > 9 
		) 
	GROUP BY
	sql_id 
	);
