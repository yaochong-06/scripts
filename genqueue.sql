PROMPT
PROMPT Which sessions are blocking and being blocked waiting for b lock? (V$LOCK)
PROMPT ----------------------------------------------------------------------------

PROMPT 1. SX and S mode is not compatible

PROMPT ---------------------------------------------------------------------------

col b_res for A20
col blocker for A10
col waiter for A10
--col b_mode for A6
--col b_req for A5
--col b_ctime for 999999

break on "b_res" on "blocker" on "b_mode" on "b_req" on "b_ctime"

select
	b.type || '-' || b.id1 ||'-'|| b.id2 as b_res,
    s1.sid || ','|| s1.serial# || '@' || s1.inst_id as blocker,
    s1.username,
    s1.sql_id,
    decode(b.lmode,1,'NULL',
                   2,'SS',
                   3,'SX',
                   4,'S',
                   5,'SSX',
                   6,'X','NONE') AS B_MODE,
    decode(b.request,1,'NULL',
                   2,'SS',
                   3,'SX',
                   4,'S',
                   5,'SSX',
                   6,'X','NONE') AS B_REQ,
	b.ctime as b_ctime,
    s2.sid || ','|| s2.serial# || '@' || s2.inst_id as waiter,
    s2.username,
    s2.sql_id,
    decode(w.lmode,1,'NULL',
                   2,'SS',
                   3,'SX',
                   4,'S',
                   5,'SSX',
                   6,'X','NONE') as w_mode,
    decode(w.request,1,'NULL',
                   2,'SS',
                   3,'SX',
                   4,'S',
                   5,'SSX',
                   6,'X','NONE') as w_req,
	w.ctime as w_ctime,
from
    gv$lock b,
    gv$lock w,
    gv$session s1,
    gv$session s2
where
    b.block > 0
and w.request > 0
and b.id1 = w.id1
and b.id2 = w.id2
and b.type = w.type
and b.inst_id = s1.inst_id
and b.sid = s1.sid
and w.inst_id = s2.inst_id
and w.sid = s2.sid
order by
    b_res,
    w_ctime
/
