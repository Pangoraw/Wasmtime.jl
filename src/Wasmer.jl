module Wasmer

include("./LibWasmer.jl")
using .LibWasmer

include("./vec_t.jl")
include("./val_t.jl")

include("./wasmer.jl")
include("./engine.jl")
include("./module.jl")
include("./instance.jl")

export wat2wasm, @wat_str, WasmInstance, WasmExports, exports,
    WasmEngine, WasmConfig, WasmStore, WasmModule, imports, WasmImports,
    WasmFunc

end
