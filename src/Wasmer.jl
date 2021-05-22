module Wasmer

using CEnum

include("./LibWasmer.jl")
using .LibWasmer

include("./vec_t.jl")

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

LibWasmer.wasm_byte_vec_t(str::AbstractString) =
    wasm_byte_vec_t(length(str), Base.unsafe_convert(Cstring, Base.unsafe_wrap(Vector{UInt8}, str)))

wat2wasm(str::AbstractString) =
    wat2wasm(WasmByteVec(collect(wasm_byte_t, str)))
function wat2wasm(wat::WasmByteVec)
    out = WasmByteVec()
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
function WasmModule(store::WasmStore, wasm_byte_vec::WasmByteVec)
    wasm_module_ptr = wasm_module_new(store.wasm_store_ptr, wasm_byte_vec)
    wasm_module_ptr == C_NULL && error("Failed to create wasm module")

    WasmModule(wasm_module_ptr)
end

julia_type_to_valtype(julia_type)::Ptr{wasm_valtype_t} =
    julia_type_to_valkind(julia_type) |> wasm_valtype_new

function WasmFunc(store::WasmStore, func::Function, return_type, input_types)
    params_vec = WasmPtrVec(collect(Ptr{wasm_valtype_t}, map(julia_type_to_valtype, input_types)))
    results_vec = WasmPtrVec([julia_type_to_valtype(return_type)])

    func_type = wasm_functype_new(params_vec, results_vec)
    @assert func_type != C_NULL "Failed to create functype"

    function jl_side_host(args::Ptr{wasm_val_vec_t}, results::Ptr{wasm_val_vec_t})::Ptr{wasm_trap_t}
        # TODO: support passing the arguments
        res = func()
        wasm_res = Ref(convert(wasm_val_t, res))
        data_ptr = unsafe_load(results).data
        wasm_val_copy(data_ptr, Base.pointer_from_objref(wasm_res))

        C_NULL
    end

    # Create a pointer to jl_side_host(args, results)
    func_ptr = Base.@cfunction($jl_side_host, Ptr{wasm_trap_t}, (Ptr{wasm_val_vec_t}, Ptr{wasm_val_vec_t}))

    host_func = wasm_func_new(store.wasm_store_ptr, func_type, func_ptr)
    wasm_functype_delete(func_type)

    host_func
end

function name_vec_ptr_to_str(name_vec_ptr::Ptr{wasm_name_t})
    @assert name_vec_ptr != C_NULL "Failed to convert wasm_name" 
    name_vec = Base.unsafe_load(name_vec_ptr)
    name = unsafe_string(name_vec.data, name_vec.size)
    wasm_name_delete(name_vec_ptr)

    name
end

struct WasmImport
    wasm_importtype_ptr::Ptr{wasm_importtype_t}
    extern_kind::wasm_externkind_enum
    import_module::String
    name::String

    function WasmImport(wasm_importtype_ptr::Ptr{wasm_importtype_t})
        name_vec_ptr = wasm_importtype_name(wasm_importtype_ptr)
        name = name_vec_ptr_to_str(name_vec_ptr)

        import_module_ptr = wasm_importtype_module(wasm_importtype_ptr)
        import_module = name_vec_ptr_to_str(import_module_ptr)

        externtype_ptr = wasm_importtype_type(wasm_importtype_ptr)
        extern_kind = wasm_externkind_enum(wasm_externtype_kind(externtype_ptr))

        new(wasm_importtype_ptr, extern_kind, import_module, name)
    end
end

struct WasmImports
    wasm_module::WasmModule
    wasm_imports::Vector{WasmImport}

    function WasmImports(wasm_module::WasmModule)
        wasm_imports_vec = WasmPtrVec(wasm_importtype_t)
        wasm_module_imports(wasm_module.wasm_module_ptr, wasm_imports_vec)
        wasm_imports = map(WasmImport, wasm_imports_vec)

        new(wasm_module, wasm_imports)
    end
end
imports(wasm_module::WasmModule) = WasmImports(wasm_module)

map_to_extern(extern_func::Ptr{wasm_func_t}) = wasm_func_as_extern(extern_func)
map_to_extern(other) = error("Type $(typeof(other)) is not supported")

