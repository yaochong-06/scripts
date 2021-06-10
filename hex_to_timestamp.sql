select to_timestamp(
        to_char( to_number( substr( p_str, 1, 2 ), 'xx' ) - 100, 'fm00' ) ||
        to_char( to_number( substr( p_str, 3, 2 ), 'xx' ) - 100, 'fm00' ) ||
        to_char( to_number( substr( p_str, 5, 2 ), 'xx' ), 'fm00' ) ||
        to_char( to_number( substr( p_str, 7, 2 ), 'xx' ), 'fm00' ) ||
        to_char( to_number( substr( p_str,9, 2 ), 'xx' )-1, 'fm00' ) ||
        to_char( to_number( substr( p_str,11, 2 ), 'xx' )-1, 'fm00' ) ||
        to_char( to_number( substr( p_str,13, 2 ), 'xx' )-1, 'fm00' ), 'yyyymmddhh24miss' )
from (select '&1' p_str from dual);
