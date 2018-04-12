const FILES = String["CLITest.jl",
                     "DecodeTest.jl",
                     "EncodeTest.jl"
                    ]

function run_test(test_module::Module)::Void
    Base.invokelatest(test_module.run)

    return nothing
end

function run_tests(test_modules::Vector{Module})::Void
    for test_module in test_modules
        run_test(test_module)
    end

    return nothing
end

run_tests([include(test_module_path) for test_module_path in FILES])
