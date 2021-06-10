rem
rem	Script:		core_demo_02.sql
rem	Author:		Jonathan Lewis
rem	Dated:		Feb 2011
rem	Purpose:	
rem
rem	Last tested 
rem		11.2.0.2
rem		10.2.0.3		
rem	Not relevant
rem		 9.2.0.8
rem		 8.1.7.4
rem
rem	Notes:
rem	Can only be run as SYS in this form
rem
rem	Diagnostics for core undo/redo concepts
rem

column indx format 9999

--	Size of in-memory undo and private redo after a small change

select
	indx,
	to_number(ktifpupe,'XXXXXXXXXXXXXXXXXXXXXXX') -
	to_number(ktifpupb,'XXXXXXXXXXXXXXXXXXXXXXX')		undo_size,
	to_number(ktifpupc,'XXXXXXXXXXXXXXXXXXXXXXX') -
		to_number(ktifpupb,'XXXXXXXXXXXXXXXXXXXXXXX')	undo_usage,
	ktifprpb											redo_start,
	to_number(ktifprpe,'XXXXXXXXXXXXXXXXXXXXXXX') -
		to_number(ktifprpb,'XXXXXXXXXXXXXXXXXXXXXXX')	redo_size,
	to_number(ktifprpc,'XXXXXXXXXXXXXXXXXXXXXXX') -
		to_number(ktifprpb,'XXXXXXXXXXXXXXXXXXXXXXX')	redo_usage
	from
		x$ktifp
;

--	Sizes of private redo


select
	indx,
	PNEXT_BUF_KCRFA_CLN,
	PTR_KCRF_PVT_STRAND,
	FIRST_BUF_KCRFA,
	LAST_BUF_KCRFA,
--	LASTCHANGE_KCRFA,			not available in 11.2
	STRAND_SIZE_KCRFA	strand_size,
	SPACE_KCRF_PVT_STRAND	strand_space
from
	x$kcrfstrand
;
