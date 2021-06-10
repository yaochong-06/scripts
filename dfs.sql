select chr(bitand(&1,-16777216)/16777215) ||
chr(bitand(&1,16711680)/65535) type,
mod(&1, 16) md
from dual
/
