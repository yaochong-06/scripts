col object_name format a35
select owner,object_type,object_name,status,last_ddl_time,created 
from dba_objects
where status <> 'VALID'
order by owner,object_type,object_name;
