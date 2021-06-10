--to_hex: transform dec to hex
--usage:  @to_hex &1
--author: sidney chen
--date:   Nov/30/2011
col hex_value justify right
select to_char(&1,'xxxxxxxxxxxxxxxxxxxx') hex_value from dual;
