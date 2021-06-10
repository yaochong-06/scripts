--检查失效对象及失效索引
col object_name format a35
select owner,object_name,object_type,status,last_ddl_time,created 
from dba_objects
where status <> 'VALID'
/
select owner,index_name,status,table_name
from dba_indexes
where status not in ('VALID','N/A')
and not (owner = 'SYSTEM' AND index_name like 'LOGMNR%')
/
