col PARAMETER1 for A20
col PARAMETER2 for A20
col PARAMETER3 for A20

select name, parameter1, parameter2, parameter3 from v$event_name where lower(name) like lower('%&1%');
