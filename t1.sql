set autotrace on
select
    /*+ index(t) */
    max(small_vc)
from
    t_1280 t
where
    id > 0
;

exec dbms_lock.sleep(4);
select
    /*+ index(t) */
    max(small_vc)
from
    t_1280 t
where
    id > 0
;

exec dbms_lock.sleep(4);
select
    /*+ index(t) */
    max(small_vc)
from
    t_1280 t
where
    id > 0
;
set autotrace off

select
    obj, tch, count(*)
from    x$_bh
where
    obj between 74699 and 74702
group by
    obj, tch
order by
    count(*);
prompt Display Latch stats from V$LATCH for latches matching %&1%

select addr, name, level#, gets, misses, immediate_gets ig, immediate_misses im
--, spin_gets spingets, wait_time
from v$latch
where lower(name) like lower('%&1%');
