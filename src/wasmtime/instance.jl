struct WasmtimeInstance
    # wasmtime instances are "just" a 64 bits identifier associated to a store, as such
    # they don't have an associated destructor of type wasmtime_delete_instance()
    # see the definition of wasmtime_instance_t in LibWasmtime for more info.
    identifier::wasmtime_instance
    store::WasmtimeStore
end

Base.unsafe_convert(::Type{Ptr{wasmtime_instance_t}}, instance::WasmtimeInstance) =
    Base.convert(Ptr{wasmtime_instance}, Base.pointer_from_objref(instance.identifier))

function WasmtimeInstance(store::WasmtimeStore, mod::WasmtimeModule)
    module_imports = imports(mod)
    n_expected_imports = length(module_imports.wasm_imports)
    @assert n_expected_imports == 0 "No imports provided, expected $n_expected_imports"

    instance = Ref(wasmtime_instance_t(0, 0))
    wasm_trap_ptr = Ref(Ptr{wasm_trap_t}())
    @wt_check GC.@preserve instance wasmtime_instance_new(
        store,
        mod,
        C_NULL,
        0,
        instance,
        wasm_trap_ptr,
    )
    if wasm_trap_ptr[] != C_NULL
        trap_msg = WasmByteVec()
        wasm_trap_message(wasm_trap_ptr[], trap_msg)
        wasm_trap_delete(wasm_trap_ptr[])

        error_message = unsafe_string(trap_msg.data, trap_msg.size)
        error(error_message)
    end

    WasmtimeInstance(instance[], store)
end

function WasmtimeInstance(linker::WasmtimeLinker, store::WasmtimeStore, mod::WasmtimeModule)
    instance = Ref(wasmtime_instance_t(0, 0))
    wasm_trap_ptr = Ref(Ptr{wasm_trap_t}())
    @wt_check GC.@preserve instance wasmtime_linker_instantiate(
        linker,
        store,
        mod,
        instance,
        wasm_trap_ptr,
    )
    if wasm_trap_ptr[] != C_NULL
        trap_msg = WasmByteVec()
        wasm_trap_message(wasm_trap_ptr[], trap_msg)
        wasm_trap_delete(wasm_trap_ptr[])

        error_message = unsafe_string(trap_msg.data, trap_msg.size)
        error(error_message)
    end

    WasmtimeInstance(instance[], store)
end

mutable struct WasmtimeInstanceExport <: AbstractWasmExport
    wasm_export_ptr::Ptr{wasm_exporttype_t}
    extern::Ref{wasmtime_extern}

    wasmtime_instance::WasmtimeInstance
    name::String
end

function (wasmtime_export::WasmtimeInstanceExport)(args...)
    extern = wasmtime_export.extern[]
    @assert extern.kind == WASM_EXTERN_FUNC "Expected an exported function but got type $(extern.kind)"

    func = Ref(extern.of.func)
    functype = wasmtime_func_type(wasmtime_export.wasmtime_instance.store, func)

    wasm_params = wasm_functype_params(functype) |> Base.unsafe_load
    wasm_results = wasm_functype_results(functype) |> Base.unsafe_load

    # TODO
    @assert wasm_params.size == 0 "Params are not implemented yet"
    @assert wasm_results.size == 0 "Results are not implemented yet"

    @assert length(args) == wasm_params.size "Expected $(wasm_params.size) arguments but got $(length(args))"

    trap = Ref(Ptr{wasm_trap_t}())
    @wt_check wasmtime_func_call(wasmtime_export.wasmtime_instance.store, func, C_NULL, 0, C_NULL, 0, trap)

    nothing
end

function exports(instance::WasmtimeInstance)
    instance_type = wasmtime_instance_type(instance.store, instance)
    @assert instance_type != C_NULL "Failed to get module type from WasmtimeModule"

    wasm_exports = WasmPtrVec(wasm_exporttype_t)
    wasmtime_instancetype_exports(instance_type, wasm_exports)

    wasmtime_exports = map(enumerate(wasm_exports)) do (i, wasm_export_ptr)
        owned_wasm_export_ptr = wasm_exporttype_copy(wasm_export_ptr)
        @assert owned_wasm_export_ptr != C_NULL "Failed to copy WASM export"

        extern = wasmtime_extern(
            UInt8(0),
            wasmtime_extern_union(Tuple(UInt8(0xab) for _ = 1:16)),
        )
        name_vec = Ref(wasm_name(0, Ptr{wasm_byte_t}()))
        char_ptr =
            Base.unsafe_convert(
                Ptr{Nothing},
                Base.unsafe_convert(Ptr{wasm_byte_vec_t}, name_vec),
            ) + Base.sizeof(Csize_t)
        len_ptr = Base.unsafe_convert(
            Ptr{Csize_t},
            Base.unsafe_convert(Ptr{wasm_byte_vec_t}, name_vec),
        )
        exists = wasmtime_instance_export_nth(
            instance.store,
            instance,
            i - 1,
            char_ptr,
            len_ptr,
            Base.pointer_from_objref(extern),
        )
        exists || error("Export #$i does not exists")
        name = unsafe_string(name_vec[].data, name_vec[].size)

        WasmtimeInstanceExport(wasm_export_ptr, extern, instance, name)
    end

    WasmExports(instance, wasmtime_exports)
end
