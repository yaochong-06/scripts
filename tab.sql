


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
select
        owner seg_owner,
        segment_name seg_segment_name,
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
   
   cursor c_sta is select stale_stats,last_analyzed from dba_tab_statistics where owner = upper(:owner) and table_name = upper(:table_name);
   v_sta c_sta%rowtype;
   
   cursor c_modi is select b.INSERTS,b.UPDATES,b.DELETES,b.TIMESTAMP
   from dba_tab_modifications b 
   where b.table_name = upper(:table_name) and b.table_owner = upper(:owner) order by b.timestamp;
   v_modi c_modi%rowtype; 
   
   cursor c_tab_partitions is select T.PARTITION_POSITION,T.PARTITION_NAME,T.HIGH_VALUE,decode(T.NUM_ROWS,null,'None') as NUM_ROWS,decode(to_char(t.last_analyzed,'YYYYMMDD'),null,'None') as last_analyzed,
   round(S.G,2) as G from dba_tab_partitions t, (select sum(bytes/1024/1024/1024) G ,partition_name from dba_segments where segment_name = upper(:table_name) and owner = upper(:owner) 
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
Top 20 Big LOB Information in The Database');
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
Non partitioned Table Modification Information(dba_tab_modifications)');
  dbms_output.put_line('======================');
  dbms_output.put_line('---------------------------------------------------------------------');
  dbms_output.put_line('|'  || ' INSERTS          |' || ' UPDATES      ' || '| DELETES |' || ' TIMESTAMP ' || '|');
  dbms_output.put_line('---------------------------------------------------------------------');
  open c_modi;
    loop fetch c_modi into v_modi;
    exit when c_modi%notfound;
    dbms_output.put_line('| ' || v_modi.INSERTS ||' | '|| v_modi.UPDATES || ' | '|| v_modi.DELETES || ' | '|| v_modi.TIMESTAMP || '|');
    end loop;
    dbms_output.put_line('---------------------------------------------------------------------');
  close c_modi;



  else 
  dbms_output.put_line('
Partitioned Table Segment Information');
  dbms_output.put_line('======================');
  
    open c_tab_partitions;
    dbms_output.put_line('------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
    dbms_output.put_line('| POSITION |' || ' PARTITION_NAME    ' || '| HIGH_VALUE                                                                       |' || ' NUM_ROWS       ' || '| LAST_ANALYZED |' || ' PARTITION_SIZE(G) '||'|');
    dbms_output.put_line('------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
    loop fetch c_tab_partitions into v_tab_pars;
    exit when c_tab_partitions%notfound;
    dbms_output.put_line('| '|| rpad(v_tab_pars.PARTITION_POSITION,8) || ' | ' || rpad(v_tab_pars.partition_name,17) || ' | ' || lpad(v_tab_pars.HIGH_VALUE,80) || ' | ' || lpad(v_tab_pars.NUM_ROWS,14) || ' | ' || lpad(v_tab_pars.last_analyzed,13) || ' | ' || lpad(v_tab_pars.g,17) || ' |');
    end loop;
    dbms_output.put_line('------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  close c_tab_partitions;

end if;
end;
/

