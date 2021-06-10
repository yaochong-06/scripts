set linesize 600
select * from v$sga_dynamic_components;
select * from v$sgainfo;
col sgares_parameter head PARAMETER for a30
col sgares_component head COMPONENT for a30

SELECT
    component		sgares_component
  , oper_type
  , oper_mode
  , parameter		sgares_parameter
  , initial_size
  , target_size
  , final_size
  , status
  , to_char(start_time,'yyyy-mm-dd hh24:mi:ss')
  , to_char(end_time,'yyyy-mm-dd hh24:mi:ss')
FROM
	v$sga_resize_ops
ORDER BY
	start_time
/
col BEGIN_INTERVAL_TIME for A22
col END_INTERVAL_TIME for A22
col name for A20
SELECT
	to_char(A.BEGIN_INTERVAL_TIME,'yyyy-mm-dd hh24:mi:ss') BEGIN_INTERVAL_TIME
  , to_char(A.END_INTERVAL_TIME,'yyyy-mm-dd hh24:mi:ss') END_INTERVAL_TIME
  , name
  , B.BYTES  
FROM WRM$_SNAPSHOT A, DBA_HIST_SGASTAT B  
WHERE A.SNAP_ID = B.SNAP_ID  
and (lower(name) like lower('%&1%') 
	or lower(pool) like lower('%&1%'))
ORDER BY 1; 
REM  Investigate trends in the SGA
REM   It is safe to run this query as often as you like.
REM   
REM   You can change "and bytes > 10000000" higher
REM    or lower to fit your needs.  10.2.x redesigned
REM    the v$sgastat view and it will contain hundreds
REM    of rows and it is usually not necessary to see
REM    them all.

set lines 100
set pages 9999
col mb format 999,999
col name heading "Name"

spool allocations.out

select to_char(sysdate, 'dd-MON-yyyy hh24:mi:ss') "Script Run TimeStamp" from dual;

select to_char(startup_time, 'dd-MON-yyyy hh24:mi:ss') "Startup Time" from v$instance;

select name, round((bytes/1024/1024),0) MB 
from v$sgastat where pool='shared pool' 
and bytes > 1000
order by bytes desc
/

spool off
clear breaks

--------------------------------------------------------------------------------
--
-- File name:   sgastatx
-- Purpose:     Show shared pool stats by sub-pool from X$KSMSS
--
-- Author:      Tanel Poder
-- Copyright:   (c) http://www.tanelpoder.com
--              
-- Usage:       @sgastatx <statistic name>
-- 	        @sgastatx "free memory"
--	        @sgastatx cursor
--
-- Other:       The other script for querying V$SGASTAT is called sgastat.sql
--              
--              
--
--------------------------------------------------------------------------------

COL subpool HEAD SUBPOOL FOR a30

PROMPT
PROMPT -- All allocations:

SELECT
    'shared pool ('||NVL(DECODE(TO_CHAR(ksmdsidx),'0','0 - Unused',ksmdsidx), 'Total')||'):'  subpool
  , SUM(ksmsslen) bytes
  , ROUND(SUM(ksmsslen)/1048576,2) MB
FROM 
    x$ksmss
WHERE
    ksmsslen > 0
--AND ksmdsidx > 0 
GROUP BY ROLLUP
   ( ksmdsidx )
ORDER BY
    subpool ASC
/

BREAK ON subpool SKIP 1
PROMPT -- Allocations matching "&1":

SELECT 
    subpool
  , name
  , SUM(bytes)                  
  , ROUND(SUM(bytes)/1048576,2) MB
FROM (
    SELECT
        'shared pool ('||DECODE(TO_CHAR(ksmdsidx),'0','0 - Unused',ksmdsidx)||'):'      subpool
      , ksmssnam      name
      , ksmsslen      bytes
    FROM 
        x$ksmss
    WHERE
        ksmsslen > 0
    AND LOWER(ksmssnam) LIKE LOWER('%&1%')
)
GROUP BY
    subpool
  , name
ORDER BY
    subpool    ASC
  , SUM(bytes) DESC
/

BREAK ON subpool DUP
