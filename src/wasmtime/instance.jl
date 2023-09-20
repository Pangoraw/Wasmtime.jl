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

struct WasmtimeMemory <: AbstractVector{UInt8}
    export_::WasmtimeInstanceExport
end

"Page size of the memory"
function memory_size(mem::WasmtimeMemory)
    extern = mem.export_.extern[]
    @assert extern.kind == WASM_EXTERN_MEMORY
    memory = Ref(extern.of.memory)
    store = mem.export_.wasmtime_instance.store

    sz = LibWasmtime.wasmtime_memory_size(store, memory)
    Int(sz)
end

function memory_max(mem::WasmtimeMemory)
    extern = mem.export_.extern[]
    @assert extern.kind == WASM_EXTERN_MEMORY
    memory = Ref(extern.of.memory)
    store = mem.export_.wasmtime_instance.store

    mem_type = LibWasmtime.wasmtime_memory_type(store, memory)
    max = Ref{UInt64}()
    hasmax = LibWasmtime.wasmtime_memorytype_maximum(mem_type, max)
    hasmax ? max[] : typemax(UInt64)
end

struct WasmtimeFunc
    export_::WasmtimeInstanceExport
end

function Base.size(mem::WasmtimeMemory)
    extern = mem.export_.extern[]
    @assert extern.kind == WASM_EXTERN_MEMORY
    memory = Ref(extern.of.memory)
    store = mem.export_.wasmtime_instance.store

    sz = LibWasmtime.wasmtime_memory_data_size(store, memory)
    (Int(sz),)
end

function Base.getindex(mem::WasmtimeMemory, i)
    extern = mem.export_.extern[]
    @assert extern.kind == WASM_EXTERN_MEMORY
    memory = Ref(extern.of.memory)
    store = mem.export_.wasmtime_instance.store

    1 <= i <= length(mem) || throw("out of bounds $i")
    data_ptr = LibWasmtime.wasmtime_memory_data(store, memory) |> Ptr{UInt8}
    unsafe_load(data_ptr, i)
end

function Base.setindex!(mem::WasmtimeMemory, v, i)
    extern = mem.export_.extern[]
    @assert extern.kind == WASM_EXTERN_MEMORY
    memory = Ref(extern.of.memory)
    store = mem.export_.wasmtime_instance.store

    1 <= i <= length(mem) || throw("out of bounds $i")
    data_ptr = LibWasmtime.wasmtime_memory_data(store, memory) |> Ptr{UInt8}

    unsafe_store!(data_ptr, v, i)
end

function grow!(mem::WasmtimeMemory, delta)
    extern = mem.export_.extern[]
    @assert extern.kind == WASM_EXTERN_MEMORY
    memory = Ref(extern.of.memory)
    store = mem.export_.wasmtime_instance.store

    if delta + memory_size(mem) > memory_max(mem)
        max = memory_max(mem)
        sz = memory_size(mem)
        error("invalid delta $delta (maximum page size is $max, current $sz)")
    end

    prev_size = Ref{UInt64}()
    @wt_check wasmtime_memory_grow(store, memory, delta, prev_size)
    Int(prev_size[])
end

function (func::WasmtimeFunc)(args...)
    wasmtime_export = func.export_
    extern = wasmtime_export.extern[]
    @assert extern.kind == WASM_EXTERN_FUNC "Expected an exported function but got type $(extern.kind)"

    func = Ref(extern.of.func)
    functype = wasmtime_func_type(wasmtime_export.wasmtime_instance.store, func)

    wasm_params = Base.unsafe_convert(Ptr{WasmVec{wasm_valtype_vec_t,Ptr{wasm_valtype_t}}}, wasm_functype_params(functype)) |> Base.unsafe_load
    wasm_results = Base.unsafe_convert(Ptr{WasmVec{wasm_valtype_vec_t,Ptr{wasm_valtype_t}}}, wasm_functype_results(functype)) |> Base.unsafe_load

    @assert length(args) == length(wasm_params) "Expected $(wasm_params.size) arguments but got $(length(args))"
    params_kind = wasm_valtype_kind.(wasm_params)

    wasmtime_params = wasmtime_val[]
    for (i, (param, kind)) in enumerate(zip(args, params_kind))
        jtype = typeof(param)
        etype = wasmtime_valkind_to_julia(kind)
        @assert jtype == etype "Parameter #$i is of type $jtype, expected $etype"

        valunion = Ref{wasmtime_valunion}(wasmtime_valunion(Tuple(zero(UInt8) for _ in 1:16)))
        GC.@preserve valunion begin
            ptr = Base.unsafe_convert(Ptr{wasmtime_valunion}, valunion)
            if jtype == Int32
                ptr.i32 = etype(param)
            elseif jtype == Int64
                ptr.i64 = etype(param)
            elseif jtype == Float32
                ptr.f32 = etype(param)
            elseif jtype == Float64
                ptr.f64 = etype(param)
            end
        end
        push!(wasmtime_params, wasmtime_val(kind, valunion[]))
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
        trap
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

    length(results) == 1 ?
        first(results) : results
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

        export_ = WasmtimeInstanceExport(wasm_export_ptr, extern, instance, name)
        if extern.kind == WASM_EXTERN_FUNC
            WasmtimeFunc(export_)
        elseif extern.kind == WASM_EXTERN_MEMORY
            WasmtimeMemory(export_)
        else # generic export, TODO: complete
            export_
        end
    end

    WasmExports(instance, wasmtime_exports)
end

name(func::WasmtimeFunc) = func.export_.name
name(mem::WasmtimeMemory) = mem.export_.name
name(export_::WasmtimeInstanceExport) = export_.name
