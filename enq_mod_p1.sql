-- usage: @enq_mod_p1.sql <p1>
-- desc: compute the enqueue mode, from the p1 of the enqueue wait evnet
-- by Sidney Chen

select bitand(&1,power(2,14)-1) from dual;
