col server_type for A13
col process for A10

SELECT
    dfo_number, tq_id, server_type, instance, process, num_rows
FROM
    V$PQ_TQSTAT
ORDER BY
    dfo_number DESC, tq_id, server_type desc, instance, process;
