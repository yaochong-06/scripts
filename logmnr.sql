--step 0 stop archvie log rman backup
--step 1: enable min supplemental log data

ALTER DATABASE ADD SUPPLEMENTAL LOG DATA;

SELECT SUPPLEMENTAL_LOG_DATA_MIN FROM V$DATABASE;
--step 2.1: add the oldest archive log files in +DG_CS2PRD_ARCH/CS2PRD
execute dbms_logmnr.add_logfile(logfilename=>'+DISKGROUP1/cs2dbqa5/onlinelog/group_3a.rdo');
execute dbms_logmnr.add_logfile(logfilename=>'+DISKGROUP1/cs2dbqa5/onlinelog/group_4a.rdo');
execute dbms_logmnr.add_logfile(logfilename=>'+DISKGROUP1/cs2dbqa5/onlinelog/group_1a.rdo');
execute dbms_logmnr.add_logfile(logfilename=>'/home/u02/app/oracle/product/11.1.0/oradata/cs10g/redo01.log');
execute dbms_logmnr.add_logfile(logfilename=>'/home/u02/app/oracle/product/11.1.0/oradata/cs10g/redo03.log');

-- step 2.2 using the DICT_FROM_ONLINE_CATALOG
EXECUTE DBMS_LOGMNR.START_LOGMNR(options=>dbms_logmnr.DICT_FROM_ONLINE_CATALOG);

--step 3. special for online redo log, using the CONTINUOUS_MINE option to direct logmnr automatically add the log file
ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-mm-dd HH24:MI:SS';
BEGIN
   DBMS_LOGMNR.START_LOGMNR(
   STARTTIME => '2011-5-6 18:00:00',
   ENDTIME => '2011-5-6 19:30:00',
   OPTIONS => DBMS_LOGMNR.DICT_FROM_ONLINE_CATALOG + DBMS_LOGMNR.CONTINUOUS_MINE);
END;
/

--step 4.1 check the oldest archived log files and its first_time
select name,first_time,COMPLETION_TIME from v$archived_log where first_time > sysdate-1 order by 2
/

--step 4.2 confirm which log files are loaded
select * from v$logmnr_logs order by LOW_TIME;


--Scenario 1: Using LogMiner to Track Changes Made by a Specific User

SELECT username, count(*) FROM V$LOGMNR_CONTENTS group by username order by count(*);

--Scenario 2: Using LogMiner to Calculate Table Access Statistics

SELECT SEG_OWNER, SEG_NAME, COUNT(*) AS Hits FROM
        V$LOGMNR_CONTENTS WHERE SEG_NAME NOT LIKE '%$' 
        GROUP BY SEG_OWNER, SEG_NAME ORDER BY Hits DESC;

--Scenario 3: Using LogMiner to track which sql run most by the specific user
select distinct username, sql_redo, count(*) from v$LOGMNR_CONTENTS where username like '&1' group by username, sql_redo order by 3
/

--Scenario 4: scn, timestamp, sql_redo
col scn for 999999999999999
col session_info for A100
select username,session_info,scn, timestamp, sql_redo from v$logmnr_contents where operation='DDL' and upper(sql_redo) like '%USER$%' order by 2;

--find the delete from obj$ to find the data object id of the dropped object
select scn, timestamp, sql_redo from v$logmnr_contents where timestamp = to_timestamp('2011-04-11 00:00:00','yyyy-mm-dd hh24:mi:ss') order by 1;
