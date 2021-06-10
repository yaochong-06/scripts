create or replace procedure invalid_tree(p_owner in varchar2, p_routine in varchar2, p_level in number := 1)
is
cursor c1 is select * from all_objects
where owner = p_owner
and object_name = p_routine
and object_type in ('PACKAGE','PROCEDURE','FUNCTION','OBJECT','TRIGER','VIEW');

cursor c2 is select owner,
	object_type,
	object_name,
	status,
	last_ddl_time
	from all_objects
	where object_name in (SELECT referenced_name 
		from all_dependencies 
		where name = p_routine and owner = p_owner)
	and object_type not in ('SYNONYM','UNDEFINED');

begin
	for c1_rec in c1 loop
		dbms_output.put_line('*' || lpad(' ',p_level) || c1_rec.owner || '.' || c1_rec.object_name || '(' || c1_rec.object_type || ') '
			|| ' status = ' || c1_rec.status || ' => last modified: ' || to_char(c1_rec.last_ddl_time, 'YYYY-MON-DD HH24:MI:SS'));
	end loop;

	for c2_rec in c2 loop
		if c2_rec.status = 'VALID' then
			dbms_output.put_line('*' || lpad(' ', p_level+1) || c2_rec.owner || '.' || c2_rec.object_name || '(' || c2_rec.object_type|| ') '
				|| ' status = ' || c2_rec.status || ' => last modified: ' || to_char(c2_rec.last_ddl_time,'YYYY-MON-DD HH24:MI:SS'));
		else
			invalid_tree(c2_rec.owner,c2_rec.object_name,p_level+1);
		end if;
	end loop;
end;
/
