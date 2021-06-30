
set linesize 3000
SELECT NAME,
       ROUND(TOTAL,2) TOTAL_MB,
       ROUND(TOTAL - FREE, 2) USED_MB,
       ROUND(FREE, 2) FREE_MB,
       ROUND((TOTAL - FREE) / TOTAL * 100, 2) "pct_used%"
  FROM (SELECT 'SGA' NAME,
               (SELECT SUM(VALUE / 1024 / 1024) FROM V$SGA) TOTAL,
               (SELECT SUM(BYTES / 1024 / 1024)
                  FROM V$SGASTAT
                 WHERE NAME = 'free memory') FREE
          FROM DUAL)
UNION
SELECT NAME,
       ROUND(TOTAL,2) TOTAL_MB,
       ROUND(USED, 2) USED_MB,
       ROUND(TOTAL - USED, 2) FREE_MB,
       ROUND(USED / TOTAL * 100, 2) "pct_used%"
  FROM (SELECT 'PGA' NAME,
               (SELECT VALUE / 1024 / 1024 TOTAL
                  FROM V$PGASTAT
                 WHERE NAME = 'aggregate PGA target parameter') TOTAL,
               (SELECT VALUE / 1024 / 1024 USED
                  FROM V$PGASTAT
                 WHERE NAME = 'total PGA allocated') USED
          FROM DUAL)
UNION
SELECT NAME,
       ROUND(TOTAL, 2) TOTAL_MB,
       ROUND((TOTAL - FREE), 2) USED_MB,
       ROUND(FREE, 2) FREE_MB,
       ROUND((TOTAL - FREE) / TOTAL * 100, 2) "pct_used%"
  FROM (SELECT 'Shared pool' NAME,
               (SELECT SUM(BYTES / 1024 / 1024)
                  FROM V$SGASTAT
                 WHERE POOL = 'shared pool') TOTAL,
               (SELECT BYTES / 1024 / 1024
                  FROM V$SGASTAT
                 WHERE NAME = 'free memory'
                   AND POOL = 'shared pool') FREE
          FROM DUAL)
UNION
SELECT NAME,
       ROUND(TOTAL, 2) TOTAL_MB,
       ROUND(TOTAL - FREE, 2) USED_MB,
       ROUND(FREE, 2) FREE_MB,
       ROUND((TOTAL - FREE) / TOTAL, 2) "pct_used%"
  FROM (SELECT 'Default pool' NAME,
               (SELECT A.CNUM_REPL *
                       (SELECT VALUE
                          FROM V$PARAMETER
                         WHERE NAME = 'db_block_size') / 1024 / 1024 TOTAL
                  FROM X$KCBWDS A, V$BUFFER_POOL P
                 WHERE A.SET_ID = P.LO_SETID
                   AND P.NAME = 'DEFAULT'
                   AND P.BLOCK_SIZE =
                       (SELECT VALUE
                          FROM V$PARAMETER
                         WHERE NAME = 'db_block_size')) TOTAL,
               (SELECT A.ANUM_REPL *
                       (SELECT VALUE
                          FROM V$PARAMETER
                         WHERE NAME = 'db_block_size') / 1024 / 1024 FREE
                  FROM X$KCBWDS A, V$BUFFER_POOL P
                 WHERE A.SET_ID = P.LO_SETID
                   AND P.NAME = 'DEFAULT'
                   AND P.BLOCK_SIZE =
                       (SELECT VALUE
                          FROM V$PARAMETER
                         WHERE NAME = 'db_block_size')) FREE
          FROM DUAL)
UNION
SELECT NAME,
       NVL(ROUND(TOTAL, 2), 0) TOTAL_MB,
       NVL(ROUND(TOTAL - FREE, 2), 0) USED_MB,
       NVL(ROUND(FREE, 2), 0) FREE_MB,
       NVL(ROUND((TOTAL - FREE) / TOTAL, 2), 0) "pct_used%"
  FROM (SELECT 'KEEP pool' NAME,
               (SELECT A.CNUM_REPL *
                       (SELECT VALUE
                          FROM V$PARAMETER
                         WHERE NAME = 'db_block_size') / 1024 / 1024 TOTAL
                  FROM X$KCBWDS A, V$BUFFER_POOL P
                 WHERE A.SET_ID = P.LO_SETID
                   AND P.NAME = 'KEEP'
                   AND P.BLOCK_SIZE =
                       (SELECT VALUE
                          FROM V$PARAMETER
                         WHERE NAME = 'db_block_size')) TOTAL,
               (SELECT A.ANUM_REPL *
                       (SELECT VALUE
                          FROM V$PARAMETER
                         WHERE NAME = 'db_block_size') / 1024 / 1024 FREE
                  FROM X$KCBWDS A, V$BUFFER_POOL P
                 WHERE A.SET_ID = P.LO_SETID
                   AND P.NAME = 'KEEP'
                   AND P.BLOCK_SIZE =
                       (SELECT VALUE
                          FROM V$PARAMETER
                         WHERE NAME = 'db_block_size')) FREE
          FROM DUAL)
