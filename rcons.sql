rem **************************************************************** 
rem 
rem If necessary, reformat the columns to avoid column wrapping. 
rem 
rem Change the table name USER_CONSTRAINTS to ALL_CONSTRAINTS or  
rem DBA_CONSTRAINTS to change the scope of the query.  
rem 
rem To list the reference on a particular table only, add the table 
rem name to the WHERE clause, i.e., 
rem  
rem    AND A.TABLE_NAME = &tbl_name 
rem 
rem **************************************************************** 
 
column table_name         format a20 
column key_name           format a14 
column referencing_table  format a20 
column foreign_key_name   format a14 
column fk_status          format a8 
 
set linesize 80 
set pagesize 0 
set tab      off 
set space    1 
 
SELECT  
    A.TABLE_NAME table_name, 
    A.CONSTRAINT_NAME key_name, 
    B.TABLE_NAME referencing_table, 
    B.CONSTRAINT_NAME foreign_key_name, 
    B.STATUS fk_status  
FROM USER_CONSTRAINTS A, USER_CONSTRAINTS B  
WHERE 
    A.CONSTRAINT_NAME = B.R_CONSTRAINT_NAME and 
    B.CONSTRAINT_TYPE = 'R' 
ORDER BY 1, 2, 3, 4;
