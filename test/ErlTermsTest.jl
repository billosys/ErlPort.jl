using Base.Test

using ErlPort.ErlTerms

@test decode("") == ""
@test_throws IncompleteData decode(1)
