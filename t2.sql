select obj, tch, count(*)
from x$bh where obj between 1 and 74702
group by
    obj, tch
order by
    count(*);
