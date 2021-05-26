using WASM.Wasmtime
using Test

backend = isdefined(@__MODULE__, :Wasmer) ? Wasmer : Wasmtime

include("./table.jl")
include("./import_export.jl")
include("./wat2wasm.jl")
include("./wasi.jl")