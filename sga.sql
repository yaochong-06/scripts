
-- display the latch statistics for each row cache

col cache# for 99 heading C#
col parameter for A32
col type for A12
col subordinate# for 99 heading S#
col modifications for 9999 heading modi#
col child_no for 999 heading CNO
col immediate_gets for 999999 heading IG

select
	dc.kqrstcid cache#,
	dc.kqrsttxt parameter,
	decode(dc.kqrsttyp,1,'PARENT','SUBORDINATE') type,
	decode(dc.kqrsttyp,2,kqrstsno,null) subordinate#,
	dc.kqrstgrq gets,
	dc.kqrstgmi misses,
	dc.kqrstmrq modifications,
	dc.kqrstmfl flushes,
	dc.kqrstcln child_no,
	la.gets,
	la.misses,
	la.immediate_gets
from
	x$kqrst dc,
	v$latch_children la
where
	dc.inst_id = userenv('instance')
	and la.child# = dc.kqrstcln
	and la.name = 'row cache objects'
	order by 1,2,3,4
;
--------------------------------------------------------------------------------
--
-- File name:   la.sql ( Latch Address )
-- Purpose:     Show which latch occupies a given memory address and its stats
--
-- Author:      Tanel Poder
-- Usage:       @la <address_in_hex>
--              @la 50BE2178
--
--------------------------------------------------------------------------------
column la_name heading NAME format a40
column la_chld heading CHLD format 99999

select 
    addr, latch#, 0 la_chld, name la_name, gets, immediate_gets igets, 
    misses, immediate_misses imisses, spin_gets spingets, sleeps, wait_time
from v$latch_parent
where addr = hextoraw(lpad('&1', (select vsize(addr)*2 from v$latch_parent where rownum = 1) ,0))
union all
select 
    addr, latch#, child#, name la_name, gets, immediate_gets igets,
    misses, immediate_misses imisses, spin_gets spingets, sleeps, wait_time 
from v$latch_children
where addr = hextoraw(lpad('&1', (select vsize(addr)*2 from v$latch_children where rownum = 1) ,0))
/
prompt Display Latch Children stats from V$LATCH for latches matching

select addr, child#, name, gets, misses, immediate_gets ig, immediate_misses im, spin_gets spingets
from v$latch_children
where lower(name) like lower('%&name%')
order by name, child#
/
