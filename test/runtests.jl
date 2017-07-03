module ErlPortTests

const FILES = String["CLITest.jl",
                     #"DecodeTest.jl",
                     #"EncodeTest.jl",
                     #"ErlProtoTest.jl",
                     #"ErlTermsTest.jl",
                     #"ErlangTest.jl",
                     #"StdIOTest.jl"
                    ]

function run()::Void
    run(FILES)
end

function run(files::Vector{String})::Void
    for file in files
        let test_module::Module = include(file)
            test_module.run()
        end
    end
end

end # module

ErlPortTests.run()
