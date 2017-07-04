module EncodeTest

using Base.Test
using ErlPort.Exceptions
using ErlPort.ErlTerms.Encode

function run()::Void
    # tests for supporting functions
    @testset begin
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
    @testset begin
        @test encode(:erlang) == b"\x83d\0\6erlang"
        @test encode(:test) == b"\x83d\0\4test"
        @test encode(Symbol("")) == b"\x83d\0\0"
        @test encodeterm(:erlang) == b"d\0\6erlang"
        @test encodeterm(:test) == b"d\0\4test"
        @test encodeterm(Symbol("")) == b"d\0\0"
    end

    # tests for bools
    @testset begin
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
    @testset begin
        @test encode(nothing) == b"\x83d\0\7nothing"
        @test encode(:nothing) == b"\x83d\0\7nothing"
        @test encodeterm(nothing) == b"d\0\7nothing"
        @test encodeterm(:nothing) == b"d\0\7nothing"
    end

    # tests for list
    @testset begin
    end

    # tests for string
    @testset begin
    end

    # tests for tuples
    @testset begin
    end

    # tests for improper list
    @testset begin
    end

    # tests for short int
    @testset begin
        @test encode(0) == b"\x83a\0"
        @test encode(1) == b"\x83a\1"
        @test encode(255) == b"\x83a\xff"
    end

    # tests for int
    @testset begin
        @test encode(-1) == b"\x83b\xff\xff\xff\xff"
        @test encode(256) == b"\x83b\0\0\1\0"
        @test encode(-2147483648) == b"\x83b\x80\0\0\0"
        @test encode(2147483647) == b"\x83b\x7f\xff\xff\xff"
    end

    # tests for long int
    @testset begin
        @test encode(-2147483649) == b"\x83n\4\1\1\0\0\x80"
        @test encode(2147483648) == b"\x83n\4\0\0\0\0\x80"
        @test encode(BigInt(2)^2040) == vcat(b"\x83o\0\0\1\0\0", zeros(255), b"\1")
        @test encode(-BigInt(2)^2040) == vcat(b"\x83o\0\0\1\0\1", zeros(255), b"\1")
    end

    # tests for int errors
    # XXX add some!

    # tests for float
    @testset begin
    end

    # tests for opaque objects
    @testset begin
    end

    # tests for compressed terms
    @testset begin
    end

    return nothing
end

end # module
