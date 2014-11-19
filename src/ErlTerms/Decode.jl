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

export decode, decodeterm, decodestring, decodeatom
export decompressterm, int2unpack, int4unpack

using Zlib
using ErlPort.Exceptions

include("Tags.jl")

function decode(bytes::Array{Uint8,1})
    if length(bytes) == 0
        throw(IncompleteData(bytes))
    end
    if bytes[1] != 131
        throw(UnknownProtocolVersion(bytes[1]))
    end
    if length(bytes) < 4
        throw(IncompleteData(bytes))
    end
    if bytes[2] == b"P"[1]
        # XXX maybe have this match the call to decode below? bytes[2:end]
        # instead of just bytes?
        return decodeterm(decompressterm(bytes))
    end
    return decodeterm(bytes[2:end])
end

function decode(unsupported)
    throw(UnsupportedType(unsupported))
end

function int4unpack(bytes)
    int(reinterpret(Int32, reverse(bytes))[1])
end

function int2unpack(bytes)
    int(reinterpret(Int8, reverse(bytes))[1])
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
    elseif tag in [listtag, smalltupletag, largetupletag]
        return bytes
    elseif tag == smallinttag
        return bytes
    elseif tag == inttag
        return bytes
    elseif tag == bintag
        return bytes
    elseif tag == newfloattag
        return bytes
    elseif tag in [smallbiginttag, largebiginttag]
        # XXX move logic out to function
        if tag == smallbiginttag
            (length, sign) = (0, 0)
            tail = bytes[4:end]
        else
            (length, sign) = (0, 0)
            tail = bytes[7:end]
        end
        n = 0
        if length
            n = 0
            if sign
                n = -n
            end
        end
        return n, tail[length+1:end]
    else
        throw(UnsupportedData(bytes))
    end
end

function decodeatom(bytes::Array{Uint8,1})
    len = length(bytes)
    if len < 3
        throw(IncompleteData(bytes))
    end
    unpackedlen = int2unpack(bytes[2:3]) + 3
    if len < unpackedlen
        throw(IncompleteData(bytes))
    end
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
    len = length(bytes)
    if len < 3
        throw(IncompleteData(bytes))
    end
    unpackedlen = int2unpack(bytes[2:3]) + 3
    if len < unpackedlen
        throw(IncompleteData(bytes))
    end
    (bytes[4:unpackedlen], bytes[unpackedlen+1:end])
end

end
