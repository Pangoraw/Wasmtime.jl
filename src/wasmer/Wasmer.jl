module Wasmer

include("../base.jl")

const libwasmer = libwasm

include("./wat2wasm.jl")
include("./engine.jl")
include("./wasi.jl")

export wat2wasm,
    @wat_str,
    WasmInstance,
    WasmExports,
    exports,
    WasmEngine,
    WasmConfig,
    WasmStore,
    WasmModule,
    imports,
    WasmImports,
    WasmFunc

end # module Wasmer
