


prompt Show information about all the tables in the database and the tables you entered...

set serveroutput on
set feedback off
set verify off
set linesize 500
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



undefine table_name
undefine owner
var table_name varchar2(100);
var owner varchar2(100);

begin
  :table_name := upper('&table_name');
  :owner :=upper('&owner');
end;
/


declare
    v_cnt number;
    v_open_mode varchar2(100) :=null;
    v_protection_mode  varchar2(100) :=null;
    v_switchover  varchar2(100) :=null;
    v_force_logging varchar2(100) :=null;

    cursor c_seg is select sum(bytes/1024/1024/1024) G ,partition_name from dba_segments where segment_name = upper(:table_name) and owner = upper(:owner) 
group by partition_name order by partition_name;
    v_seg c_seg%rowtype;
    cursor c_stats is SELECT A.COLUMN_NAME,B.NUM_ROWS,A.NUM_DISTINCT CARDINALITY,ROUND(A.NUM_DISTINCT / decode(B.NUM_ROWS,0,1,B.NUM_ROWS) * 100, 2) SELECTIVITY,A.HISTOGRAM,A.NUM_BUCKETS
  FROM DBA_TAB_COL_STATISTICS A, DBA_TABLES B
 WHERE A.OWNER = B.OWNER
   AND A.TABLE_NAME = B.TABLE_NAME
   AND A.TABLE_NAME = upper(:table_name) and a.owner = upper(:owner) order by A.OWNER,A.COLUMN_NAME;
   v_stats c_stats%rowtype;
   
   cursor c_sta is select case when PARTITION_NAME is null then 'Current Table' else PARTITION_NAME end as PARTITION_NAME ,
                          case when PARTITION_POSITION is null then 'Current Table' else to_char(PARTITION_POSITION) end as PARTITION_POSITION,stale_stats,last_analyzed from dba_tab_statistics where owner = upper(:owner) and table_name = upper(:table_name);
   v_sta c_sta%rowtype;
   
   cursor c_modi is select b.INSERTS,b.UPDATES,b.DELETES,b.TIMESTAMP
   from dba_tab_modifications b 
   where b.table_name = upper(:table_name) and b.table_owner = upper(:owner) order by b.timestamp;
   v_modi c_modi%rowtype; 
   
   cursor c_tab_partitions is select T.PARTITION_POSITION,T.PARTITION_NAME,
                               T.HIGH_VALUE,
                               case when t.NUM_ROWS is null then 'None' else to_char(t.NUM_ROWS) end as NUM_ROWS,
                               case when to_char(t.last_analyzed,'YYYYMMDD') is null then 'None' else to_char(t.last_analyzed,'YYYYMMDD') end as last_analyzed,
                               round(S.G,2) as G,
                               t.subpartition_count as subpartition_cnt,t.COMPRESSION
   from dba_tab_partitions t, (select sum(bytes/1024/1024/1024) G ,partition_name from dba_segments where segment_name = upper(:table_name) and owner = upper(:owner) 
   group by partition_name) s 
   where s.partition_name = t.PARTITION_NAME
   and table_owner = upper(:owner)
   and table_name = upper(:table_name)
   order by t.partition_position;
   v_tab_pars c_tab_partitions%rowtype;

   cursor c_big_tab is select OWNER,SEGMENT_NAME,SIZE_MB from (select owner,nvl2(PARTITION_NAME,SEGMENT_NAME||'.'||PARTITION_NAME,SEGMENT_NAME) SEGMENT_NAME ,trunc(bytes/1024/1024) as SIZE_MB
   from dba_segments where segment_type like 'TABLE%' order by bytes desc)
   where  rownum < 21;
   v_big_tab c_big_tab%rowtype;

   cursor c_big_lob is select OWNER,TABLE_NAME,COLUMN_NAME,SEGMENT_NAME,SIZE_MB from
   (select a.owner,b.table_name,b.column_name,a.SEGMENT_NAME ,trunc(a.bytes/1024/1024) as SIZE_MB from dba_segments a,dba_lobs b
   where a.segment_type like 'LOB%' and a.SEGMENT_NAME=b.SEGMENT_NAME order by a.bytes desc) where  rownum < 11;
   v_big_lob c_big_lob%rowtype;



