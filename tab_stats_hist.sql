select savtime, rowcnt, blkcnt, avgrln, analyzetime from sys.wri$_optstat_tab_history where obj#=&1;
