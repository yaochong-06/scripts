--desc:   query the undo info for the special session
--usage:  @undo <chongzi>
--author: chong yao
--date:	  Nov/30/2021

prompt -----------------------------------------------------------------------------------------

prompt |     shows active transaction,rollback segments imformation...                        |

prompt -----------------------------------------------------------------------------------------

col TABLESPACE_NAME for a20
col username for A20
select
        vs.sid,
        vs.serial#,
        vs.username,
        rn.name usn,
        vt.start_time,
        vt.log_io,
        vt.phy_io,
        vt.used_ublk,
        vt.used_urec,
        vt.recursive
from
v$transaction vt,
v$session vs,
v$rollname rn
where vt.addr = vs.taddr
and vt.xidusn = rn.usn
/


/*
  This script shows undo usage every 10 minutes since 24 hours ago
*/
prompt -----------------------------------------------------------------------------------------

prompt |     shows undo usage every 10 minutes since 24 hours ago...                          |

prompt -----------------------------------------------------------------------------------------

col mb for a20
col name for a30
col con_id for 9999
set linesize 400
set pages 100
SELECT INST_ID,
       BEGIN_TIME,
       END_TIME,
       TRUNC(UNDOBLKS * (SELECT VALUE
                           FROM V$PARAMETER
                          WHERE NAME = 'db_block_size'
                            AND ROWNUM = 1) / 1024 / 1024,
             2) || 'MB' AS MB
  FROM GV$UNDOSTAT
 WHERE BEGIN_TIME > SYSDATE - 1
 ORDER BY BEGIN_TIME;

col Owner for A8
col USN for 999
col segment_type for A12

select
	dba_segments.owner,
	dba_segments.tablespace_name,
	dba_rollback_segs.segment_id USN,
	dba_segments.segment_type,
	dba_segments.segment_name,
--	dba_rollback_segs.initial_extent,
--	dba_rollback_segs.next_extent,
--	dba_segments.min_extents,
--	dba_segments.max_extents,
	dba_segments.bytes,
	dba_segments.extents,
	dba_rollback_segs.status,
	dba_rollback_segs.file_id,
	dba_rollback_segs.block_id
from
	sys.dba_segments, 
	sys.dba_rollback_segs
where
	sys.dba_segments.segment_name = sys.dba_rollback_segs.segment_name 
order by
	sys.dba_rollback_segs.segment_id; 
--dead transaction
prompt show dead transaction...
select distinct KTUXECFL,count(*) from x$ktuxe group by KTUXECFL;

select ADDR,KTUXEUSN,KTUXESLT,KTUXESQN,KTUXESIZ from x$ktuxe where KTUXECFL = 'DEAD';


set serveroutput on
declare
 l_start number;
 l_end    number;
 begin
   select ktuxesiz into l_start from x$ktuxe where (KTUXEUSN,KTUXESLT) in (select KTUXEUSN,KTUXESLT from x$ktuxe where  KTUXECFL ='DEAD');
   dbms_lock.sleep(60);
   select ktuxesiz into l_end from x$ktuxe where (KTUXEUSN,KTUXESLT) in (select KTUXEUSN,KTUXESLT from x$ktuxe where  KTUXECFL ='DEAD');
   
dbms_output.put_line('time est Hours:'|| round(l_end/(l_start -l_end)/60,2));
 exception
   when others then
      dbms_output.put_line(substr(SQLERRM,1,80));
 end; 
/

-- 2G ITO

col MinEx for a5
col INI_Extent for a10
select r.name Rollback_Name,
       seg.bytes/1024/1024 "size(M)",
       seg.TABLESPACE_NAME,
       l.addr,
       p.spid SPID,
       nvl(p.username,'NO TRANSACTION') Transaction,
       p.terminal Terminal
from v$lock l,
     v$process p,
     v$rollname r,
     dba_segments seg
where   l.addr = p.addr(+)
and     trunc(l.id1(+)/65536)=r.usn
and     l.type(+) = 'TX'
and     l.lmode(+) = 6
and     r.name = seg.segment_name
and	seg.bytes > 2*1024*1024*1024; --check any rollback segment > 2G, then trigger ITO


-- detail info for all rollback segments
prompt show detail info for all rollback segments...
set pagesize 66
set line 200 
col "ID#" for a10
col "Owner" for a15
col "Tablespace Name" for a15
col "Rollback Name" for a15
col "Next Exts" for a15
col "Status" for a15
col "Size (K)" for a10
col "EXTEND" for a10

TTitle left "*** Database:  "dbname", Rollback Information ( As of:  " xdate "  ) ***" skip 2 
 
