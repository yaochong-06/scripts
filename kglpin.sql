-- usage:   @kglpin <raw_addr>
-- example: @kglpin 177B52878
-- author:  Sidney Chen
-- date:    2011-Dec-12

col sql_text for A40
select
	sid, serial#, kgllkmod, kgllkreq, kgllktype, sql_text
from
	dba_kgllock w, v$session s, v$sqlarea a
where
	w.kgllkuse = s.saddr
and w.kgllkhdl=hextoraw(lpad('&1', vsize(w.kgllkhdl)*2, 0))
and s.sql_address = a.address
and s.sql_hash_value = a.hash_value;
