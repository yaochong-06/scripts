set autotrace on
select
    /*+ full(t) */
    max(small_vc)
from
    t_12800 t
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
