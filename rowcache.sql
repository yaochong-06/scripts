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
