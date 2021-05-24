module WASM

iswasmer = true

include("./base.jl")

if iswasmer
    include("./wasmer/Wasmer.jl")
    using .Wasmer
end

end # module WASM
