module Wasmtime

include("./LibWasmtime.jl")
using .LibWasmtime

abstract type AbstractWasmEngine end
abstract type AbstractWasmModule end

include("./vec_t.jl")
include("./val_t.jl")
include("./imports.jl")
include("./exports.jl")

include("./wasm/store.jl")
include("./wasm/module.jl")
include("./wasm/instance.jl")

export WasmMemory,
    WasmStore,
    WasmInstance,
    exports,
    WasmStore,
    WasmModule,
    imports,
    WasmImports,
    WasmFunc

include("./engine.jl")
include("./wasmtime/error.jl")
include("./wasmtime/wat2wasm.jl")
include("./wasmtime/store.jl")
include("./wasmtime/wasi.jl")
include("./wasmtime/module.jl")
include("./wasmtime/linker.jl")
include("./wasmtime/instance.jl")

include("./wasm/table.jl")

export WasmTable,
    wat2wasm,
    @wat_str,
    WasmInstance,
    WasmExports,
    exports,
    WasmEngine,
    WasmStore,
    WasmModule,
    imports,
    WasmImports,
    WasmFunc

"""
    instanciate(bytes::AbstractVector{UInt8})::WasmtimeInstance

Creates an engine, store, module from the bytes containing valid WebAssembly
and then creates an instance of the said module. The code for this function is
is also a great example of how to use the lower level API to reuse the store, engine
or module for example.
"""
function instantiate(modbytes::AbstractVector{UInt8}; link_wasi = false)
    engine = WasmEngine()
    store = WasmtimeStore(engine)

    wasm_vec = WasmVec(modbytes)
    module_ = WasmtimeModule(engine, wasm_vec)

    if link_wasi
        wconf = Wasmtime.WasiConfig("wasm_unstable")
        set_wasi!(store, wconf)

        linker = WasmtimeLinker(engine)
        define_wasi!(linker)

        instance = WasmtimeInstance(linker, store, module_)
    else
        instance = WasmtimeInstance(store, module_)
    end

    return instance
end

_maybe_unwrap(t) = length(t) == 1 ? only(t) : t

"""
    wcall(instance::WasmtimeInstance, func::Symbol, return_type, arg_types, args...)

`wcall` is analogous to the `ccall` function in julia to call exported WebAssembly
functions.
"""
function wcall(instance, func, return_types, arg_types, args...)
    func_ptr = getproperty(exports(instance), func)

    instance_exports = exports(instance)

    base_ptr = if haskey(instance_exports, :memory) # todo
        WasmtimeMemory(instance_exports.memory).ptr
    else
        Ptr{Nothing}(0)
    end

    @show arg_types args
    wasm_args = map(
        ((type, arg),) ->
            type <: Ptr ? Base.convert(type, arg) - base_ptr : Base.convert(type, arg),
        zip(arg_types, args),
    )
    ret = func_ptr(wasm_args...)

    map(
        ((return_type, return_value),) ->
            return_type <: Ptr ? Base.convert(return_type, Int64(return_value)) + base_ptr :
            Base.convert((return_type,), return_value),
        zip(return_types, ret),
    ) |> _maybe_unwrap
end

const invalid_format_err = "Expression should be of type instance.func(arg1::ArgType1, arg2::ArgType2)::ReturnType"

"""
    @wcall instance.func(arg1::TypeArg1, arg2::TypeArg2)::ReturnType

`@wcall` presents a more natural way to use `wcall` in a similar fashion that `@ccall`.
"""
macro wcall(def)
    @assert Meta.isexpr(def, :(::)) invalid_format_err

    call, ret_type = def.args
    head, args_def... = call.args
    @assert Meta.isexpr(head, :., 2) invalid_format_err

    instance, func = head.args
    @assert instance isa Symbol invalid_format_err
    @assert func isa QuoteNode invalid_format_err

    @assert all(Meta.isexpr.(args_def, :(::))) invalid_format_err
    args = map(ex -> first(ex.args), args_def)
    arg_types = Expr(:tuple, map(ex -> last(ex.args), args_def)...)

    Expr(:call, wcall, instance, func, ret_type, arg_types, args...) |> esc
end

export instantiate, wcall, @wcall

end # Wasmtime
