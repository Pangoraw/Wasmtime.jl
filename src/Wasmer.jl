module Wasmer

using CEnum

include("./LibWasmer.jl")
using .LibWasmer

function wasmer_last_error_length()
    ccall((:wasmer_last_error_length, libwasmer), Cint, ())
end

function wasmer_last_error_message(error_length=get_last_error_length())
    error_length === 0 && return

    buffer = Vector{UInt8}(undef, error_length)
    buffer_ptr = Base.unsafe_convert(Ptr{UInt8}, buffer)
    res = ccall((:wasmer_last_error_message, libwasmer), Cint, (Cstring, Cint), buffer_ptr, error_length)
    res === -1 && error("Failed to retrieve last wasmer error")

    unsafe_string(buffer_ptr, error_length)
end

function check_wasmer_error()
    error_length = wasmer_last_error_length()
    if error_length != 0
        error_msg = wasmer_last_error_message(error_length)
        error(error_msg)
    end
end

import Base: unsafe_convert
Base.unsafe_convert(::Type{Ptr{wasm_byte_vec_t}}, vec::wasm_byte_vec_t) =
    Base.unsafe_convert(Ptr{wasm_byte_vec_t}, Base.pointer_from_objref(vec))
Base.unsafe_convert(::Type{Ptr{wasm_extern_vec_t}}, vec::wasm_extern_vec_t) =
    Base.unsafe_convert(Ptr{wasm_extern_vec_t}, Base.pointer_from_objref(vec))
Base.unsafe_convert(::Type{Ptr{wasm_exporttype_vec_t}}, vec::wasm_exporttype_vec_t) =
    Base.unsafe_convert(Ptr{wasm_exporttype_vec_t}, Base.pointer_from_objref(vec))
Base.unsafe_convert(::Type{Ptr{wasm_val_vec_t}}, vec::wasm_val_vec_t) =
    Base.unsafe_convert(Ptr{wasm_val_vec_t}, Base.pointer_from_objref(vec))

LibWasmer.wasm_byte_vec_t(str::AbstractString) =
    wasm_byte_vec_t(length(str), Base.unsafe_convert(Cstring, Base.unsafe_wrap(Vector{UInt8}, str)))


wat2wasm(str::AbstractString) =
    wat2wasm(wasm_byte_vec_t(str))
function wat2wasm(wat::wasm_byte_vec_t)
    out = wasm_byte_vec_t(0, C_NULL)
    ccall((:wat2wasm, libwasmer), Cvoid, (Ptr{wasm_byte_vec_t}, Ptr{wasm_byte_vec_t}), wat, out)
    check_wasmer_error()

    out
end

macro wat_str(wat::String)
    :(wat2wasm($wat))
end

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


mutable struct WasmModule
    wasm_module_ptr::Ptr{wasm_module_t}

    WasmModule(module_ptr::Ptr{wasm_module_t}) = finalizer(new(module_ptr)) do wasm_module
        wasm_module_delete(wasm_module.wasm_module_ptr)
    end
end
function WasmModule(store::WasmStore, wasm_byte_vec::wasm_byte_vec_t)
    wasm_module_ptr = wasm_module_new(store.wasm_store_ptr, wasm_byte_vec)
    wasm_module_ptr == C_NULL && error("Failed to create wasm module")

    WasmModule(wasm_module_ptr)
end

mutable struct WasmInstance
    wasm_instance_ptr::Ptr{wasm_instance_t}
    wasm_module::WasmModule
    
    WasmInstance(wasm_instance_ptr::Ptr{wasm_instance_t}, wasm_module::WasmModule) = finalizer(new(wasm_instance_ptr, wasm_module)) do wasm_instance
        wasm_instance_delete(wasm_instance.wasm_instance_ptr)
    end
end
function WasmInstance(store::WasmStore, wasm_module::WasmModule)
    imports = wasm_extern_vec_t(0, C_NULL)
    wasm_instance_ptr = wasm_instance_new(store.wasm_store_ptr, wasm_module.wasm_module_ptr, imports, C_NULL)
    wasm_instance_ptr == C_NULL && error("Failed to create WASM instance")
    WasmInstance(wasm_instance_ptr, wasm_module)
