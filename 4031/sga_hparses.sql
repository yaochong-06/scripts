create table t1 as select sql_text from v$sqlarea;

alter table t1 add sql_text_wo_constants varchar2(1000);

create or replace function 
remove_constants( p_query in varchar2 ) return varchar2
as
    l_query long;
    l_char  varchar2(1);
    l_in_quotes boolean default FALSE;
begin
    for i in 1 .. length( p_query )
    loop
        l_char := substr(p_query,i,1);
        if ( l_char = '''' and l_in_quotes )
        then
            l_in_quotes := FALSE;
        elsif ( l_char = '''' and NOT l_in_quotes )
        then
            l_in_quotes := TRUE;
            l_query := l_query || '''#';
        end if;
        if ( NOT l_in_quotes ) then
            l_query := l_query || l_char;
        end if;
    end loop;
    l_query := translate( l_query, '0123456789', '@@@@@@@@@@' );
    for i in 0 .. 8 loop
        l_query := replace( l_query, lpad('@',10-i,'@'), '@' );
        l_query := replace( l_query, lpad(' ',10-i,' '), ' ' );
    end loop;
    return upper(l_query);
end;
/
update t1 set sql_text_wo_constants = remove_constants(sql_text);

select sql_text_wo_constants, count(*)
  from t1
 group by sql_text_wo_constants
having count(*) > 100
 order by 2
/
