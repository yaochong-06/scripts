








set serveroutput on 
set linesize 500
set pages 0

undefine table_name
undefine owner
var table_name varchar2(100);
var owner varchar2(100);

begin
  :table_name := upper('&table_name');
  :owner :=upper('&owner');
end;
/


declare
    cursor c_i is SELECT A.INDEX_NAME,A.COLUMN_NAME,A.COLUMN_POSITION,decode(b.TABLESPACE_NAME,null,'None',B.TABLESPACE_NAME) as TABLESPACE_NAME,B.INDEX_TYPE,B.DEGREE,
       round(C.BYTES / 1024 / 1024) AS INDEX_MB,
       A.DESCEND,
       case when B.STATUS = 'UNUSABLE' then 'NO' else 'YES' end USABLE,
       decode(to_char(B.last_analyzed,'yymmdd hh24:mi'),null,'None',
       to_char(b.last_analyzed,'yymmdd hh24:mi')) as last_analyzed,
       case when b.visibility = 'VISIBLE' then 'YES' else 'NO ' end visibility,
       case when uniqueness = 'UNIQUE' then 'YES' else 'NO ' end UNIQUENESS
  FROM DBA_IND_COLUMNS A, DBA_INDEXES B, DBA_SEGMENTS C
 WHERE A.INDEX_NAME = B.INDEX_NAME
   AND A.TABLE_NAME = :table_name
   AND a.INDEX_OWNER = :owner
   AND C.SEGMENT_NAME = A.INDEX_NAME
 ORDER BY INDEX_NAME, COLUMN_POSITION;
    v_i c_i%rowtype;

    cursor c_foreign_key_without_index is select owner,
                                                 table_name,
                                                 constraint_name,
                                                 substr(cname1 || nvl2(cname2,','||cname2,null) || nvl2(cname3,','||cname3,null) || nvl2(cname4,','||cname4,null) || nvl2(cname5,','||cname5,null) || nvl2(cname6,','||cname6,null) || nvl2(cname7,','||cname7,null) || nvl2(cname8,','||cname8,null),0,400) as cols
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
                   from dba_cons_columns where owner not in ('SYSTEM','OWBSYS','XS$NULL','FLOWS_FILES','WMSYS','DIP','XDB','SYS','ANONYMOUS','QMONITOR','ORDPLUGINS','OUTLN','ORDSYS','SI_INFORMTN_SCHEMA',
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
         );
         v_f c_foreign_key_without_index%rowtype;
         cursor c_par_ind is select index_name, PARTITION_POSITION as PART_POSITION, PARTITION_NAME, BLEVEL, LEAF_BLOCKS, NUM_ROWS, DISTINCT_KEYS,
                             CLUSTERING_FACTOR,
                             case when STATUS = 'UNUSABLE' then 'NO' else 'YES' end USABLE,
                             high_value
                             from dba_ind_partitions
                             where index_name in 
                            (
                            select index_name from dba_indexes where table_name = UPPER(:table_name)
                            and INDEX_OWNER = upper(:owner)
                            and partitioned = 'YES') order by index_name, partition_position;

         v_part c_par_ind%rowtype;



begin

  dbms_output.put_line('
Index Information(contains Global and Local index)');
  dbms_output.put_line('======================');
  dbms_output.put_line('---------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  dbms_output.put_line('| INDEX_NAME         |' || ' COLUMN_NAME        ' || '| COLUMN_POSITION |' || ' TABLESPACE_NAME ' || '| INDEX_TYPE |' || ' DEGREE ' || '| INDEX_MB |' || ' DESCEND ' || '| USABLE |'  || ' LAST_ANALYZED '|| '| VISIABLE |'  || ' UNIQUENESS '|| '|');
  dbms_output.put_line('---------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  open c_i;
    loop fetch c_i into v_i;
    exit when c_i%notfound;
    dbms_output.put_line('| ' || rpad(v_i.INDEX_NAME,18) ||' | '|| rpad(v_i.COLUMN_NAME,18) || ' | '|| lpad(v_i.COLUMN_POSITION,15) || ' | '|| lpad(v_i.TABLESPACE_NAME,15) || ' | '|| lpad(v_i.INDEX_TYPE,10) || ' | '|| lpad(v_i.DEGREE,6) ||  ' | '|| lpad(v_i.INDEX_MB,8) || ' | '|| lpad(v_i.DESCEND,7) || ' | '|| lpad(v_i.USABLE,6) || ' | '|| lpad(v_i.LAST_ANALYZED,13) || ' | '|| lpad(v_i.visibility,8) || ' | '|| lpad(v_i.UNIQUENESS,11) ||'|');
    end loop;
    dbms_output.put_line('---------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  close c_i;


    dbms_output.put_line('
Partition Index Information(if index is Local Index)');
  dbms_output.put_line('======================');
  dbms_output.put_line('---------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  dbms_output.put_line('| INDEX_NAME         |' || ' PART_POSITION ' || '| PARTITION_NAME |' || ' BLEVEL ' || '| LEAF_BLOCKS |' || ' NUM_ROWS ' || '| DISTINCT_KEYS |' || ' CLUSTERING_FACTOR '  || '| USABLE |'|| ' HIGH_VALUE                         '|| '|');
  dbms_output.put_line('---------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  open c_par_ind;
    loop fetch c_par_ind into v_part;
    exit when c_par_ind%notfound;
    dbms_output.put_line('| ' || rpad(v_part.INDEX_NAME,18) ||' | '|| lpad(v_part.PART_POSITION,13) || ' | '|| lpad(v_part.PARTITION_NAME,14) || ' | '|| lpad(v_part.BLEVEL,6) || ' | '|| lpad(v_part.LEAF_BLOCKS,11) || ' | '|| lpad(v_part.NUM_ROWS,8) ||  ' | '|| lpad(v_part.DISTINCT_KEYS,13) || ' | '|| lpad(v_part.CLUSTERING_FACTOR,17) || ' | '|| lpad(v_part.USABLE,6) || ' | '|| lpad(v_part.HIGH_VALUE,35)||'|');
    end loop;
    dbms_output.put_line('---------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  close c_par_ind;





  dbms_output.put_line('
Foreign Key Without Index Information');
  dbms_output.put_line('======================');
  dbms_output.put_line('---------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  dbms_output.put_line('| OWNER                |' || ' TABLE_NAME            ' || '| CONSTRAINT_NAME         |' || ' COLUMNS                                                                                        ' || '|');
  dbms_output.put_line('---------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  open c_foreign_key_without_index;
    loop fetch c_foreign_key_without_index into v_f;
    exit when c_foreign_key_without_index%notfound;
    dbms_output.put_line('| ' || rpad(v_f.OWNER,20) ||' | '|| rpad(v_f.TABLE_NAME,21) || ' | '|| rpad(v_f.CONSTRAINT_NAME,23) || ' | ' || rpad(v_f.cols,95) || '|');
    end loop;
    dbms_output.put_line('---------------------------------------------------------------------------------------------------------------------------------------------------------------------------');
  close c_foreign_key_without_index;

end;
/







 
















