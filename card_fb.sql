select HASHV_KKOAR
, SQLID_KKOAR
, CHILDNO_KKOAR
, HINTID_KKOAR
, HINTTEXT_KKOAR
from x$kkoar_hint
where sqlid_kkoar in ('&1')
/
