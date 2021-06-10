--
-- @old_rowid.sql <block_id> <rowslot> <file_id>
--

select
    obj.name
from
    seq$    seq,
    obj$    obj
where
    seq.rowid = (
        select
            dbms_rowid.rowid_to_extended(
                '&1.&2.&3',   -- block.rowslot.file
                'SYS',
                'SEQ$',
                0
            )
        from dual
    )
and obj.obj# = seq.obj#
/
