PARSE ERROR: ospid=32915, error=1013 for statement:
explain plan for
select /*test*/count(1) from custentryelist h where h.status = '70' and h.opdatatype is null and h.predate >= to_date('2018-01-06 00:00:00','yyyy-mm-dd hh24:mi:ss') and h.predate < to_date('2018-01-07 00:00:00','yyyy-mm-dd hh24:mi:ss') and cbepcomcode='0000010';

Additional information: hd=0x259bccb8d8 phd=0x259bff8848 flg=0x20 cisid=85 sid=85 ciuid=85 uid=85
Sat Jan 06 17:34:27 2018
PARSE ERROR: ospid=32915, error=1013 for statement:
select count(1) from custentryelist h where h.status = '70' and h.opdatatype is null and h.predate >= to_date('2018-01-06 00:00:00','yyyy-mm-dd hh24:mi:ss') and h.predate < to_date('2018-01-07 00:00:00','yyyy-mm-dd hh24:mi:ss') and cbepcomcode='0000010'
Additional information: hd=0x259bccb8d8 phd=0x259bff8848 flg=0x20 cisid=85 sid=85 ciuid=85 uid=85
Sat Jan 06 17:38:02 2018
PARSE ERROR: ospid=17178, error=947 for statement:
insert /*+ append */ into sys.ora_temp_1_ds_3680523 SELECT /*+  no_parallel(t) no_parallel_index(t) dbms_stats cursor_sharing_exact use_weak_name_resl dynamic_sampling(0) no_monitoring no_substrb_pad  */"PACKFLAG","GROSSWEIGHT","LPN","ORDERCODE","REPUSHDATE","REPUSHNUM","WMS_SDATE","EXC_REMARK","BBACKTAX","WEIGHKGS","SPECCCODETYPE","CNWLBGPREPAREICODE","OP_INVALIDTIME", rowid SYS_DS_ALIAS_0  from "CUSTOMS"."CUSTENTRYELIST" sample (  9.2064076597)  t  WHERE TBL$OR$IDX$PART$NUM("CUSTOMS"."CUSTENTRYELIST",0,4,0,"ROWID") = :objn UNION ALL SELECT  "PACKFLAG", "GROSSWEIGHT", "LPN", "ORDERCODE", "REPUSHDATE", "REPUSHNUM", "WMS_SDATE", "EXC_REMARK", "BBACKTAX", "WEIGHKGS", "SPECCCODETYPE", "CNWLBGPREPAREICODE", "OP_INVALIDTIME", SYS_DS_ALIAS_0 FROM sys.ora_temp_1_ds_3680523 WHERE 1 = 0
Additional information: hd=0x257fd85f98 phd=0x257a3ddc40 flg=0x101476 cisid=0 sid=0 ciuid=0 uid=0
----- PL/SQL Call Stack -----
  object      line  object
    handle    number  name
    0x25771fbb28     15133  package body SYS.DBMS_STATS
    0x25771fbb28     15256  package body SYS.DBMS_STATS
    0x25771fbb28     15414  package body SYS.DBMS_STATS
    0x25771fbb28     22119  package body SYS.DBMS_STATS
    0x25771fbb28     22947  package body SYS.DBMS_STATS
    0x25771fbb28     23262  package body SYS.DBMS_STATS
    0x25771fbb28     24077  package body SYS.DBMS_STATS
    0x25771fbb28     31145  package body SYS.DBMS_STATS
    Sat Jan 06 17:38:57 2018
    PARSE ERROR: ospid=13037, error=900 for statement:
    explain plan set statement_id='STATEMENTID_15152313518192965' for alter system kill session '3134,64829'
    Additional information: hd=0x257f1040e0 phd=0x2576bb17a0 flg=0x28 cisid=84 sid=84 ciuid=84 uid=84


SQL> explain plan for
select /*test*/count(1) from custentryelist h where h.status = '70' and h.opdatatype is null and h.predate >= to_date('2018-01-06 00:00:00','yyyy-mm-dd hh24:mi:ss') and h.predate < to_date('2018-01-07 00:00:00','yyyy-mm-dd hh24:mi:ss') and cbepcomcode='0000010';  2
^Cselect /*test*/count(1) from custentryelist h where h.status = '70' and h.opdatatype is null and h.predate >= to_date('2018-01-06 00:00:00','yyyy-mm-dd hh24:mi:ss') and h.predate < to_date('2018-01-07 00:00:00','yyyy-mm-dd hh24:mi:ss') and cbepcomcode='0000010'
                             *
                             ERROR at line 2:
                             ORA-01013: user requested cancel of current operation
