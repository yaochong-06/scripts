--
-- Script: qeps.sql
--
-- Script to report the explain plan for the most expensive N SQL statements -- based on user specified criteria:
--
--    buffer_gets     - 1
--    CPU time        - 2
--    disk_reads      - 3
--    rows_processed  - 4
--    executions      - 5
--    parse calls     - 6
--    Buffers/Exec    - 7
--    Cost per row    - 8    
--
-- Usage: start qeps.sql
--
-- This scripts requires qep.sql in order to function.
-- See Oracle Metalink Note: 550578.1 for more detail.
--
SET ECHO OFF
PROMPT
PROMPT Starting QEPS.SQL
PROMPT
PROMPT NOTES: 
PROMPT
PROMPT The database parameter statistics_level should be set to ALL
PROMPT to obtain full statistics in the plan output.
PROMPT
PROMPT Script only works with Oracle 9.2 and above
PROMPT
PROMPT Script must be run from a database account with access to:
PROMPT
PROMPT .    gv$sql_plan
PROMPT .    gv$sqltext_with_newlines
PROMPT .    gv$sql_plan_statistics_all
PROMPT     
PROMPT Requires the partner script qep.sql
PROMPT     
SET HEAD OFF 
SET SERVEROUT OFF 
SET FEEDBACK OFF
SET VERIFY OFF
SET TIMING OFF
SET PAUSE OFF
SET PAGESIZE 0
prompt  Available Expense Criteria:
prompt
prompt  buffer_gets     - 1
prompt  CPU time        - 2
prompt  disk_reads      - 3
prompt  rows_processed  - 4
prompt  executions      - 5
prompt  parse calls     - 6
prompt  Buffers/Exec    - 7
prompt  Cost per row    - 8
prompt
accept  sec_opt prompt "Please select required expense criteria [7]: "

accept top_n prompt 'Please enter the number of SQL Statements to report [5]: ' 

SET TERMOUT OFF

SPOOL gen_plans.sql

SELECT  /* QWEKLOIPYRTJHH7 */ 
       'define instid='      ||'''' || inst_id      ||'''' || CHR(10) ||
       'define hash_value='  ||'''' || hash_value   ||'''' || CHR(10) ||
       'define address='     ||'''' || address      ||'''' || CHR(10) ||
       'define child_number='||'''' || child_number ||'''' || CHR(10) ||
       'start qep'
FROM
    (SELECT inst_id, hash_value, child_number, address, buffer_gets 
       FROM gv$sql
      WHERE sql_text NOT LIKE '%QWEKLOIPYRTJHH7%'
        AND (UPPER(sql_text) like 'SELECT%'
             OR UPPER(sql_text) like 'UPDATE%'
             OR UPPER(sql_text) like 'DELETE%'
             OR UPPER(sql_text) like 'INSERT%')
      ORDER BY 
              DECODE('&sec_opt',
                          NULL,
                          buffer_gets / decode(greatest(rows_processed,executions),0,1, 
                                               greatest(rows_processed,executions)),
                          1, buffer_gets,
                          2, cpu_time,
                          3, disk_reads,
                          4, rows_processed,
                          5, executions,
                          6, parse_calls,
                          7, buffer_gets / decode(executions,0,1, executions),
                          8, buffer_gets / decode(greatest(rows_processed,executions),0,1,
                                                  greatest(rows_processed,executions))) DESC )
WHERE rownum < DECODE(TO_NUMBER('&&top_n'),NULL, 6, &&top_n + 1)
/
SPOOL OFF
SET HEAD ON PAGESIZE 66 
--
-- Setup Sort Opt descr for main report
--
BREAK ON SORTOPT
COLUMN SORTOPT NEW_VALUE SORTOPT_VAR
SELECT  /* QWEKLOIPYRTJHH7 */ 
       decode(NVL('&sec_opt',7)
                      ,1,'Buffer Gets',
                       2,'CPU time',
                       3,'Disk Reads',
                       4,'Rows Processed',
                       5,'Executions',
                       6,'Parse Calls',
                       7,'Buffers/Exec',
                       8,'Cost per Row') SORTOPT
FROM DUAL;
CLEAR BREAKS


COLUMN instance_name NEW_VALUE instance
SELECT instance_name 
  FROM v$instance;

COLUMN file_date NEW_VALUE file_date_var
SELECT  /* QWEKLOIPYRTJHH7 */ 
        TO_CHAR(SYSDATE, 'YYYYMMDD_HH24MISS') ||'.txt' file_date
FROM DUAL;


COLUMN SYSDATE new_value today
SELECT  /* QWEKLOIPYRTJHH7 */ 
        To_Char(SYSDATE,'mm/dd/yyyy') "sysdate" FROM DUAL
/

SPOOL qeps_&instance._&file_date_var
TTITLE left today skip 2 center 'Top &&top_n Performing SQL Statements for Database Instance &&instance by &&sortopt_var ' skip 2


SET TERMOUT ON
start gen_plans
spool 
spool off
