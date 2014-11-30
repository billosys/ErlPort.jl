using Zlib

function int4unpack(bytes)
    int(reinterpret(Int32, reverse(bytes))[1])
end

function int2unpack(bytes)
    int(reinterpret(Int8, reverse(bytes))[1])
end

function floatunpack(bytes)
    reinterpret(Float64, reverse(bytes))[1]
end

function charintpack(value::Integer, size::Int)
    bytes = zeros(Uint8, size)
    for i=1:size
        bytes[i] = uint8(value)
        value = value >>> 8
        end
    reverse(bytes)
end

function charintpack(value::Integer)
    bytes = []
    while value != 0
        bytes = vcat(bytes, uint8(value & 0xff))
        value = value >>> 8
    end
    uint8(bytes)
end

function charint4pack(integer::Integer)
    charintpack(integer, 4)
end

function charint2pack(integer::Integer)
    charintpack(integer, 2)
end

function charsignedint4pack(integer::Integer)
    charintpack(integer, 4)
end

function lencheck(bytes::Array{Uint8,1}, limit::Int64)
    len = length(bytes)
    lencheck(len, len < limit, bytes)
end

function lencheck(bytes::Array{Uint8,1}, pred::Bool)
    len = length(bytes)
    lencheck(len, pred, bytes)
end

function lencheck(len::Int64, limit::Int64, bytes::Array{Uint8,1})
    lencheck(limit, len < limit, bytes)
end

function lencheck(len::Int64, pred::Bool, bytes::Array{Uint8,1})
    if pred
        throw(IncompleteData(bytes))
    end
    len
end

function compressterm(encodedterm, compression::Bool)
    compressterm(encodedterm, 6)
end

function compressterm(encodedterm, compression::Int)
    if compression < 0 || compression > 9
        throw(InvalidCompressionLevel(compression))
    end
    comp = Zlib.compress(encodedterm, compression)
    len = length(encodedterm)
    # XXX add check here for too small of length
    if length(comp) + 5 <= len
        vcat(int4pack(len), comp)
    end
end

function decompressterm(bytes::Array{Uint8,1})
    if length(bytes) < 16
        throw(IncompleteData(bytes))
    end
    sentlen = int4unpack(bytes[3:6])
    term = Zlib.decompress(bytes[7:end])
    actuallen = length(term)
    if actuallen != sentlen
        msg = "Header declared $sentlen bytes but got $actuallen bytes."
        throw(InvalidCompressedTag(msg))
    end
    return term
end
