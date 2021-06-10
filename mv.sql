select owner, mview_name, rewrite_enabled, refresh_mode, last_refresh_type, last_refresh_date
from dba_mviews
where lower(mview_name) like lower('%&1%');
