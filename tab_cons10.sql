--Display the constraints on a table
col owner format a12
col column_name format a18
col table_name format a25
col index_name format a30
select a.owner,a.table_name,a.constraint_name,b.column_name,a.constraint_type,a.index_name,a.status
from all_constraints a,all_cons_columns b
where a.owner = b.owner
and a.constraint_name = b.constraint_name
and a.table_name = upper('&tab_name');
