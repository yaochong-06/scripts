spool im_seg_detail.txt
set echo on
set num 13

col DISTDIM for A15
col CREATETIME for A30

select
	INST_ID            ,
	TSN                ,
	RELFILE            ,
	BLOCK_ID           ,
	DATAOBJ            ,
	OBJ                ,
	BASEOBJ            ,
	INC                ,
	SPARE_ID           ,
	SEGTYPE            ,
	DISTDIM            ,
	MEMADDR            ,
	MEMEXTENTS         ,
	MEMBYTES           ,
	EXTENTS            ,
	BLOCKS             ,
	DATABLOCKS         ,
	BLOCKSINMEM        ,
	BYTES              ,
	CREATETIME         ,
	STATUS             ,
	POPULATE_STATUS    
from gv$im_segments_detail
where dataobj in
(
	select
		data_object_id
	from
		dba_objects
	where
		owner='DMREG'
	and	object_name = 'DM_REG_EXP_SUM_F'
	and	subobject_name = 'P201406_R05_8'
	and 	object_type = 'TABLE SUBPARTITION'
)
order by INST_ID
;
spool off
