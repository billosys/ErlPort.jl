version = UInt8(131)

# See http://erlang.org/doc/apps/erts/erl_ext_dist.html, tags are in the same
# order.

# Compressed tag is mentioned in introduction
# (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id86906)
compressedtag = UInt8(80)

# ATOM_CACHE_REF (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id87859)
atomcachereftag = UInt8(82)

# SMALL_INTEGER_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id87935)
smallinttag = UInt8(97)

# INTEGER_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id87998)
inttag = UInt8(98)

# FLOAT_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id88062)
floattag = UInt8(99)

# ATOM_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id88138)
atomtag = UInt8(100)

# REFERENCE_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id88237)
reftag = UInt8(101)

# PORT_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id88395)
porttag = UInt8(102)

# PID_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id88514)
pidtag = UInt8(103)

# SMALL_TUPLE_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id88658)
smalltupletag = UInt8(104)

# LARGE_TUPLE_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id88750)
largetupletag = UInt8(105)

# MAP_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id88840)
maptag = UInt8(116)

# NIL_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id88950)
niltag = UInt8(106)

# STRING_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id89001)
stringtag = UInt8(107)

# LIST_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id89094)
listtag = UInt8(108)

# BINARY_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id89212)
bintag = UInt8(109)

# SMALL_BIG_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id89309)
smallbiginttag = UInt8(110)

# LARGE_BIG_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id89416)
largebiginttag = UInt8(111)

# NEW_REFERENCE_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id89519)
newreftag = UInt8(114)

# SMALL_ATOM_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id89692)
smallatomtag = UInt8(115)

# FUN_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id89811)
funtag = UInt8(117)

# NEW_FUN_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id90058)
newfuntag = UInt8(112)

# EXPORT_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id90435)
exporttag = UInt8(113)

# BIT_BINARY_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id90579)
bitbintag = UInt8(77)

# NEW_FLOAT_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id90685)
newfloattag = UInt8(70)

# ATOM_UTF8_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id90753)
atomutf8tag = UInt8(118)

# SMALL_ATOM_UTF8_EXT (http://erlang.org/doc/apps/erts/erl_ext_dist.html#id90855)
smallatomutf8tag = UInt8(119)