mutable struct WasmInstance
    wasm_instance_ptr::Ptr{wasm_instance_t}
    wasm_module::WasmModule
    
    WasmInstance(wasm_instance_ptr::Ptr{wasm_instance_t}, wasm_module::WasmModule) = finalizer(new(wasm_instance_ptr, wasm_module)) do wasm_instance
        wasm_instance_delete(wasm_instance.wasm_instance_ptr)
    end
end
function WasmInstance(store::WasmStore, wasm_module::WasmModule)
    module_imports = imports(wasm_module)
    n_expected_imports = length(module_imports.wasm_imports)
    @assert n_expected_imports == 0 "No imports provided, expected $n_expected_imports"

    empty_imports = WasmVecPtr(wasm_importtype_t)
    wasm_instance_ptr = wasm_instance_new(store.wasm_store_ptr, wasm_module.wasm_module_ptr, empty_imports, C_NULL)
    @assert wasm_instance_ptr != C_NULL "Failed to create WASM instance"
    WasmInstance(wasm_instance_ptr, wasm_module)
end
function WasmInstance(store::WasmStore, wasm_module::WasmModule, host_imports::Vector{T}) where T
    module_imports = imports(wasm_module)
    n_expected_imports = length(module_imports.wasm_imports)
    n_provided_imports = length(host_imports)
    @assert n_expected_imports == length(host_imports) "$n_provided_imports imports provided, expected $n_expected_imports"
    externs_vec = WasmPtrVec(map(map_to_extern, host_imports))

    wasm_instance_ptr = wasm_instance_new(store.wasm_store_ptr, wasm_module.wasm_module_ptr, externs_vec, C_NULL)
    @assert wasm_instance_ptr != C_NULL "Failed to create WASM instance"
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

function julia_type_to_valkind(julia_type::Type)::wasm_valkind_enum
    if julia_type == Int32
        WASM_I32
    elseif julia_type == Int64
        WASM_I64
    elseif julia_type == Float32
        WASM_F32
    elseif julia_type == Float64
        WASM_F64
    else
        error("No corresponding valkind for type $julia_type")
    end
end

function valkind_to_julia_type(valkind::wasm_valkind_enum)
    if valkind == WASM_I32
        Int32
    elseif valkind == WASM_I64
        Int64
    elseif valkind == WASM_F32
        Float32
    elseif valkind == WASM_F64
        Float64
    else
        error("No corresponding type for kind $valkind")
    end
end

Base.convert(::Type{wasm_val_t}, i::Int32) = WasmInt32(i)
Base.convert(::Type{wasm_val_t}, i::Int64) = WasmInt64(i)
Base.convert(::Type{wasm_val_t}, f::Float32) = WasmFloat32(f)
Base.convert(::Type{wasm_val_t}, f::Float64) = WasmFloat64(f)

Base.convert(::Type{wasm_val_t}, val::wasm_val_t) = val
function Base.convert(julia_type, wasm_val::wasm_val_t)
    valkind = julia_type_to_valkind(julia_type)
    @assert valkind == wasm_val.kind "Cannot convert a value of kind $(wasm_val.kind) to corresponding kind $valkind"
    ctag = Ref(wasm_val.of)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_2}, r)
    jl_val = GC.@preserve ctag unsafe_load(Ptr{julia_type}(ptr))
    jl_val
end

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

    converted_args = collect(wasm_val_t, map(arg -> convert(wasm_val_t, arg), args))
    params_vec = WasmVec(converted_args)

    default_val = wasm_val_t(tuple(zeros(UInt8, 16)...))
    results_vec = WasmVec([default_val for _ in 1:result_arity])

    wasm_func_call(extern_as_func, params_vec, results_vec)

    results = map(1:result_arity) do i
        Base.unsafe_load(results_vec.data, i)
    end

    results
end

mutable struct WasmExports
    wasm_instance::WasmInstance
    wasm_exports::Vector{WasmExport}

    function WasmExports(wasm_instance::WasmInstance)
        exports = WasmPtrVec(wasm_exporttype_t)
        wasm_module_exports(wasm_instance.wasm_module.wasm_module_ptr, exports)
        externs = WasmPtrVec(wasm_extern_t)
        wasm_instance_exports(wasm_instance.wasm_instance_ptr, externs)
        @assert length(exports) == length(externs)

        exports_vector = map(a -> WasmExport(a..., wasm_instance), zip(exports, externs))

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
