module Wasmtime

include("./LibWasmtime.jl")
using .LibWasmtime

abstract type AbstractWasmEngine end
abstract type AbstractWasmModule end

include("./vec_t.jl")
include("./val_t.jl")
include("./imports.jl")
include("./exports.jl")

include("./wasm/store.jl")
include("./wasm/module.jl")
include("./wasm/instance.jl")

export WasmMemory,
    WasmStore,
    WasmInstance,
    WasmExports,
    exports,
    WasmStore,
    WasmModule,
    imports,
    WasmImports,
    WasmFunc

include("./engine.jl")
include("./wasmtime/error.jl")
include("./wasmtime/wat2wasm.jl")
include("./wasmtime/store.jl")
include("./wasmtime/wasi.jl")
include("./wasmtime/module.jl")
include("./wasmtime/linker.jl")
include("./wasmtime/instance.jl")

include("./wasm/table.jl")

export WasmTable,
    wat2wasm,
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

end # Wasmtime
