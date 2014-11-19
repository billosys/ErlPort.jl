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
end

testcase() do
    expected = [107,0,20,100,100,100,100,100,100,100,100,100,100,
                100,100,100,100,100,100,100,100,100,100]
    @test decompressterm(compdata1) == expected
end

# basic decode errors
@test_throws UnsupportedType decode("")
@test_throws IncompleteData decode(b"")
@test_throws UnknownProtocolVersion decode(b"\0")
@test_throws IncompleteData decode(b"\x83")

# decode atoms
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
# decode predefined atoms

# decode empty list

# decode string list
@test_throws IncompleteData decodestring(b"")
@test_throws IncompleteData decodestring(b"\0")
@test_throws IncompleteData decodestring(b"\0\0")

# decode list

# decode improper list

# decode small tuple

# decode large tuple

# decode opaque object

# decode small integer

# decode integer

# decode binary

# decode float

# decode small big integer

# decode big integer

# decode compressed term
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
#                             [116,97,105,108])
