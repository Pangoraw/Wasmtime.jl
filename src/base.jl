include("./LibWasm.jl")
using .LibWasm

include("./vec_t.jl")
include("./val_t.jl")

abstract type AbstractWasmEngine end

include("./store.jl")
include("./module.jl")
include("./instance.jl")

export WasmStore,
    WasmInstance,
    WasmExports,
    exports,
    WasmStore,
    WasmModule,
    imports,
    WasmImports,
    WasmFunc