select  substr(sys.dba_rollback_segs.SEGMENT_ID,1,5) "ID#", 
        substr(sys.dba_segments.OWNER,1,8) "Owner", 
        substr(sys.dba_segments.TABLESPACE_NAME,1,17) "Tablespace Name", 
        substr(sys.dba_segments.SEGMENT_NAME,1,17) "Rollback Name", 
        substr(sys.dba_rollback_segs.INITIAL_EXTENT,1,10) "INI_Extent",
        substr(sys.dba_rollback_segs.NEXT_EXTENT,1,10) "Next Exts",
        substr(sys.dba_segments.MIN_EXTENTS,1,5) "MinEx",
        substr(sys.dba_segments.MAX_EXTENTS,1,5) "MaxEx",
        substr(sys.dba_segments.BYTES/1024,1,15) "Size (K)", 
        substr(sys.dba_segments.EXTENTS,1,6) "Extent#", 
        substr(sys.dba_rollback_segs.STATUS,1,10) "Status" 
from sys.dba_segments, 
     sys.dba_rollback_segs
where sys.dba_segments.segment_name = sys.dba_rollback_segs.segment_name 
and   sys.dba_segments.segment_type = 'ROLLBACK' -- 'TYPE2 UNDO'
order by sys.dba_rollback_segs.segment_id; 
 
ttitle off 
 
TTitle left " " skip 2 - left "*** Database:  "dbname", Rollback Status ( As of:  " xdate " )  ***" skip 2 
col "Rollback_Name" for a20
col "WAITS" for a10
col "XACTS" for a10
col "WRAPS" for a10
col "EXTENT" for a10

select substr(V$rollname.NAME,1,10)   "Rollback_Name",
       substr(V$rollstat.EXTENTS,1,6) "EXTENT",
       v$rollstat.RSSIZE, 
       v$rollstat.OPTSIZE,
       v$rollstat.WRITES,
       substr(v$rollstat.XACTS,1,6)   "XACTS",
       v$rollstat.GETS,
       substr(v$rollstat.WAITS,1,6)   "WAITS",
       v$rollstat.HWMSIZE, 
       v$rollstat.SHRINKS,
       substr(v$rollstat.WRAPS,1,6)   "WRAPS",
       round((sysdate-to_date(v$instance.startup_time))/(v$rollstat.writes/v$rollstat.rssize),1) "HOURS", 
       substr(v$rollstat.EXTENDS,1,6) "EXTEND",
       v$rollstat.AVESHRINK,
       v$rollstat.AVEACTIVE
from v$rollname, 
     v$rollstat,
     v$instance
where v$rollname.USN = v$rollstat.USN
order by v$rollname.USN;
 
ttitle off 
 
TTitle left " " skip 2 - left "*** Database:  "dbname", Rollback Segment Mapping ( As of:  "  xdate " ) ***" skip 2 
 
col "ROLLBACK_NAME" for a22

select  r.name as "ROLLBACK_NAME",
        p.pid ORACLE_PID, 
        p.spid VMS_PID, 
        nvl(p.username,'NO TRANSACTION') Transaction, 
        p.terminal Terminal
from v$lock l, 
     v$process p, 
     v$rollname r 
where   l.addr = p.addr(+) 
and     trunc(l.id1(+)/65536)=r.usn 
and     l.type(+) = 'TX' 
and     l.lmode(+) = 6 
order by r.name; 

ttitle off
set linesize 400
col OBJECT_NAME for a30
col username for a15
col status for a10
col OBJECT_NAME for a30

select  s.username,  s.sid,       rn.name,     rs.extents
               ,rs.status,  t.used_ublk,  t.used_urec
               ,do.object_name
        from    v$transaction   t
               ,v$session       s
               ,v$rollname      rn
               ,v$rollstat      rs
               ,v$locked_object lo
               ,dba_objects     do
        where  t.addr        = s.taddr
        and    t.xidusn      = rn.usn
        and    rn.usn        = rs.usn
        and    t.xidusn      = lo.xidusn(+)
        and    do.object_id  = lo.object_id
/


prompt Show undo statistics from V$UNDOSTAT....
col uds_mb head MB format 999999.99
col uds_maxquerylen head "MAX|QRYLEN" format 999999
col uds_maxqueryid  head "MAX|QRY_ID" format a13 
col uds_ssolderrcnt head "ORA-|1555" format 999
col uds_nospaceerrcnt head "SPC|ERR" format 99999
col uds_unxpstealcnt head "UNEXP|STEAL" format 9999999
col uds_expstealcnt head "EXP|STEAL" format 9999999
col end_time for a12
select * from (
    select 
        begin_time, 
        to_char(end_time, 'HH24:MI:SS') end_time, 
        txncount, 
        undoblks * (select block_size from dba_tablespaces where upper(tablespace_name) = 
                        (select upper(value) from v$parameter where name = 'undo_tablespace')
                   ) / 1048576 uds_MB ,
        maxquerylen uds_maxquerylen,
        maxqueryid  uds_maxqueryid,
        ssolderrcnt uds_ssolderrcnt,
        nospaceerrcnt uds_nospaceerrcnt,
 	unxpstealcnt uds_unxpstealcnt,
	expstealcnt uds_expstealcnt
    from 
        v$undostat
    order by
        begin_time desc
) where rownum <= 30;

