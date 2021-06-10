col name for A35

select
    name,
    group_number,
    file_number,
    -- file_incarnation, 文件后缀
    alias_index,
    alias_incarnation,
    parent_index,
    reference_index,
    alias_directory,
    system_created
from
    v$asm_alias;
-- query the extents belong to a specific file

prompt grid asm execution
prompt DISK_KFFXP disk on which AU is located Disk number where the extent is allocated.
prompt NUMBER_KFFXP file number for the extent ASM file number. Join with v$asm_file and v$asm_alias

col GROUP_NAME for a10
SELECT distinct 
    '+' || g.name as GROUP_NAME,
    x.NUMBER_KFFXP as FILE_NUMBER,
    x.DISK_KFFXP as AU_ALLOCATED_DISKNUMBER,
    COUNT(x.DISK_KFFXP) over(partition by x.NUMBER_KFFXP,x.DISK_KFFXP) as EXTENTS
FROM
    X$KFFXP x,v$asm_alias a,v$asm_file f, v$asm_diskgroup g
WHERE a.FILE_NUMBER=f.FILE_NUMBER 
    AND a.FILE_NUMBER = x.NUMBER_KFFXP
    AND g.GROUP_NUMBER = x.GROUP_KFFXP
    AND x.GROUP_KFFXP = &GROUP_NUMBER 
    AND x.NUMBER_KFFXP = &FILE_NUMBER


col FULL_ALIAS_PATH for A80
SELECT '+' || gname || SYS_CONNECT_BY_PATH(ANAME, '/') FULL_ALIAS_PATH,GROUP_NUMBER
  FROM (SELECT G.NAME            GNAME,
               A.PARENT_INDEX    PINDEX,
               A.NAME            ANAME,
               A.REFERENCE_INDEX RINDEX,
               G.GROUP_NUMBER    GROUP_NUMBER
          FROM V$ASM_ALIAS A, V$ASM_DISKGROUP G
         WHERE A.GROUP_NUMBER = G.GROUP_NUMBER)
 START WITH (MOD(PINDEX, POWER(2, 24))) = 0
CONNECT BY PRIOR RINDEX = PINDEX;


col type for A15
select
    group_number,
    file_number,
--  compound_index,
--  incarnation,
    block_size,
    blocks,
    bytes,
--  space,
    type,
    redundancy,
    striped,
    creation_date
--  modification_date,
--  redundancy_lowered
from
    v$asm_file;
