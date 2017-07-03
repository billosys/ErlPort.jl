using ErlPort.Exceptions
using ErlPort.ErlTerms.Decode

include("Testing.jl")

# XXX Do we need to test REFERENCE_EXT, PORT_EXT, PID_EXT, NEW_REFERENCE_EXT, FUN_EXT, NEW_FUN_EXT, EXPORT_EXT

# data for use by tests
badsizecompdata = vcat(b"\x83P\0\0\0\x16\x78\xda\xcb\x66\x10\x49\xc1\2\0\x5d",
                       b"\x60\x08\x50")
compdata1 = b"\x83P\0\0\0\x17\x78\xda\xcb\x66\x10\x49\xc1\2\0\x5d\x60\x08\x50"
compdata2 = vcat(b"\x83P\0\0\0\x17\x78\xda\xcb\x66\x10\x49\xc1\2\0\x5d\x60",
                 b"\x08\x50tail")

tuplepart = b"d\0\1ad\0\1bd\0\1cd\0\1dd\0\1ed\0\1fd\0\1gd\0\1hd\0\1id\0\1jd\0\1kd\0\1ld\0\1md\0\1nd\0\1od\0\1p"
largetuple1 = vcat(b"i\0\0\1\0",
                   tuplepart, tuplepart, tuplepart, tuplepart, tuplepart, tuplepart,
                   tuplepart, tuplepart, tuplepart, tuplepart, tuplepart, tuplepart,
                   tuplepart, tuplepart, tuplepart, tuplepart)

smallbigintmax = vcat(b"n\xff\0", fill(UInt8(255), 255))
largebigintmin = vcat(b"o\0\0\1\0\0", fill(UInt8(0), 255), b"\1")

# tests for supporting functions
testcase() do
    @test size1unpack(b"\x0a")             == 0x0a
    @test size1unpack(b"\xaa")             == 0xaa
    @test size2unpack(b"\x0a\x0b")         == 0x0a0b
    @test size2unpack(b"\xaa\xbb")         == 0xaabb
    @test size4unpack(b"\x0a\x0b\x0c\x0d") == 0x0a0b0c0d
    @test size4unpack(b"\xaa\xbb\xcc\xdd") == 0xaabbccdd

    expected = [107,0,20,100,100,100,100,100,100,100,100,100,100,
                100,100,100,100,100,100,100,100,100,100]
    @test decompressterm(compdata1) == expected
end

# basic decode errors
testcase() do
    @test_throws UnsupportedType decode("")
    @test_throws IncompleteData decode(b"")
    @test_throws UnknownProtocolVersion decode(b"\0")
    @test_throws IncompleteData decode(b"\x83")
end

# decode empty list (that is in fact a nil) (NIL_EXT)
testcase() do
    @test_throws IncompleteData decodenil(b"")
    #@test_throws IncompleteData decodenil(b"\0") # XXX decode functions don't check term tag
    @test decode(b"\x83j") == ([], b"")
    @test decodenil(b"j") == ([], b"")
    @test decodenil(b"jtail") == ([], b"tail")
end

# decode atoms (ATOM_EXT)
testcase() do
    @test_throws IncompleteData decode(b"\x83d")
    @test_throws IncompleteData decode(b"\x83d\0")
    @test_throws IncompleteData decode(b"\x83d\0\1")
    @test decode(b"\x83d\0\0") == (symbol(""), [])
    @test decode(b"\x83d\0\0tail") == (symbol(""), b"tail")
    @test decode(b"\x83d\0\4test") == (:test, b"")
    @test decode(b"\x83d\0\4testtail") == (:test, b"tail")
    @test decode(b"\x83d\0\4true") == (true, b"")
    @test decode(b"\x83d\0\5false") == (false, b"")
    @test decode(b"\x83d\0\x09undefined") == (nothing, b"")
    @test decodeatom(b"d\0\0") == (symbol(""), [])
    @test decodeatom(b"d\0\0tail") == (symbol(""), b"tail")
    @test decodeatom(b"d\0\4test") == (:test, b"")
    @test decodeatom(b"d\0\4testtail") == (:test, b"tail")
    @test decodeatom(b"d\0\4true") == (true, b"")
    @test decodeatom(b"d\0\5false") == (false, b"")
    @test decodeatom(b"d\0\x09undefined") == (nothing, b"")
end

# decode predefined atoms (ATOM_CACHE_REF)
testcase() do
    #atomcachereftag = UInt8(82)
end

# decode small atoms (SMALL_ATOM_EXT)
testcase() do
    #smallatomtag = UInt8(115)
