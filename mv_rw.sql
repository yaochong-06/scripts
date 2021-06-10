--
-- desc why the sql is not using the mview
-- result of dbms_mview.explain_rewrite
--

SELECT message
FROM rewrite_table
WHERE statement_id = '&1';
