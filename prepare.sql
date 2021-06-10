set echo on

drop table t_1280 purge;
drop table t_12800 purge;
create table t_1280
pctfree 99
pctused 1
as
with generator as (
    select  --+ materialize
        rownum id
    from dual
    connect by
        rownum <= 10000
)
select
    rownum          id,
    lpad(rownum,10,'0') small_vc,
    rpad('x',100)       padding
from
    generator   v1,
    generator   v2
where
    rownum <= 1280
;

create table t_12800
pctfree 99
pctused 1
as
with generator as (
    select  --+ materialize
        rownum id
    from dual
    connect by
        rownum <= 10000
)
select
    rownum          id,
    lpad(rownum,10,'0') small_vc,
    rpad('x',100)       padding
from
    generator   v1,
    generator   v2
where
    rownum <= 12800
;

create index t_1280_id on t_1280(id);
create index t_12800_id on t_12800(id);

alter table t_1280 storage (buffer_pool keep);
alter table t_12800 storage (buffer_pool keep);

alter index t_1280_id storage (buffer_pool keep);
alter index t_1280_id storage (buffer_pool keep);

------------------------------------------
--Query the data_object_id
------------------------------------------
select
    object_name, object_id, data_object_id
from
    user_objects
where
    object_name in  (
        'T_1280',
        'T_12800',
        'T_1280_ID',
        'T_12800_ID'
    )
order by
    object_id
;

