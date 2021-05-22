using CEnum

@cenum Compiler::UInt32 begin
    Cranelift = 0x00
    LLVM = 0x01
    Singlepass = 0x02
end

@cenum Engine::UInt32 begin
    JIT = 0x00
    Native = 0x01
    ObjectFile = 0x02
end

wasmer_is_compiler_available(compiler::Compiler) =
    @ccall libwasmer.wasmer_is_compiler_available(compiler::Cint)::Bool

wasmer_is_engine_available(engine::Engine) =
    @ccall libwasmer.wasmer_is_engine_available(engine::Cint)::Bool

function first_available_compiler()
    compilers = Compiler[Cranelift, LLVM, Singlepass]
    compiler_idx = findfirst(wasmer_is_compiler_available, compilers)
    @assert compiler_idx !== nothing "No available compiler"
    compilers[compiler_idx]
end

function first_available_engine()
    engines = Engine[JIT, Native, ObjectFile]
    engine_idx = findfirst(wasmer_is_engine_available, engines)
    @assert engine_idx !== nothing "No available engine"
    engines[engine_idx]
end
    
struct WasmConfig
    compiler::Compiler
    engine::Engine

    function WasmConfig(;
        compiler::Compiler=first_available_compiler(),
        engine::Engine=first_available_engine()
    )
        @assert wasmer_is_compiler_available(compiler) "Compiler $compiler is not available"
        @assert wasmer_is_engine_available(engine) "Engine $engine is available"

        new(compiler, engine)
    end
end

mutable struct WasmEngine
    wasm_engine_ptr::Ptr{wasm_engine_t}
    config::WasmConfig

    WasmEngine(wasm_engine_ptr::Ptr{wasm_engine_t}, config::WasmConfig) = finalizer(new(wasm_engine_ptr, config)) do wasm_engine
        wasm_engine_delete(wasm_engine.wasm_engine_ptr)
    end
end
function WasmEngine(config::WasmConfig)
    wasm_config_ptr = wasm_config_new()

    @ccall libwasmer.wasm_config_set_compiler(wasm_config_ptr::Ptr{wasm_config_t}, config.compiler::Cint)::Cvoid
    @ccall libwasmer.wasm_config_set_engine(wasm_config_ptr::Ptr{wasm_config_t}, config.engine::Cint)::Cvoid

    wasm_engine_ptr = LibWasmer.wasm_engine_new_with_config(wasm_config_ptr)
    WasmEngine(wasm_engine_ptr, config)
end
WasmEngine(;compiler=first_available_compiler(), engine=first_available_engine()) =
    WasmEngine(WasmConfig(;compiler, engine))

Base.show(io::IO, engine::WasmEngine) = print(io, "WasmEngine($(engine.config.compiler), $(engine.config.engine))")

mutable struct WasmStore
    wasm_store_ptr::Ptr{wasm_store_t}

    WasmStore(wasm_store_ptr::Ptr{wasm_store_t}) = finalizer(new(wasm_store_ptr)) do wasm_store
        wasm_store_delete(wasm_store.wasm_store_ptr)
    end
end
WasmStore(wasm_engine::WasmEngine) = WasmStore(wasm_store_new(wasm_engine.wasm_engine_ptr))

Base.show(io::IO, ::WasmStore) = print(io, "WasmStore()")