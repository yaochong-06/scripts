set linesize 500
set serveroutput on
set feedback off
set verify off


set linesize 500
set serveroutput on
set feedback off
set verify off
declare
    v_cnt number;

    cursor c_tbs is SELECT a.tablespace_name,
       lpad(round((total-free) / maxsize * 100, 1) || '%',9) as used_pct,
       rpad(lpad('#',ceil((nvl(total-free,0)/b.maxsize)*20),'#'),20,' ') as used,
       b.autoextensible,
       round(total/1024,1) as TOTAL_GB,
       round((total - free)/1024,1) as USED_GB,
       round(free/1024,1) as FREE_GB,
       b.cnt DATAFILE_COUNT,
       c.status,
       c.CONTENTS,
       c.extent_management,
       c.allocation_type,
       b.maxsize
FROM   (SELECT tablespace_name,
               round(SUM(bytes) / ( 1024 * 1024 ), 1) free
        FROM   dba_free_space
        GROUP BY tablespace_name) a,
       (SELECT tablespace_name,
               round(SUM(bytes) / ( 1024 * 1024 ), 1) total,
               count(*)                               cnt,
               max(autoextensible)                  autoextensible,
               sum(decode(autoextensible, 'YES', floor(maxbytes/1048576), floor(bytes / 1048576 ))) maxsize
        FROM   dba_data_files
        GROUP  BY tablespace_name) b,
       dba_tablespaces c
WHERE  a.tablespace_name = b.tablespace_name
       AND a.tablespace_name = c.tablespace_name
UNION ALL
SELECT /*+ NO_MERGE */ 
  a.tablespace_name,
        lpad(round(100 * (b.tot_used_mb / a.maxsize ),1) || '%',9) as used_pct,
        rpad(lpad('#',ceil((nvl(b.tot_used_mb+0.001,0)/a.maxsize)*20),'#'),20,' ') as used,
        a.aet as autoextensible,
        round(a.avail_size_mb/1024,1) as TOTAL_GB,
        round(b.tot_used_mb/1024,1) as USED_GB,
        round((a.avail_size_mb - b.tot_used_mb)/1024,1) as FREE_GB,
        a.cnt DATAFILE_COUNT,
        c.status,
        c.CONTENTS,
        c.extent_management,
        c.allocation_type,
        a.maxsize
FROM   (SELECT tablespace_name,
               sum(bytes)/1024/1024 as avail_size_mb,
               max(autoextensible)       aet,
               count(*)                  cnt,
               sum(decode(autoextensible, 'YES', floor(maxbytes/1048576), floor(bytes/1048576))) maxsize
        FROM   dba_temp_files
        GROUP  BY tablespace_name) A,
       (SELECT tablespace_name,
               SUM(bytes_used) /1024/1024 as tot_used_mb
        FROM   gv$temp_extent_pool
        GROUP  BY tablespace_name) B,
       dba_tablespaces c
WHERE  a.tablespace_name = b.tablespace_name
       AND a.tablespace_name = c.tablespace_name    
order by 2 desc;
     v_tbs c_tbs%rowtype;

     cursor c_tmp is SELECT C.SQL_ID,
       A.USERNAME,
       A.SID||','||A.SERIAL# as sid_and_serial,
       A.OSUSER,
       A.MACHINE,
       A.LAST_CALL_ET as elapse_time,
       B.TABLESPACE as TABLESPACE_NAME,
       (B.BLOCKS * (select value from v$parameter where name='db_block_size')/1024/1024) as USED_MB,
       C.SQL_TEXT
  FROM V$SESSION A, V$TEMPSEG_USAGE B, V$SQLAREA C
 WHERE A.SADDR = B.SESSION_ADDR
   AND C.ADDRESS = A.SQL_ADDRESS
   AND C.HASH_VALUE = A.SQL_HASH_VALUE
