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
module Encode

export encode, encodeterm,
charintpack, charint4pack, charint2pack, charsignedint4pack

include("Tags.jl")
include("Util.jl")

function encode(term; compressed=false)
    encoded = encodeterm(term)
    if compressed
        encoded = vcat(compressedtag, compressterm(encoded, compressed))
    end
    vcat(version, encoded)
end

function encodeboolorsym(term)
    str = string(term)
    vcat(atomtag, charint2pack(length(str)), codeunits(str))
end

function encodeterm(term::Symbol)
    encodeboolorsym(term)
end

function encodeterm(term::Nothing)
    encodeboolorsym(:undefined)
end

function encodeterm(term::Bool)
    encodeboolorsym(term)
end

function encodeterm(term::T) where {T <: AbstractVector{UInt8}}
    local length_pack::Vector{UInt8} = charint4pack(length(term))
    return vcat(bintag, length_pack, term)
end

function encodeterm(term::AbstractVector)
    local len::UInt32 = length(term)
    if len > typemax(UInt32)
        throw(InvalidListLength(len))
    end
    local length_pack = charint4pack(len)
    local listmembers::Vector{UInt8} = vcat(map(encodeterm, term)...)
    return vcat(listtag, length_pack, listmembers, niltag)
end

function encodeterm(term::AbstractString)
    local length_pack::Vector{UInt8} = charint4pack(length(term))
    local binary::AbstractVector{UInt8} = codeunits(term)
    return vcat(bintag, length_pack, binary)
end

function encodeterm(term::Tuple)
    len = length(term)
    if len <= typemax(UInt8)
        header = vcat(smalltupletag, convert(UInt8, len))
    elseif arity <= typemax(UInt32)
        header = charint4pack(arity)
    else
        throw(InvalidTupleArity(arity))
    end


    vcat(header, vcat(collect(map(encodeterm, term))...))
end

function encodeterm(term::Integer)
    if 0 <= term <= typemax(UInt8)
        return vcat(smallinttag, UInt8(term))
    elseif typemin(Int32) <= term <= typemax(Int32)
        return vcat(inttag, charsignedint4pack(term))
    end
    if term >= 0
        sign = 0
    else
        sign = 1
        term = -term
    end
    bytes = charintpack(term)
    len = length(bytes)
    if len <= typemax(UInt8)
        return vcat(smallbiginttag, len, sign, bytes)
    elseif len <= typemax(UInt32)
        return vcat(largebiginttag, charint4pack(len), sign, bytes)
    end
    msg = "Got length: $len"
    throw(InvalidIntLength(msg))
end

function encodeterm(term::Float64)
    if isnan(term)
        return encodeterm(:nan)
    else
        return vcat(newfloattag, hex2bytes(string(reinterpret(Unsigned, term), base = 16, pad = sizeof(term) * 2)))
    end
end

function encodeterm(term::Dict)
    result = vcat(maptag, charint4pack(length(term)))
    for (key, value) in term
        result = vcat(result, encodeterm(key), encodeterm(value))
    end
    result
end

end
