version = uint8(131)

# See http://erlang.org/doc/apps/erts/erl_ext_dist.html, tags are in the same
# order.

# Compressed tag is mentioned in introduction
# (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id86906)
compressedtag = uint8(80)

# ATOM_CACHE_REF (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id87859)
atomcachereftag = uint8(82)

# SMALL_INTEGER_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id87935)
smallinttag = uint8(97)

# INTEGER_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id87998)
inttag = uint8(98)

# FLOAT_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id88062)
floattag = uint8(99)

# ATOM_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id88138)
atomtag = uint8(100)

# REFERENCE_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id88237)
reftag = uint8(101)

# PORT_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id88395)
porttag = uint8(102)

# PID_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id88514)
pidtag = uint8(103)

# SMALL_TUPLE_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id88658)
smalltupletag = uint8(104)

# LARGE_TUPLE_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id88750)
largetupletag = uint8(105)

# MAP_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id88840)
maptag = uint8(116)

# NIL_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id88950)
niltag = uint8(106)

# STRING_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id89001)
stringtag = uint8(107)

# LIST_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id89094)
listtag = uint8(108)

# BINARY_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id89212)
bintag = uint8(109)

# SMALL_BIG_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id89309)
smallbiginttag = uint8(110)

# LARGE_BIG_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id89416)
largebiginttag = uint8(111)

# NEW_REFERENCE_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id89519)
newreftag = uint8(114)

# SMALL_ATOM_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id89692)
smallatomtag = uint8(115)

# FUN_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id89811)
funtag = uint8(117)

# NEW_FUN_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id90058)
newfuntag = uint8(112)

# EXPORT_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id90435)
exporttag = uint8(113)

# BIT_BINARY_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id90579)
bitbintag = uint8(77)

# NEW_FLOAT_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id90685)
newfloattag = uint8(70)

# ATOM_UTF8_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id90753)
atomutf8tag = uint8(118)

# SMALL_ATOM_UTF8_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id90855)
smallatomutf8tag = uint8(119)
