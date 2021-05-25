module Wasmtime

include("../base.jl")

const libwasmtime = libwasm

include("./engine.jl")
include("./wat2wasm.jl")
include("./wasi.jl")

export wat2wasm, @wat_str, WasmInstance, WasmExports, exports,
    WasmEngine, WasmConfig, WasmStore, WasmModule, imports, WasmImports,
    WasmFunc

end # Wasmtime