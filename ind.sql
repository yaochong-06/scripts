/*
  this scripts show available indexes & index columns of input table_name.
*/

prompt Show The Index Information of The Input Table(args:table_name):
undefine table_name
var table_name varchar2(100);
begin
  :table_name := upper('&table_name');
end;
/
set linesize 500
col table_name format a25
col index_name format a30
col column_name format a20
col tablespace_name format a15
col index_type format a22
col index_owner for a12
set pages 100
col degree for a6
col "UNUSABLE/USABLE" for a10
col DESCEND for a6
col index_type for a21
col INDEX_MB for 999999
col column_position heading 'COLUMN|POSITION'
SELECT A.INDEX_OWNER,
       A.TABLE_NAME,
       A.INDEX_NAME,
       A.COLUMN_NAME,
       A.COLUMN_POSITION,
       B.TABLESPACE_NAME,
       B.INDEX_TYPE,
       B.DEGREE,
       C.BYTES / 1024 / 1024 AS INDEX_MB,
       A.DESCEND,
       case when B.STATUS = 'UNUSABLE' then 'UNUSABLE' else 'USABLE' end "UNUSABLE/USABLE",
       B.last_analyzed,
       case when b.visibility = 'VISIBLE' then 'YES' else 'NO ' end VISIBILITY,
       case when uniqueness = 'UNIQUE' then 'YES' else 'NO ' end UNIQUENESS
  FROM DBA_IND_COLUMNS A, DBA_INDEXES B, DBA_SEGMENTS C
 WHERE A.INDEX_NAME = B.INDEX_NAME
   AND A.TABLE_NAME = :table_name
   AND C.SEGMENT_NAME = A.INDEX_NAME
 ORDER BY INDEX_NAME, COLUMN_POSITION
/

prompt Display the Foreign key without index...

set linesize 300
col owner for a30
col columns for a40 
col tablename for a20
col constraint_name for a30 

select owner, table_name, constraint_name,
     cname1 || nvl2(cname2,','||cname2,null) ||
     nvl2(cname3,','||cname3,null) || nvl2(cname4,','||cname4,null) ||
     nvl2(cname5,','||cname5,null) || nvl2(cname6,','||cname6,null) ||
     nvl2(cname7,','||cname7,null) || nvl2(cname8,','||cname8,null)
            columns
  from ( select b.owner,
                b.table_name,
                b.constraint_name,
                max(decode( position, 1, column_name, null )) cname1,
                max(decode( position, 2, column_name, null )) cname2,
                max(decode( position, 3, column_name, null )) cname3,
                max(decode( position, 4, column_name, null )) cname4,
                max(decode( position, 5, column_name, null )) cname5,
                max(decode( position, 6, column_name, null )) cname6,
                max(decode( position, 7, column_name, null )) cname7,
                max(decode( position, 8, column_name, null )) cname8,
                count(*) col_cnt
           from (select owner,
                        constraint_name,
                        column_name,
                        position
                   from dba_cons_columns where owner not in ('SYSTEM','OWBSYS','XS$NULL','FLOWS_FILES','WMSYS','DIP',
                      'XDB','SYS','ANONYMOUS','SCOTT','QMONITOR','ORDPLUGINS','OUTLN','ORDSYS','SI_INFORMTN_SCHEMA',
                      'ORDDATA','OJVMSYS','SPATIAL_WFS_ADMIN_USR','MDSYS','LBACSYS','SPATIAL_CSW_ADMIN_USR','DVSYS','DBSNMP','APEX_PUBLIC_USER',
                      'APPQOSSYS','APEX_040200','ORACLE_OCM','AUDSYS','CTXSYS','MDDATA','APEX_030200','EXFSYS','MGMT_VIEW','OLAPSYS','SYSMAN','OWBSYS_AUDIT',
'WH_SYNC','GSMADMIN_INTERNAL')) a,
                dba_constraints b
          where a.constraint_name = b.constraint_name
            and b.constraint_type = 'R'
            and a.owner = b.owner
          group by b.owner, b.table_name, b.constraint_name
       ) cons
 where col_cnt > ALL
         ( select count(*)
             from dba_ind_columns i
            where i.table_name = cons.table_name
              and i.column_name in (cname1, cname2, cname3, cname4,
                                    cname5, cname6, cname7, cname8 )
              and i.column_position <= cons.col_cnt
              and i.INDEX_OWNER = cons.owner
            group by i.index_name
         )
/



select index_name, partition_position, partition_name, BLEVEL, LEAF_BLOCKS, NUM_ROWS, DISTINCT_KEYS,
	AVG_LEAF_BLOCKS_PER_KEY, AVG_DATA_BLOCKS_PER_KEY, CLUSTERING_FACTOR,
	STATUS, LAST_ANALYZED, high_value
from dba_ind_partitions
where index_name in 
(
select index_name
from dba_indexes
where table_name = UPPER(:table_name)
and partitioned = 'YES'
)
order by index_name, partition_position
/

