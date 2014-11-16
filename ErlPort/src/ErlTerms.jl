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
module ErlTerms

export IncompleteData, UnknownProtocolVersion, InvalidCompressedTag,
UnsupportedData, UnsupportedType
decode, getindex, length

import Base.length

include("Exceptions.jl")

type Atom
  bytes::Array{Uint8,1}
end

Atom() = Atom(b"")

getindex(atom::Atom, index::Int64) = getindex(atom.bytes, index)
getindex(atom::Atom, range::UnitRange{Int64}) = getindex(atom.bytes, range)
length(atom::Atom) = Base.length(atom.bytes)

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
    if bytes[2] == b"P"
        # compressed term
        if length(bytes) < 16
            throw(IncompleteData(bytes))
        end
        # XXX add support for decompressing
    end
    decodeterm(bytes[2:end])
end

function decode(unsupported)
    throw(UnsupportedType(unsupported))
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
        return bytes
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
    ln = length(bytes)
    if ln < 3
        throw(IncompleteData(bytes))
    end
    unpackedln = 0
    if ln < unpackedln
        throw(IncompleteData(bytes))
    end
    name = bytes[3:unpackedln]
    if name == b"true"
        return true, bytes[unpackedln:end]
    elseif name == b"false"
        return false, bytes[unpackedln:end]
    elseif name == b"undefined"
        return None, bytes[unpackedln:end]
    else
        return symbol(name), bytes[unpackedln:end]
    end
end


end
