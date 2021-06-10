--
-- desc:	get the endpoit value for a string
-- author:	Sidney Chen
-- date:	Sep-5-2011

select to_number(replace(substr(d, instr(d,':') + 2),','),'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX')
from
(
select dump(rpad('&1', 15, ' '),16) d from dual
)
/
