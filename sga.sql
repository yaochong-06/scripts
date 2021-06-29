set linesize 600
col COMPONENT for a35
select COMPONENT,
round(CURRENT_SIZE/1024/1024/1024,2) as CURRENT_G,
round(MIN_SIZE/1024/1024/1024,2) MIN_G,
round(MAX_SIZE/1024/1024/1024,2) as MAX_G,
round(USER_SPECIFIED_SIZE/1024/1024/1024,2) as USER_SPECIFIED_G,
OPER_COUNT,
LAST_OPER_TYPE,
LAST_OPER_MODE,
LAST_OPER_TIME,
round(GRANULE_SIZE/1024/1024) as GRANULE_SIZE_M
from v$sga_dynamic_components;
select * from v$sgainfo;
col sgares_parameter head PARAMETER for a30
col sgares_component head COMPONENT for a30

SELECT
    component		sgares_component
  , oper_type
  , oper_mode
  , parameter		sgares_parameter
  , round(initial_size/1024/1024/1024,2) as initial_gb
  , round(target_size/1024/1024/1024,2) as target_gb
  , round(final_size/1024/1024/1024,2) as final_gb
  , status
  , to_char(start_time,'yyyymmdd hh24:mi:ss') as start_time
  , to_char(end_time,'yyyymmdd hh24:mi:ss') as end_time
FROM
	v$sga_resize_ops
ORDER BY
	start_time
/

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
    SELECT 'shared pool ('||DECODE(TO_CHAR(ksmdsidx),'0','0 - Unused',ksmdsidx)||'):'      subpool
      , ksmssnam      name
      , ksmsslen      bytes
    FROM  x$ksmss WHERE ksmsslen > 0
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
