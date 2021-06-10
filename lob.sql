--------------------------------------------------------------------------------
--
-- File name:   lob.sql
-- Purpose:     query the lob segment belong to the table
--
-- Author:      Sidney Chen
-- Copyright:   (c) http://sid.gd
--              
-- Usage:       @lob [schema.]<object_name_pattern>
-- 	        	@lob mytable
--	        	@lob system.table
--              @lob sys%.%tab%
--
--------------------------------------------------------------------------------

col column_name for A30

select TABLE_NAME, column_name, segment_name, tablespace_name, index_name 
from dba_lobs
where 
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
/
