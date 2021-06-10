prompt show constraint other than R for the table &1...
select
'select dbms_metadata.get_ddl(''CONSTRAINT'','''|| co.constraint_name || ''',''' || co.owner || ''') from dual;' cons_ddl
from
     dba_constraints co,
     dba_cons_columns cc
where
    co.owner              = cc.owner
and co.table_name         = cc.table_name
and co.constraint_name    = cc.constraint_name
and co.constraint_type    <> 'R'
and upper(co.table_name) LIKE
                upper(CASE
                    WHEN INSTR('&1','.') > 0 THEN
                        SUBSTR('&1',INSTR('&1','.')+1)
                    ELSE
                        '&1'
                    END
                     )
AND co.owner LIKE
        CASE WHEN INSTR('&1','.') > 0 THEN
            UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
        ELSE
            user
        END
order by
     co.owner,
     co.table_name,
     co.constraint_type,
     co.constraint_name
/

select
        dbms_metadata.get_ddl('CONSTRAINT',co.constraint_name,co.owner) cons_ddl
from
     dba_constraints co,
     dba_cons_columns cc
where
    co.owner              = cc.owner
and co.table_name         = cc.table_name
and co.constraint_name    = cc.constraint_name
and co.constraint_type    <> 'R'
and upper(co.table_name) LIKE
                upper(CASE
                    WHEN INSTR('&1','.') > 0 THEN
                        SUBSTR('&1',INSTR('&1','.')+1)
                    ELSE
                        '&1'
                    END
                     )
AND co.owner LIKE
        CASE WHEN INSTR('&1','.') > 0 THEN
            UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
        ELSE
            user
        END
order by
     co.owner,
     co.table_name,
     co.constraint_type,
     co.constraint_name
/


prompt show Referential constraint for the table &1...
select
        dbms_metadata.get_ddl('REF_CONSTRAINT',co.constraint_name,co.owner) cons_ddl
from
     dba_constraints co,
     dba_cons_columns cc
where
    co.owner              = cc.owner
and co.table_name         = cc.table_name
and co.constraint_name    = cc.constraint_name
and co.constraint_type    = 'R'
and upper(co.table_name) LIKE
                upper(CASE
                    WHEN INSTR('&1','.') > 0 THEN
                        SUBSTR('&1',INSTR('&1','.')+1)
                    ELSE
                        '&1'
                    END
                     )
AND co.owner LIKE
        CASE WHEN INSTR('&1','.') > 0 THEN
            UPPER(SUBSTR('&1',1,INSTR('&1','.')-1))
        ELSE
            user
        END
order by
     co.owner,
     co.table_name,
     co.constraint_type,
     co.constraint_name
/
