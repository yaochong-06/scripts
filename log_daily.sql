-- Daily Count and Size of Redo Log Space (Single Instance)
--
SELECT A.*,
Round(A.Count#*B.AVG#/1024/1024) Daily_Avg_Mb
FROM
(
   SELECT
   To_Char(First_Time,'YYYY-MM-DD') DAY,
   Count(1) Count#,
   Min(RECID) Min#,
   Max(RECID) Max#
FROM
   v$log_history
GROUP BY 
   To_Char(First_Time,'YYYY-MM-DD')
ORDER
BY 1 DESC
) A,
(
SELECT
Avg(BYTES) AVG#,
Count(1) Count#,
Max(BYTES) Max_Bytes,
Min(BYTES) Min_Bytes
FROM
v$log
) B
;
