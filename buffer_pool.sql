select name, block_size, buffers from v$buffer_pool
/
prompt buffer_pool_working_data_sets
select set_id,cnum_set,set_latch,nxt_repl,prv_repl,nxt_replax, prv_replax,cnum_repl,anum_repl, dbwr_num from x$kcbwds
/
