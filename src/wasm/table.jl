"""
A wrapper for wasm_table_t specific to wasmtime, since the wasmtime c-api is currently missing
wasm_ref_as_func()
"""
mutable struct WasmTable <: AbstractVector{WasmFuncRef}
    store::WasmStore
    wasm_table_ptr::Ptr{wasm_table_t}
end
function WasmTable(store::WasmStore, limits::Pair{Int,Int})
    wasm_limits = wasm_limits_t(limits...)
    table_valtype = wasm_valtype_new(WASM_FUNCREF)
    @assert table_valtype != C_NULL "Failed to create table valtype"

    table_type = GC.@preserve wasm_limits wasm_tabletype_new(
        table_valtype,
        pointer_from_objref(wasm_limits),
    )
    @assert table_type != C_NULL "Failed to create table type"

    wasm_table_ptr = wasm_table_new(store, table_type, C_NULL)
    @assert wasm_table_ptr != C_NULL "Failed to create table"

    # finalizer(wasm_table_delete, WasmTable(store, wasm_table_ptr))
    WasmTable(store, wasm_table_ptr)
end

Base.unsafe_convert(::Type{Ptr{wasm_table_t}}, wasm_table::WasmTable) =
    wasm_table.wasm_table_ptr

Base.IndexStyle(::Type{WasmTable}) = IndexLinear()
Base.size(table::WasmTable) = (wasm_table_size(table) |> Int,)
function Base.getindex(table::WasmTable, i::Int)
    wasm_val_ref = Ref(wasm_val_t(tuple((zero(UInt8) for _ = 1:16)...)))

    index = i - 1

    wasmtime_context = @ccall libwasmtime.wasmtime_store_context(table.store::Ptr{wasm_store_t})::Ptr{Nothing}
    res = @ccall libwasmtime.wasmtime_table_get(
        wasmtime_context::Ptr{Nothing},
        table::Ptr{wasm_table_t},
        index::Cint,
        wasm_val_ref::Ptr{wasm_val_t},
    )::Bool
    @assert res "Failed to access index $i"
    @assert wasm_val_ref[].kind == WASM_FUNCREF

    WasmFuncRef(wasm_func_ptr[])
end
function Base.setindex!(table::WasmTable, v, i::Int)
    wasm_table_set(table, v, i - 1) # TODO: use result
end

map_to_extern(extern_table::WasmTable) = wasm_table_as_extern(extern_table)
