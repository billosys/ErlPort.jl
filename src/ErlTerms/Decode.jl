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

export decode, decodeterm, decodestring
export decompressterm, int2unpack, int4unpack

using Zlib
using ErlPort.Exceptions

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
        msg = "Header declared $sent_len bytes but got $actual_len bytes."
        throw(InvalidCompressedTag(msg))
    end
    return term
end

function decodeterm(bytes::Array{Uint8,1})
    if length(bytes) == 0
        throw(IncompleteData(bytes))
    end
    tag = bytes[1]
    if tag == 100
        # ATOM_EXT
        return decodeatom(bytes)
    elseif tag == 106
        # NIL_EXT
        return bytes
    elseif tag == 107
        # STRING_EXT
        return decodestring(bytes)
    elseif tag in b"lhi"
        # LIST_EXT, SMALL_TUPLE_EXT, LARGE_TUPLE_EXT
        return bytes
    elseif tag == 97
        # SMALL_INTEGER_EXT
        return bytes
    elseif tag == 98
        # INTEGER_EXT
        return bytes
    elseif tag == 109
        # BINARY_EXT
        return bytes
    elseif tag == 70
        # NEW_FLOAT_EXT
        return bytes
    elseif tag in b"no"
        # SMALL_BIG_EXT, LARGE_BIG_EXT
        if tag == 110
            return bytes
        end
        return bytes
    else
        throw(UnsupportedData(bytes))
    end
end

function decodeatom(bytes::Array{Uint8,1})
    len = length(bytes)
    if ln < 3
        throw(IncompleteData(bytes))
    end
    unpackedlen = int2unpack(bytes[2:3]) + 3
    if len < unpackedlen
        throw(IncompleteData(bytes))
    end
    name = bytes[3:unpackedlen]
    if name == b"true"
        return true, bytes[unpackedlen:end]
    elseif name == b"false"
        return false, bytes[unpackedlen:end]
    elseif name == b"undefined"
        return None, bytes[unpackedlen:end]
    else
        return symbol(name), bytes[unpackedlen:end]
    end
end

function decodenil(bytes::Array{Uint8,1})
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
    bytes[4:unpackedlen], bytes[unpackedlen+1:end]
end

end
