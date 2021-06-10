
col tablespace_name for a10
col owner for A15
col segment_name for A15
col partition_name for A15

select * from v$im_segments
where lower(SEGMENT_NAME) like lower('%&1%');
