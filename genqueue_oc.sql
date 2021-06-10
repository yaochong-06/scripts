select
	b.inst_id b_inst_id,
	b.type || '-' || b.id1 ||'-'|| b.id2 as b_res,
    b.sid  as blocker,
    b.lmode as bmod,
	b.request as breq,
	b.ctime as b_ctime,
	w.inst_id w_inst_id,
    w.sid as waiter,
	w.lmode as wmod,
	w.request as wreq,
	w.ctime as w_ctime
from
    gv$lock b,
    gv$lock w
where
    b.block > 0
and w.request > 0
and b.id1 = w.id1
and b.id2 = w.id2
and b.type = w.type
order by
    b_res,
    w_ctime
/