end

Base.show(io::IO, ::WasmInstance) = print(io, "WasmInstance()")
Base.show(io::IO, ::WasmStore) = print(io, "WasmStore()")

# TODO: the other value types
function WasmInt32(i::Int32) 
    val = Ref(wasm_val_t(tuple((zero(UInt8) for _ in 1:16)...)))
    ptr = Base.unsafe_convert(Ptr{wasm_val_t}, Base.pointer_from_objref(val))
    ptr.kind = WASM_I32
    ptr.of.i32 = i

    val[]
end
function WasmInt64(i::Int64) 
    val = Ref(wasm_val_t(tuple((zero(UInt8) for _ in 1:16)...)))
    ptr = Base.unsafe_convert(Ptr{wasm_val_t}, Base.pointer_from_objref(val))
    ptr.kind = WASM_I64
    ptr.of.i64 = i

    val[]
end
function WasmFloat32(i::Int32) 
    val = Ref(wasm_val_t(tuple((zero(UInt8) for _ in 1:16)...)))
    ptr = Base.unsafe_convert(Ptr{wasm_val_t}, Base.pointer_from_objref(val))
    ptr.kind = WASM_F32
    ptr.of.f32 = i

    val[]
end
function WasmFloat64(i::Int64) 
    val = Ref(wasm_val_t(tuple((zero(UInt8) for _ in 1:16)...)))
    ptr = Base.unsafe_convert(Ptr{wasm_val_t}, Base.pointer_from_objref(val))
    ptr.kind = WASM_F64
    ptr.of.f64 = i

    val[]
end

Base.convert(::Type{wasm_val_t}, i::Int32) = WasmInt32(i)
Base.convert(::Type{wasm_val_t}, i::Int64) = WasmInt64(i)
Base.convert(::Type{wasm_val_t}, f::Float32) = WasmFloat32(f)
Base.convert(::Type{wasm_val_t}, f::Float64) = WasmFloat64(f)

Base.convert(::Type{Int32}, wasm_val::wasm_val_t) = 
    wasm_val.kind == WASM_I32 ? wasm_val.of.i32 : error("Cannot convert value of type $(wasm_valkind_enum(wasm_val.kind)) to Int32")
Base.convert(::Type{Int64}, wasm_val::wasm_val_t) =
    wasm_val.kind == WASM_I64 ? wasm_val.of.i64 : error("Cannot convert value of type $(wasm_valkind_enum(wasm_val.kind)) to Int64")
Base.convert(::Type{Float32}, wasm_val::wasm_val_t) = 
    wasm_val.kind == WASM_I32 ? wasm_val.of.f32 : error("Cannot convert value of type $(wasm_valkind_enum(wasm_val.kind)) to Float32")
Base.convert(::Type{Float64}, wasm_val::wasm_val_t) =
    wasm_val.kind == WASM_I64 ? wasm_val.of.f64 : error("Cannot convert value of type $(wasm_valkind_enum(wasm_val.kind)) to Float64")

function Base.show(io::IO, wasm_val::wasm_val_t)
    name, maybe_val = if wasm_val.kind == WASM_I32
        "WasmInt32", wasm_val.of.i32 |> string
    elseif wasm_val.kind == WASM_I64
        "WasmInt64", wasm_val.of.i64 |> string
    elseif wasm_val.kind == WASM_F32
        "WasmFloat32", wasm_val.of.f32 |> string
    elseif wasm_val.kind == WASM_F64
        "WasmFloat64", wasm_val.of.f64 |> string
    else
        "WasmAny", ""
    end

    print(io, "$name($maybe_val)")
end

