# TODO: Group Wasmtime.WasmEngine and Wasmer.WasmEngine

mutable struct WasmEngine <: AbstractWasmEngine
    wasm_engine_ptr::Ptr{wasm_engine_t}

    WasmEngine(wasm_engine_ptr) = finalizer(new(wasm_engine_ptr)) do wasm_engine
        wasm_engine_delete(wasm_engine_ptr)
    end
end
function WasmEngine()
    wasm_engine_ptr = wasm_engine_new()
    WasmEngine(wasm_engine_ptr)
end

Base.unsafe_convert(::Type{Ptr{wasm_engine_t}}, wasm_engine::WasmEngine) = wasm_engine.wasm_engine_ptr
Base.show(io::IO, ::WasmEngine) = print(io, "WasmEngine()")