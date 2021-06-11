SELECT c.name, cu.timestamp,
       cu.equality_preds AS equality, cu.equijoin_preds AS equijoin,
       cu.nonequijoin_preds AS noneequijoin, cu.range_preds AS range,
       cu.like_preds AS "LIKE", cu.null_preds AS "NULL"
FROM sys.col$ c, sys.col_usage$ cu, sys.obj$ o, sys.user$ u
WHERE c.obj# = cu.obj# (+)
AND c.intcol# = cu.intcol# (+)
AND c.obj# = o.obj#
AND o.owner# = u.user#
AND o.name LIKE UPPER('&TABLE_NAME')
AND u.name LIKE UPPER('&OWNER')
ORDER BY c.col#
/
