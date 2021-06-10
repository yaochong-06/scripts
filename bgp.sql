select paddr, name, description from v$bgprocess where rawtohex(paddr) <> '00' order by name;
