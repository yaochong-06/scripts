col CACHE_ID for A10
col cache_key for A10
col name for a20
select cache_id, cache_key, type, name, status, scn, invalidations, scan_count, row_count, creation_timestamp from GV$RESULT_CACHE_OBJECTS t;
/
