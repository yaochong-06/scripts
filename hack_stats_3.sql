
--
-- hack the histogram for the column of date type 
-- !!! without histogram
--

define TABLE_NAME='MCCI_ILM_INTERACTION'
define COLUMN_NAME='INTERACTION_DT'

declare
	m_statrec		dbms_stats.statrec;
--	m_val_array		dbms_stats.numarray;

	m_val_array		dbms_stats.datearray;
--	m_val_array		dbms_stats.chararray;		-- 32 byte char max
--	m_val_array		dbms_stats.rawarray;		-- 32 byte raw max
	
	m_distcnt		number;
	m_density		number;
	m_nullcnt		number;
	m_avgclen		number;

	m_low			date;
	m_high			date;
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
	-- set the increase high value one month
	--

	IF m_statrec.epc = 2 THEN
		SELECT raw_to_date(low_value), raw_to_date(high_value) INTO m_low, m_high
		FROM user_tab_col_statistics
		WHERE table_name = '&&TABLE_NAME' AND column_name = '&&COLUMN_NAME';

		m_high := ADD_MONTHS(m_high, 1);

		m_val_array := DBMS_STATS.DATEARRAY(m_low, m_high);
		m_statrec.minval:=NULL;
		m_statrec.maxval:=NULL;
		m_statrec.bkvals:=NULL;
		m_statrec.novals:=NULL;

		--
		--	Should terminate here if the count exceeds 254
		--

		dbms_stats.prepare_column_values(
			srec		=> m_statrec,
			datevals	=> m_val_array			
		);

		dbms_stats.set_column_stats(
			ownname		=> NULL,
			tabname		=> '&&TABLE_NAME',
			colname		=> '&&COLUMN_NAME', 
			distcnt		=> m_distcnt,
			density		=> m_density,
			nullcnt		=> m_nullcnt,
			srec		=> m_statrec,
			avgclen		=> m_avgclen,
			no_invalidate	=> false
		); 

	end if;
end;
/
