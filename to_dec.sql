--to_hex: transform hex to dec
--usage:  @to_dec &1
--author: sidney chen
--date:   Nov/30/2011

col hex_value justify right
select to_number('&1','xxxxxxxxxxxxxxxxxxxx') dec_value from dual;
