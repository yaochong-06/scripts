drop table p_type purge;
drop table p_t purge;
drop table p_children purge;

create table p_type as select distinct object_type from all_objects;

pause
create table p_children as select object_id from all_objects;

pause
create table p_t 
(owner, object_id, object_name, object_type, created)
partition by range(created)
(
partition p1 values less than (to_date('2010-01-01','yyyy-mm-dd')),
partition p2 values less than (to_date('2010-07-01','yyyy-mm-dd')),
partition p3 values less than (to_date('2011-01-01','yyyy-mm-dd')),
partition p4 values less than (to_date('2011-07-01','yyyy-mm-dd')),
partition p5 values less than (maxvalue)
)
as select owner, object_id, object_name, object_type, created from all_objects;

pause
alter table p_type add constraint p_type_pk primary key(object_type);
pause
alter table p_t add constraint p_t_fk foreign key (object_type) references p_type;
pause
alter table p_t add constraint p_t_pk primary key (object_id);
pause
alter table p_children add constraint p_children_fk foreign key (object_id) references p_t(object_id);
pause
create index p_children_fk_idx on p_children(object_id);

pause
exec dbms_stats.gather_table_stats(user, 'p_type', cascade=>true);
exec dbms_stats.gather_table_stats(user, 'p_t', cascade=>true);
exec dbms_stats.gather_table_stats(user, 'p_children', cascade=>true);


pause
alter table p_t drop partition p1;
--failed

create table p_t_1 as select * from p_t where 1=0;
alter table p_t_1 add constraint p_t_1_pk primary key(object_id) disable validate;

alter table p_t exchange partition p1 with table p_t_1 including indexes without validation;
--failed

alter table p_children disable constraint p_children_fk;

alter table p_t exchange partition p1 with table p_t_1 including indexes without validation;
alter index p_t_pk rebuild nologging parallel;
alter index p_t_pk logging noparallel;


select count(*) from p_t_1;
delete from p_children where object_id in (select object_id from p_t_1);
commit;
alter table p_children enable constraint p_children_fk;
