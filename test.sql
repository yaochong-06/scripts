
set serveroutput on 
set verify off
set timing off
set linesize 500
set pages 0

undefine table_name
undefine owner
var table_name varchar2(100);
var owner varchar2(100);

begin
  :owner :=upper('&owner');
  :table_name := upper('&table_name');
end;
/

--alter session set nls_date_format='yyyy-mm-dd hh24:mi:ss';
declare
    cursor c_sga is SELECT NAME,
       ROUND(TOTAL,2) TOTAL_MB,
       ROUND(TOTAL - FREE, 2) USED_MB,
       ROUND(FREE, 2) FREE_MB,
       ROUND((TOTAL - FREE) / TOTAL * 100, 2) pct_used
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
       ROUND(USED / TOTAL * 100, 2) pct_used
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
       ROUND((TOTAL - FREE) / TOTAL * 100, 2) pct_used
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
       ROUND((TOTAL - FREE) / TOTAL * 100, 2) pct_used
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
       NVL(ROUND((TOTAL - FREE) / TOTAL, 2), 0) pct_used
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
       NVL(ROUND((TOTAL - FREE) / TOTAL, 2), 0) pct_used
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
       NVL(ROUND((TOTAL - FREE) / TOTAL, 2), 0) pct_used
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
       NVL(ROUND((TOTAL - FREE) / TOTAL, 2), 0) pct_used
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
       (TOTAL - FREE) / TOTAL * 100 pct_used
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
       ROUND((TOTAL - FREE) / TOTAL * 100, 2) pct_used
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
 ORDER BY pct_used DESC;
    v_sga c_sga%rowtype;

    cursor c_com is select COMPONENT,
round(CURRENT_SIZE/1024/1024/1024,2) as CURRENT_G,
round(MIN_SIZE/1024/1024/1024,2) MIN_G,
round(MAX_SIZE/1024/1024/1024,2) as MAX_G,
round(USER_SPECIFIED_SIZE/1024/1024/1024,2) as USER_SPECIFIED_G,
OPER_COUNT,
LAST_OPER_TYPE,
decode(LAST_OPER_MODE,null,'None',LAST_OPER_MODE) as LAST_OPER_MODE,
decode(LAST_OPER_TIME,null,'None',LAST_OPER_TIME) as LAST_OPER_TIME,
round(GRANULE_SIZE/1024/1024) as GRANULE_SIZE_M
from v$sga_dynamic_components;
   v_com c_com%rowtype;

    cursor c_sub is SELECT
     'shared pool ('||NVL(DECODE(TO_CHAR(ksmdsidx),'0','0 - Unused',ksmdsidx), 'Total')||'):'  subpool
    , SUM(ksmsslen) bytes
    , ROUND(SUM(ksmsslen)/1048576,2) MB FROM x$ksmss WHERE ksmsslen > 0
   GROUP BY ROLLUP (ksmdsidx) ORDER BY
    subpool ASC;
    v_sub c_sub%rowtype;

    cursor c_subcom is select * from (
  SELECT 'shared pool ('||DECODE(TO_CHAR(ksmdsidx),'0','0 - Unused',ksmdsidx)||'):' subpool, 
    ksmssnam as name, 
    round(ksmsslen/1024/1024,2)  as MB,
    round(100 * ksmsslen/sum(ksmsslen) over(partition by ksmdsidx),2) as pct,
    rank() over(partition by ksmdsidx order by ksmsslen desc) as rank
  FROM  x$ksmss WHERE ksmsslen > 0
  ) where rank < 21;
    v_subcom c_subcom%rowtype;

