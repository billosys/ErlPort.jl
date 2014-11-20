# Copyright (c) 2014, Dreki Þórgísl <dreki@billo.systems>
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

export decode, decodeterm, decodestring, decodeatom,
decodesmallint, decodeint, decodebin, decodefloat,
decodesmalltuple,
decompressterm, int2unpack, int4unpack

include("Tags.jl")
include("Util.jl")

function decode(bytes::Array{Uint8,1})
    lencheck(bytes, length(bytes) == 0)
    if bytes[1] != 131
        throw(UnknownProtocolVersion(bytes[1]))
    end
    if length(bytes) >= 2 && bytes[2] == compressed
        # XXX maybe have this match the call to decode below? bytes[2:end]
        # instead of just bytes?
        return decodeterm(decompressterm(bytes))
    end
    return decodeterm(bytes[2:end])
end

function decode(unsupported)
    throw(UnsupportedType(unsupported))
end

function decodeterm(bytes::Array{Uint8,1})
    if length(bytes) == 0
        throw(IncompleteData(bytes))
    end
    tag = bytes[1]
    if tag == atomtag
        return decodeatom(bytes)
    elseif tag == niltag
        return decodenil(bytes)
    elseif tag == stringtag
        return decodestring(bytes)
    elseif tag == smalltupletag
        return decodesmalltuple(bytes)
    elseif tag in [listtag, smalltupletag, largetupletag]
        return bytes
    elseif tag == smallinttag
        return decodesmallint(bytes)
    elseif tag == inttag
        return decodeint(bytes)
    elseif tag == bintag
        return decodebin(bytes)
    elseif tag == newfloattag
        return decodefloat(bytes)
    elseif tag in [smallbiginttag, largebiginttag]
        # XXX move logic out to function
        if tag == smallbiginttag
            (len, sign) = (0, 0)
            tail = bytes[4:end]
        else
            (len, sign) = (0, 0)
            tail = bytes[7:end]
        end
        n = 0
        if len
            n = 0
            if sign
                n = -n
            end
        end
        return n, tail[len+1:end]
    else
        throw(UnsupportedData(bytes))
    end
end

function decodeterm(acc::Array, byte::Uint8)
    vcat(acc, decodeterm([byte]))
end

function decodeatom(bytes::Array{Uint8,1})
    len = lencheck(bytes, 3)
    unpackedlen = lencheck(len, int2unpack(bytes[2:3]) + 3, bytes)
    name = bytes[4:unpackedlen]
    if name == b"true"
        return (true, bytes[unpackedlen+1:end])
    elseif name == b"false"
        return (false, bytes[unpackedlen+1:end])
    elseif name == b"undefined"
        return (nothing, bytes[unpackedlen+1:end])
    else
        return (symbol(name), bytes[unpackedlen+1:end])
    end
end

function decodenil(bytes::Array{Uint8,1})
    #return (nothing, bytes[2:end])
    return ([], bytes[2:end])
end

function decodestring(bytes::Array{Uint8,1})
    len = lencheck(bytes, 3)
    unpackedlen = lencheck(len, int2unpack(bytes[2:3]) + 3, bytes)
    (bytes[4:unpackedlen], bytes[unpackedlen+1:end])
end

function decodesmallint(bytes::Array{Uint8,1})
    lencheck(bytes, 2)
    (bytes[2], bytes[3:end])
end

function decodeint(bytes::Array{Uint8,1})
    lencheck(bytes, 5)
    (int4unpack(bytes[2:5]), bytes[6:end])
end

function decodebin(bytes::Array{Uint8,1})
    len = lencheck(bytes, 5)
    unpackedlen = lencheck(len, int4unpack(bytes[2:5]) + 5, bytes)
    (bytes[6:unpackedlen], bytes[unpackedlen+1:end])
end

function decodefloat(bytes::Array{Uint8,1})
    lencheck(bytes, 9)
    (floatunpack(bytes[2:9]), bytes[10:end])
end

function converttoarray(len::Int64, tail::Array{Uint8,1})
    for i in len:-1:0
        (term, tail) = decodeterm(tail)
    end
end

function decodesmalltuple(bytes::Array{Uint8,1})
    lencheck(bytes, 2)
    (len, tail) = (bytes[2], bytes[3:end])
end

end
