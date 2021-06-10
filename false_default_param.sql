column name format a30
column value format a49
select name, value from v$parameter where isdefault='FALSE' order by 1;
