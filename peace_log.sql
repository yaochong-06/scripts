select count(*) from WMWHSE1.orders

select count(*) - 21598 from WMWHSE1.orders;


select count(*) - 21598 from WMWHSE1.orders where status >= 95;

select count(1) from wmwhse1.orders a where a.externorderkey like '151111%'  and status >92 and status <98;

select sid, username, machine from v$session where sql_id='7rhvyf5kv33jc'

alter session set current_schema=WMWHSE1;
SELECT /*+ monitor index(o IDX_ORDERS_CARRSTATUS2) */l.loc,
  COUNT(o.orderkey)
FROM loc l
LEFT JOIN orders o
ON l.udf7              = o.CARRIERCODE
AND l.loc              = o.sjqloc
AND o.status          <= '95'
AND PBBUSINESSTYPE     = '0'
AND PBCUSTOMERTYPE     ='0'
AND o.pbship          IN( ' ' , 'N')
WHERE NVL(l.udf7,' ') <> ' '
AND l.locationflag     = 'NONE'
AND l.locationtype     = 'STAGED'
AND udf7              IN
  (SELECT CARRIERCODE
  FROM orders
  WHERE orderkey            = '0005250505'
  AND NVL(CARRIERCODE,' ') <> ' '
  )
GROUP BY l.loc
ORDER BY COUNT(o.orderkey) ASC;

SELECT /*+ gather_plan_statistics */l.loc,
  COUNT(null)
FROM loc l
LEFT JOIN orders o
ON l.udf7              = o.CARRIERCODE
AND l.loc              = o.sjqloc
AND o.status          <= '95'
AND PBBUSINESSTYPE     = '0'
AND PBCUSTOMERTYPE     ='0'
AND o.pbship          IN( ' ' , 'N')
WHERE NVL(l.udf7,' ') <> ' '
AND l.locationflag     = 'NONE'
AND l.locationtype     = 'STAGED'
AND udf7              IN
  (SELECT CARRIERCODE
  FROM orders
  WHERE orderkey            = '0005250505'
  AND NVL(CARRIERCODE,' ') <> ' '
  )
GROUP BY l.loc
ORDER BY COUNT(o.orderkey) ASC;


SELECT /*+ monitor  */l.loc,
  COUNT(o.orderkey)
FROM loc l
LEFT JOIN orders o
ON l.udf7              = o.CARRIERCODE
AND l.loc              = o.sjqloc
AND o.status          <= '95'
AND PBBUSINESSTYPE     = '0'
AND PBCUSTOMERTYPE     ='0'
AND o.pbship          IN( ' ' , 'N')
WHERE NVL(l.udf7,' ') <> ' '
AND l.locationflag     = 'NONE'
AND l.locationtype     = 'STAGED'
AND udf7              IN
  (SELECT CARRIERCODE
  FROM orders
  WHERE orderkey            = '0005250505'
  AND NVL(CARRIERCODE,' ') <> ' '
  )
GROUP BY l.loc
ORDER BY COUNT(o.orderkey) ASC;