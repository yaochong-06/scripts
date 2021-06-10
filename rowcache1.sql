select 
  cache#, parameter, type, subordinate#, count, usage, fixed, gets, getmisses 
from 
 v$rowcache 
order by 
  cache#, type, subordinate# 
;
