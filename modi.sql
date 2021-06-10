col table_owner for A10
col table_name for A30

select
table_owner,
table_name,
inserts,
updates,
deletes,
timestamp
from dba_tab_modifications
where table_name = :TABLE_NAME;
