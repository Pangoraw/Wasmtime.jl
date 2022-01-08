mutable struct WasmtimeModule <: AbstractWasmModule
    wasmtime_module_ptr::Ptr{wasmtime_module_t}

    WasmtimeModule(ptr::Ptr{wasmtime_module_t}) =
        finalizer(wasmtime_module_delete, new(ptr))
end

function WasmtimeModule(engine, code)
    mod_ptr = Ref{Ptr{wasmtime_module_t}}(Ptr{wasmtime_module_t}())
    @wt_check GC.@preserve mod wasmtime_module_new(
        engine,
        code,
        length(code),
        Base.pointer_from_objref(mod_ptr),
    )
    WasmtimeModule(mod_ptr[])
end

Base.unsafe_convert(::Type{Ptr{wasmtime_module_t}}, mod::WasmtimeModule) =
    mod.wasmtime_module_ptr

Base.show(io::IO, ::WasmtimeModule) = write(io, "WasmtimeModule()")

function imports(mod::WasmtimeModule)
    module_type = wasmtime_module_type(mod)
    mod_imports = WasmPtrVec(wasm_importtype_t)
    wasmtime_moduletype_imports(module_type, mod_imports)
    WasmImports(mod, mod_imports)
end

mutable struct NotInstanciatedWasmExport <: AbstractWasmExport
    wasm_export_ptr::Ptr{wasm_exporttype_t}

    wasm_module::WasmtimeModule
    name::String

    function NotInstanciatedWasmExport(
        wasm_export_ptr::Ptr{wasm_exporttype_t},
        mod::WasmtimeModule,
    )

        owned_wasm_export_ptr = wasm_exporttype_copy(wasm_export_ptr)
        @assert owned_wasm_export_ptr != C_NULL "Failed to copy WASM export"

        name_vec_ptr = wasm_exporttype_name(owned_wasm_export_ptr)
        name_vec = Base.unsafe_load(name_vec_ptr)
        name = unsafe_string(name_vec.data, name_vec.size)
        wasm_name_delete(name_vec_ptr)

        finalizer(new(owned_wasm_export_ptr, mod, name)) do wasm_export
            wasm_exporttype_delete(wasm_export.wasm_export_ptr)
        end
    end
end

function exports(mod::WasmtimeModule)
    module_type = wasmtime_module_type(mod)
    @assert module_type != C_NULL "Failed to get module type from WasmtimeModule"

    wasm_exports = WasmPtrVec(wasm_exporttype_t)
    wasmtime_moduletype_exports(module_type, wasm_exports)

    exports_vector = map(a -> NotInstanciatedWasmExport(a, mod), wasm_exports)

    WasmExports{WasmtimeModule,NotInstanciatedWasmExport}(mod, exports_vector)
end
