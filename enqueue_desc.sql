--------------------------------------------------------------------------------
--
-- File name:   enqueue_desc.sql
-- Purpose:     query the enqueue description
--
-- Author:      Sidney Chen
-- Copyright:   (c) http://sid.gd
--              
-- Usage:       @enqueue_desc us
--				@enqueue_desc
--
--------------------------------------------------------------------------------

col REQ_DESCRIPTION for a100
select EQ_TYPE,REQ_DESCRIPTION from V$ENQUEUE_STATISTICS where EQ_TYPE like upper('%&1%')
/

