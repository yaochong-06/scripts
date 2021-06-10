-- usage:   @kglpin2 <addr>
-- example: @kglpin2 177B52878

select kglhdadr, kglnaown, kglnaobj from x$kglob where kglhdadr = hextoraw(lpad('&1', vsize(w.kgllkhdl)*2, 0));
