--Import table stats from stattab
var table_name varchar2(100)
var table_owner varchar2(100)
begin
  :table_name := '&table_name';
  :table_owner := '&table_owner';
end;
/
exec DBMS_STATS.IMPORT_TABLE_STATS(ownname => :table_owner,tabname => :table_name,stattab => 'ORASTAT',cascade => TRUE,statown => 'OPS$ADMIN');