# TODO: One for each exporttype_type?
mutable struct WasmExport
    # The wasm_exporttype_t refers to the export on the module side
    wasm_export_ptr::Ptr{wasm_exporttype_t}
    # The wasm_extern_t refers to the export on the instance side
    wasm_extern_ptr::Ptr{wasm_extern_t}
    wasm_instance::WasmInstance
    name::String

    function WasmExport(
        wasm_export_ptr::Ptr{wasm_exporttype_t}, 
        wasm_extern_ptr::Ptr{wasm_extern_t},
        wasm_instance::WasmInstance,
    )
        name_vec_ptr = wasm_exporttype_name(wasm_export_ptr)
        name_vec = Base.unsafe_load(name_vec_ptr)
        name = unsafe_string(name_vec.data, name_vec.size)
        wasm_name_delete(name_vec_ptr)

        # TODO: Extract type here
        new(wasm_export_ptr, wasm_extern_ptr, wasm_instance, name)
    end
end

function (wasm_export::WasmExport)(args...)
    wasm_externtype_ptr = wasm_exporttype_type(wasm_export.wasm_export_ptr)
    @assert wasm_externtype_ptr != C_NULL "Failed to get export type for export $(wasm_export.name)"
    wasm_externkind = wasm_externtype_kind(wasm_externtype_ptr)
    @assert wasm_externkind == WASM_EXTERN_FUNC "Called export '$(wasm_export.name)' is not a function"

    extern_as_func = wasm_extern_as_func(wasm_export.wasm_extern_ptr)
    extern_as_func == C_NULL && error("Can not use export $(wasm_export.name) as a function")
    
    params_arity = wasm_func_param_arity(extern_as_func)
    result_arity = wasm_func_result_arity(extern_as_func)

    provided_params = length(args)
    if params_arity != provided_params
        error("Wrong number of argument to function $(wasm_export.name), expected $params_arity, got $provided_params")
    end

    converted_args = collect(map(arg -> convert(wasm_val_t, arg), args))
    params_vec = wasm_val_vec_t(0, C_NULL)

    args_ptr = Base.pointer(converted_args)
    GC.@preserve converted_args args_ptr wasm_val_vec_new(params_vec, params_arity, args_ptr)

    results_vec = wasm_val_vec_t(0, C_NULL)
    wasm_val_vec_new_uninitialized(results_vec, result_arity)

    wasm_func_call(extern_as_func, params_vec, results_vec)

    results = map(1:result_arity) do i
        Base.unsafe_load(results_vec.data, i)
    end
    wasm_val_vec_delete(params_vec)
    wasm_val_vec_delete(results_vec)

    results
end

mutable struct WasmExports
    wasm_instance::WasmInstance
    wasm_exports::Vector{WasmExport}

    function WasmExports(wasm_instance::WasmInstance)
        exports = wasm_exporttype_vec_t(0, C_NULL)
        wasm_module_exports(wasm_instance.wasm_module.wasm_module_ptr, exports)
        externs = wasm_extern_vec_t(0, C_NULL)
        wasm_instance_exports(wasm_instance.wasm_instance_ptr, externs)
        @assert exports.size == externs.size

        exports_vector = map(1:exports.size) do i
            wasm_export_ptr = Base.unsafe_load(exports.data, i)
            wasm_extern_ptr = Base.unsafe_load(externs.data, i)
            WasmExport(wasm_export_ptr, wasm_extern_ptr, wasm_instance)
        end

        new(wasm_instance, exports_vector)
    end
end
exports(instance::WasmInstance) = WasmExports(instance)

function Base.getproperty(wasm_exports::WasmExports, f::Symbol)
    if f ∈ fieldnames(WasmExports)
        return getfield(wasm_exports, f)
    end

    lookup_name = string(f)
    export_index = findfirst(wasm_export -> wasm_export.name == lookup_name, wasm_exports.wasm_exports)
    @assert export_index !== nothing "Export $f not found"

    wasm_exports.wasm_exports[export_index]
end

export WasmInstance, WasmModule, WasmInt32, WasmInt64, WasmFloat32, WasmFloat64,
    WasmEngine, WasmStore, WasmExports, WasmExport, exports, wat2wasm, @wat_str

end
