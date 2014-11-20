using ErlPort.Exceptions
using ErlPort.ErlTerms.Encode

include("Testing.jl")

# tests for supporting functions
testcase() do
    @test charint4pack(1) == b"\x00\x00\x00\x01"
    @test charint4pack(1000) == b"\x00\x00\x03\xe8"
    @test charint4pack(72000) == b"\x00\x01\x19@"
    @test charint4pack(1000000000) == b";\x9a\xca\x00"
    @test charint4pack(4294967295) == b"\xff\xff\xff\xff"
    @test charint2pack(1) == b"\x00\x01"
    @test charint2pack(1000) == b"\x03\xe8"
    @test charint2pack(10000) == b"'\x10"
    @test charint2pack(50092) == b"\xc3\xac"
    @test charint2pack(65535) == b"\xff\xff"
end

# tests for atoms
testcase() do
    @test encode(:erlang) == b"\x83d\0\6erlang"
    @test encode(:test) == b"\x83d\0\4test"
    @test encode(symbol("")) == b"\x83d\0\0"
    @test encodeterm(:erlang) == b"d\0\6erlang"
    @test encodeterm(:test) == b"d\0\4test"
    @test encodeterm(symbol("")) == b"d\0\0"
end

# tests for bools
testcase() do
    @test encode(true) == b"\x83d\0\4true"
    @test encode(:true) == b"\x83d\0\4true"
    @test encode(false) == b"\x83d\0\5false"
    @test encode(:false) == b"\x83d\0\5false"
    @test encodeterm(true) == b"d\0\4true"
    @test encodeterm(:true) == b"d\0\4true"
    @test encodeterm(false) == b"d\0\5false"
    @test encodeterm(:false) == b"d\0\5false"
end

# tests for nothing
testcase() do
    @test encode(nothing) == b"\x83d\0\7nothing"
    @test encode(:nothing) == b"\x83d\0\7nothing"
    @test encodeterm(nothing) == b"d\0\7nothing"
    @test encodeterm(:nothing) == b"d\0\7nothing"
end

# tests for list
testcase() do
end

# tests for string
testcase() do
end

# tests for tuples
testcase() do
end

# tests for improper list
testcase() do
end

# tests for long int
testcase() do
end

# tests for int
testcase() do
end

# tests for short int
testcase() do
end

# tests for float
testcase() do
end

# tests for opaque objects
testcase() do
end

# tests for compressed terms
testcase() do
end
