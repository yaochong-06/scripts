--Library pool usage
-- library pool
set pages 1000
set lines 110
break on report 
compute sum of gets on report
compute sum of pins on report
compute avg of "gethitratio(%)" on report
compute avg of "pinhitratio(%)" on report
compute avg of "loadpinratio(%)" on report
compute avg of invalidations on report
prompt loadpinratio < 1%
prompt gethitratio > 95% 
prompt invalidations = 0
select namespace,gets,round(gethitratio*100,2) "gethitratio(%)",
       pins,round(pinhitratio*100,2) "pinhitratio(%)",
       round((reloads)/decode(pins,0,1,pins)*100,2) "loadpinratio(%)", invalidations
  from v$librarycache;

prompt Estimate library cache size = sum(sharable_mem from v$db_object_cache) 
prompt                               + 250 * total_opening_cursors
select sum(estimate_size) "estimate library cache size"
  from   (
    select sum(sharable_mem) estimate_size from v$db_object_cache
      where type in ('PACKAGE','PACKAGE BODY','FUNCTION','PROCEDURE')
    union all  
    select sum(sharable_mem) estimate_size from v$db_object_cache 
      where executions > 5  
    union all
    select 250 * sum(users_opening ) estimate_size from v$sql
  ) ;


-- dictionary pool
compute avg of "getmissratio(%)" on report
prompt getmisses/gets < 15%
select parameter, round(getmisses/decode(gets,0,1,gets)*100,2) "getmissratio(%)"
  from v$rowcache
  order by 2 desc;

-- shared_pool_reserved
prompt free_space > 1/2 shared_pool_reserved and request_misses = 0 ---- too large
prompt request_failures > 0  --- too small 
select free_space,avg_free_size,request_misses,request_failures,aborted_requests
  from v$shared_pool_reserved;

col name format a30    
col owner format a10
prompt object could be pin in the database
    select name,owner,sharable_mem,type from v$db_object_cache
      where sharable_mem > 10000
        and kept = 'NO'
        and type in ('PACKAGE','PACKAGE BODY','FUNCTION','PROCEDURE');

select * from ( select owner,name,type,executions,loads from v$db_object_cache 
  where kept = 'NO' 
    and type  in ('PACKAGE','PACKAGE BODY','FUNCTION',
                  'PROCEDURE','SEQUENCE','TYPE','TRIGGER','SYNONYM')
  order by executions desc) where rownum < 10
        
  