end

# decode UTF-8 atoms (ATOM_UTF8_EXT)
testcase() do
    #atomutf8tag = UInt8(118)
end

# decode small, UTF-8 atoms (SMALL_ATOM_UTF8_EXT)
testcase() do
    #smallatomutf8tag = UInt8(119)
end

# decode string list (STRING_EXT)
testcase() do
    @test_throws IncompleteData decodestring(b"")
    @test_throws IncompleteData decodestring(b"\0")
    @test_throws IncompleteData decodestring(b"\0\0")
    @test decode(b"\x83k\0\1\1") == (b"\1", b"")
    @test decode(b"\x83k\0\6string") == (b"string", b"")
    @test decodestring(b"k\0\0") == (b"", b"")
    @test decodestring(b"k\0\0tail") == (b"", b"tail")
    @test decodestring(b"k\0\6string") == (b"string", b"")
    @test decodestring(b"k\0\x1f\xc3\xa1rv\xc3\xadzt\xc5\xb1r\xc5\x91\x20t\xc3\xbck\xc3\xb6rf\xc3\xbar\xc3\xb3g\xc3\xa9p") == (b"árvíztűrő tükörfúrógép", b"")
end

# decode list (LIST_EXT)
testcase() do
    @test decode(b"\x83l\0\0\0\4a\1d\0\1aa\3d\0\x09undefinedj") == ([1,:a,3,nothing], b"")
    @test decodelist(b"l\0\0\0\4a\1d\0\1aa\3d\0\x09undefinedj") == ([1,:a,3,nothing], b"")
    @test decodelist(b"l\0\0\0\4a\1d\0\1aa\3d\0\x09undefinedjtail") == ([1,:a,3,nothing], b"tail")
end

# decode improper list (LIST_EXT continued)
# XXX how should we handle improper lists in Julia?

# decode small tuple (SMALL_TUPLE_EXT)
testcase() do
    @test_throws IncompleteData decodesmalltuple(b"")
    @test_throws IncompleteData decodesmalltuple(b"\0")
    @test_throws IncompleteData decodesmalltuple(b"h\1")
    @test decode(b"\x83h\2a\1a\2") == ((1,2), b"")
    @test decode(b"\x83h\3a\x0aa\x14a\x1e") == ((10,20,30), b"")
    @test decode(b"\x83h\4d\0\1ad\0\1bd\0\1cd\0\1d") == ((:a,:b,:c,:d), b"")
    @test decode(b"\x83h\2a\1a\2tail") == ((1,2), b"tail")
    @test decodesmalltuple(b"h\0") == ((), b"")
    @test decodesmalltuple(b"h\0tail") == ((), b"tail")
    # it's a real tuple that has only 1 element
    @test decodesmalltuple(b"h\1a\1") == ((1,), b"")
    @test decodesmalltuple(b"h\2a\1a\2tail") == ((1,2), b"tail")
end

# decode large tuple (LARGE_TUPLE_EXT)
testcase() do
    (lt1, tail1) = decode(vcat(b"\x83", largetuple1, b"tail"))
    @test tail1 == b"tail"

    (lt2, tail2) = decodelargetuple(largetuple1)
    @test (length(lt2), tail2) == (256, b"")
    @test lt2[1]   == :a
    @test lt2[256] == :p
end

# decode opaque object

# decode small integer (SMALL_INTEGER_EXT)
testcase() do
    @test_throws IncompleteData decode(b"\x83a")
    @test decode(b"\x83a\0") == (0, b"")
    @test decode(b"\x83a\0tail") == (0, b"tail")
    @test decode(b"\x83a\xff") == (255, b"")
    @test decode(b"\x83a\xfftail") == (255, b"tail")
    @test_throws IncompleteData decodesmallint(b"a")
    @test decodesmallint(b"a\0") == (0, b"")
    @test decodesmallint(b"a\0tail") == (0, b"tail")
    @test decodesmallint(b"a\xff") == (255, b"")
    @test decodesmallint(b"a\xfftail") == (255, b"tail")
end

