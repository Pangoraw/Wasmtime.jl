mutable struct WasmtimeLinker
    wasmtime_linker_ptr::Ptr{wasmtime_linker_t}

    WasmtimeLinker(ptr::Ptr{wasmtime_linker_t}) = finalizer(wasmtime_linker_delete, new(ptr))
end

WasmtimeLinker(engine) = wasmtime_linker_new(engine) |> WasmtimeLinker

Base.unsafe_convert(::Type{Ptr{wasmtime_linker_t}}, linker::WasmtimeLinker) = linker.wasmtime_linker_ptr
Base.show(io::IO, ::WasmtimeLinker) = write(io, "WasmtimeLinker()")

define_wasi!(linker) = (@wt_check wasmtime_linker_define_wasi(linker));
