col ENDPOINT_ACTUAL_VALUE for A20
select endpoint_number, endpoint_value,ENDPOINT_ACTUAL_VALUE
from 
dba_tab_histograms
where (
	UPPER(table_name) LIKE 
	UPPER(CASE 
	WHEN INSTR('&1','.') > 0 THEN 
		SUBSTR('&1',INSTR('&1','.')+1)
	ELSE
		'&1'
				END
			)
			AND UPPER(owner) LIKE
			CASE WHEN INSTR('&1','.') > 0 THEN
				UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
			ELSE
				user
			END
	)
AND UPPER(column_name) like UPPER('%&2%')
order by endpoint_number
/
