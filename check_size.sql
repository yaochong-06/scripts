col segment_name for A20

select segment_name, round(sum(BYTES)/1024/1024) original_size, round(sum(INMEMORY_SIZE)/1024/1024) inmemory_size, round(sum(BYTES)/sum(INMEMORY_SIZE),2) inmem_compress_ratio
from v$im_segments
where SEGMENT_NAME in ('D_PRCID_MA_P', 'D_ORG', 'D_SECTORDES', 'D_EMPOYEE_P', 'D_EMPLOYEEDES_P', 'F_PAYDETAILS_P','F_PAYDETAILS_SUM','D_LEVEL3DES')
group by segment_name
order by 1;

select 
round(sum(BYTES)/1024/1024) total_original_size, round(sum(INMEMORY_SIZE)/1024/1024) total_inmemory_size
from v$im_segments
where SEGMENT_NAME in ('D_PRCID_MA_P', 'D_ORG', 'D_SECTORDES', 'D_EMPOYEE_P', 'D_PRCID_MA_P', 'F_PAYDETAILS_P');

select
	POOL,
	round(ALLOC_BYTES/1024/1024/1024) "ALLOC_BYTES(GB)",
	round(USED_BYTES/1024/1024/1024) "USED_BYTES(GB)",
	POPULATE_STATUS
from v$inmemory_area;

