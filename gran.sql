col component for A25
select
	ge.grantype, ct.component,
	ge.granprev, ge.grannum, ge.grannext,
	ge.granstate, ge.baseaddr
from
	x$ksmge ge,
	x$kmgsct ct
where
	--ge.grantype != 6
	ct.grantype = ge.grantype
order by
ge.grantype,
ct.component,
ge.grannum
/
