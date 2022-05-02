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

"""
    WasmtimeMemory(export::WasmtimeInstanceExport)

A minimal wrapper around `wasmtime_memory_t`

Example of how to access and write to it from a wasi instance:

```julia
instance = ...

memory = WasmtimeMemory(exports(instance).memory)

# Example of setting the memory.
string_to_pass = "a very long string"
for (i, c) in enumerate(string_to_pass)
    mem[ptr + i] = c
end
```
"""
struct WasmtimeMemory <: AbstractVector{UInt8}
    ptr::Ptr{UInt8}

    mem::wasmtime_memory_t
    exp::WasmtimeInstanceExport
end
function WasmtimeMemory(exp)
    @assert exp.extern[].kind == WASMTIME_EXTERN_MEMORY "The given export is not a valid memory."

    mem = Ref(exp.extern[].of.memory)
    ptr = LibWasmtime.wasmtime_memory_data(exp.wasmtime_instance.store, mem)

    WasmtimeMemory(ptr, mem[], exp)
end

Base.unsafe_convert(::Type{Ptr{wasmtime_memory_t}}, mem::WasmtimeMemory) =
    Base.convert(Ptr{wasmtime_memory_t}, Base.pointer_from_objref(mem.mem))
Base.size(mem::WasmtimeMemory) = (length(mem),)
Base.length(mem::WasmtimeMemory) =
    LibWasmtime.wasmtime_memory_data_size(mem.exp.wasmtime_instance.store, mem)
Base.getindex(mem::WasmtimeMemory, i) = Base.unsafe_load(mem.ptr, i)
Base.setindex!(mem::WasmtimeMemory, val, i) = Base.unsafe_store!(mem.ptr, val, i)

function wasmtime_valkind_to_julia(valkind::wasmtime_valkind_t)::Type
    if valkind == WASMTIME_I32
        Int32
    elseif valkind == WASMTIME_I64
        Int64
    elseif valkind == WASMTIME_F32
        Float32
    elseif valkind == WASMTIME_F64
        Float64
    elseif valkind == WASMTIME_FUNCREF
        wasmtime_func_t
    elseif valkind == WASMTIME_EXTERNREF
        Ptr{wasmtime_externref_t}
    elseif valkind == WASMTIME_V128
        wasmtime_v128
    else
        error("Invalid value kind $type")
    end
end

function (wasmtime_export::WasmtimeInstanceExport)(args...)
    extern = wasmtime_export.extern[]
    @assert extern.kind == WASM_EXTERN_FUNC "Expected an exported function but got type $(extern.kind)"

    func = Ref(extern.of.func)
    functype = wasmtime_func_type(wasmtime_export.wasmtime_instance.store, func)

    wasm_params =
        Base.unsafe_convert(
            Ptr{WasmVec{wasm_valtype_vec_t,Ptr{wasm_valtype_t}}},
            wasm_functype_params(functype),
        ) |> Base.unsafe_load
    wasm_results =
        Base.unsafe_convert(
            Ptr{WasmVec{wasm_valtype_vec_t,Ptr{wasm_valtype_t}}},
            wasm_functype_results(functype),
        ) |> Base.unsafe_load

    @assert length(args) == length(wasm_params) "Expected $(wasm_params.size) arguments but got $(length(args))"
    params_kind = wasm_valtype_kind.(wasm_params)

    wasmtime_params = wasmtime_val[]
    for (i, (param, kind)) in enumerate(zip(args, params_kind))
        jtype = typeof(param)
        etype = wasmtime_valkind_to_julia(kind)
        @assert jtype == etype "Parameter #$i is of type $jtype, expected $etype"

        valunion =
            Ref{wasmtime_valunion}(wasmtime_valunion(Tuple(zero(UInt8) for _ = 1:16)))
        ptr = Base.unsafe_convert(Ptr{wasmtime_valunion}, valunion)
        GC.@preserve valunion ptr.i32 = etype(param)
        push!(wasmtime_params, wasmtime_val(WASM_I32, valunion[]))
    end

    wasmtime_results = Vector{wasmtime_val}(undef, length(wasm_results))

    trap = Ref(Ptr{wasm_trap_t}())
    @wt_check GC.@preserve wasmtime_params wasmtime_results wasmtime_func_call(
        wasmtime_export.wasmtime_instance.store,
        func,
        pointer(wasmtime_params),
        length(wasmtime_params),
        pointer(wasmtime_results),
        length(wasmtime_results),
        trap,
    )

    results = map(wasmtime_results) do result
        if result.kind == WASMTIME_I32
            result.of.i32
        elseif result.kind == WASMTIME_I64
            result.of.i64
        elseif result.kind == WASMTIME_F32
            result.of.f32
        elseif result.kind == WASMTIME_F64
            result.of.f64
        elseif result.kind == WASMTIME_V128
            result.of.v128
        elseif result.kind == WASMTIME_FUNCREF
            result.of.funcref
        elseif result.kind == WASMTIME_EXTERNREF
            result.of.externref
        else
            error("Unknown value kind $(result.kind)")
        end
    end

    length(results) == 1 ? first(results) : results
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
    wasmtime_exports = Dict{Symbol,WasmtimeInstanceExport}(
        Symbol(exp.name) => exp for exp in wasmtime_exports
    )

    WasmExports(instance, wasmtime_exports)
end
