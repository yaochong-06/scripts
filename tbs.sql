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
       round((total-free) / maxsize * 100, 1) || '%' as used_pct,
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
        round(100 * (b.tot_used_mb / a.maxsize ),1) || '%' as used_pct,
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
    

    v_pga_cnt number;
    v_tmp_cnt number;
 
    cursor c_recovery is SELECT decode(name,null,'None',name) as recovery_dest,
decode(space_limit,0,0,(space_used - SPACE_RECLAIMABLE) / space_limit * 100) as used_pct
FROM v$recovery_file_dest;
     v_recovery c_recovery%rowtype;

    cursor c_big_tab is select OWNER,SEGMENT_NAME,SIZE_MB,PARTITION_NAME from (select owner,nvl2(PARTITION_NAME,SEGMENT_NAME||'.'||PARTITION_NAME,SEGMENT_NAME) SEGMENT_NAME ,trunc(bytes/1024/1024) as SIZE_MB,decode(PARTITION_NAME,null,'None',PARTITION_NAME) as PARTITION_NAME
    from dba_segments where segment_type like 'TABLE%' and owner  not in ('OWBSYS','FLOWS_FILES','WMSYS','XDB','QMONITOR','OUTLN',
                            'ORDSYS','ORDDATA','OJVMSYS','MDSYS','LBACSYS','DVSYS','DBSNMP','APPQOSSYS','APEX_040200','AUDSYS',
                            'CTXSYS','APEX_030200','EXFSYS','OLAPSYS','SYSMAN','WH_SYNC','GSMADMIN_INTERNAL') order by bytes desc)
    where  rownum < 21;
    v_big_tab c_big_tab%rowtype;


    cursor c_big_lob is select OWNER,TABLE_NAME,COLUMN_NAME,SEGMENT_NAME,SIZE_MB from
    (select a.owner,b.table_name,b.column_name,a.SEGMENT_NAME ,trunc(a.bytes/1024/1024) as SIZE_MB from dba_segments a,dba_lobs b
    where a.segment_type like 'LOB%' and a.owner not in ('OWBSYS','FLOWS_FILES','WMSYS','XDB','QMONITOR','OUTLN',
                               'ORDSYS','ORDDATA','OJVMSYS','MDSYS','LBACSYS','DVSYS','DBSNMP','APPQOSSYS','APEX_040200','AUDSYS',
                               'CTXSYS','APEX_030200','EXFSYS','OLAPSYS','SYSMAN','WH_SYNC','GSMADMIN_INTERNAL') and a.SEGMENT_NAME=b.SEGMENT_NAME order by a.bytes desc) where  rownum < 11;
    v_big_lob c_big_lob%rowtype;

