using WASM.Wasmtime
using Test

backend = isdefined(@__MODULE__, :Wasmer) ? Wasmer : Wasmtime

include("./import_export.jl")
include("./wat2wasm.jl")
include("./wasi.jl")