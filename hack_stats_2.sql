--
-- hack the Frequency histogram and density for the column
-- the m_cutoff must <= 254
--

define TABLE_NAME='T1'
define COLUMN_NAME='SKEW'

declare

	m_statrec		dbms_stats.statrec;
	m_val_array		dbms_stats.numarray;

--	m_val_array		dbms_stats.datearray;
--	m_val_array		dbms_stats.chararray;		-- 32 byte char max
--	m_val_array		dbms_stats.rawarray;		-- 32 byte raw max
	
	m_distcnt		number;
	m_density		number;
	m_nullcnt		number;
	m_avgclen		number;

	m_cutoff		number :=50;				-- set here your own variable
	m_rows_for_non_freq		number :=50;		-- set here your own variable
begin

	dbms_stats.get_column_stats(
		ownname		=> NULL,
		tabname		=> '&&TABLE_NAME',
		colname		=> '&&COLUMN_NAME', 
		distcnt		=> m_distcnt,
		density		=> m_density,
		nullcnt		=> m_nullcnt,
		srec		=> m_statrec,
		avgclen		=> m_avgclen
	); 

--
--	Load column information into the two critical arrays
--

	select *
	bulk collect 
	into
		m_val_array, 
		m_statrec.bkvals
	from 
	(
		select 
			&&COLUMN_NAME, 
			count(*)
		from
			&&TABLE_NAME
		group by
			&&COLUMN_NAME
		order by
			count(*) desc
	)
	where
	rownum <= m_cutoff
	order by 
	&&COLUMN_NAME	
	;


	m_statrec.epc		:= m_val_array.count;

	--
	--	Should terminate here if the count exceeds 254
	--

	dbms_stats.prepare_column_values(
		srec	=> m_statrec,
		numvals	=> m_val_array			
	);

	select
		1/count(*) * m_rows_for_non_freq
	into
		m_density
	from
		&&TABLE_NAME;

	dbms_stats.set_column_stats(
		ownname		=> NULL,
		tabname		=> '&&TABLE_NAME',
		colname		=> '&&COLUMN_NAME', 
		distcnt		=> m_distcnt,
		density		=> m_density,
		nullcnt		=> m_nullcnt,
		srec		=> m_statrec,
		avgclen		=> m_avgclen
--		flags		=> 0
	); 

end;
/
