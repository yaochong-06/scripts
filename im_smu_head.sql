select
    a.object_name, a.subobject_name, sum(TOTAL_ROWS), sum(INVALID_ROWS), sum(INVALID_BLOCKS)
from dba_objects a, gV$IM_SMU_HEAD b
where a.data_object_id = b.objd
group by a.object_name, a.subobject_name
order by 3 desc;
