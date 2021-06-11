select count(*) from DBA_SQL_PLAN_DIRECTIVES;
select count(*) from dba_stat_extensions;

EXEC DBMS_SPD.flush_sql_plan_directive;
 
BEGIN 
  FOR rec in (SELECT directive_id did FROM DBA_SQL_PLAN_DIRECTIVES)
  LOOP
    DBMS_SPD.DROP_SQL_PLAN_DIRECTIVE (  directive_id        => rec.did);
  END LOOP;
END;
/

begin
--        for r in (select owner, table_name, extension from user_stat_extensions where droppable = 'YES' --and creator='SYSTEM'
        for r in (select owner, table_name, extension, extension_name from dba_stat_extensions where creator = 'SYSTEM' AND extension_name LIKE 'SYS_STS%' order by owner,table_name,extension_name
					) loop
                dbms_stats.drop_extended_stats(r.owner, r.table_name, r.extension);
        end loop;
end;
/

select count(*) from DBA_SQL_PLAN_DIRECTIVES;
select count(*) from dba_stat_extensions;
