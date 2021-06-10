set linesize 300
col owner for a20
col index_name for a25
col table_name for a25
select
    u.name owner,
    io.name index_name,
    t.name table_name,
    decode(bitand(i.flags, 65536), 0, 'NO', 'YES') monitoring,
    decode(bitand(ou.flags, 1), 0, 'NO', 'YES') used,
    ou.start_monitoring,
    ou.end_monitoring
from sys.user$ u, sys.obj$ io, sys.obj$ t, sys.ind$ i, sys.object_usage ou
where
    i.obj# = ou.obj#
    and io.obj# = ou.obj#
    and t.obj# = i.bo#
    and u.user# = io.owner#
    and lower(u.name) like '%' || lower('&username') || '%'
    and lower(t.name) like '%' || lower('&table_name') || '%';
