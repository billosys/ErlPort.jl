using Base.Test

function formatfailure (r)
    expr = "Expression -> $(r.expr)"
    # Julia 0.3.2 doesn't have resultexpr field :-(
    # expt = "Expected value -> "
    # actl = "Actual value -> $(r.resultexpr)"
    #error("testcase failed\n\t$expr\n\t$expt\n\t$actl")
    error("testcase failed\n\t$expr\n")
end

testhandler(r::Test.Success) = nothing
testhandler(r::Test.Failure) = formatfailure(r)
testhandler(r::Test.Error)   = rethrow(r)

function testcase(func::Function)
    Test.with_handler(func, testhandler)
end
