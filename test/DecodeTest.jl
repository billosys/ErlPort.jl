using ErlPort.Exceptions
using ErlPort.ErlTerms.Decode

include("Testing.jl")

# data for use by tests
lenheader1 = b"\0\0\0\x17"
lenheader2 = b"\0\x14"
badsizecompdata = vcat(b"\x83P\0\0\0\x16\x78\xda\xcb\x66\x10\x49\xc1\2\0\x5d",
                       b"\x60\x08\x50")
compdata1 = b"\x83P\0\0\0\x17\x78\xda\xcb\x66\x10\x49\xc1\2\0\x5d\x60\x08\x50"
compdata2 = vcat(b"\x83P\0\0\0\x17\x78\xda\xcb\x66\x10\x49\xc1\2\0\x5d\x60",
                 b"\x08\x50tail")

# tests for supporting functions
testcase() do
    @test int4unpack(lenheader1) == 23
    @test int2unpack(lenheader2) == 20
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

# decode nil

# decode atoms
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

# decode predefined atoms

# decode empty list

# decode string list
testcase() do
    @test_throws IncompleteData decodestring(b"")
    @test_throws IncompleteData decodestring(b"\0")
    @test_throws IncompleteData decodestring(b"\0\0")
end

# decode list

# decode improper list

# decode small tuple

# decode large tuple

# decode opaque object

# decode small integer
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

# decode integer
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

# decode binary
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
end

# decode float
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
    @test decodefloat(b"F\0\0\0\0\0\0\0\0") == (0.0, b"")
    @test decodefloat(b"F\0\0\0\0\0\0\0\0tail") == (0.0, b"tail")
    @test decodefloat(b"F?\xf8\0\0\0\0\0\0") == (1.5, b"")
    @test decodefloat(b"F?\xf8\0\0\0\0\0\0tail") == (1.5, b"tail")
    @test_throws IncompleteData decodefloat(b"F")
    @test_throws IncompleteData decodefloat(b"F\0")
    @test_throws IncompleteData decodefloat(b"F\0\0")
    @test_throws IncompleteData decodefloat(b"F\0\0\0")
    @test_throws IncompleteData decodefloat(b"F\0\0\0\0")
    @test_throws IncompleteData decodefloat(b"F\0\0\0\0\0")
    @test_throws IncompleteData decodefloat(b"F\0\0\0\0\0\0")
    @test_throws IncompleteData decodefloat(b"F\0\0\0\0\0\0\0")
end

# decode small big integer

# decode big integer

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
                                Uint8[])
    # XXX the following test fails because the Zlib library for Julia doesn't
    # provide a flush-like mechanism that the Python zlib library does
    # @test decode(compdata2) == ([100,100,100,100,100,100,100,100,100,100,
    #                              100,100,100,100, 100,100,100,100,100,100],
    #                             b"tail")
end
