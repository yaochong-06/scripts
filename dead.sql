select distinct KTUXECFL,count(*) from x$ktuxe group by KTUXECFL;
select ADDR,KTUXEUSN,KTUXESLT,KTUXESQN,KTUXESIZ, KTUXECFL from x$ktuxe where KTUXECFL ='DEAD';
select ADDR,KTUXEUSN,KTUXESLT,KTUXESQN,KTUXESIZ, KTUXECFL from x$ktuxe where KTUXESIZ > 1024;
