# Copyright (c) 2014, Dreki Þórgísl <dreki@billo.systems>
#               2014, Bence Golda <bence@cursorinsight.com>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
#
#  * Redistributions of source code must retain the above copyright notice,
#    this list of conditions and the following disclaimer.
#  * Redistributions in binary form must reproduce the above copyright notice,
#    this list of conditions and the following disclaimer in the documentation
#    and/or other materials provided with the distribution.
#  * Neither the name of the copyright holders nor the names of its
#    contributors may be used to endorse or promote products derived from this
#    software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
# AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
# IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
# ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
# INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
# CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
# ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
module Decode

using ErlPort.Exceptions

export decode, decode_with_tail,
decodeterm, decodeatom,
decodesmallint, decodeint, decodenewfloat,
decodesmallbigint, decodelargebigint,
decodemap, decodefloat,
decodebin,
decodenil, decodestring, decodelist,
decodesmalltuple, decodelargetuple,
decompressterm,
size1unpack, size2unpack, size4unpack # for tests only XXX: do we really need this here?

include("Tags.jl")
include("Util.jl")

function decode(bytes::Array{UInt8,1})
    (result, acc) = decode(view(bytes, 1:length(bytes)))
    if length(acc) > 0
        throw(IncompleteData(acc))
    end
    return result
end

function decode_with_tail(bytes::Array{UInt8, 1})
    decode(view(bytes, 1:length(bytes)))
end

function decode(bytes::SubArray{UInt8})
    lencheck(bytes, 1)
    if bytes[1] != version
        throw(UnknownProtocolVersion(bytes[1]))
    end
    if length(bytes) >= 2 && bytes[2] == compressedtag
        throw(NotImplemented())
    end

    return decodeterm(view(bytes, 2:length(bytes)))
end

function decode(unsupported)
    throw(UnsupportedType(unsupported))
end

function decodeterm(bytes::Array{UInt8,1})
    decodeterm(view(bytes, 1:length(bytes)))
end

function decodeterm(bytes::SubArray{UInt8})
    lencheck(bytes, 1)
    tag = bytes[1]
    if tag == atomtag
        return decodeatom(bytes)
    elseif tag == niltag
        return decodenil(bytes)
    elseif tag == stringtag
        return decodestring(bytes)
    elseif tag == smalltupletag
        return decodesmalltuple(bytes)
    elseif tag == largetupletag
        return decodelargetuple(bytes)
    elseif tag == listtag
        return decodelist(bytes)
    elseif tag == smallinttag
        return decodesmallint(bytes)
    elseif tag == inttag
        return decodeint(bytes)
    elseif tag == bintag
        return decodebin(bytes)
    elseif tag == newfloattag
        return decodenewfloat(bytes)
    elseif tag == smallbiginttag
        return decodesmallbigint(bytes)
    elseif tag == largebiginttag
        return decodelargebigint(bytes)
    elseif tag == maptag
        return decodemap(bytes)
    elseif tag == floattag
        return decodefloat(bytes)
    else
        throw(UnsupportedData(bytes))
    end
end

function decodeterm(acc::Array, byte::UInt8)
    vcat(acc, decodeterm([byte]))
end

function decodeatom(bytes::Array{UInt8,1})
    decodeatom(view(bytes, 1:length(bytes)))
end

function decodeatom(bytes::SubArray{UInt8})
    len = lencheck(bytes, 3)
    unpackedlen = lencheck(len, size2unpack(view(bytes, 2:3)) + 3, bytes)
    name = bytes[4:unpackedlen]
    if name == b"true"
        return (true, view(bytes, unpackedlen+1:length(bytes)))
    elseif name == b"false"
        return (false, view(bytes, unpackedlen+1:length(bytes)))
    elseif name == b"undefined"
        return (nothing, view(bytes, unpackedlen+1:length(bytes)))
    elseif name == b"nan"
        return (NaN, view(bytes, unpackedlen+1:length(bytes)))
    else
        return (Symbol(name), view(bytes, unpackedlen+1:length(bytes)))
    end
end

function decodenil(bytes::Array{UInt8,1})
    decodenil(view(bytes, 1:length(bytes)))
end

function decodenil(bytes::SubArray{UInt8})
    lencheck(bytes, 1)
    return ([], view(bytes, 2:length(bytes)))
end

function decodestring(bytes::Array{UInt8,1})
    decodestring(view(bytes, 1:length(bytes)))
end

function decodestring(bytes::SubArray{UInt8})
    len = lencheck(bytes, 3)
    unpackedlen = lencheck(len, size2unpack(view(bytes, 2:3)) + 3, bytes)
    (bytes[4:unpackedlen], view(bytes, unpackedlen+1:length(bytes)))
end

function decodesmallint(bytes::Array{UInt8,1})::Tuple{UInt8, Array{UInt8,1}}
    decodesmallint(view(bytes, 1:length(bytes)))
end

function decodesmallint(bytes::SubArray{UInt8})
    lencheck(bytes, 2)
    (int1unpack(bytes[2]), view(bytes, 3:length(bytes)))
end

function decodeint(bytes::Array{UInt8,1})
    decodeint(view(bytes, 1:length(bytes)))
