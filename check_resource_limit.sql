-- report system resource utilizations, and DB connections info
-- Feb 2, 2009 YB
-- April 29, 2010 Sid
set line 180
set pagesize 100
col INITIAL_ALLOCATION for a20
col LIMIT_VALUE for a20
col Today for a25
col instance_name for a10

select 
     to_char(sysdate,'yyyy-mm-dd hh24:mi:ss') Today, 
     a.instance_name,
     b.* 
 from 
     gv$instance a, 
     gv$resource_limit b 
where 
     (b.resource_name in ('processes','sessions','max_rollback_segments','max_shared_servers','parallel_max_servers')
	 or b.resource_name like 'ges%'
	 or b.resource_name like 'gcs%')
  and 
     a.inst_id=b.inst_id
order by 
     b.inst_id,b.resource_name
/
select INST_ID,SESSIONS_CURRENT,SESSIONS_HIGHWATER from gv$license
/
select inst_id,count(*) Total_Conn from gv$session group by inst_id
/
