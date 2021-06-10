COL desc_column_id 		HEAD "Col#" FOR A4
COL desc_column_name	        HEAD "Column Name" FOR A30
COL desc_data_type		HEAD "Type" FOR A20 WORD_WRAP
COL desc_nullable		HEAD "Null?" FOR A10
COL low_value			head "Low" for A20
COL high_value			head "High" for A20

SELECT
	CASE WHEN hidden_column = 'YES' THEN 'H' ELSE ' ' END||
	LPAD(column_id,3)	desc_column_id,
	column_name	desc_column_name,
	CASE WHEN nullable = 'N' THEN 'NOT NULL' ELSE NULL END AS desc_nullable,
	data_type||CASE
--					WHEN data_type = 'NUMBER' THEN '('||data_precision||CASE WHEN data_scale = 0 THEN NULL ELSE ','||data_scale END||')'
					WHEN data_type = 'NUMBER' THEN '('||data_precision||','||data_scale||')'
					ELSE '('||data_length||')'
				END AS desc_data_type,
	--data_default,
	num_distinct,
	density,
	num_nulls,
	num_buckets,
	histogram,
	case when data_type='VARCHAR2' or data_type='CHAR' 		then to_char(raw_to_varchar2(low_value))
		when data_type = 'DATE' or data_type like 'TIMESTAMP%'	then to_char(raw_to_date(low_value))
		when data_type = 'NUMBER'				then to_char(raw_to_num(low_value))
		else null end low_value,
	case when data_type='VARCHAR2' or data_type='CHAR'		then to_char(raw_to_varchar2(high_value))
		when data_type = 'DATE' or data_type like 'TIMESTAMP%'	then to_char(raw_to_date(high_value))
		when data_type = 'NUMBER'				then to_char(raw_to_num(high_value))
		else null end high_value
FROM
	dba_tab_cols
WHERE
	upper(table_name) LIKE
				upper(CASE
					WHEN INSTR('&1','.') > 0 THEN
					    SUBSTR('&1',INSTR('&1','.')+1)
					ELSE
					    '&1'
					END
				     )
AND	owner LIKE
		CASE WHEN INSTR('&1','.') > 0 THEN
			UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
		ELSE
			user
		END
ORDER BY
	column_id ASC
/