end

function decodeint(bytes::SubArray{UInt8})
    lencheck(bytes, 5)
    (int4unpack(view(bytes, 2:5)), view(bytes, 6:length(bytes)))
end

function decodebin(bytes::Array{UInt8,1})
    decodebin(view(bytes, 1:length(bytes)))
end

function decodebin(bytes::SubArray{UInt8})
    len = lencheck(bytes, 5)
    unpackedlen = lencheck(len, size4unpack(view(bytes, 2:5)) + 5, bytes)
    (bytes[6:unpackedlen], view(bytes, unpackedlen+1:length(bytes)))
end

function decodenewfloat(bytes::Array{UInt8,1})
    decodenewfloat(view(bytes, 1:length(bytes)))
end

function decodenewfloat(bytes::SubArray{UInt8})
    lencheck(bytes, 9)
    (floatunpack(view(bytes, 2:9)), view(bytes, 10:length(bytes)))
end

function decodelist(bytes::Array{UInt8,1})
    decodelist(view(bytes, 1:length(bytes)))
end

function decodelist(bytes::SubArray{UInt8})
    lencheck(bytes, 5)
    (results, tail) = converttoarray(size4unpack(view(bytes, 2:5)), view(bytes, 6:length(bytes)))
    # XXX mojombo's BERT (https://github.com/mojombo/bert) does the same -- it
    # skips the improper part in lists (or throws a RuntimeError)
    (skipped, tail) = decodeterm(tail)
    (results, tail)
end

function converttoarray(len::UInt64, tail::Array{UInt8,1})
    converttoarray(len::UInt64, view(tail, 1:length(tail)))
end

function converttoarray(len::UInt64, tail::SubArray{UInt8})
    local results = Vector{Any}()
    if len > 0
        results = map(0:1:len-1) do i
            (term, tail) = decodeterm(tail)
            term
        end
    end
    (results, tail)
end

function decodesmalltuple(bytes::Array{UInt8,1})
    decodesmalltuple(view(bytes, 1:length(bytes)))
end

function decodesmalltuple(bytes::SubArray{UInt8})
    lencheck(bytes, 2)
    converttotuple(size1unpack(bytes[2]), view(bytes, 3:length(bytes)))
end

function decodelargetuple(bytes::Array{UInt8,1})
    decodelargetuple(view(bytes, 1:length(bytes)))
end

function decodelargetuple(bytes::SubArray{UInt8})
    lencheck(bytes, 5)
    converttotuple(size4unpack(view(bytes, 2:5)), view(bytes, 6:length(bytes)))
end

function converttotuple(len::UInt64, tail::SubArray{UInt8})
    if len < 1
        return( (), tail )
    end
    (results, tail) = converttoarray(len, tail)
    (tuple(results...), tail)
end

function decodesmallbigint(bytes::Array{UInt8,1})
    decodesmallbigint(view(bytes, 1:length(bytes)))
end

function decodesmallbigint(bytes::SubArray{UInt8})
    len = lencheck(bytes, 3)
    bisize = size1unpack(bytes[2])
    lencheck(len, bisize + 3, bytes)
    result = computebigint(bisize, view(bytes, 4:bisize+3), bytes[3])
    (result, view(bytes, bisize+4:length(bytes)))
end

function decodelargebigint(bytes::Array{UInt8,1})
    decodelargebigint(view(bytes, 1:length(bytes)))
end

function decodelargebigint(bytes::SubArray{UInt8})
    len = lencheck(bytes, 6)
    bisize = size4unpack(view(bytes, 2:5))
    lencheck(len, bisize + 6, bytes)
    result = computebigint(bisize, view(bytes, 7:bisize+6), bytes[6])
    (result, view(bytes, bisize+7:length(bytes)))
end

function computebigint(len::UInt64, coefficients::Array{UInt8,1}, sign::UInt8)
    computebigint(len::UInt64, view(coefficients, 1:length(coefficients)), sign)
end

function computebigint(len::UInt64, coefficients::SubArray{UInt8}, sign::UInt8)
    result = convert(Int64, sum((256 .^ collect(0:len-1)) .* coefficients))
    return(sign > 0 ? -result : result)
end

function decodemap(bytes::Array{UInt8,1})
    decodemap(view(bytes, 1:length(bytes)))
end

function decodemap(bytes::SubArray{UInt8})
    len = lencheck(bytes, 5)
    bisize = size4unpack(view(bytes, 2:5))
    result = Dict()

    bytes = view(bytes, 6:length(bytes))
    i = 1
    while i <= bisize
        (key, bytes) = decodeterm(bytes)
        (value, bytes) = decodeterm(bytes)
        result[key] = value
        i += 1
    end

    (result, bytes)
end

function decodefloat(bytes::Array{UInt8,1})::Tuple{Float64, Vector{UInt8}}
    decodefloat(view(bytes, 1:length(bytes)))
end

function decodefloat(bytes::SubArray{UInt8})
    len = lencheck(bytes, 9)
    result = hex2num(bytes2hex(view(bytes, 2:9)))
    (result, view(bytes, 10:length(bytes)))
end

end