# decode integer (INTEGER_EXT)
testcase() do
    @test_throws IncompleteData decode(b"\x83b")
    @test_throws IncompleteData decode(b"\x83b\0")
    @test_throws IncompleteData decode(b"\x83b\0\0")
    @test_throws IncompleteData decode(b"\x83b\0\0\0")
    @test decode(b"\x83b\0\0\0\0") == (0, [])
    @test decode(b"\x83b\0\0\0\0tail") == (0, b"tail")
    @test decode(b"\x83b\x7f\xff\xff\xff") == (2147483647, [])
    @test decode(b"\x83b\x7f\xff\xff\xfftail") == (2147483647, b"tail")
    @test decode(b"\x83b\xff\xff\xff\xff") == (-1, [])
    @test decode(b"\x83b\xff\xff\xff\xfftail") == (-1, b"tail")
    @test_throws IncompleteData decodeint(b"b")
    @test_throws IncompleteData decodeint(b"b\0")
    @test_throws IncompleteData decodeint(b"b\0\0")
    @test_throws IncompleteData decodeint(b"b\0\0\0")
    @test decodeint(b"b\0\0\0\0") == (0, [])
    @test decodeint(b"b\0\0\0\0tail") == (0, b"tail")
    @test decodeint(b"b\x7f\xff\xff\xff") == (2147483647, [])
    @test decodeint(b"b\x7f\xff\xff\xfftail") == (2147483647, b"tail")
    @test decodeint(b"b\xff\xff\xff\xff") == (-1, [])
    @test decodeint(b"b\xff\xff\xff\xfftail") == (-1, b"tail")
end

# decode binary (BINARY_EXT)
testcase() do
    @test_throws IncompleteData decode(b"\x83m")
    @test_throws IncompleteData decode(b"\x83m\0")
    @test_throws IncompleteData decode(b"\x83m\0\0")
    @test_throws IncompleteData decode(b"\x83m\0\0\0")
    @test_throws IncompleteData decode(b"\x83m\0\0\0\1")
    @test decode(b"\x83m\0\0\0\0") == (b"", b"")
    @test decode(b"\x83m\0\0\0\0tail") == (b"", b"tail")
    @test decode(b"\x83m\0\0\0\4data") == (b"data", b"")
    @test decode(b"\x83m\0\0\0\4datatail") == (b"data", b"tail")
    @test decodebin(b"m\0\0\0\0") == (b"", b"")
    @test decodebin(b"m\0\0\0\0tail") == (b"", b"tail")
    @test decodebin(b"m\0\0\0\4data") == (b"data", b"")
    @test decodebin(b"m\0\0\0\4datatail") == (b"data", b"tail")
    @test_throws IncompleteData decodebin(b"m")
    @test_throws IncompleteData decodebin(b"m\0")
    @test_throws IncompleteData decodebin(b"m\0\0")
    @test_throws IncompleteData decodebin(b"m\0\0\0")
    @test_throws IncompleteData decodebin(b"m\0\0\0\1")
    @test decodebin(b"m\0\0\0\x1f\xc3\xa1rv\xc3\xadzt\xc5\xb1r\xc5\x91\x20t\xc3\xbck\xc3\xb6rf\xc3\xbar\xc3\xb3g\xc3\xa9p") == (b"árvíztűrő tükörfúrógép", b"")
end

# decode bitstring (BIT_BINARY_EXT)
testcase() do
    # XXX follow-up
    #@test_throws IncompleteData decode(b"\x83M")
    #@test_throws IncompleteData decode(b"\x83M\0")
    #@test_throws IncompleteData decode(b"\x83M\0\0")
    #@test_throws IncompleteData decode(b"\x83M\0\0\0")
    #@test_throws IncompleteData decode(b"\x83M\0\0\0\0")
    #@test_throws IncompleteData decode(b"\x83M\0\0\0\1\0")
    #@test_throws IncompleteData decode(b"\x83M\0\0\0\1\0")
    #@test decode(b"\x83M\0\0\0\0\0") == (b"", b"")
    #@test decode(b"\x83M\0\0\0\0\3") == (b"", b"")
    #@test decode(b"\x83M\0\0\0\0\5tail") == (b"", b"tail")
    #@test decode(b"\x83M\0\0\0\1\1\x80") == (b"\1", b"")
    #@test decode(b"\x83M\0\0\0\1\1\x80tail") == (b"\1", b"tail")
end

# decode float (FLOAT_EXT)
testcase() do
    # XXX that is represented by its sprintf'ed string...
end