UNION
SELECT NAME,
       NVL(ROUND(TOTAL, 2), 0) TOTAL_MB,
       NVL(ROUND(TOTAL - FREE, 2), 0) USED_MB,
       NVL(ROUND(FREE, 2), 0) FREE_MB,
       NVL(ROUND((TOTAL - FREE) / TOTAL, 2), 0) "pct_used%"
  FROM (SELECT 'RECYCLE pool' NAME,
               (SELECT A.CNUM_REPL *
                       (SELECT VALUE
                          FROM V$PARAMETER
                         WHERE NAME = 'db_block_size') / 1024 / 1024 TOTAL
                  FROM X$KCBWDS A, V$BUFFER_POOL P
                 WHERE A.SET_ID = P.LO_SETID
                   AND P.NAME = 'RECYCLE'
                   AND P.BLOCK_SIZE =
                       (SELECT VALUE
                          FROM V$PARAMETER
                         WHERE NAME = 'db_block_size')) TOTAL,
               (SELECT A.ANUM_REPL *
                       (SELECT VALUE
                          FROM V$PARAMETER
                         WHERE NAME = 'db_block_size') / 1024 / 1024 FREE
                  FROM X$KCBWDS A, V$BUFFER_POOL P
                 WHERE A.SET_ID = P.LO_SETID
                   AND P.NAME = 'RECYCLE'
                   AND P.BLOCK_SIZE =
                       (SELECT VALUE
                          FROM V$PARAMETER
                         WHERE NAME = 'db_block_size')) FREE
          FROM DUAL)
UNION
SELECT NAME,
       NVL(ROUND(TOTAL, 2), 0) TOTAL_MB,
       NVL(ROUND(TOTAL - FREE, 2), 0) USED_MB,
       NVL(ROUND(FREE, 2), 0) FREE_MB,
       NVL(ROUND((TOTAL - FREE) / TOTAL, 2), 0) "pct_used%"
  FROM (SELECT 'DEFAULT 16K buffer cache' NAME,
               (SELECT A.CNUM_REPL * 16 / 1024 TOTAL
                  FROM X$KCBWDS A, V$BUFFER_POOL P
                 WHERE A.SET_ID = P.LO_SETID
                   AND P.NAME = 'DEFAULT'
                   AND P.BLOCK_SIZE = 16384) TOTAL,
               (SELECT A.ANUM_REPL * 16 / 1024 FREE
                  FROM X$KCBWDS A, V$BUFFER_POOL P
                 WHERE A.SET_ID = P.LO_SETID
                   AND P.NAME = 'DEFAULT'
                   AND P.BLOCK_SIZE = 16384) FREE
          FROM DUAL)
UNION
SELECT NAME,
       NVL(ROUND(TOTAL, 2), 0) TOTAL_MB,
       NVL(ROUND(TOTAL - FREE, 2), 0) USED_MB,
       NVL(ROUND(FREE, 2), 0) FREE_MB,
       NVL(ROUND((TOTAL - FREE) / TOTAL, 2), 0) "pct_used%"
  FROM (SELECT 'DEFAULT 32K buffer cache' NAME,
               (SELECT A.CNUM_REPL * 32 / 1024 TOTAL
                  FROM X$KCBWDS A, V$BUFFER_POOL P
                 WHERE A.SET_ID = P.LO_SETID
                   AND P.NAME = 'DEFAULT'
                   AND P.BLOCK_SIZE = 32768) TOTAL,
               (SELECT A.ANUM_REPL * 32 / 1024 FREE
                  FROM X$KCBWDS A, V$BUFFER_POOL P
                 WHERE A.SET_ID = P.LO_SETID
                   AND P.NAME = 'DEFAULT'
                   AND P.BLOCK_SIZE = 32768) FREE
          FROM DUAL)
UNION
SELECT NAME,
       TOTAL as TOTAL_MB,
       TOTAL - FREE USED_MB,
       FREE as FREE_MB,
       (TOTAL - FREE) / TOTAL * 100 "pct_used%"
  FROM (SELECT 'Java Pool' NAME,
               (SELECT SUM(BYTES / 1024 / 1024) TOTAL
                  FROM V$SGASTAT
                 WHERE POOL = 'java pool'
                 GROUP BY POOL) TOTAL,
               (SELECT BYTES / 1024 / 1024 FREE
                  FROM V$SGASTAT
                 WHERE POOL = 'java pool'
                   AND NAME = 'free memory') FREE
          FROM DUAL)
UNION
SELECT NAME,
       ROUND(TOTAL, 2) as TOTAL_MB,
       ROUND(TOTAL - FREE, 2) USED_MB,
       ROUND(FREE, 2) FREE_MB,
       ROUND((TOTAL - FREE) / TOTAL * 100, 2) "pct_used%"
  FROM (SELECT 'Large Pool' NAME,
               (SELECT SUM(BYTES / 1024 / 1024) TOTAL
                  FROM V$SGASTAT
                 WHERE POOL = 'large pool'
                 GROUP BY POOL) TOTAL,
               (SELECT BYTES / 1024 / 1024 FREE
                  FROM V$SGASTAT
                 WHERE POOL = 'large pool'
                   AND NAME = 'free memory') FREE
          FROM DUAL)
 ORDER BY "pct_used%" DESC;
 

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

PROMPT Show shared pool stats by sub-pool from X$KSMSS
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
PROMPT -- Allocations matching "&ksmssnam":

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
    AND LOWER(ksmssnam) LIKE LOWER('%&ksmssnam%')
)
GROUP BY
    subpool
  , name
ORDER BY
    subpool    ASC
  , SUM(bytes) DESC
/

BREAK ON subpool DUP