order by b.blocks;
     v_tmp c_tmp%rowtype;

    cursor c_pga is select /*+ ordered leading(d) */ 
    c.sql_id,
    a.username,
    a.sid||','||a.serial# as sid_and_serial,
    a.machine,
    a.LAST_CALL_ET as elapse_time,
    to_char(a.logon_time,'yyyymmdd hh24:mi:ss') as LOGON_TIME,
    round(d.PGA_USED_MEM / 1024 / 1024,2) as PGA_USED_MB,
    c.sql_text
    from v$process d,v$session a,v$sqlarea c
    where a.sql_id = c.sql_id
    and a.paddr = d.addr
    and d.PGA_USED_MEM >= 1024 * 1024 * 10
    order by d.PGA_USED_MEM; 
    v_pga c_pga%rowtype;

     cursor c_recovery is SELECT name as recovery_dest,
decode(space_limit,0,0,(space_used - SPACE_RECLAIMABLE) / space_limit * 100) as used_pct
FROM v$recovery_file_dest;
     v_recovery c_recovery%rowtype;

begin

  dbms_output.put_line('
Tablespace Used Information');
  dbms_output.put_line('======================');
  dbms_output.put_line('------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  dbms_output.put_line('| TABLESPACE_NAME     |' || ' Used_Pct% ' || '|                 Used |' || ' AUTOEXTEND ' || '| TOTAL_GB |' || ' USED_GB ' || '| FREE_GB |' || ' FILE_CNT ' || '| STATUS |' || '  CONTENTS ' || '| EXTENT_MANAGE |' || ' MAXSIZE(MB) ' || '|'); 
  dbms_output.put_line('------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  open c_tbs;
    loop fetch c_tbs into v_tbs;
    exit when c_tbs%notfound;
    dbms_output.put_line('| ' || rpad(v_tbs.TABLESPACE_NAME,19) ||' | '|| lpad(v_tbs.used_pct,9) || ' | '|| rpad(v_tbs.used,20) || ' | '|| lpad(v_tbs.autoextensible,10) || ' | '|| lpad(v_tbs.TOTAL_GB,8) || ' | '|| lpad(v_tbs.USED_GB,7) || ' | '|| lpad(v_tbs.FREE_GB,7) || ' | '|| lpad(v_tbs.DATAFILE_COUNT,8) || ' | '|| lpad(v_tbs.STATUS,6) || ' | '|| lpad(v_tbs.CONTENTS,9) || ' | '||lpad(v_tbs.extent_management,13) ||' | ' || lpad(v_tbs.maxsize,12) || '|');
    end loop;
    dbms_output.put_line('------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  close c_tbs;


  dbms_output.put_line('
Current Usage Information of Temp Tablespace Per Session');
  dbms_output.put_line('======================');
  dbms_output.put_line('------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  dbms_output.put_line('| SQL_ID        |'  || ' USERNAME     |' || ' sid_and_serial# ' || '|      MACHINE |' || ' ELAPSE_TIME(S) |'|| ' TABLESPACE_NAME ' || '| USED_MB |' || '                                          SQL_TEXT ' || '|'); 
  dbms_output.put_line('------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  open c_tmp;
    loop fetch c_tmp into v_tmp;
    exit when c_tmp%notfound;
    dbms_output.put_line('| ' || lpad(v_tmp.SQL_ID,13) || ' | '||rpad(v_tmp.USERNAME,12) ||' | '|| lpad(v_tmp.sid_and_serial,15) || ' | '|| lpad(v_tmp.MACHINE,12) || ' | '|| lpad(v_tmp.elapse_time,14) || ' | ' ||lpad(v_tmp.TABLESPACE_NAME,15) || ' | '|| lpad(v_tmp.USED_MB,7) || ' | '|| rpad(v_tmp.SQL_TEXT,50)  || '|');
    end loop;
    dbms_output.put_line('------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  close c_tmp;
  

  dbms_output.put_line('
Current Usage Information of PGA Memory(>10M) Per Session');
  dbms_output.put_line('======================');
  dbms_output.put_line('------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  dbms_output.put_line('| SQL_ID        |'  || ' USERNAME     |' || ' sid_and_serial# ' || '|      MACHINE |' || ' ELAPSE_TIME(S) |'|| '        LOGON_TIME ' || '| PGA_USED_MB |' || '                                          SQL_TEXT ' || '|'); 
  dbms_output.put_line('------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  open c_pga;
    loop fetch c_pga into v_pga;
    exit when c_pga%notfound;
    dbms_output.put_line('| ' || lpad(v_pga.SQL_ID,13) || ' | '||rpad(v_pga.USERNAME,12) ||' | '|| lpad(v_pga.sid_and_serial,15) || ' | '|| lpad(v_pga.MACHINE,12) || ' | '|| lpad(v_pga.elapse_time,14) || ' | ' ||lpad(v_pga.LOGON_TIME,17) || ' | '|| lpad(v_pga.PGA_USED_MB,11) || ' | '|| rpad(v_pga.SQL_TEXT,50)  || '|');
    end loop;
    dbms_output.put_line('------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  close c_pga;


  dbms_output.put_line('
Fast Recovery Dest Information');
  dbms_output.put_line('======================');
  dbms_output.put_line('------------------------------------------------------------------------------------------------------------');
  dbms_output.put_line('| RECOVERY_DEST                                                                                |' || ' Used_Pct% ' || '|'); 
  dbms_output.put_line('------------------------------------------------------------------------------------------------------------');
  open c_recovery;
    loop fetch c_recovery into v_recovery;
    exit when c_recovery%notfound;
    dbms_output.put_line('| ' || rpad(v_recovery.recovery_dest,92) ||' | '|| lpad(v_recovery.used_pct,10) || '|');
    end loop;
    dbms_output.put_line('------------------------------------------------------------------------------------------------------------');
  close c_recovery;
end;
/










declare
  v_cnt number;
  cursor c_group is SELECT
    GROUP_NUMBER,
    NAME as DISKGROUP_NAME,
    lpad(round(ALLOCATION_UNIT_SIZE/1024/1024) || 'M',7) as "AU_SIZE",
    STATE,
    TYPE,
    round(TOTAL_MB/1024) as TOTAL_GB,
    round(FREE_MB/1024) as FREE_GB,
    lpad(round((TOTAL_MB-FREE_MB)/TOTAL_MB*100) || '%',9) as Used_Pct,
    round(USABLE_FILE_MB/1024) as "USABLE_FILE_GB" ,
    REQUIRED_MIRROR_FREE_MB
from
    V$ASM_DISKGROUP;
  v_group c_group%rowtype;
  cursor c_disk is select b.GROUP_NUMBER as GROUP_NUMBER,
  b.name as DISKGROUP_NAME,
  a.path,
  a.FAILGROUP,a.name as DISK_NAME,a.STATE,a.MODE_STATUS,a.HEADER_STATUS,a.MOUNT_STATUS,a.REPAIR_TIMER
from v$asm_disk a,v$asm_diskgroup b where a.GROUP_NUMBER = b.GROUP_NUMBER order by b.GROUP_NUMBER,a.path;
  v_disk c_disk%rowtype;

  cursor c_client is select GROUP_NUMBER,INSTANCE_NAME,DB_NAME,STATUS,SOFTWARE_VERSION,COMPATIBLE_VERSION from v$asm_client order by GROUP_NUMBER;
  v_client c_client%rowtype;
  
begin
  select count(*) into v_cnt from v$ASM_DISKGROUP;
if v_cnt = 0 then
  dbms_output.put_line('
ASM Diskgroup is not currently in Use...');
  dbms_output.put_line('======================');
else
  dbms_output.put_line('
ASM Diskgroup Information');
  dbms_output.put_line('======================');
  dbms_output.put_line('----------------------------------------------------------------------------------------------------------------------------------------------');
  dbms_output.put_line('| GROUP_NUMBER |' || ' DISKGROUP_NAME ' || '| AU_SIZE |' || '     STATE ' || '|   TYPE |' || ' TOTAL_GB ' || '| FREE_GB |' || ' "Used_Pct%" ' || '| USABLE_FILE_GB |' || ' REQUIRED_MIRROR_FREE_MB ' || '|'); 
  dbms_output.put_line('----------------------------------------------------------------------------------------------------------------------------------------------');
  open c_group;
    loop fetch c_group into v_group;
    exit when c_group%notfound;
    dbms_output.put_line('| ' || rpad(v_group.GROUP_NUMBER,12) ||' | '|| rpad(v_group.DISKGROUP_NAME,14) || ' | '|| lpad(v_group.AU_SIZE,7) || ' | '|| lpad(v_group.STATE,9) || ' | '|| lpad(v_group.TYPE,6) || ' | '|| lpad(v_group.TOTAL_GB,8) || ' | '|| lpad(v_group.FREE_GB,7) || ' | '|| lpad(v_group.Used_Pct,11) || ' | '|| lpad(v_group.USABLE_FILE_GB,14) || ' | '|| lpad(v_group.REQUIRED_MIRROR_FREE_MB,24) || '|');
    end loop;
    dbms_output.put_line('----------------------------------------------------------------------------------------------------------------------------------------------');
  close c_group;
  dbms_output.put_line('
ASM Disk Information');
  dbms_output.put_line('======================');
  dbms_output.put_line('----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  dbms_output.put_line('| GROUP_NUMBER |' || ' DISKGROUP_NAME ' || '|                                            PATH |' || '      FAILGROUP ' || '|      DISK_NAME |' || '   STATE ' || '| MODE_STATS |' || ' HEADER_STATS ' || '| MOUNT_STATS |' || ' REPAIR_TIMER ' || '|'); 
  dbms_output.put_line('----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  open c_disk;
    loop fetch c_disk into v_disk;
    exit when c_disk%notfound;
    dbms_output.put_line('| ' || rpad(v_disk.GROUP_NUMBER,12) ||' | '|| rpad(v_disk.DISKGROUP_NAME,14) || ' | '|| lpad(v_disk.path,47) || ' | '|| lpad(v_disk.FAILGROUP,14) || ' | '|| lpad(v_disk.DISK_NAME,14) || ' | '|| lpad(v_disk.STATE,7) || ' | '|| lpad(v_disk.MODE_STATUS,10) || ' | '|| lpad(v_disk.HEADER_STATUS,12) || ' | '|| lpad(v_disk.MOUNT_STATUS,11) || ' | '|| lpad(v_disk.REPAIR_TIMER,13) || '|');
    end loop;
    dbms_output.put_line('----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  close c_disk;

dbms_output.put_line('
ASM Client Information');
  dbms_output.put_line('======================');
  dbms_output.put_line('-------------------------------------------------------------------------------------------------');
  dbms_output.put_line('| GROUP_NUMBER |' || ' INSTANCE_NAME ' || '|  DB_NAME |' || '      STATUS |' || ' SOFTWARE_VERSION ' || '| COMPATIBLE_VERSION ' || '|'); 
  dbms_output.put_line('-------------------------------------------------------------------------------------------------');
  open c_client;
    loop fetch c_client into v_client;
    exit when c_client%notfound;
    dbms_output.put_line('| ' || rpad(v_client.GROUP_NUMBER,12) ||' | '|| lpad(v_client.INSTANCE_NAME,13) || ' | '|| lpad(v_client.DB_NAME,8) || ' | '|| lpad(v_client.STATUS,11) || ' | '|| lpad(v_client.SOFTWARE_VERSION,16) || ' | '|| lpad(v_client.COMPATIBLE_VERSION,19) || '|');
    end loop;
    dbms_output.put_line('-------------------------------------------------------------------------------------------------');
  close c_client;
  end if;
end;
/




prompt asm_rebalance_file

SELECT
    file_num,
    MAX(extent_count) max_disk_extents,
    MIN(extent_count) min_disk_extents,
    MAX(extent_count) - MIN(extent_count) disk_extents_imbalance
FROM (
    SELECT
    number_kffxp file_num,
    disk_kffxp disk_num,
    COUNT(xnum_kffxp) extent_count
    FROM
        x$kffxp
    WHERE
        group_kffxp = 1
        AND disk_kffxp != 65534
        GROUP BY number_kffxp, disk_kffxp
        ORDER BY number_kffxp, disk_kffxp)
GROUP BY file_num
HAVING MAX(extent_count) - MIN(extent_count) > 5
ORDER BY disk_extents_imbalance DESC;


