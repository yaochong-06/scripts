col table_owner for A10
col table_name for A10
col partition_name for A10
col tabpart_high_value head HIGH_VALUE_RAW for a10
col compression for A10
col compress_for for A10

select
    table_owner        
  , table_name         
  , partition_position pos
  , composite          
  , partition_name     
  , num_rows
  , blocks
  , subpartition_count 
  , high_value         tabpart_high_value
  , high_value_length 
  , compression
  , compress_for
from
    dba_tab_partitions
where
    upper(table_name) LIKE 
                upper(CASE 
                    WHEN INSTR('&1','.') > 0 THEN 
                        SUBSTR('&1',INSTR('&1','.')+1)
                    ELSE
                        '&1'
                    END
                     )
AND table_owner LIKE
        CASE WHEN INSTR('&1','.') > 0 THEN
            UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
        ELSE
            user
        END
ORDER BY
    table_owner        
  , table_name         
  , partition_position
/


select t.table_name
  from user_constraints t
 where t.constraint_name in ( select w.r_constraint_name
                                from user_constraints w
                                join user_part_tables q
                                  on (q.table_name = w.table_name and
                                      q.ref_ptn_constraint_name = w.constraint_name)

select table_name
from user_part_tables
where 
