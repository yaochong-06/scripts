select 'ALTER SYSTEM KILL SESSION ''' || sid || ',' || s.SERIAL# || ''';' cmd from v$session s where event like 'latch: cache buffers chains' and status='ACTIVE';

select 'ALTER SYSTEM KILL SESSION ''' || sid || ',' || s.SERIAL# || ',@'|| inst_id || ''';' cmd from gv$session s where sql_id = '4zm49www5ks8u';


--batch kill one user's session
set serveroutput on size 100000;
begin
for x in (select 'ALTER SYSTEM KILL SESSION ''' || sid || ',' || s.SERIAL# || ''';' cmd from v$session s where event like 'latch: cache buffers chains')
loop
	begin
    execute immediate x.cmd;
	dbms_output.put_lint(x.cmd);
	exception when others then null;
	end;
end loop;
end;
/

--kill from OS level
select 'kill -9 ' || vp.spid
from v$session vs, v$process vp
where vs.paddr = vp.addr
and vs.username like 'CS2_HOUSEKEEPING_OWNER';

--rollback dead lock
SELECT 'ROLLBACK FORCE "' || p.local_tran_id || '";'  FROM dba_2pc_pending p WHERE p.state <> 'forced rollback';


--monitor the rollback transaction progress
select vs.sid, vt.used_ublk,vt.used_urec,vt.start_time,vt.log_io,vt.phy_io,vt.CR_get,vt.CR_change from v$transaction vt, v$session vs where vt.addr = vs.taddr;
select vs.sid, vt.used_ublk,vt.used_urec,vt.start_time,vt.log_io,vt.phy_io,vt.CR_get,vt.CR_change from v$transaction vt, v$session vs where vt.addr = vs.taddr and sid=&sid;


ps -ef | grep "LOCAL=NO" | awk '{print "kill -9 " $2}' | sh
