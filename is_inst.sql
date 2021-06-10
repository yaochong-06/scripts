COL SEGMENT_NAME FOR A20
COL OWNER FOR A15
COL PARTITION_NAME FOR A20
COL SEGMENT_TYPE FOR A15
COL OWNER FOR A15
COL POPULATE_STATUS FOR A20
COL INMEMORY_PRIORITY FOR A8
COL INMEMORY_DISTRIBUTE FOR A10
COL INMEMORY_DUPLIDATE FOR A12
COL POOL FOR A10

select inst_id,owner, segment_name, round(sum(BYTES)/1024) "original_size(KB)", round(sum(INMEMORY_SIZE)/1024) "inmemory_size(KB)", round(sum(BYTES)/sum(INMEMORY_SIZE),2) im_cmr
from gv$im_segments
where lower(SEGMENT_NAME) like lower('%&1%')
group by inst_id,owner, segment_name
order by 4;

