select 'alter system kill session ''' || sid || ',' || serial# || ''';' from v$session where type!='BACKGROUND';
