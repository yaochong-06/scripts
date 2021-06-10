column fkey format a80 word_wrapped
select
'alter table "' || child_tname || '"' || chr(10) ||
'add constraint "' || child_cons_name || '"' || chr(10) ||
'foreign key ( ' || child_columns || ' ) ' || chr(10) ||
'references "' || parent_tname || '" ( ' || 
        parent_columns || ') NoValidate;' fkey
from
( select a.table_name child_tname, a.constraint_name 
          child_cons_name,
         b.r_constraint_name parent_cons_name,
         max(decode(position, 1,     '"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position, 2,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position, 3,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position, 4,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position, 5,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position, 6,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position, 7,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position, 8,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position, 9,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position,10,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position,11,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position,12,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position,13,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position,14,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position,15,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position,16,', '||'"'||
                substr(column_name,1,30)||'"',NULL))
            child_columns
    from user_cons_columns a, user_constraints b
   where a.constraint_name = b.constraint_name
     and b.constraint_type = 'R'
   group by a.table_name, a.constraint_name, 
               b.r_constraint_name ) child,
( select a.constraint_name parent_cons_name, a.table_name 
          parent_tname,
         max(decode(position, 1,     '"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position, 2,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position, 3,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position, 4,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position, 5,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position, 6,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position, 7,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position, 8,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position, 9,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position,10,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position,11,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position,12,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position,13,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position,14,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position,15,', '||'"'||
                substr(column_name,1,30)||'"',NULL)) ||
         max(decode(position,16,', '||'"'||
                substr(column_name,1,30)||'"',NULL))
            parent_columns
    from user_cons_columns a, user_constraints b
   where a.constraint_name = b.constraint_name
     and b.constraint_type in ( 'P', 'U' )
   group by a.table_name, a.constraint_name ) parent
where child.parent_cons_name = parent.parent_cons_name
 -- and parent.parent_tname like upper('%&1%');
/

