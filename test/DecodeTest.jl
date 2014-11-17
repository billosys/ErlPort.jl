using Base.Test

using ErlPort.Exceptions
using ErlPort.ErlTerms.Decode

# basic decode errors
@test_throws IncompleteData decode("")
@test_throws UnknownProtocolVersion decode(b"\0")
@test_throws IncompleteData decode(b"\x83")
#@test_throws InvalidCompressedTag decode(b"\x83z")

# decode atoms
@test_throws IncompleteData decode(b"\x83d")
@test_throws IncompleteData decode(b"\x83d\0")
#@test_throws IncompleteData decode(b"\x83d\0\1")
@test decode(b"\x83d\0\0") == "xxx"
@test decode(b"\x83d\0\0tail") == "xxx"
@test decode(b"\x83d\0\4test") == "xxx"
@test decode(b"\x83d\0\4testtail") == "xxx"

# decode predefined atoms

# decode empty list

# decode string list

# decode list

# decode improper list

# decode small tuple

# decode large tuple

# decode opaque object

# decode small integer

# decode integer

# decode binary

# decode float

# decode small big integer

# decode big integer

# decode compressed term
