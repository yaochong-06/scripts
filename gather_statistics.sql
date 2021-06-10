set linesize 3000
alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
create table gather_stat_log(id number,owner varchar2(32),table_name varchar2(32),percent number,degree number,gmt_create date,log_type varchar2(10),content varchar2(100));
alter table gather_stat_log add constraint pk_gather_stat_log primary key(id);
create index i_gather_stat_log_gc_tn on gather_stat_log(gmt_create,table_name);
create sequence seq_gather_stat_log MINVALUE 1 MAXVALUE 999999999999999 INCREMENT BY 1 START WITH 1 CACHE 20 NOORDER  NOCYCLE;


create or replace procedure gather_statistics as
v_err varchar2(100);
  CURSOR STALE_TABLE IS
    SELECT OWNER,
           SEGMENT_NAME,
           CASE
             WHEN SIZE_GB < 0.5 THEN
              30
             WHEN SIZE_GB >= 0.5 AND SIZE_GB < 1 THEN
              20
             WHEN SIZE_GB >= 1 AND SIZE_GB < 5 THEN
              10
             WHEN SIZE_GB >= 5 AND SIZE_GB < 10 THEN
              5
             WHEN SIZE_GB >= 10 THEN
              1
           END AS PERCENT,
           8 AS DEGREE
      FROM (SELECT OWNER,
                   SEGMENT_NAME,
                   SUM(BYTES / 1024 / 1024 / 1024) SIZE_GB
              FROM DBA_SEGMENTS a
             WHERE (owner,SEGMENT_NAME) IN
                   (SELECT /*+ UNNEST */
                    DISTINCT owner,TABLE_NAME
                      FROM DBA_TAB_STATISTICS
                     WHERE (LAST_ANALYZED IS NULL OR STALE_STATS = 'YES')
                       AND OWNER not in('SYSTEM',
                       'WMSYS',
                       'XDB',
                       'SYS',
                       'SCOTT',
                       'QMONITOR',
                       'OUTLN',
                       'ORDSYS',
                       'ORDDATA',
                       'OJVMSYS',
                       'MDSYS',
                       'LBACSYS',
                       'DVSYS',
                       'DBSNMP','APEX_040200','AUDSYS','CTXSYS','APEX_030200','EXFSYS','OLAPSYS','SYSMAN','WH_SYNC','GSMADMIN_INTERNAL')
                       and stattype_locked is null
                       and table_name not like 'SYS%' and table_name not like 'SCH%' and table_name not like 'BIN%')
               and not exists
             (select null
                      from dba_tables b
                     where b.iot_type = 'IOT_OVERFLOW'
                       and a.segment_name = b.table_name)
             GROUP BY OWNER, SEGMENT_NAME);
BEGIN
  DBMS_STATS.FLUSH_DATABASE_MONITORING_INFO;
  FOR STALE IN STALE_TABLE LOOP
  begin
    DBMS_STATS.GATHER_TABLE_STATS(OWNNAME          => STALE.OWNER,
                                  TABNAME          => STALE.SEGMENT_NAME,
                                  ESTIMATE_PERCENT => STALE.PERCENT,
                                  METHOD_OPT       => 'for all columns size repeat',
                                  DEGREE           => 8,
                                  CASCADE          => TRUE);
    insert into gather_stat_log(id,owner,table_name,percent,degree,gmt_create,log_type) values(seq_gather_stat_log.nextval,STALE.OWNER,STALE.SEGMENT_NAME,STALE.PERCENT,8,sysdate,'info');
    commit;
    exception
        when others then
        v_err:=substr(SQLERRM,1,80);
        insert into gather_stat_log(id,owner,table_name,percent,degree,gmt_create,log_type,content)values(seq_gather_stat_log.nextval,STALE.OWNER,STALE.SEGMENT_NAME,STALE.PERCENT,8,sysdate,'error',v_err);
        commit;
    end;
  END LOOP;
END;
/
 BEGIN
  DBMS_SCHEDULER.CREATE_JOB(JOB_NAME        => 'GATHER_STATIC_JOB',
                            JOB_TYPE        => 'STORED_PROCEDURE',
                            JOB_ACTION      => 'GATHER_STATISTICS',
                            START_DATE      => to_date('2019-11-04 00:10:00','yyyy-mm-dd hh24:mi:ss'),
                            REPEAT_INTERVAL => 'FREQ=WEEKLY',
                            AUTO_DROP       => FALSE,
                            COMMENTS        => 'GATHER STATISTICS');
END;
/

begin 
	DBMS_SCHEDULER.ENABLE('GATHER_STATIC_JOB'); 
end;
/
--查询下次执行时间
col enabled for a10
col job_name for a17
col start_date for a20
col end_date for a20
col last_start_date for a20
col NEXT_RUN_DATE for a20
select JOB_NAME,
to_char(LAST_START_DATE,'yyyy-mm-dd hh24:mi:ss') as last_start_date,
to_char(NEXT_RUN_DATE,'yyyy-mm-dd hh24:mi:ss') as NEXT_RUN_DATE,
to_char(START_DATE,'yyyy-mm-dd hh24:mi:ss') as start_date,
to_char(END_DATE,'yyyy-mm-dd hh24:mi:ss') as end_date,
ENABLED 
from dba_scheduler_jobs where job_name like '%GATHER_STATIC_JOB%';

prompt table statistics are locked

select owner,table_name,stattype_locked
from dba_tab_statistics
where owner not in ('SYSTEM','OWBSYS','FLOWS_FILES','WMSYS','XDB','SYS','SCOTT','QMONITOR','OUTLN','ORDSYS','ORDDATA','OJVMSYS','MDSYS','LBACSYS','DVSYS',
                    'DBSNMP','APPQOSSYS','APEX_040200','AUDSYS','CTXSYS','APEX_030200','EXFSYS','OLAPSYS','SYSMAN','WH_SYNC','GSMADMIN_INTERNAL')
and stattype_locked is not null 
/

prompt gather extended statistics

select DBMS_STATS.REPORT_COL_USAGE(user, 'T_GAME_XYDC') from dual;
begin
    DBMS_STATS.SEED_COL_USAGE(null, null, 300);
end;
/
select dbms_stats.create_extended_stats(user,'T_GAME_XYDC') from dual;
begin
    dbms_stats.gather_table_stats(user,'T_GAME_XYDC',method_opt=>'for all hidden columns size 1024');
end;
/

select dbms_stats.create_extended_stats('BANK','FBBALANCE','(HDATE,BANKID)') from dual;
begin
    dbms_stats.gather_table_stats('BANK','FBBALANCE',method_opt=>'for all hidden columns size 254');
end;
/
