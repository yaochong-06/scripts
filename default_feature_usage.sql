 SELECT  a.*
 FROM    (
         SELECT  dfs.dbid,dfs.name,dfs.version,dfs.DETECTED_USAGES,dfs.CURRENTLY_USED,dfs.description,dfs.TOTAL_SAMPLES,dfs.last_sample_date, ROW_NUMBER() OVER (PARTITION BY name ORDER BY version
 DESC) rno
         FROM    DBA_FEATURE_USAGE_STATISTICS dfs
         WHERE   detected_usages > 0
         AND     name IN
                 (
                 'Advanced Security',
                 'Automatic Database Diagnostic Monitor',
                 'Data Mining',
                 'Diagnostic Pack',
                 'Label Security',
                 'Partitioning (user)',
                 'RMAN - Tape Backup',
                 'Real Application Clusters (RAC)',
                 'SQL Access Advisor',
                 'SQL Tuning Advisor',
                 'SQL Tuning Set',
                 'Spatial',
                 'Transparent Gateway'
                 )
         ) a
 WHERE   a.rno = 1
/