# decode new float (NEW_FLOAT_EXT)
testcase() do
    @test_throws IncompleteData decode(b"\x83F")
    @test_throws IncompleteData decode(b"\x83F\0")
    @test_throws IncompleteData decode(b"\x83F\0\0")
    @test_throws IncompleteData decode(b"\x83F\0\0\0")
    @test_throws IncompleteData decode(b"\x83F\0\0\0\0")
    @test_throws IncompleteData decode(b"\x83F\0\0\0\0\0")
    @test_throws IncompleteData decode(b"\x83F\0\0\0\0\0\0")
    @test_throws IncompleteData decode(b"\x83F\0\0\0\0\0\0\0")
    @test decode(b"\x83F\0\0\0\0\0\0\0\0") == (0.0, b"")
    @test decode(b"\x83F\0\0\0\0\0\0\0\0tail") == (0.0, b"tail")
    @test decode(b"\x83F?\xf8\0\0\0\0\0\0") == (1.5, b"")
    @test decode(b"\x83F?\xf8\0\0\0\0\0\0tail") == (1.5, b"tail")
    @test decodenewfloat(b"F\0\0\0\0\0\0\0\0") == (0.0, b"")
    @test decodenewfloat(b"F\0\0\0\0\0\0\0\0tail") == (0.0, b"tail")
    @test decodenewfloat(b"F?\xf8\0\0\0\0\0\0") == (1.5, b"")
    @test decodenewfloat(b"F?\xf8\0\0\0\0\0\0tail") == (1.5, b"tail")
    @test_throws IncompleteData decodenewfloat(b"F")
    @test_throws IncompleteData decodenewfloat(b"F\0")
    @test_throws IncompleteData decodenewfloat(b"F\0\0")
    @test_throws IncompleteData decodenewfloat(b"F\0\0\0")
    @test_throws IncompleteData decodenewfloat(b"F\0\0\0\0")
    @test_throws IncompleteData decodenewfloat(b"F\0\0\0\0\0")
    @test_throws IncompleteData decodenewfloat(b"F\0\0\0\0\0\0")
    @test_throws IncompleteData decodenewfloat(b"F\0\0\0\0\0\0\0")
end

# decode small big integer (SMALL_BIG_EXT)
testcase() do
    @test_throws IncompleteData decode(b"\x83n")
    @test_throws IncompleteData decode(b"\x83n\0")
    @test_throws IncompleteData decode(b"\x83n\1\0")
    @test_throws IncompleteData decode(b"\x83n\2\0\0")
    @test decode(b"\x83n\1\0\0") == (0, b"")
    @test decode(b"\x83n\1\0\0tail") == (0, b"tail")

    @test decodesmallbigint(b"n\1\0\1") == (1, b"")
    @test decodesmallbigint(b"n\1\1\1") == (-1, b"")
    @test decodesmallbigint(b"n\2\0\1\2") == (513, b"")
    @test decodesmallbigint(smallbigintmax) == (256^255-1, b"")
end

# decode large big integer (LARGE_BIG_EXT)
testcase() do
    @test_throws IncompleteData decode(b"\x83o")
    @test_throws IncompleteData decode(b"\x83o\0")
    @test_throws IncompleteData decode(b"\x83o\0\0")
    @test_throws IncompleteData decode(b"\x83o\0\0\0")
    @test_throws IncompleteData decode(b"\x83o\0\0\0\0")
    @test_throws IncompleteData decode(b"\x83o\0\0\0\1\0")
    @test_throws IncompleteData decode(b"\x83o\0\0\0\2\0\0")
    @test decode(b"\x83o\0\0\0\1\0\0") == (0, b"")
    @test decode(b"\x83o\0\0\0\1\0\0tail") == (0, b"tail")

    @test decodelargebigint(b"o\0\0\0\1\0\1") == (1, b"")
    @test decodelargebigint(b"o\0\0\0\1\1\1") == (-1, b"")
    @test decodelargebigint(b"o\0\0\0\2\1\1\2") == (-513, b"")
    @test decodelargebigint(largebigintmin) == (256^255, b"")
end

# decode map (MAP_EXT)

# decode compressed term
testcase() do
    @test_throws IncompleteData decode(b"\x83P")
    @test_throws IncompleteData decode(b"\x83P\0")
    @test_throws IncompleteData decode(b"\x83P\0\0")
    @test_throws IncompleteData decode(b"\x83P\0\0\0")
    @test_throws IncompleteData decode(b"\x83P\0\0\0\0")
    @test_throws InvalidCompressedTag decode(badsizecompdata)
    @test decode(compdata1) == ([100,100,100,100,100,100,100,100,100,100,
                                 100,100,100,100, 100,100,100,100,100,100],
                                UInt8[])
    # XXX the following test fails because the Zlib library for Julia doesn't
    # provide a flush-like mechanism that the Python zlib library does
    # @test decode(compdata2) == ([100,100,100,100,100,100,100,100,100,100,
    #                              100,100,100,100, 100,100,100,100,100,100],
    #                             b"tail")
end

