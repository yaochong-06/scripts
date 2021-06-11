col dba_object head object for a12 truncate

select block_class, object_type, dba_object, tch, dirty, count(*)
from
(select  /*+ ORDERED */
        decode(bh.class,1,'data block',2,'sort block',3,'save undo block',
               4,'segment header',5,'save undo header',6,'free list',7,'extent map',
               8,'1st level bmb',9,'2nd level bmb',10,'3rd level bmb', 11,'bitmap block',
               12,'bitmap index block',13,'file header block',14,'unused',
               15,'system undo header',16,'system undo block', 17,'undo header',
               18,'undo block'
        ) block_class,
        o.object_type,
        o.owner||'.'||o.object_name             dba_object,
        bh.tch,
        decode(mod(flag, 2), 1, 'Y', 'N') dirty
from
        x$bh            bh,
        dba_objects     o
where
        bh.obj = o.data_object_id
and     o.data_object_id in
        ( select data_object_id
          from all_objects
         where object_name = upper('&OBJECT_NAME') AND owner = upper('&owner')
        ))
group by block_class, object_type, dba_object, tch, dirty
order by count(*)
/
