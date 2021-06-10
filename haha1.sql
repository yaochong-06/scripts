select q'[exec DBMS_STATS.GATHER_TABLE_STATS(OWNNAME=> ']' || OWNER || q'[',TABNAME=> ']' || SEGMENT_NAME || q'[',ESTIMATE_PERCENT =>]' || PERCENT || q'[,METHOD_OPT=> 'for all columns size auto',DEGREE=> 50,CASCADE => TRUE);]' as sql_command
from (
SELECT OWNER,
      SEGMENT_NAME,
           CASE
             WHEN SIZE_GB < 0.5 THEN
              30
             WHEN SIZE_GB >= 0.5 AND SIZE_GB < 1 THEN
              20
             WHEN SIZE_GB >= 1 AND SIZE_GB < 5 THEN
              10
             WHEN SIZE_GB >= 5 AND SIZE_GB < 10 THEN
              5
             WHEN SIZE_GB >= 10 THEN
              1
           END AS PERCENT,
           8 AS DEGREE
      FROM (SELECT OWNER,
                   SEGMENT_NAME,
                   SUM(BYTES / 1024 / 1024 / 1024) SIZE_GB
              FROM DBA_SEGMENTS a
             WHERE (owner,SEGMENT_NAME) IN
                   (SELECT /*+ UNNEST */
                    DISTINCT owner,TABLE_NAME
                      FROM DBA_TAB_STATISTICS
                     WHERE  OWNER  in ('DWM','DWUPRR','DWD','DWO')
  and stattype_locked is null and last_analyzed < sysdate -1)
             GROUP BY OWNER, SEGMENT_NAME)
order BY PERCENT);

exec DBMS_STATS.GATHER_TABLE_STATS(OWNNAME=> 'DWM',TABNAME=> 'M_LOAN_LIST',ESTIMATE_PERCENT =>1,METHOD_OPT=> 'for all columns size auto',DEGREE=> 50,CASCADE => TRUE);                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              
