function int4unpack(bytes)
    int(reinterpret(Int32, reverse(bytes))[1])
end

function int2unpack(bytes)
    int(reinterpret(Int8, reverse(bytes))[1])
end

function floatunpack(bytes)
    reinterpret(Float64, reverse(bytes))[1]
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

function decompressterm(bytes::Array{Uint8,1})
    if length(bytes) < 16
        throw(IncompleteData(bytes))
    end
    sentlen = int4unpack(bytes[3:6])
    term = decompress(bytes[7:end])
    actuallen = length(term)
    if actuallen != sentlen
        msg = "Header declared $sentlen bytes but got $actuallen bytes."
        throw(InvalidCompressedTag(msg))
    end
    return term
end
