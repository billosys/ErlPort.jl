module EncodeTest

using Test
using ErlPort.Exceptions
using ErlPort.ErlTerms.Encode

function run()::Nothing
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
        @test encode(nothing) == b"\x83d\0\x09undefined"
        @test encode(:nothing) == b"\x83d\0\7nothing"
        @test encodeterm(nothing) == b"d\0\x09undefined"
        @test encodeterm(:nothing) == b"d\0\7nothing"
    end

    # tests for list
    @testset begin
        @test encode([]) == b"\x83l\0\0\0\0j"
        @test encode([1]) == b"\x83l\0\0\0\1a\1j"
        @test encode([1, 2]) == b"\x83l\0\0\0\2a\1a\2j"
        @test encode([:a]) == b"\x83l\0\0\0\1d\0\1aj"
        @test encode([:a, :ok]) == b"\x83l\0\0\0\2d\0\1ad\0\2okj"
        @test encodeterm([]) == b"l\0\0\0\0j"
        @test encodeterm([1]) == b"l\0\0\0\1a\1j"
        @test encodeterm([1, 2]) == b"l\0\0\0\2a\1a\2j"
        @test encodeterm([:a]) == b"l\0\0\0\1d\0\1aj"
        @test encodeterm([:a, :ok]) == b"l\0\0\0\2d\0\1ad\0\2okj"
    end

    # tests for binary data (vector of UInt8's)
    @testset begin
        @test encode(b"") == b"\x83m\0\0\0\0"
        @test encode(b"something") == b"\x83m\0\0\0\x09something"
        @test encode(b"nothing") == b"\x83m\0\0\0\7nothing"
        @test encodeterm(b"") == b"m\0\0\0\0"
        @test encodeterm(b"something") == b"m\0\0\0\x09something"
        @test encodeterm(b"nothing") == b"m\0\0\0\7nothing"
    end


    # tests for string
    @testset begin
        @test encode("") == b"\x83m\0\0\0\0"
        @test encode("something") == b"\x83m\0\0\0\x09something"
        @test encode("nothing") == b"\x83m\0\0\0\7nothing"
        @test encodeterm("") == b"m\0\0\0\0"
        @test encodeterm("something") == b"m\0\0\0\x09something"
        @test encodeterm("nothing") == b"m\0\0\0\7nothing"

        @test encode(SubString("")) == b"\x83m\0\0\0\0"
        @test encode(SubString("something")) == b"\x83m\0\0\0\x09something"
        @test encode(SubString("nothing")) == b"\x83m\0\0\0\7nothing"
        @test encodeterm(SubString("")) == b"m\0\0\0\0"
        @test encodeterm(SubString("something")) == b"m\0\0\0\x09something"
        @test encodeterm(SubString("nothing")) == b"m\0\0\0\7nothing"
    end

    # tests for tuples
    @testset begin
        @test encode(()) == b"\x83h\0"
        @test encode((1,)) == b"\x83h\1a\1"
        @test encode((1, 2)) == b"\x83h\2a\1a\2"
        @test encodeterm(()) == b"h\0"
        @test encodeterm((1,)) == b"h\1a\1"
        @test encodeterm((1, 2)) == b"h\2a\1a\2"
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
        @test encode(0.0) == b"\x83\x46\0\0\0\0\0\0\0\0"
        @test encode(1.5) == b"\x83\x46\x3f\xf8\0\0\0\0\0\0"
        @test encode(NaN) == b"\x83d\0\3nan"
        @test encodeterm(NaN) == b"d\0\3nan"
    end

    # tests for opaque objects
    @testset begin
    end

    # tests for compressed terms
    @testset begin
    end

    # tests for map
    @testset "encode map" begin
        # \x61 = 100 = SMALL_INT_EXT
        # \x64 = 100 = ATOM_EXT
        # \x6a = 106 = NIL_EXT
        # \x6c = 108 = LIST_EXT
        # \x6d = 109 = BINARY_EXT
        # \x74 = 116 = MAP_EXT
        @test encode(Dict()) == b"\x83\x74\0\0\0\0"
        @test encode(Dict(:a => 2)) == b"\x83\x74\0\0\0\1\x64\0\1a\x61\2"
        @test encode(Dict(:a => Dict(:a => 2))) ==
              b"\x83\x74\0\0\0\1\x64\0\1a\x74\0\0\0\1\x64\0\1a\x61\2"

        # In the BERT version, either element of the map can come first.
        @test encode(Dict(b"b" => [], :a => 2)) in
              (b"\x83\x74\0\0\0\2\x6d\0\0\0\1b\x6c\0\0\0\0\x6a\x64\0\1a\x61\2",
               b"\x83\x74\0\0\0\2\x64\0\1a\x61\2\x6d\0\0\0\1b\x6c\0\0\0\0\x6a")

        @test encodeterm(Dict()) == b"\x74\0\0\0\0"
        @test encodeterm(Dict(:a => 2)) == b"\x74\0\0\0\1d\0\1a\x61\2"
        @test encodeterm(Dict(:a => Dict(:a => 2))) ==
              b"\x74\0\0\0\1\x64\0\1a\x74\0\0\0\1\x64\0\1a\x61\2"

        @test encodeterm(Dict(b"b" => [], :a => 2)) in
              (b"\x74\0\0\0\2\x6d\0\0\0\1b\x6c\0\0\0\0\x6a\x64\0\1a\x61\2",
               b"\x74\0\0\0\2\x64\0\1a\x61\2\x6d\0\0\0\1b\x6c\0\0\0\0\x6a")
    end

    return nothing
end

end # module