begin

  dbms_output.put_line('
SGA and PGA Usage Size and Pct)');
  dbms_output.put_line('======================');
  dbms_output.put_line('-------------------------------------------------------------------------------------------------');
  dbms_output.put_line('| NAME                          |' || ' TOTAL_MB       ' || '| USED_MB        |' || ' FREE_MB         ' || '| PCT_USED%'|| ' |');
  dbms_output.put_line('-------------------------------------------------------------------------------------------------');
  open c_sga;
    loop fetch c_sga into v_sga;
    exit when c_sga%notfound;
    dbms_output.put_line('| ' || rpad(v_sga.NAME,29) ||' | '|| lpad(v_sga.TOTAL_MB,14) || ' | '|| lpad(v_sga.USED_MB,14) || ' | '|| lpad(v_sga.FREE_MB,15) || ' | '|| lpad(v_sga.pct_used,9) || ' |');
    end loop;
    dbms_output.put_line('-------------------------------------------------------------------------------------------------');
  close c_sga;


    dbms_output.put_line('
SGA components Information from v$sga_dynamic_components');
  dbms_output.put_line('======================');
  dbms_output.put_line('-----------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  dbms_output.put_line('| COMPONENT                 |' || ' CURRENT_GB ' || '| MIN_GB |' || ' MAX_GB ' || '| USER_SPECIFIED_GB |' || ' OPER_COUNT ' || '| LAST_OPER_TYPE |' || ' LAST_OPER_MODE '  || '| LAST_OPER_TIME      |'|| ' GRANULE_SIZE_MB '|| '|');
  dbms_output.put_line('-----------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  open c_com;
    loop fetch c_com into v_com;
    exit when c_com%notfound;
    dbms_output.put_line('| ' || rpad(v_com.COMPONENT,25) ||' | '|| lpad(v_com.CURRENT_G,10) || ' | '|| lpad(v_com.MIN_G,6) || ' | '|| lpad(v_com.MAX_G,6) || ' | '|| lpad(v_com.USER_SPECIFIED_G,17) || ' | '|| lpad(v_com.OPER_COUNT,10) ||  ' | '|| rpad(v_com.LAST_OPER_TYPE,14) || ' | '|| rpad(v_com.LAST_OPER_MODE,14) || ' | '|| rpad(v_com.LAST_OPER_TIME,19) || ' | '|| lpad(v_com.GRANULE_SIZE_M,15)||' |');
    end loop;
    dbms_output.put_line('-----------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  close c_com;


  dbms_output.put_line('
Shared Pool Sub Pool Size Information');
  dbms_output.put_line('======================');
  dbms_output.put_line('---------------------------------------------------------------');
  dbms_output.put_line('| SUBPOOL                |' || ' SUBPOOL_BYTES         ' || '| SUBPOOL_MB ' || '|');
  dbms_output.put_line('---------------------------------------------------------------');
  open c_sub;
    loop fetch c_sub into v_sub;
    exit when c_sub%notfound;
    dbms_output.put_line('| ' || rpad(v_sub.subpool,22) ||' | '|| lpad(v_sub.bytes,21) || ' | '|| lpad(v_sub.MB,10) || ' |');
    end loop;
    dbms_output.put_line('---------------------------------------------------------------');
  close c_sub;

  dbms_output.put_line('
Shared Pool Sub Pool components Detail Information');
  dbms_output.put_line('======================');
  dbms_output.put_line('-------------------------------------------------------------------------------------------------------');
  dbms_output.put_line('| RANK |' || ' SUBPOOL                |' || ' COMPONENT_NAME                     ' || '| CURRENT_SIZE_MB |' || ' CURRENT_PCT% ' || '|');
  dbms_output.put_line('-------------------------------------------------------------------------------------------------------');
  open c_subcom;
    loop fetch c_subcom into v_subcom;
    exit when c_subcom%notfound;
    dbms_output.put_line('| ' || lpad(v_subcom.RANK,4)|| ' | ' || rpad(v_subcom.SUBPOOL,22) ||' | '|| rpad(v_subcom.NAME,34) || ' | '|| lpad(v_subcom.MB || ' M',15) || ' | '|| lpad(v_subcom.pct || '%',12) || ' |');
    end loop;
    dbms_output.put_line('-------------------------------------------------------------------------------------------------------');
  close c_subcom;

end;
/

