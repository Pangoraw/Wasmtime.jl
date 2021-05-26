module WasmRuntime

include("./base.jl")

iswasmer = occursin("wasmer", libwasm)
iswasmtime = occursin("wasmtime", libwasm)

if iswasmer
    include("./wasmer/Wasmer.jl")
end

if iswasmtime
    include("./wasmtime/Wasmtime.jl")
end

end # module WasmRuntime
