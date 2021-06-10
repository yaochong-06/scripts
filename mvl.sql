select master, log_table, rowids, purge_interval, last_purge_date, last_purge_status
from dba_mview_logs
where lower(master) like lower('%&1%');
