col seg_owner head OWNER for a20
col seg_segment_name head SEGMENT_NAME for a30
col seg_segment_type head SEGMENT_TYPE for a20
col seg_partition_name head SEG_PART_NAME for a20
col seg_tablespace_name head TABLESPACE for A20


col DUMMY noprint
compute sum of SEG_MB on DUMMY
break on DUMMY

select 
        NULL DUMMY,
	owner seg_owner, 
	segment_name seg_segment_name, 
	partition_name seg_partition_name,
	segment_type seg_segment_type, 
	tablespace_name seg_tablespace_name, 
	blocks,
	round(bytes/1048576,2) SEG_MB,
	header_file hdrfil,
	HEADER_BLOCK hdrblk
from 
	dba_segments 
where 
	upper(segment_name) LIKE 
                UPPER(CASE 
                    WHEN INSTR('&1','.') > 0 THEN 
                        SUBSTR('&1',INSTR('&1','.')+1)
                    ELSE
                        '&1'
                    END
                     )
AND UPPER(owner) LIKE
        UPPER(CASE WHEN INSTR('&1','.') > 0 THEN
            UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
        ELSE
            user
        END)
/
