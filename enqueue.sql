PROMPT
PROMPT Which sessions are blocking and being blocked waiting for b lock? (V$LOCK)
PROMPT ----------------------------------------------------------------------------

PROMPT 1. SX and S mode is not compatible

PROMPT ---------------------------------------------------------------------------

col b_res for A20
--col b_mode for A6
--col b_req for A5
--col b_ctime for 999999

break on "b_res" on "blocker" on "b_mode" on "b_req" on "b_ctime"

select
	b.type || '-' || b.id1 ||'-'|| b.id2 as b_res,
    b.sid  as blocker,
    decode(b.lmode,1,'null',
                   2,'ss',
                   3,'sx',
                   4,'s',
                   5,'ssx',
                   6,'x','none') as b_mode,
    decode(b.request,1,'null',
                   2,'ss',
                   3,'sx',
                   4,'s',
                   5,'ssx',
                   6,'x','none') as b_req,
	b.ctime as b_ctime,
    w.sid as waiter,
    decode(w.lmode,1,'null',
                   2,'ss',
                   3,'sx',
                   4,'s',
                   5,'ssx',
                   6,'x','none') as w_mode,
    decode(w.request,1,'null',
                   2,'ss',
                   3,'sx',
                   4,'s',
                   5,'ssx',
                   6,'x','none') as w_req,
	w.ctime as w_ctime
from
    v$lock b,
    v$lock w
where
    b.block = 1
and w.request > 0
and b.id1 = w.id1
and b.id2 = w.id2
and b.type = w.type
order by
    b_res,
    w_ctime
/
