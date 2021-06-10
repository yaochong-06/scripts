export PATH=$ORACLE_HOME/bin:$PATH
#if too many sqls(max=50) finished in $interval seconds and create sql monitor report time is greater than $interval,you should increase the interval value
#sql begin with /* can not be captured,because can't create file name with *
#execute every $interval seconds
interval=60
#get elapsed time longger than $min_run_time seconds
min_run_time=10

mkdir -p sqlmon

cd sqlmon

while true ; do
btime=`date +%s`

cur_time=`date '+%Y%m%d%H%M'`

sqlplus -s / as sysdba << ! | awk '{if($1!="TOP" && length($0)>0 && $1 != "----") print $1,$2,$3,$4,$5,$6,$7,$8,$9;}' | tee ${cur_time}_sqlmon.tmp
set lines 2000
set verify off
set timing off
set pages 50000
set heading off
set feedback off
set trimspool on
spool ${cur_time}_sqlmon.lst
col sql_text format a50 trunc
col username format a15 trunc
select to_char(rownum,'000') top,a.*
from (select sql_id,lpad(round((LAST_REFRESH_TIME-SQL_EXEC_START)*24*3600),5,'0'),
             sql_exec_id,to_char(sql_exec_start,'YYYYMMDDHH24MISS') sql_exec_start,
             sql_plan_hash_value,inst_id,username,sql_text
             from Gv\$sql_Monitor 
       where (LAST_REFRESH_TIME-SQL_EXEC_START)*24*3600>${min_run_time}
       and sql_plan_hash_value >0
       and status like 'DONE%'
       and LAST_REFRESH_TIME>=sysdate  -  $interval/3600/24
       and LAST_REFRESH_TIME<=sysdate
       and sql_text is not null
       order by elapsed_time desc
      ) a where rownum<=50;  
spool off
!

echo "query sql_id for monitor report finished!"

while read num sql_id elap_t sql_exec_id sql_exec_start sql_plan_hash_value inst_id username sql_text
do

  htm_name=${elap_t}s_${sql_id}_${sql_exec_start}_inst_${inst_id}_${username}_${sql_text}.html
  echo get monitor report for top $num SQL_ID:$sql_id output:$htm_name
  sqlplus -s / as sysdba << ! >/dev/null
  set echo off
  set linesize 2000
  set heading off
  set pages 0
  set long 20000000
  set longchunksize 20000000
  set timing off
  set feedback off
  set trimspool on
  spool ${htm_name}
    select dbms_sqltune.report_sql_monitor(sql_id=>'${sql_id}', sql_exec_id=>'${sql_exec_id}', sql_exec_start=>to_date('${sql_exec_start}','YYYYMMDDHH24MISS'), type=>'ACTIVE') Monitor_report from dual;
  spool off
!

done < ${cur_time}_sqlmon.tmp

rm ${cur_time}_sqlmon.tmp
rm ${cur_time}_sqlmon.lst

echo "Get all monitor report finished!"


 etime=`date +%s`
 lefttime=$(($interval-$etime+$btime))
 #echo $lefttime
 sleep $lefttime;
done
