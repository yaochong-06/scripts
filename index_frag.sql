--1. del_lf_rows / lf_rows > 0.3
--2. If the 'HEIGHT' is greater than 4
--3. If the number of rows in the index ('LF_ROWS') is significantly smaller than 'LF_BLKS' this can indicate a large number of deletes

validate index &1;
select del_lf_rows/lf_rows del_row_ratio, height, LF_ROWS, LF_BLKS from index_stats;
