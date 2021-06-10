-- 检查数据库自动收集统计信息任务是否开启
select  status from dba_autotask_client  where client_name='auto optimizer stats collection';
