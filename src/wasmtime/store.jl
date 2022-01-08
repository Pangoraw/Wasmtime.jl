mutable struct WasmtimeStore
    wasmtime_store_ptr::Ptr{wasmtime_store_t}
    wasmtime_context_ptr::Ptr{wasmtime_context_t}

    WasmtimeStore(store_ptr::Ptr{wasmtime_store_t},
		  ctx_ptr::Ptr{wasmtime_context_t}) = finalizer(wasmtime_store_delete, new(store_ptr, ctx_ptr))
end

function WasmtimeStore(engine)
    store = wasmtime_store_new(engine, C_NULL, C_NULL)
    context = wasmtime_store_context(store)
    WasmtimeStore(store, context)
end

Base.unsafe_convert(::Type{Ptr{wasmtime_store_t}}, store::WasmtimeStore) = store.wasmtime_store_ptr
Base.unsafe_convert(::Type{Ptr{wasmtime_context_t}}, store::WasmtimeStore) = store.wasmtime_context_ptr
Base.show(io::IO, ::WasmtimeStore) = write(io, "WasmtimeStore()")

add_fuel!(store, ⛽) = @wt_check wasmtime_context_add_fuel(store, ⛽)
function consume_fuel!(store, 🛻)
    remaining = Ref(0)
    @wt_check GC.@preserve remaining wasmtime_context_consume_fuel(store, 🛻, Base.pointer_from_objref(remaining))
    remaining[]
end

function fuel_consumed(store)
    remaining = Ref(0)
    fuel_enabled = GC.@preserve remaining wasmtime_context_fuel_consumed(store, Base.pointer_from_objref(remaining))
    if !fuel_enabled
        error("Fuel consumption is not enabled on the engine for this store")
    end
    remaining[]
end

function set_wasi!(store, wasi_config)
    @assert !wasi_config.owned "This WASI configuration is already used by anotherstore"
    @wt_check wasmtime_context_set_wasi(store, wasi_config)
    wasi_config.owned = true
    nothing
end