begin
   dbms_output.put_line('
Top 20 Big Table Information in The Database');
  dbms_output.put_line('======================');
  dbms_output.put_line('-------------------------------------------------------------');
  dbms_output.put_line('| OWNER            |' || ' SEGMENT_NAME              ' || '|   SIZE(MB) ' ||'|');
  dbms_output.put_line('-------------------------------------------------------------');
  open c_big_tab;
    loop fetch c_big_tab into v_big_tab;
    exit when c_big_tab%notfound;
    dbms_output.put_line('| ' || rpad(v_big_tab.OWNER,16) ||' | '|| rpad(v_big_tab.SEGMENT_NAME,25) || ' | '|| lpad(v_big_tab.SIZE_MB,11) || '|');
    end loop;
    dbms_output.put_line('-------------------------------------------------------------');
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


  select count(*) into v_cnt from dba_segments where segment_name = upper(:table_name) and owner = upper(:owner);
  
if v_cnt = 1 then


  dbms_output.put_line('
Non partitioned Table Segment Information');
  dbms_output.put_line('======================');
  open c_seg;
    loop fetch c_seg into v_seg;
    exit when c_seg%notfound;
    dbms_output.put_line('TABLE_NAME : '|| :TABLE_NAME  || '  |  ' || 'SEGMENT_SIZE : '|| round(v_seg.g,2));
    end loop;
  close c_seg;
  


  dbms_output.put_line('
Non partitioned Table Statistics Information');
  dbms_output.put_line('======================');
  dbms_output.put_line('----------------------------------------------------------------------------------------------');
  dbms_output.put_line('| COLUMN_NAME          |' || ' NUM_ROWS      ' || '| CARDINALITY |' || ' SELECTIVITY ' || '| HISTOGRAM |' || ' NUM_BUCKETS ' || '|');
  dbms_output.put_line('----------------------------------------------------------------------------------------------');
  open c_stats;
    loop fetch c_stats into v_stats;
    exit when c_stats%notfound;
    dbms_output.put_line('| ' || rpad(v_stats.COLUMN_NAME,20) ||' | '|| rpad(v_stats.NUM_ROWS,13) || ' | '|| rpad(v_stats.CARDINALITY,11) || ' | '|| lpad(v_stats.SELECTIVITY || '%',11) || ' | '|| lpad(v_stats.HISTOGRAM,9) || ' | '|| lpad(v_stats.NUM_BUCKETS,12) || '|');
    end loop;
    dbms_output.put_line('----------------------------------------------------------------------------------------------');
  close c_stats;


  dbms_output.put_line('
Non partitioned Table Statistics STALE_STATS, Yes Means Expired');
  dbms_output.put_line('======================');
  dbms_output.put_line('-------------------------------------');
  dbms_output.put_line('| STALE_STATS |' || ' LAST_ANALYZED       ' || '|');
  dbms_output.put_line('-------------------------------------');
  open c_sta;
    loop fetch c_sta into v_sta;
    exit when c_sta%notfound;
    dbms_output.put_line('| ' || lpad(v_sta.STALE_STATS,11) ||' | '|| v_sta.LAST_ANALYZED || ' |');
    end loop;
    dbms_output.put_line('-------------------------------------');
  close c_sta;


  dbms_output.put_line('
Non partitioned Table Modification,Stats Expired Reason Information(dba_tab_modifications)');
  dbms_output.put_line('======================');
  dbms_output.put_line('-----------------------------------------------------------------------');
  dbms_output.put_line('|'  || ' INSERTS          |' || ' UPDATES      ' || '| DELETES      |' || ' TIMESTAMP          ' || '|');
  dbms_output.put_line('-----------------------------------------------------------------------');
  open c_modi;
    dbms_stats.flush_database_monitoring_info;
    loop fetch c_modi into v_modi;
    exit when c_modi%notfound;
    dbms_output.put_line('| ' || lpad(v_modi.INSERTS,16) ||' | '|| lpad(v_modi.UPDATES,12) || ' | '|| lpad(v_modi.DELETES,12) || ' | '|| v_modi.TIMESTAMP || '|');
    end loop;
    dbms_output.put_line('-----------------------------------------------------------------------');
  close c_modi;



  else 
  dbms_output.put_line('
Partition Table Segment Information');
  dbms_output.put_line('======================');
  
    open c_tab_partitions;
    dbms_output.put_line('-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
    dbms_output.put_line('| POSITION |' || ' PARTITION_NAME    ' || '| HIGH_VALUE                                                   |' || ' NUM_ROWS    ' || '| LAST_ANALYZED |' || ' PARTITION_SIZE(G) '|| '| SUBPART_CNT |' || ' COMPRESSION ' ||'|');
    dbms_output.put_line('-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
    loop fetch c_tab_partitions into v_tab_pars;
    exit when c_tab_partitions%notfound;
    dbms_output.put_line('| '|| rpad(v_tab_pars.PARTITION_POSITION,8) || ' | ' || rpad(v_tab_pars.partition_name,17) || ' | ' || rpad(v_tab_pars.HIGH_VALUE,60) || ' | ' || lpad(v_tab_pars.NUM_ROWS,11) || ' | ' || lpad(v_tab_pars.last_analyzed,13) || ' | ' || lpad(v_tab_pars.g,17) || ' | ' || lpad(v_tab_pars.subpartition_cnt,11) ||  ' | ' || lpad(v_tab_pars.compression,11) || ' |');
    end loop;
    dbms_output.put_line('-----------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  close c_tab_partitions;


  dbms_output.put_line('
Partition Table Statistics Information');
  dbms_output.put_line('======================');
  dbms_output.put_line('----------------------------------------------------------------------------------------------');
  dbms_output.put_line('| COLUMN_NAME          |' || ' NUM_ROWS      ' || '| CARDINALITY |' || ' SELECTIVITY ' || '| HISTOGRAM |' || ' NUM_BUCKETS ' || '|');
  dbms_output.put_line('----------------------------------------------------------------------------------------------');
  open c_stats;
    loop fetch c_stats into v_stats;
    exit when c_stats%notfound;
    dbms_output.put_line('| ' || rpad(v_stats.COLUMN_NAME,20) ||' | '|| rpad(v_stats.NUM_ROWS,13) || ' | '|| rpad(v_stats.CARDINALITY,11) || ' | '|| lpad(v_stats.SELECTIVITY || '%',11) || ' | '|| lpad(v_stats.HISTOGRAM,9) || ' | '|| lpad(v_stats.NUM_BUCKETS,12) || '|');
    end loop;
    dbms_output.put_line('----------------------------------------------------------------------------------------------');
  close c_stats;

  dbms_output.put_line('
Partitioned Table Statistics STALE_STATS, Yes Means Expired');
  dbms_output.put_line('======================');
  dbms_output.put_line('----------------------------------------------------------------------------------');
  dbms_output.put_line('| PARTITION_NAME        |' || ' PARTITION_POSITION ' || '| STALE_STATS |' || ' LAST_ANALYZED       ' || '|');
  dbms_output.put_line('----------------------------------------------------------------------------------');
  open c_sta;
    loop fetch c_sta into v_sta;
    exit when c_sta%notfound;
    dbms_output.put_line('| ' || lpad(v_sta.partition_name,21)|| ' | ' || lpad(v_sta.partition_position,18) || ' | ' ||lpad(v_sta.STALE_STATS,11) ||' | '|| v_sta.LAST_ANALYZED || ' |');
    end loop;
    dbms_output.put_line('----------------------------------------------------------------------------------');
  close c_sta;


  dbms_output.put_line('
Partitione Table Modification Information(dba_tab_modifications)');
  dbms_output.put_line('======================');
  dbms_output.put_line('-----------------------------------------------------------------------');
  dbms_output.put_line('|'  || ' INSERTS          |' || ' UPDATES      ' || '| DELETES      |' || ' TIMESTAMP          ' || '|');
  dbms_output.put_line('-----------------------------------------------------------------------');
  open c_modi;
    loop fetch c_modi into v_modi;
    exit when c_modi%notfound;
    dbms_output.put_line('| ' || lpad(v_modi.INSERTS,16) ||' | '|| lpad(v_modi.UPDATES,12) || ' | '|| lpad(v_modi.DELETES,12) || ' | '|| v_modi.TIMESTAMP || '|');
    end loop;
    dbms_output.put_line('-----------------------------------------------------------------------');
  close c_modi;





end if;
end;
/

--Table stats

set echo off
set scan on
set lines 150
set pages 66
set verify off
set feedback off
set termout off
column uservar new_value Table_Owner noprint
select user uservar from dual;
set termout on
column TABLE_NAME heading "Tables owned by &Table_Owner" format a30
undefine table_name
undefine owner
prompt
accept owner prompt 'Please enter Name of Table Owner (Null = &Table_Owner): '
accept table_name  prompt 'Please enter Table Name to show Statistics for: '
column TABLE_NAME heading "Table|Name" format a15
column PARTITION_NAME heading "Partition|Name" format a15
column SUBPARTITION_NAME heading "SubPartition|Name" format a15
column NUM_ROWS heading "Number|of Rows" format 9,999,999,990
column BLOCKS for a7 heading "Blocks" format 99,999,990
column EMPTY_BLOCKS heading "Empty|Blocks" format 999,999,990

column AVG_SPACE heading "Average|Space" format 9,990
column CHAIN_CNT heading "Chain|Count" format 999,990
column AVG_ROW_LEN heading "Average|Row Len" format 990
column COLUMN_NAME  heading "Column|Name" format a27
column NULLABLE heading Null|able format a4
column NUM_DISTINCT heading "Distinct|Values" format 999,999,990
column NUM_NULLS heading "Number|Nulls" format 999,999,990
column NUM_BUCKETS heading "Number|Buckets" format 990
column DENSITY heading "Density" format 990
column INDEX_NAME heading "Index|Name" format a15
column UNIQUENESS heading "Unique" format a9
column BLEV heading "B|Tre|Lev" format 90
column LEAF_BLOCKS heading "Leaf|Blks" format 9,999,990 
column DISTINCT_KEYS heading "Distinct|Keys" format 999,999,990
column AVG_LEAF_BLOCKS_PER_KEY heading "Average|Leaf Block|Per Key" format 99,990
column AVG_DATA_BLOCKS_PER_KEY heading "Average|Data Block|Per Key" format 99,990
column CLUSTERING_FACTOR heading "Cluster|Factor" format 999,999,990
column COLUMN_POSITION heading "Col|Pos" format 990
column col heading "Column|Details" format a24
column COLUMN_LENGTH heading "Col|Len" format 9,990
column GLOBAL_STATS heading "Global|Stats" format a6
column USER_STATS heading "User|Stats" format a6
column SAMPLE_SIZE heading "Sample|Size" format 99,999,990
column to_char(t.last_analyzed,'MM-DD-YYYY') heading "Date|MM-DD-YYYY" format a10

prompt
prompt ***********
prompt Table Level
prompt ***********
prompt
select
    TABLE_NAME,
    NUM_ROWS,
    BLOCKS,
    EMPTY_BLOCKS,
    AVG_SPACE,
    CHAIN_CNT,
    AVG_ROW_LEN,
    GLOBAL_STATS,
    USER_STATS,
    SAMPLE_SIZE,
    to_char(t.last_analyzed,'MM-DD-YYYY')
from dba_tables t
where
    owner = upper(nvl('&&Owner',user))
and table_name = upper('&&Table_name')
/
select
    COLUMN_NAME,
    decode(t.DATA_TYPE,
           'NUMBER',t.DATA_TYPE||'('||
           decode(t.DATA_PRECISION,
                  null,t.DATA_LENGTH||')',
                  t.DATA_PRECISION||','||t.DATA_SCALE||')'),
                  'DATE',t.DATA_TYPE,
                  'LONG',t.DATA_TYPE,
                  'LONG RAW',t.DATA_TYPE,
                  'ROWID',t.DATA_TYPE,
                  'MLSLABEL',t.DATA_TYPE,
                  t.DATA_TYPE||'('||t.DATA_LENGTH||')') ||' '||
    decode(t.nullable,
              'N','NOT NULL',
              'n','NOT NULL',
              NULL) col,
    NUM_DISTINCT,
    DENSITY,
    NUM_BUCKETS,
    NUM_NULLS,
    GLOBAL_STATS,
    USER_STATS,
    SAMPLE_SIZE,
    to_char(t.last_analyzed,'MM-DD-YYYY')
from dba_tab_columns t
where
    table_name = upper('&Table_name')
and owner = upper(nvl('&Owner',user))
/
col index_name for a30
select
    INDEX_NAME,
    BLEVEL BLev,
    LEAF_BLOCKS,
    DISTINCT_KEYS,
    NUM_ROWS,
    AVG_LEAF_BLOCKS_PER_KEY,
    AVG_DATA_BLOCKS_PER_KEY,
    CLUSTERING_FACTOR,
    SAMPLE_SIZE,
    to_char(t.last_analyzed,'MM-DD-YYYY')
from
    dba_indexes t
where
    table_name = upper('&Table_name')
and table_owner = upper(nvl('&Owner',user))
/
break on index_name
col index_name for a30
select
    distinct i.INDEX_NAME,
    i.COLUMN_NAME,
    i.COLUMN_POSITION,
    decode(t.DATA_TYPE,
           'NUMBER',t.DATA_TYPE||'('||
           decode(t.DATA_PRECISION,
                  null,t.DATA_LENGTH||')',
                  t.DATA_PRECISION||','||t.DATA_SCALE||')'),
                  'DATE',t.DATA_TYPE,
                  'LONG',t.DATA_TYPE,
                  'LONG RAW',t.DATA_TYPE,
                  'ROWID',t.DATA_TYPE,
                  'MLSLABEL',t.DATA_TYPE,
                  t.DATA_TYPE||'('||t.DATA_LENGTH||')') ||' '||
           decode(t.nullable,
                  'N','NOT NULL',
                  'n','NOT NULL',
                  NULL) col
from
    dba_ind_columns i,
    dba_tab_columns t
where
    i.table_name = upper('&Table_name')
and owner = upper(nvl('&Owner',user))
and i.table_name = t.table_name
and i.column_name = t.column_name
order by index_name,column_position
/

prompt
prompt ***************
prompt Partition Level
prompt ***************

select
    PARTITION_NAME,
    NUM_ROWS,
    BLOCKS,
    EMPTY_BLOCKS,
    AVG_SPACE,
    CHAIN_CNT,
    AVG_ROW_LEN,
    GLOBAL_STATS,
    USER_STATS,
    SAMPLE_SIZE,
    to_char(t.last_analyzed,'MM-DD-YYYY')
from
    dba_tab_partitions t
where
    table_owner = upper(nvl('&&Owner',user))
and table_name = upper('&&Table_name')
order by partition_position
/


break on partition_name
select
    PARTITION_NAME,
    COLUMN_NAME,
    NUM_DISTINCT,
    DENSITY,
    NUM_BUCKETS,
    NUM_NULLS,
    GLOBAL_STATS,
    USER_STATS,
    SAMPLE_SIZE,
    to_char(t.last_analyzed,'MM-DD-YYYY')
from
    dba_PART_COL_STATISTICS t
where
    table_name = upper('&Table_name')
and owner = upper(nvl('&Owner',user))
/

break on partition_name
select
    t.INDEX_NAME,
    t.PARTITION_NAME,
    t.BLEVEL BLev,
    t.LEAF_BLOCKS,
    t.DISTINCT_KEYS,
    t.NUM_ROWS,
    t.AVG_LEAF_BLOCKS_PER_KEY,
    t.AVG_DATA_BLOCKS_PER_KEY,
    t.CLUSTERING_FACTOR,
    t.GLOBAL_STATS,
    t.USER_STATS,
    t.SAMPLE_SIZE,
    to_char(t.last_analyzed,'MM-DD-YYYY')
from
    dba_ind_partitions t,
    dba_indexes i
where
    i.table_name = upper('&Table_name')
and i.table_owner = upper(nvl('&Owner',user))
and i.owner = t.index_owner
and i.index_name=t.index_name
/


prompt
prompt ***************
prompt SubPartition Level
prompt ***************

select
    PARTITION_NAME,
    SUBPARTITION_NAME,
    NUM_ROWS,
    BLOCKS,
    EMPTY_BLOCKS,
    AVG_SPACE,
    CHAIN_CNT,
    AVG_ROW_LEN,
    GLOBAL_STATS,
    USER_STATS,
    SAMPLE_SIZE,
    to_char(t.last_analyzed,'MM-DD-YYYY')
from
    dba_tab_subpartitions t
where
    table_owner = upper(nvl('&&Owner',user))
and table_name = upper('&&Table_name')
order by SUBPARTITION_POSITION
/
break on partition_name
select
    p.PARTITION_NAME,
    t.SUBPARTITION_NAME,
    t.COLUMN_NAME,
    t.NUM_DISTINCT,
    t.DENSITY,
    t.NUM_BUCKETS,
    t.NUM_NULLS,
    t.GLOBAL_STATS,
    t.USER_STATS,
    t.SAMPLE_SIZE,
    to_char(t.last_analyzed,'MM-DD-YYYY')
from
    dba_SUBPART_COL_STATISTICS t,
    dba_tab_subpartitions p
where
    t.table_name = upper('&Table_name')
and t.owner = upper(nvl('&Owner',user))
and t.subpartition_name = p.subpartition_name
and t.owner = p.table_owner
and t.table_name=p.table_name
/

break on partition_name
select
    t.INDEX_NAME,
    t.PARTITION_NAME,
    t.SUBPARTITION_NAME,
    t.BLEVEL BLev,
    t.LEAF_BLOCKS,
    t.DISTINCT_KEYS,
    t.NUM_ROWS,
    t.AVG_LEAF_BLOCKS_PER_KEY,
    t.AVG_DATA_BLOCKS_PER_KEY,
    t.CLUSTERING_FACTOR,
    t.GLOBAL_STATS,
    t.USER_STATS,
    t.SAMPLE_SIZE,
    to_char(t.last_analyzed,'MM-DD-YYYY')
from
    dba_ind_subpartitions t,
    dba_indexes i
where
    i.table_name = upper('&Table_name')
and i.table_owner = upper(nvl('&Owner',user))
and i.owner = t.index_owner
and i.index_name=t.index_name
/

clear breaks
set echo on