begin

  dbms_output.enable(buffer_size => NULL);
  dbms_output.put_line('
FCNT Means DATAFILE_CNT
Used% Means PCT_USED%
AUTO? Means AUTOEXTEND
MANAGE? Means EXTENT_MANAGEMENT
Tablespace Used Information');
  dbms_output.put_line('======================');
  dbms_output.put_line('-------------------------------------------------------------------------------------------------------------------------------------------------');
  dbms_output.put_line('| TABLESPACE_NAME     |' || ' Used% ' || '|                 Used |' || ' AUTO? ' || '| TOTAL_GB |' || ' USED_GB ' || '| FREE_GB |' || ' FCNT ' || '| STATUS |' || '  CONTENTS ' || '| MANAGE? |' || ' MAXSIZE(MB) ' || '|'); 
  dbms_output.put_line('-------------------------------------------------------------------------------------------------------------------------------------------------');
  open c_tbs;
    loop fetch c_tbs into v_tbs;
    exit when c_tbs%notfound;
    dbms_output.put_line('| ' || rpad(v_tbs.TABLESPACE_NAME,19) ||' | '|| lpad(v_tbs.used_pct,5) || ' | '|| rpad(v_tbs.used,20) || ' | '|| lpad(v_tbs.autoextensible,5) || ' | '|| lpad(v_tbs.TOTAL_GB,8) || ' | '|| lpad(v_tbs.USED_GB,7) || ' | '|| lpad(v_tbs.FREE_GB,7) || ' | '|| lpad(v_tbs.DATAFILE_COUNT,4) || ' | '|| lpad(v_tbs.STATUS,6) || ' | '|| lpad(v_tbs.CONTENTS,9) || ' | '||lpad(v_tbs.extent_management,7) ||' | ' || lpad(v_tbs.maxsize,12) || '|');
    end loop;
    dbms_output.put_line('-------------------------------------------------------------------------------------------------------------------------------------------------');
  close c_tbs;
  
  select count(*) into v_tmp_cnt FROM V$SESSION A, V$TEMPSEG_USAGE B, V$SQLAREA C
 WHERE A.SADDR = B.SESSION_ADDR
   AND C.ADDRESS = A.SQL_ADDRESS
   AND C.HASH_VALUE = A.SQL_HASH_VALUE
order by b.blocks;
  if v_tmp_cnt > 0 then 
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
  else 
  dbms_output.put_line('
There is no Session that Use Temp Tablespace Disk Space');
  dbms_output.put_line('======================');
  end if;  

 select count(*) into v_pga_cnt
 from v$process d,v$session a,v$sqlarea c
    where a.sql_id = c.sql_id
    and a.paddr = d.addr
    and d.PGA_USED_MEM >= 1024 * 1024 * 10
    order by d.PGA_USED_MEM;
  if v_pga_cnt > 0 then 
 
  dbms_output.put_line('
Current Usage Information of PGA Memory(>10M) Per Session');
  dbms_output.put_line('======================');
  dbms_output.put_line('--------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  dbms_output.put_line('| SQL_ID        |'  || ' USERNAME     |' || ' sid_and_serial# ' || '|      MACHINE |' || ' ELAPSE_TIME(S) |'|| '        LOGON_TIME ' || '| PGA_USED_MB |' || '                                      SQL_TEXT ' || '|'); 
  dbms_output.put_line('--------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  open c_pga;
    loop fetch c_pga into v_pga;
    exit when c_pga%notfound;
    dbms_output.put_line('| ' || lpad(v_pga.SQL_ID,13) || ' | '||rpad(v_pga.USERNAME,12) ||' | '|| lpad(v_pga.sid_and_serial,15) || ' | '|| lpad(v_pga.MACHINE,12) || ' | '|| lpad(v_pga.elapse_time,14) || ' | ' ||lpad(v_pga.LOGON_TIME,17) || ' | '|| lpad(v_pga.PGA_USED_MB,11) || ' | '|| rpad(v_pga.SQL_TEXT,46)  || '|');
    end loop;
    dbms_output.put_line('--------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  close c_pga;
  else 
  dbms_output.put_line('
There is no Session that PGA Memory Usage > 10M for Per Session');
  dbms_output.put_line('======================');
  end if;


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

  dbms_output.put_line('
Top 20 Big Table Information in The Database');
  dbms_output.put_line('======================');
  dbms_output.put_line('----------------------------------------------------------------------------------------------------');
  dbms_output.put_line('| OWNER            |' || ' SEGMENT_NAME                     ' || '|   SIZE(MB) ' || '| PARTITION_NAME                ' ||'|');
  dbms_output.put_line('----------------------------------------------------------------------------------------------------');
  open c_big_tab;
    loop fetch c_big_tab into v_big_tab;
    exit when c_big_tab%notfound;
    dbms_output.put_line('| ' || rpad(v_big_tab.OWNER,16) ||' | '|| rpad(v_big_tab.SEGMENT_NAME,32) || ' | '|| lpad(v_big_tab.SIZE_MB,10) || ' | ' || rpad(v_big_tab.PARTITION_NAME,30)|| '|');
    end loop;
    dbms_output.put_line('----------------------------------------------------------------------------------------------------');
  close c_big_tab;


  dbms_output.put_line('
Top 20 Big LOB Information in The Database (When Migrating Database,<purge dba_recyclebin;> can purge unnecessary LOB)');
  dbms_output.put_line('======================');
  dbms_output.put_line('-------------------------------------------------------------------------------------------------------------------');
  dbms_output.put_line('| OWNER            |' || ' TABLE_NAME                ' || '| COLUMN_NAME          |' || ' SEGMENT_NAME                   ' || '| SIZE(MB) ' || '|');
  dbms_output.put_line('-------------------------------------------------------------------------------------------------------------------');
  open c_big_lob;
    loop fetch c_big_lob into v_big_lob;
    exit when c_big_lob%notfound;
    dbms_output.put_line('| ' || rpad(v_big_lob.OWNER,16) ||' | '|| rpad(v_big_lob.TABLE_NAME,25) || ' | '|| rpad(v_big_lob.COLUMN_NAME,20) ||  ' | '|| rpad(v_big_lob.SEGMENT_NAME,30) ||  ' | '|| lpad(v_big_lob.SIZE_MB,9) ||'|');
    end loop;
    dbms_output.put_line('-------------------------------------------------------------------------------------------------------------------');
  close c_big_lob;

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
ASM Diskgroup is not in Useage');
  dbms_output.put_line('======================');
else
  dbms_output.put_line('
ASM Diskgroup Information');
  dbms_output.put_line('======================');
  dbms_output.put_line('----------------------------------------------------------------------------------------------------------------------------------------');
  dbms_output.put_line('| GROUP# |' || ' DISKGROUP_NAME ' || '| AU_SIZE |' || '     STATE ' || '|   TYPE |' || ' TOTAL_GB ' || '| FREE_GB |' || ' "Used_Pct%" ' || '| USABLE_FILE_GB |' || ' REQUIRED_MIRROR_FREE_MB ' || '|'); 
  dbms_output.put_line('----------------------------------------------------------------------------------------------------------------------------------------');
  open c_group;
    loop fetch c_group into v_group;
    exit when c_group%notfound;
    dbms_output.put_line('| ' || rpad(v_group.GROUP_NUMBER,6) ||' | '|| rpad(v_group.DISKGROUP_NAME,14) || ' | '|| lpad(v_group.AU_SIZE,7) || ' | '|| lpad(v_group.STATE,9) || ' | '|| lpad(v_group.TYPE,6) || ' | '|| lpad(v_group.TOTAL_GB,8) || ' | '|| lpad(v_group.FREE_GB,7) || ' | '|| lpad(v_group.Used_Pct,11) || ' | '|| lpad(v_group.USABLE_FILE_GB,14) || ' | '|| lpad(v_group.REQUIRED_MIRROR_FREE_MB,24) || '|');
    end loop;
    dbms_output.put_line('----------------------------------------------------------------------------------------------------------------------------------------');
  close c_group;
  dbms_output.put_line('
ASM Disk Information');
  dbms_output.put_line('======================');
  dbms_output.put_line('----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  dbms_output.put_line('| GROUP# |' || ' DISKGROUP_NAME ' || '|                                            PATH |' || '      FAILGROUP ' || '|      DISK_NAME |' || '   STATE ' || '| MODE_STATS |' || ' HEADER_STATS ' || '| MOUNT_STATS |' || ' REPAIR_TIMER ' || '|'); 
  dbms_output.put_line('----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  open c_disk;
    loop fetch c_disk into v_disk;
    exit when c_disk%notfound;
    dbms_output.put_line('| ' || rpad(v_disk.GROUP_NUMBER,6) ||' | '|| rpad(v_disk.DISKGROUP_NAME,14) || ' | '|| lpad(v_disk.path,47) || ' | '|| lpad(v_disk.FAILGROUP,14) || ' | '|| lpad(v_disk.DISK_NAME,14) || ' | '|| lpad(v_disk.STATE,7) || ' | '|| lpad(v_disk.MODE_STATUS,10) || ' | '|| lpad(v_disk.HEADER_STATUS,12) || ' | '|| lpad(v_disk.MOUNT_STATUS,11) || ' | '|| lpad(v_disk.REPAIR_TIMER,13) || '|');
    end loop;
    dbms_output.put_line('----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  close c_disk;

dbms_output.put_line('
ASM Client Information');
  dbms_output.put_line('======================');
  dbms_output.put_line('-------------------------------------------------------------------------------------------');
  dbms_output.put_line('| GROUP# |' || ' INSTANCE_NAME ' || '|  DB_NAME |' || '      STATUS |' || ' SOFTWARE_VERSION ' || '| COMPATIBLE_VERSION ' || '|'); 
  dbms_output.put_line('-------------------------------------------------------------------------------------------');
  open c_client;
    loop fetch c_client into v_client;
    exit when c_client%notfound;
    dbms_output.put_line('| ' || rpad(v_client.GROUP_NUMBER,16) ||' | '|| lpad(v_client.INSTANCE_NAME,13) || ' | '|| lpad(v_client.DB_NAME,8) || ' | '|| lpad(v_client.STATUS,11) || ' | '|| lpad(v_client.SOFTWARE_VERSION,16) || ' | '|| lpad(v_client.COMPATIBLE_VERSION,19) || '|');
    end loop;
    dbms_output.put_line('-------------------------------------------------------------------------------------------');
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



prompt Show the overall situation of table size ...


col "less_2G%" for a9
col "less_4G%" for a9
col "less_6G%" for a9
col "less_8G%" for a9
col "less_10G%" for a9
col "less_20G%" for a9
col "less_30G%" for a9
col "less_40G%" for a9
col "less_50G%" for a9
col "less_60G%" for a9
col "less_70G%" for a9
col "less_80G%" for a9
col "less_90G%" for a9
col "less_100G%" for a9
col "more_100G%" for a9

select
less_than_2G || ' ' || round(less_than_2G/total*100,2)||'%' as "less_2G%",
less_than_4G || ' ' || round(less_than_4G/total*100,2)||'%' as "less_4G%",
less_than_6G || ' ' || round(less_than_6G/total*100,2)||'%' as "less_6G%",
less_than_8G || ' ' || round(less_than_8G/total*100,2)||'%' as "less_8G%",
less_than_10G || ' ' || round(less_than_10G/total*100,2)||'%' as "less_10G%",
less_than_20G || ' ' || round(less_than_20G/total*100,2)||'%' as "less_20G%",
less_than_30G || ' ' ||  round(less_than_30G/total*100,2)||'%' as "less_30G%",
less_than_40G || ' ' ||  round(less_than_40G/total*100,2)||'%' as "less_40G%",
less_than_50G || ' ' ||  round(less_than_50G/total*100,2)||'%' as "less_50G%",
less_than_60G || ' ' ||  round(less_than_60G/total*100,2)||'%' as "less_60G%",
less_than_70G || ' ' ||  round(less_than_70G/total*100,2)||'%' as "less_70G%",
less_than_80G || ' ' ||  round(less_than_80G/total*100,2)||'%' as "less_80G%",
less_than_90G || ' ' ||  round(less_than_90G/total*100,2)||'%' as "less_90G%",
less_than_100G || ' ' ||  round(less_than_100G/total*100,2)||'%' as "less_100G%",
greater_than_100G || ' ' ||  round(greater_than_100G/total*100,2)||'%' as "more_100G%"
from
(
select
        sum(case when seg_GB < 2 then 1 else 0 end) less_than_2G,
        sum(case when seg_GB >= 2 and seg_GB < 4 then 1 else 0 end) less_than_4G,
        sum(case when seg_GB >= 4 and seg_GB < 6 then 1 else 0 end) less_than_6G,
        sum(case when seg_GB >= 6 and seg_GB < 8 then 1 else 0 end) less_than_8G,
        sum(case when seg_GB >= 8 and seg_GB < 10 then 1 else 0 end) less_than_10G,
        sum(case when seg_GB >= 10 and seg_GB  < 20 then 1 else 0 end) less_than_20G,
        sum(case when seg_GB >= 20 and seg_GB  < 30 then 1 else 0 end) less_than_30G,
        sum(case when seg_GB >= 30 and seg_GB  < 40 then 1 else 0 end) less_than_40G,
        sum(case when seg_GB >= 40 and seg_GB  < 50 then 1 else 0 end) less_than_50G,
        sum(case when seg_GB >= 50 and seg_GB  < 60 then 1 else 0 end) less_than_60G,
        sum(case when seg_GB >= 60 and seg_GB  < 70 then 1 else 0 end) less_than_70G,
        sum(case when seg_GB >= 70 and seg_GB  < 80 then 1 else 0 end) less_than_80G,
        sum(case when seg_GB >= 80 and seg_GB  < 90 then 1 else 0 end) less_than_90G,
        sum(case when seg_GB >= 90 and seg_GB  < 100 then 1 else 0 end) less_than_100G,
        sum(case when seg_GB >= 100 then 1 else 0 end) greater_than_100G,
        count(*) total
from
(
select owner seg_owner,segment_name seg_segment_name,
        partition_name seg_partition_name,
        segment_type seg_segment_type,
        tablespace_name seg_tablespace_name,
        blocks,
        round(bytes/1073741824,2) seg_GB,
        header_file hdrfil,
        HEADER_BLOCK hdrblk
from
        dba_segments
where
SEGMENT_TYPE='TABLE'
and
OWNER not in ('SYS', 'SYSTEM', 'DBSNMP','SYSMAN','OUTLN','MDSYS','ORDSYS','EXFSYS','DMSYS','WMSYS','CTXSYS','ANONYMOUS','XDB','ORDPLUGINS','OLAPSYS','PUBLIC')
))
/
