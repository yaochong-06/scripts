-- usage:   @kglpin1 <objname>
-- example: @kglpin DUMMY_PROC

select kglhdadr, kglnaown, kglnaobj from x$kglob where kglnaobj = '&1';
