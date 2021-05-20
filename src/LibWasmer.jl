module LibWasmer

using CEnum

const wasmer_location = get(ENV, "WASMER_LOCATION", "../wasmer")
const libwasmer = joinpath(wasmer_location, "lib/libwasmer.so")


# no prototype is found for this function at wasm.h:29:13, please use with caution
function assertions()
    ccall((:assertions, libwasmer), Cvoid, ())
end

const byte_t = Cchar

const float32_t = Cfloat

const float64_t = Cdouble

const wasm_byte_t = byte_t

mutable struct wasm_byte_vec_t
    size::Csize_t
    data::Ptr{wasm_byte_t}
end

function wasm_byte_vec_new_empty(out)
    @ccall libwasmer.wasm_byte_vec_new_empty(out::Ptr{wasm_byte_vec_t})::Cvoid
end

function wasm_byte_vec_new_uninitialized(out, arg2)
    @ccall libwasmer.wasm_byte_vec_new_uninitialized(out::Ptr{wasm_byte_vec_t}, arg2::Csize_t)::Cvoid
end

function wasm_byte_vec_new(out, arg2, arg3)
    @ccall libwasmer.wasm_byte_vec_new(out::Ptr{wasm_byte_vec_t}, arg2::Csize_t, arg3::Ptr{wasm_byte_t})::Cvoid
end

function wasm_byte_vec_copy(out, arg2)
    @ccall libwasmer.wasm_byte_vec_copy(out::Ptr{wasm_byte_vec_t}, arg2::Ptr{wasm_byte_vec_t})::Cvoid
end

function wasm_byte_vec_delete(arg1)
    @ccall libwasmer.wasm_byte_vec_delete(arg1::Ptr{wasm_byte_vec_t})::Cvoid
end

const wasm_name_t = wasm_byte_vec_t

function wasm_name_new_from_string(out, s)
    @ccall libwasmer.wasm_name_new_from_string(out::Ptr{wasm_name_t}, s::Cstring)::Cvoid
end

function wasm_name_new_from_string_nt(out, s)
    @ccall libwasmer.wasm_name_new_from_string_nt(out::Ptr{wasm_name_t}, s::Cstring)::Cvoid
end

mutable struct wasm_config_t end

function wasm_config_delete(arg1)
    @ccall libwasmer.wasm_config_delete(arg1::Ptr{wasm_config_t})::Cvoid
end

# no prototype is found for this function at wasm.h:127:36, please use with caution
function wasm_config_new()
    ccall((:wasm_config_new, libwasmer), Ptr{wasm_config_t}, ())
end

mutable struct wasm_engine_t end

function wasm_engine_delete(arg1)
    @ccall libwasmer.wasm_engine_delete(arg1::Ptr{wasm_engine_t})::Cvoid
end

# no prototype is found for this function at wasm.h:136:36, please use with caution
function wasm_engine_new()
    ccall((:wasm_engine_new, libwasmer), Ptr{wasm_engine_t}, ())
end

function wasm_engine_new_with_config(arg1)
    @ccall libwasmer.wasm_engine_new_with_config(arg1::Ptr{wasm_config_t})::Ptr{wasm_engine_t}
end

mutable struct wasm_store_t end

function wasm_store_delete(arg1)
    @ccall libwasmer.wasm_store_delete(arg1::Ptr{wasm_store_t})::Cvoid
end

function wasm_store_new(arg1)
    @ccall libwasmer.wasm_store_new(arg1::Ptr{wasm_engine_t})::Ptr{wasm_store_t}
end

const wasm_mutability_t = UInt8

@cenum wasm_mutability_enum::UInt32 begin
    WASM_CONST = 0
    WASM_VAR = 1
end

mutable struct wasm_limits_t
    min::UInt32
    max::UInt32
end

mutable struct wasm_valtype_t end

function wasm_valtype_delete(arg1)
    @ccall libwasmer.wasm_valtype_delete(arg1::Ptr{wasm_valtype_t})::Cvoid
end

mutable struct wasm_valtype_vec_t
    size::Csize_t
    data::Ptr{Ptr{wasm_valtype_t}}
end

function wasm_valtype_vec_new_empty(out)
    @ccall libwasmer.wasm_valtype_vec_new_empty(out::Ptr{wasm_valtype_vec_t})::Cvoid
end

function wasm_valtype_vec_new_uninitialized(out, arg2)
    @ccall libwasmer.wasm_valtype_vec_new_uninitialized(out::Ptr{wasm_valtype_vec_t}, arg2::Csize_t)::Cvoid
end

function wasm_valtype_vec_new(out, arg2, arg3)
    @ccall libwasmer.wasm_valtype_vec_new(out::Ptr{wasm_valtype_vec_t}, arg2::Csize_t, arg3::Ptr{Ptr{wasm_valtype_t}})::Cvoid
end

function wasm_valtype_vec_copy(out, arg2)
    @ccall libwasmer.wasm_valtype_vec_copy(out::Ptr{wasm_valtype_vec_t}, arg2::Ptr{wasm_valtype_vec_t})::Cvoid
end

function wasm_valtype_vec_delete(arg1)
    @ccall libwasmer.wasm_valtype_vec_delete(arg1::Ptr{wasm_valtype_vec_t})::Cvoid
end

function wasm_valtype_copy(arg1)
    @ccall libwasmer.wasm_valtype_copy(arg1::Ptr{wasm_valtype_t})::Ptr{wasm_valtype_t}
end

const wasm_valkind_t = UInt8

@cenum wasm_valkind_enum::UInt32 begin
    WASM_I32 = 0
    WASM_I64 = 1
    WASM_F32 = 2
    WASM_F64 = 3
    WASM_ANYREF = 128
    WASM_FUNCREF = 129
end

function wasm_valtype_new(arg1)
    @ccall libwasmer.wasm_valtype_new(arg1::wasm_valkind_t)::Ptr{wasm_valtype_t}
end

function wasm_valtype_kind(arg1)
    @ccall libwasmer.wasm_valtype_kind(arg1::Ptr{wasm_valtype_t})::wasm_valkind_t
end

function wasm_valkind_is_num(k)
    @ccall libwasmer.wasm_valkind_is_num(k::wasm_valkind_t)::Bool
end

function wasm_valkind_is_ref(k)
    @ccall libwasmer.wasm_valkind_is_ref(k::wasm_valkind_t)::Bool
end

function wasm_valtype_is_num(t)
    @ccall libwasmer.wasm_valtype_is_num(t::Ptr{wasm_valtype_t})::Bool
end

function wasm_valtype_is_ref(t)
    @ccall libwasmer.wasm_valtype_is_ref(t::Ptr{wasm_valtype_t})::Bool
end

mutable struct wasm_functype_t end

function wasm_functype_delete(arg1)
    @ccall libwasmer.wasm_functype_delete(arg1::Ptr{wasm_functype_t})::Cvoid
end

mutable struct wasm_functype_vec_t
    size::Csize_t
    data::Ptr{Ptr{wasm_functype_t}}
end

function wasm_functype_vec_new_empty(out)
    @ccall libwasmer.wasm_functype_vec_new_empty(out::Ptr{wasm_functype_vec_t})::Cvoid
end

function wasm_functype_vec_new_uninitialized(out, arg2)
    @ccall libwasmer.wasm_functype_vec_new_uninitialized(out::Ptr{wasm_functype_vec_t}, arg2::Csize_t)::Cvoid
end

function wasm_functype_vec_new(out, arg2, arg3)
    @ccall libwasmer.wasm_functype_vec_new(out::Ptr{wasm_functype_vec_t}, arg2::Csize_t, arg3::Ptr{Ptr{wasm_functype_t}})::Cvoid
end

function wasm_functype_vec_copy(out, arg2)
    @ccall libwasmer.wasm_functype_vec_copy(out::Ptr{wasm_functype_vec_t}, arg2::Ptr{wasm_functype_vec_t})::Cvoid
end

function wasm_functype_vec_delete(arg1)
    @ccall libwasmer.wasm_functype_vec_delete(arg1::Ptr{wasm_functype_vec_t})::Cvoid
end

function wasm_functype_copy(arg1)
    @ccall libwasmer.wasm_functype_copy(arg1::Ptr{wasm_functype_t})::Ptr{wasm_functype_t}
end

function wasm_functype_new(params, results)
    @ccall libwasmer.wasm_functype_new(params::Ptr{wasm_valtype_vec_t}, results::Ptr{wasm_valtype_vec_t})::Ptr{wasm_functype_t}
end

function wasm_functype_params(arg1)
    @ccall libwasmer.wasm_functype_params(arg1::Ptr{wasm_functype_t})::Ptr{wasm_valtype_vec_t}
end

function wasm_functype_results(arg1)
    @ccall libwasmer.wasm_functype_results(arg1::Ptr{wasm_functype_t})::Ptr{wasm_valtype_vec_t}
end

mutable struct wasm_globaltype_t end

function wasm_globaltype_delete(arg1)
    @ccall libwasmer.wasm_globaltype_delete(arg1::Ptr{wasm_globaltype_t})::Cvoid
end

mutable struct wasm_globaltype_vec_t
    size::Csize_t
    data::Ptr{Ptr{wasm_globaltype_t}}
end

function wasm_globaltype_vec_new_empty(out)
    @ccall libwasmer.wasm_globaltype_vec_new_empty(out::Ptr{wasm_globaltype_vec_t})::Cvoid
end

function wasm_globaltype_vec_new_uninitialized(out, arg2)
    @ccall libwasmer.wasm_globaltype_vec_new_uninitialized(out::Ptr{wasm_globaltype_vec_t}, arg2::Csize_t)::Cvoid
end

function wasm_globaltype_vec_new(out, arg2, arg3)
    @ccall libwasmer.wasm_globaltype_vec_new(out::Ptr{wasm_globaltype_vec_t}, arg2::Csize_t, arg3::Ptr{Ptr{wasm_globaltype_t}})::Cvoid
end

function wasm_globaltype_vec_copy(out, arg2)
    @ccall libwasmer.wasm_globaltype_vec_copy(out::Ptr{wasm_globaltype_vec_t}, arg2::Ptr{wasm_globaltype_vec_t})::Cvoid
end

function wasm_globaltype_vec_delete(arg1)
    @ccall libwasmer.wasm_globaltype_vec_delete(arg1::Ptr{wasm_globaltype_vec_t})::Cvoid
end

function wasm_globaltype_copy(arg1)
    @ccall libwasmer.wasm_globaltype_copy(arg1::Ptr{wasm_globaltype_t})::Ptr{wasm_globaltype_t}
end

function wasm_globaltype_new(arg1, arg2)
    @ccall libwasmer.wasm_globaltype_new(arg1::Ptr{wasm_valtype_t}, arg2::wasm_mutability_t)::Ptr{wasm_globaltype_t}
end

function wasm_globaltype_content(arg1)
    @ccall libwasmer.wasm_globaltype_content(arg1::Ptr{wasm_globaltype_t})::Ptr{wasm_valtype_t}
end

function wasm_globaltype_mutability(arg1)
    @ccall libwasmer.wasm_globaltype_mutability(arg1::Ptr{wasm_globaltype_t})::wasm_mutability_t
end

mutable struct wasm_tabletype_t end

function wasm_tabletype_delete(arg1)
    @ccall libwasmer.wasm_tabletype_delete(arg1::Ptr{wasm_tabletype_t})::Cvoid
end

mutable struct wasm_tabletype_vec_t
    size::Csize_t
    data::Ptr{Ptr{wasm_tabletype_t}}
end

function wasm_tabletype_vec_new_empty(out)
    @ccall libwasmer.wasm_tabletype_vec_new_empty(out::Ptr{wasm_tabletype_vec_t})::Cvoid
end

function wasm_tabletype_vec_new_uninitialized(out, arg2)
    @ccall libwasmer.wasm_tabletype_vec_new_uninitialized(out::Ptr{wasm_tabletype_vec_t}, arg2::Csize_t)::Cvoid
end

function wasm_tabletype_vec_new(out, arg2, arg3)
    @ccall libwasmer.wasm_tabletype_vec_new(out::Ptr{wasm_tabletype_vec_t}, arg2::Csize_t, arg3::Ptr{Ptr{wasm_tabletype_t}})::Cvoid
end

function wasm_tabletype_vec_copy(out, arg2)
    @ccall libwasmer.wasm_tabletype_vec_copy(out::Ptr{wasm_tabletype_vec_t}, arg2::Ptr{wasm_tabletype_vec_t})::Cvoid
end

function wasm_tabletype_vec_delete(arg1)
    @ccall libwasmer.wasm_tabletype_vec_delete(arg1::Ptr{wasm_tabletype_vec_t})::Cvoid
end

function wasm_tabletype_copy(arg1)
    @ccall libwasmer.wasm_tabletype_copy(arg1::Ptr{wasm_tabletype_t})::Ptr{wasm_tabletype_t}
end

function wasm_tabletype_new(arg1, arg2)
    @ccall libwasmer.wasm_tabletype_new(arg1::Ptr{wasm_valtype_t}, arg2::Ptr{wasm_limits_t})::Ptr{wasm_tabletype_t}
end

function wasm_tabletype_element(arg1)
    @ccall libwasmer.wasm_tabletype_element(arg1::Ptr{wasm_tabletype_t})::Ptr{wasm_valtype_t}
end

function wasm_tabletype_limits(arg1)
    @ccall libwasmer.wasm_tabletype_limits(arg1::Ptr{wasm_tabletype_t})::Ptr{wasm_limits_t}
end

mutable struct wasm_memorytype_t end

function wasm_memorytype_delete(arg1)
    @ccall libwasmer.wasm_memorytype_delete(arg1::Ptr{wasm_memorytype_t})::Cvoid
end

mutable struct wasm_memorytype_vec_t
    size::Csize_t
    data::Ptr{Ptr{wasm_memorytype_t}}
end

function wasm_memorytype_vec_new_empty(out)
    @ccall libwasmer.wasm_memorytype_vec_new_empty(out::Ptr{wasm_memorytype_vec_t})::Cvoid
end

function wasm_memorytype_vec_new_uninitialized(out, arg2)
    @ccall libwasmer.wasm_memorytype_vec_new_uninitialized(out::Ptr{wasm_memorytype_vec_t}, arg2::Csize_t)::Cvoid
end

function wasm_memorytype_vec_new(out, arg2, arg3)
    @ccall libwasmer.wasm_memorytype_vec_new(out::Ptr{wasm_memorytype_vec_t}, arg2::Csize_t, arg3::Ptr{Ptr{wasm_memorytype_t}})::Cvoid
end

function wasm_memorytype_vec_copy(out, arg2)
    @ccall libwasmer.wasm_memorytype_vec_copy(out::Ptr{wasm_memorytype_vec_t}, arg2::Ptr{wasm_memorytype_vec_t})::Cvoid
end

function wasm_memorytype_vec_delete(arg1)
    @ccall libwasmer.wasm_memorytype_vec_delete(arg1::Ptr{wasm_memorytype_vec_t})::Cvoid
end

function wasm_memorytype_copy(arg1)
    @ccall libwasmer.wasm_memorytype_copy(arg1::Ptr{wasm_memorytype_t})::Ptr{wasm_memorytype_t}
end

function wasm_memorytype_new(arg1)
    @ccall libwasmer.wasm_memorytype_new(arg1::Ptr{wasm_limits_t})::Ptr{wasm_memorytype_t}
end

function wasm_memorytype_limits(arg1)
    @ccall libwasmer.wasm_memorytype_limits(arg1::Ptr{wasm_memorytype_t})::Ptr{wasm_limits_t}
end

mutable struct wasm_externtype_t end

function wasm_externtype_delete(arg1)
    @ccall libwasmer.wasm_externtype_delete(arg1::Ptr{wasm_externtype_t})::Cvoid
end

mutable struct wasm_externtype_vec_t
    size::Csize_t
    data::Ptr{Ptr{wasm_externtype_t}}
end

function wasm_externtype_vec_new_empty(out)
    @ccall libwasmer.wasm_externtype_vec_new_empty(out::Ptr{wasm_externtype_vec_t})::Cvoid
end

function wasm_externtype_vec_new_uninitialized(out, arg2)
    @ccall libwasmer.wasm_externtype_vec_new_uninitialized(out::Ptr{wasm_externtype_vec_t}, arg2::Csize_t)::Cvoid
end

function wasm_externtype_vec_new(out, arg2, arg3)
    @ccall libwasmer.wasm_externtype_vec_new(out::Ptr{wasm_externtype_vec_t}, arg2::Csize_t, arg3::Ptr{Ptr{wasm_externtype_t}})::Cvoid
end

function wasm_externtype_vec_copy(out, arg2)
    @ccall libwasmer.wasm_externtype_vec_copy(out::Ptr{wasm_externtype_vec_t}, arg2::Ptr{wasm_externtype_vec_t})::Cvoid
end

function wasm_externtype_vec_delete(arg1)
    @ccall libwasmer.wasm_externtype_vec_delete(arg1::Ptr{wasm_externtype_vec_t})::Cvoid
end

function wasm_externtype_copy(arg1)
    @ccall libwasmer.wasm_externtype_copy(arg1::Ptr{wasm_externtype_t})::Ptr{wasm_externtype_t}
end

const wasm_externkind_t = UInt8

@cenum wasm_externkind_enum::UInt32 begin
    WASM_EXTERN_FUNC = 0
    WASM_EXTERN_GLOBAL = 1
    WASM_EXTERN_TABLE = 2
    WASM_EXTERN_MEMORY = 3
end

function wasm_externtype_kind(arg1)
    @ccall libwasmer.wasm_externtype_kind(arg1::Ptr{wasm_externtype_t})::wasm_externkind_t
end

function wasm_functype_as_externtype(arg1)
    @ccall libwasmer.wasm_functype_as_externtype(arg1::Ptr{wasm_functype_t})::Ptr{wasm_externtype_t}
end

function wasm_globaltype_as_externtype(arg1)
    @ccall libwasmer.wasm_globaltype_as_externtype(arg1::Ptr{wasm_globaltype_t})::Ptr{wasm_externtype_t}
end

function wasm_tabletype_as_externtype(arg1)
    @ccall libwasmer.wasm_tabletype_as_externtype(arg1::Ptr{wasm_tabletype_t})::Ptr{wasm_externtype_t}
end

function wasm_memorytype_as_externtype(arg1)
    @ccall libwasmer.wasm_memorytype_as_externtype(arg1::Ptr{wasm_memorytype_t})::Ptr{wasm_externtype_t}
end

function wasm_externtype_as_functype(arg1)
    @ccall libwasmer.wasm_externtype_as_functype(arg1::Ptr{wasm_externtype_t})::Ptr{wasm_functype_t}
end

function wasm_externtype_as_globaltype(arg1)
    @ccall libwasmer.wasm_externtype_as_globaltype(arg1::Ptr{wasm_externtype_t})::Ptr{wasm_globaltype_t}
end

function wasm_externtype_as_tabletype(arg1)
    @ccall libwasmer.wasm_externtype_as_tabletype(arg1::Ptr{wasm_externtype_t})::Ptr{wasm_tabletype_t}
end

function wasm_externtype_as_memorytype(arg1)
    @ccall libwasmer.wasm_externtype_as_memorytype(arg1::Ptr{wasm_externtype_t})::Ptr{wasm_memorytype_t}
end

function wasm_functype_as_externtype_const(arg1)
    @ccall libwasmer.wasm_functype_as_externtype_const(arg1::Ptr{wasm_functype_t})::Ptr{wasm_externtype_t}
end

function wasm_globaltype_as_externtype_const(arg1)
    @ccall libwasmer.wasm_globaltype_as_externtype_const(arg1::Ptr{wasm_globaltype_t})::Ptr{wasm_externtype_t}
end

function wasm_tabletype_as_externtype_const(arg1)
    @ccall libwasmer.wasm_tabletype_as_externtype_const(arg1::Ptr{wasm_tabletype_t})::Ptr{wasm_externtype_t}
end

function wasm_memorytype_as_externtype_const(arg1)
    @ccall libwasmer.wasm_memorytype_as_externtype_const(arg1::Ptr{wasm_memorytype_t})::Ptr{wasm_externtype_t}
end

function wasm_externtype_as_functype_const(arg1)
    @ccall libwasmer.wasm_externtype_as_functype_const(arg1::Ptr{wasm_externtype_t})::Ptr{wasm_functype_t}
end

function wasm_externtype_as_globaltype_const(arg1)
    @ccall libwasmer.wasm_externtype_as_globaltype_const(arg1::Ptr{wasm_externtype_t})::Ptr{wasm_globaltype_t}
end

function wasm_externtype_as_tabletype_const(arg1)
    @ccall libwasmer.wasm_externtype_as_tabletype_const(arg1::Ptr{wasm_externtype_t})::Ptr{wasm_tabletype_t}
end

function wasm_externtype_as_memorytype_const(arg1)
    @ccall libwasmer.wasm_externtype_as_memorytype_const(arg1::Ptr{wasm_externtype_t})::Ptr{wasm_memorytype_t}
end

mutable struct wasm_importtype_t end

function wasm_importtype_delete(arg1)
    @ccall libwasmer.wasm_importtype_delete(arg1::Ptr{wasm_importtype_t})::Cvoid
end

mutable struct wasm_importtype_vec_t
    size::Csize_t
    data::Ptr{Ptr{wasm_importtype_t}}
end

function wasm_importtype_vec_new_empty(out)
    @ccall libwasmer.wasm_importtype_vec_new_empty(out::Ptr{wasm_importtype_vec_t})::Cvoid
end

function wasm_importtype_vec_new_uninitialized(out, arg2)
    @ccall libwasmer.wasm_importtype_vec_new_uninitialized(out::Ptr{wasm_importtype_vec_t}, arg2::Csize_t)::Cvoid
end

function wasm_importtype_vec_new(out, arg2, arg3)
    @ccall libwasmer.wasm_importtype_vec_new(out::Ptr{wasm_importtype_vec_t}, arg2::Csize_t, arg3::Ptr{Ptr{wasm_importtype_t}})::Cvoid
end

function wasm_importtype_vec_copy(out, arg2)
    @ccall libwasmer.wasm_importtype_vec_copy(out::Ptr{wasm_importtype_vec_t}, arg2::Ptr{wasm_importtype_vec_t})::Cvoid
end

function wasm_importtype_vec_delete(arg1)
    @ccall libwasmer.wasm_importtype_vec_delete(arg1::Ptr{wasm_importtype_vec_t})::Cvoid
end

function wasm_importtype_copy(arg1)
    @ccall libwasmer.wasm_importtype_copy(arg1::Ptr{wasm_importtype_t})::Ptr{wasm_importtype_t}
end

function wasm_importtype_new(_module, name, arg3)
    @ccall libwasmer.wasm_importtype_new(_module::Ptr{wasm_name_t}, name::Ptr{wasm_name_t}, arg3::Ptr{wasm_externtype_t})::Ptr{wasm_importtype_t}
end

function wasm_importtype_module(arg1)
    @ccall libwasmer.wasm_importtype_module(arg1::Ptr{wasm_importtype_t})::Ptr{wasm_name_t}
end

function wasm_importtype_name(arg1)
    @ccall libwasmer.wasm_importtype_name(arg1::Ptr{wasm_importtype_t})::Ptr{wasm_name_t}
end

function wasm_importtype_type(arg1)
    @ccall libwasmer.wasm_importtype_type(arg1::Ptr{wasm_importtype_t})::Ptr{wasm_externtype_t}
end

mutable struct wasm_exporttype_t end

function wasm_exporttype_delete(arg1)
    @ccall libwasmer.wasm_exporttype_delete(arg1::Ptr{wasm_exporttype_t})::Cvoid
end

mutable struct wasm_exporttype_vec_t
    size::Csize_t
    data::Ptr{Ptr{wasm_exporttype_t}}
end

function wasm_exporttype_vec_new_empty(out)
    @ccall libwasmer.wasm_exporttype_vec_new_empty(out::Ptr{wasm_exporttype_vec_t})::Cvoid
end

function wasm_exporttype_vec_new_uninitialized(out, arg2)
    @ccall libwasmer.wasm_exporttype_vec_new_uninitialized(out::Ptr{wasm_exporttype_vec_t}, arg2::Csize_t)::Cvoid
end

function wasm_exporttype_vec_new(out, arg2, arg3)
    @ccall libwasmer.wasm_exporttype_vec_new(out::Ptr{wasm_exporttype_vec_t}, arg2::Csize_t, arg3::Ptr{Ptr{wasm_exporttype_t}})::Cvoid
end

function wasm_exporttype_vec_copy(out, arg2)
    @ccall libwasmer.wasm_exporttype_vec_copy(out::Ptr{wasm_exporttype_vec_t}, arg2::Ptr{wasm_exporttype_vec_t})::Cvoid
end

function wasm_exporttype_vec_delete(arg1)
    @ccall libwasmer.wasm_exporttype_vec_delete(arg1::Ptr{wasm_exporttype_vec_t})::Cvoid
end

function wasm_exporttype_copy(arg1)
    @ccall libwasmer.wasm_exporttype_copy(arg1::Ptr{wasm_exporttype_t})::Ptr{wasm_exporttype_t}
end

function wasm_exporttype_new(arg1, arg2)
    @ccall libwasmer.wasm_exporttype_new(arg1::Ptr{wasm_name_t}, arg2::Ptr{wasm_externtype_t})::Ptr{wasm_exporttype_t}
end

function wasm_exporttype_name(arg1)
    @ccall libwasmer.wasm_exporttype_name(arg1::Ptr{wasm_exporttype_t})::Ptr{wasm_name_t}
end

function wasm_exporttype_type(arg1)
    @ccall libwasmer.wasm_exporttype_type(arg1::Ptr{wasm_exporttype_t})::Ptr{wasm_externtype_t}
end

struct wasm_val_t
    data::NTuple{16, UInt8}
end

function Base.getproperty(x::Ptr{wasm_val_t}, f::Symbol)
    f === :kind && return Ptr{wasm_valkind_t}(x + 0)
    f === :of && return Ptr{__JL_Ctag_2}(x + 8)
    return getfield(x, f)
end

function Base.getproperty(x::wasm_val_t, f::Symbol)
    r = Ref{wasm_val_t}(x)
    ptr = Base.unsafe_convert(Ptr{wasm_val_t}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{wasm_val_t}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

function wasm_val_delete(v)
    @ccall libwasmer.wasm_val_delete(v::Ptr{wasm_val_t})::Cvoid
end

function wasm_val_copy(out, arg2)
    @ccall libwasmer.wasm_val_copy(out::Ptr{wasm_val_t}, arg2::Ptr{wasm_val_t})::Cvoid
end

mutable struct wasm_val_vec_t
    size::Csize_t
    data::Ptr{wasm_val_t}
end

function wasm_val_vec_new_empty(out)
    @ccall libwasmer.wasm_val_vec_new_empty(out::Ptr{wasm_val_vec_t})::Cvoid
end

function wasm_val_vec_new_uninitialized(out, arg2)
    @ccall libwasmer.wasm_val_vec_new_uninitialized(out::Ptr{wasm_val_vec_t}, arg2::Csize_t)::Cvoid
end

function wasm_val_vec_new(out, arg2, arg3)
    @ccall libwasmer.wasm_val_vec_new(out::Ptr{wasm_val_vec_t}, arg2::Csize_t, arg3::Ptr{wasm_val_t})::Cvoid
end

function wasm_val_vec_copy(out, arg2)
    @ccall libwasmer.wasm_val_vec_copy(out::Ptr{wasm_val_vec_t}, arg2::Ptr{wasm_val_vec_t})::Cvoid
end

function wasm_val_vec_delete(arg1)
    @ccall libwasmer.wasm_val_vec_delete(arg1::Ptr{wasm_val_vec_t})::Cvoid
end

mutable struct wasm_ref_t end

function wasm_ref_delete(arg1)
    @ccall libwasmer.wasm_ref_delete(arg1::Ptr{wasm_ref_t})::Cvoid
end

function wasm_ref_copy(arg1)
    @ccall libwasmer.wasm_ref_copy(arg1::Ptr{wasm_ref_t})::Ptr{wasm_ref_t}
end

function wasm_ref_same(arg1, arg2)
    @ccall libwasmer.wasm_ref_same(arg1::Ptr{wasm_ref_t}, arg2::Ptr{wasm_ref_t})::Bool
end

function wasm_ref_get_host_info(arg1)
    @ccall libwasmer.wasm_ref_get_host_info(arg1::Ptr{wasm_ref_t})::Ptr{Cvoid}
end

function wasm_ref_set_host_info(arg1, arg2)
    @ccall libwasmer.wasm_ref_set_host_info(arg1::Ptr{wasm_ref_t}, arg2::Ptr{Cvoid})::Cvoid
end

function wasm_ref_set_host_info_with_finalizer(arg1, arg2, arg3)
    @ccall libwasmer.wasm_ref_set_host_info_with_finalizer(arg1::Ptr{wasm_ref_t}, arg2::Ptr{Cvoid}, arg3::Ptr{Cvoid})::Cvoid
end

mutable struct wasm_frame_t end

function wasm_frame_delete(arg1)
    @ccall libwasmer.wasm_frame_delete(arg1::Ptr{wasm_frame_t})::Cvoid
end

mutable struct wasm_frame_vec_t
    size::Csize_t
    data::Ptr{Ptr{wasm_frame_t}}
end

function wasm_frame_vec_new_empty(out)
    @ccall libwasmer.wasm_frame_vec_new_empty(out::Ptr{wasm_frame_vec_t})::Cvoid
end

function wasm_frame_vec_new_uninitialized(out, arg2)
    @ccall libwasmer.wasm_frame_vec_new_uninitialized(out::Ptr{wasm_frame_vec_t}, arg2::Csize_t)::Cvoid
end

function wasm_frame_vec_new(out, arg2, arg3)
    @ccall libwasmer.wasm_frame_vec_new(out::Ptr{wasm_frame_vec_t}, arg2::Csize_t, arg3::Ptr{Ptr{wasm_frame_t}})::Cvoid
end

function wasm_frame_vec_copy(out, arg2)
    @ccall libwasmer.wasm_frame_vec_copy(out::Ptr{wasm_frame_vec_t}, arg2::Ptr{wasm_frame_vec_t})::Cvoid
end

function wasm_frame_vec_delete(arg1)
    @ccall libwasmer.wasm_frame_vec_delete(arg1::Ptr{wasm_frame_vec_t})::Cvoid
end

function wasm_frame_copy(arg1)
    @ccall libwasmer.wasm_frame_copy(arg1::Ptr{wasm_frame_t})::Ptr{wasm_frame_t}
end

mutable struct wasm_instance_t end

function wasm_frame_instance(arg1)
    @ccall libwasmer.wasm_frame_instance(arg1::Ptr{wasm_frame_t})::Ptr{wasm_instance_t}
end

function wasm_frame_func_index(arg1)
    @ccall libwasmer.wasm_frame_func_index(arg1::Ptr{wasm_frame_t})::UInt32
end

function wasm_frame_func_offset(arg1)
    @ccall libwasmer.wasm_frame_func_offset(arg1::Ptr{wasm_frame_t})::Csize_t
end

function wasm_frame_module_offset(arg1)
    @ccall libwasmer.wasm_frame_module_offset(arg1::Ptr{wasm_frame_t})::Csize_t
end

const wasm_message_t = wasm_name_t

mutable struct wasm_trap_t end

function wasm_trap_delete(arg1)
    @ccall libwasmer.wasm_trap_delete(arg1::Ptr{wasm_trap_t})::Cvoid
end

function wasm_trap_copy(arg1)
    @ccall libwasmer.wasm_trap_copy(arg1::Ptr{wasm_trap_t})::Ptr{wasm_trap_t}
end

function wasm_trap_same(arg1, arg2)
    @ccall libwasmer.wasm_trap_same(arg1::Ptr{wasm_trap_t}, arg2::Ptr{wasm_trap_t})::Bool
end

function wasm_trap_get_host_info(arg1)
    @ccall libwasmer.wasm_trap_get_host_info(arg1::Ptr{wasm_trap_t})::Ptr{Cvoid}
end

function wasm_trap_set_host_info(arg1, arg2)
    @ccall libwasmer.wasm_trap_set_host_info(arg1::Ptr{wasm_trap_t}, arg2::Ptr{Cvoid})::Cvoid
end

function wasm_trap_set_host_info_with_finalizer(arg1, arg2, arg3)
    @ccall libwasmer.wasm_trap_set_host_info_with_finalizer(arg1::Ptr{wasm_trap_t}, arg2::Ptr{Cvoid}, arg3::Ptr{Cvoid})::Cvoid
end

function wasm_trap_as_ref(arg1)
    @ccall libwasmer.wasm_trap_as_ref(arg1::Ptr{wasm_trap_t})::Ptr{wasm_ref_t}
end

function wasm_ref_as_trap(arg1)
    @ccall libwasmer.wasm_ref_as_trap(arg1::Ptr{wasm_ref_t})::Ptr{wasm_trap_t}
end

function wasm_trap_as_ref_const(arg1)
    @ccall libwasmer.wasm_trap_as_ref_const(arg1::Ptr{wasm_trap_t})::Ptr{wasm_ref_t}
end

function wasm_ref_as_trap_const(arg1)
    @ccall libwasmer.wasm_ref_as_trap_const(arg1::Ptr{wasm_ref_t})::Ptr{wasm_trap_t}
end

function wasm_trap_new(store, arg2)
    @ccall libwasmer.wasm_trap_new(store::Ptr{wasm_store_t}, arg2::Ptr{wasm_message_t})::Ptr{wasm_trap_t}
end

function wasm_trap_message(arg1, out)
    @ccall libwasmer.wasm_trap_message(arg1::Ptr{wasm_trap_t}, out::Ptr{wasm_message_t})::Cvoid
end

function wasm_trap_origin(arg1)
    @ccall libwasmer.wasm_trap_origin(arg1::Ptr{wasm_trap_t})::Ptr{wasm_frame_t}
end

function wasm_trap_trace(arg1, out)
    @ccall libwasmer.wasm_trap_trace(arg1::Ptr{wasm_trap_t}, out::Ptr{wasm_frame_vec_t})::Cvoid
end

mutable struct wasm_foreign_t end

function wasm_foreign_delete(arg1)
    @ccall libwasmer.wasm_foreign_delete(arg1::Ptr{wasm_foreign_t})::Cvoid
end

function wasm_foreign_copy(arg1)
    @ccall libwasmer.wasm_foreign_copy(arg1::Ptr{wasm_foreign_t})::Ptr{wasm_foreign_t}
end

function wasm_foreign_same(arg1, arg2)
    @ccall libwasmer.wasm_foreign_same(arg1::Ptr{wasm_foreign_t}, arg2::Ptr{wasm_foreign_t})::Bool
end

function wasm_foreign_get_host_info(arg1)
    @ccall libwasmer.wasm_foreign_get_host_info(arg1::Ptr{wasm_foreign_t})::Ptr{Cvoid}
end

function wasm_foreign_set_host_info(arg1, arg2)
    @ccall libwasmer.wasm_foreign_set_host_info(arg1::Ptr{wasm_foreign_t}, arg2::Ptr{Cvoid})::Cvoid
end

function wasm_foreign_set_host_info_with_finalizer(arg1, arg2, arg3)
    @ccall libwasmer.wasm_foreign_set_host_info_with_finalizer(arg1::Ptr{wasm_foreign_t}, arg2::Ptr{Cvoid}, arg3::Ptr{Cvoid})::Cvoid
end

function wasm_foreign_as_ref(arg1)
    @ccall libwasmer.wasm_foreign_as_ref(arg1::Ptr{wasm_foreign_t})::Ptr{wasm_ref_t}
end

function wasm_ref_as_foreign(arg1)
    @ccall libwasmer.wasm_ref_as_foreign(arg1::Ptr{wasm_ref_t})::Ptr{wasm_foreign_t}
end

function wasm_foreign_as_ref_const(arg1)
    @ccall libwasmer.wasm_foreign_as_ref_const(arg1::Ptr{wasm_foreign_t})::Ptr{wasm_ref_t}
end

function wasm_ref_as_foreign_const(arg1)
    @ccall libwasmer.wasm_ref_as_foreign_const(arg1::Ptr{wasm_ref_t})::Ptr{wasm_foreign_t}
end

function wasm_foreign_new(arg1)
    @ccall libwasmer.wasm_foreign_new(arg1::Ptr{wasm_store_t})::Ptr{wasm_foreign_t}
end

mutable struct wasm_module_t end

function wasm_module_delete(arg1)
    @ccall libwasmer.wasm_module_delete(arg1::Ptr{wasm_module_t})::Cvoid
end

function wasm_module_copy(arg1)
    @ccall libwasmer.wasm_module_copy(arg1::Ptr{wasm_module_t})::Ptr{wasm_module_t}
end

function wasm_module_same(arg1, arg2)
    @ccall libwasmer.wasm_module_same(arg1::Ptr{wasm_module_t}, arg2::Ptr{wasm_module_t})::Bool
end

function wasm_module_get_host_info(arg1)
    @ccall libwasmer.wasm_module_get_host_info(arg1::Ptr{wasm_module_t})::Ptr{Cvoid}
end

function wasm_module_set_host_info(arg1, arg2)
    @ccall libwasmer.wasm_module_set_host_info(arg1::Ptr{wasm_module_t}, arg2::Ptr{Cvoid})::Cvoid
end

function wasm_module_set_host_info_with_finalizer(arg1, arg2, arg3)
    @ccall libwasmer.wasm_module_set_host_info_with_finalizer(arg1::Ptr{wasm_module_t}, arg2::Ptr{Cvoid}, arg3::Ptr{Cvoid})::Cvoid
end

function wasm_module_as_ref(arg1)
    @ccall libwasmer.wasm_module_as_ref(arg1::Ptr{wasm_module_t})::Ptr{wasm_ref_t}
end

function wasm_ref_as_module(arg1)
    @ccall libwasmer.wasm_ref_as_module(arg1::Ptr{wasm_ref_t})::Ptr{wasm_module_t}
end

function wasm_module_as_ref_const(arg1)
    @ccall libwasmer.wasm_module_as_ref_const(arg1::Ptr{wasm_module_t})::Ptr{wasm_ref_t}
end

function wasm_ref_as_module_const(arg1)
    @ccall libwasmer.wasm_ref_as_module_const(arg1::Ptr{wasm_ref_t})::Ptr{wasm_module_t}
end

mutable struct wasm_shared_module_t end

function wasm_shared_module_delete(arg1)
    @ccall libwasmer.wasm_shared_module_delete(arg1::Ptr{wasm_shared_module_t})::Cvoid
end

function wasm_module_share(arg1)
    @ccall libwasmer.wasm_module_share(arg1::Ptr{wasm_module_t})::Ptr{wasm_shared_module_t}
end

function wasm_module_obtain(arg1, arg2)
    @ccall libwasmer.wasm_module_obtain(arg1::Ptr{wasm_store_t}, arg2::Ptr{wasm_shared_module_t})::Ptr{wasm_module_t}
end

function wasm_module_new(arg1, binary)
    @ccall libwasmer.wasm_module_new(arg1::Ptr{wasm_store_t}, binary::Ptr{wasm_byte_vec_t})::Ptr{wasm_module_t}
end

function wasm_module_validate(arg1, binary)
    @ccall libwasmer.wasm_module_validate(arg1::Ptr{wasm_store_t}, binary::Ptr{wasm_byte_vec_t})::Bool
end

function wasm_module_imports(arg1, out)
    @ccall libwasmer.wasm_module_imports(arg1::Ptr{wasm_module_t}, out::Ptr{wasm_importtype_vec_t})::Cvoid
end

function wasm_module_exports(arg1, out)
    @ccall libwasmer.wasm_module_exports(arg1::Ptr{wasm_module_t}, out::Ptr{wasm_exporttype_vec_t})::Cvoid
end

function wasm_module_serialize(arg1, out)
    @ccall libwasmer.wasm_module_serialize(arg1::Ptr{wasm_module_t}, out::Ptr{wasm_byte_vec_t})::Cvoid
end

function wasm_module_deserialize(arg1, arg2)
    @ccall libwasmer.wasm_module_deserialize(arg1::Ptr{wasm_store_t}, arg2::Ptr{wasm_byte_vec_t})::Ptr{wasm_module_t}
end

mutable struct wasm_func_t end

function wasm_func_delete(arg1)
    @ccall libwasmer.wasm_func_delete(arg1::Ptr{wasm_func_t})::Cvoid
end

function wasm_func_copy(arg1)
    @ccall libwasmer.wasm_func_copy(arg1::Ptr{wasm_func_t})::Ptr{wasm_func_t}
end

function wasm_func_same(arg1, arg2)
    @ccall libwasmer.wasm_func_same(arg1::Ptr{wasm_func_t}, arg2::Ptr{wasm_func_t})::Bool
end

function wasm_func_get_host_info(arg1)
    @ccall libwasmer.wasm_func_get_host_info(arg1::Ptr{wasm_func_t})::Ptr{Cvoid}
end

function wasm_func_set_host_info(arg1, arg2)
    @ccall libwasmer.wasm_func_set_host_info(arg1::Ptr{wasm_func_t}, arg2::Ptr{Cvoid})::Cvoid
end

function wasm_func_set_host_info_with_finalizer(arg1, arg2, arg3)
    @ccall libwasmer.wasm_func_set_host_info_with_finalizer(arg1::Ptr{wasm_func_t}, arg2::Ptr{Cvoid}, arg3::Ptr{Cvoid})::Cvoid
end

function wasm_func_as_ref(arg1)
    @ccall libwasmer.wasm_func_as_ref(arg1::Ptr{wasm_func_t})::Ptr{wasm_ref_t}
end

function wasm_ref_as_func(arg1)
    @ccall libwasmer.wasm_ref_as_func(arg1::Ptr{wasm_ref_t})::Ptr{wasm_func_t}
end

function wasm_func_as_ref_const(arg1)
    @ccall libwasmer.wasm_func_as_ref_const(arg1::Ptr{wasm_func_t})::Ptr{wasm_ref_t}
end

function wasm_ref_as_func_const(arg1)
    @ccall libwasmer.wasm_ref_as_func_const(arg1::Ptr{wasm_ref_t})::Ptr{wasm_func_t}
end

# typedef own wasm_trap_t * ( * wasm_func_callback_t ) ( const wasm_val_vec_t * args , own wasm_val_vec_t * results )
const wasm_func_callback_t = Ptr{Cvoid}

# typedef own wasm_trap_t * ( * wasm_func_callback_with_env_t ) ( void * env , const wasm_val_vec_t * args , wasm_val_vec_t * results )
const wasm_func_callback_with_env_t = Ptr{Cvoid}

function wasm_func_new(arg1, arg2, arg3)
    @ccall libwasmer.wasm_func_new(arg1::Ptr{wasm_store_t}, arg2::Ptr{wasm_functype_t}, arg3::wasm_func_callback_t)::Ptr{wasm_func_t}
end

function wasm_func_new_with_env(arg1, type, arg3, env, finalizer)
    @ccall libwasmer.wasm_func_new_with_env(arg1::Ptr{wasm_store_t}, type::Ptr{wasm_functype_t}, arg3::wasm_func_callback_with_env_t, env::Ptr{Cvoid}, finalizer::Ptr{Cvoid})::Ptr{wasm_func_t}
end

function wasm_func_type(arg1)
    @ccall libwasmer.wasm_func_type(arg1::Ptr{wasm_func_t})::Ptr{wasm_functype_t}
end

function wasm_func_param_arity(arg1)
    @ccall libwasmer.wasm_func_param_arity(arg1::Ptr{wasm_func_t})::Csize_t
end

function wasm_func_result_arity(arg1)
    @ccall libwasmer.wasm_func_result_arity(arg1::Ptr{wasm_func_t})::Csize_t
end

function wasm_func_call(arg1, args, results)
    @ccall libwasmer.wasm_func_call(arg1::Ptr{wasm_func_t}, args::Ptr{wasm_val_vec_t}, results::Ptr{wasm_val_vec_t})::Ptr{wasm_trap_t}
end

mutable struct wasm_global_t end

function wasm_global_delete(arg1)
    @ccall libwasmer.wasm_global_delete(arg1::Ptr{wasm_global_t})::Cvoid
end

function wasm_global_copy(arg1)
    @ccall libwasmer.wasm_global_copy(arg1::Ptr{wasm_global_t})::Ptr{wasm_global_t}
end

function wasm_global_same(arg1, arg2)
    @ccall libwasmer.wasm_global_same(arg1::Ptr{wasm_global_t}, arg2::Ptr{wasm_global_t})::Bool
end

function wasm_global_get_host_info(arg1)
    @ccall libwasmer.wasm_global_get_host_info(arg1::Ptr{wasm_global_t})::Ptr{Cvoid}
end

function wasm_global_set_host_info(arg1, arg2)
    @ccall libwasmer.wasm_global_set_host_info(arg1::Ptr{wasm_global_t}, arg2::Ptr{Cvoid})::Cvoid
end

function wasm_global_set_host_info_with_finalizer(arg1, arg2, arg3)
    @ccall libwasmer.wasm_global_set_host_info_with_finalizer(arg1::Ptr{wasm_global_t}, arg2::Ptr{Cvoid}, arg3::Ptr{Cvoid})::Cvoid
end

function wasm_global_as_ref(arg1)
    @ccall libwasmer.wasm_global_as_ref(arg1::Ptr{wasm_global_t})::Ptr{wasm_ref_t}
end

function wasm_ref_as_global(arg1)
    @ccall libwasmer.wasm_ref_as_global(arg1::Ptr{wasm_ref_t})::Ptr{wasm_global_t}
end

function wasm_global_as_ref_const(arg1)
    @ccall libwasmer.wasm_global_as_ref_const(arg1::Ptr{wasm_global_t})::Ptr{wasm_ref_t}
end

function wasm_ref_as_global_const(arg1)
    @ccall libwasmer.wasm_ref_as_global_const(arg1::Ptr{wasm_ref_t})::Ptr{wasm_global_t}
end

function wasm_global_new(arg1, arg2, arg3)
    @ccall libwasmer.wasm_global_new(arg1::Ptr{wasm_store_t}, arg2::Ptr{wasm_globaltype_t}, arg3::Ptr{wasm_val_t})::Ptr{wasm_global_t}
end

function wasm_global_type(arg1)
    @ccall libwasmer.wasm_global_type(arg1::Ptr{wasm_global_t})::Ptr{wasm_globaltype_t}
end

function wasm_global_get(arg1, out)
    @ccall libwasmer.wasm_global_get(arg1::Ptr{wasm_global_t}, out::Ptr{wasm_val_t})::Cvoid
end

function wasm_global_set(arg1, arg2)
    @ccall libwasmer.wasm_global_set(arg1::Ptr{wasm_global_t}, arg2::Ptr{wasm_val_t})::Cvoid
end

mutable struct wasm_table_t end

function wasm_table_delete(arg1)
    @ccall libwasmer.wasm_table_delete(arg1::Ptr{wasm_table_t})::Cvoid
end

function wasm_table_copy(arg1)
    @ccall libwasmer.wasm_table_copy(arg1::Ptr{wasm_table_t})::Ptr{wasm_table_t}
end

function wasm_table_same(arg1, arg2)
    @ccall libwasmer.wasm_table_same(arg1::Ptr{wasm_table_t}, arg2::Ptr{wasm_table_t})::Bool
end

function wasm_table_get_host_info(arg1)
    @ccall libwasmer.wasm_table_get_host_info(arg1::Ptr{wasm_table_t})::Ptr{Cvoid}
end

function wasm_table_set_host_info(arg1, arg2)
    @ccall libwasmer.wasm_table_set_host_info(arg1::Ptr{wasm_table_t}, arg2::Ptr{Cvoid})::Cvoid
end

function wasm_table_set_host_info_with_finalizer(arg1, arg2, arg3)
    @ccall libwasmer.wasm_table_set_host_info_with_finalizer(arg1::Ptr{wasm_table_t}, arg2::Ptr{Cvoid}, arg3::Ptr{Cvoid})::Cvoid
end

function wasm_table_as_ref(arg1)
    @ccall libwasmer.wasm_table_as_ref(arg1::Ptr{wasm_table_t})::Ptr{wasm_ref_t}
end

function wasm_ref_as_table(arg1)
    @ccall libwasmer.wasm_ref_as_table(arg1::Ptr{wasm_ref_t})::Ptr{wasm_table_t}
end

function wasm_table_as_ref_const(arg1)
    @ccall libwasmer.wasm_table_as_ref_const(arg1::Ptr{wasm_table_t})::Ptr{wasm_ref_t}
end

function wasm_ref_as_table_const(arg1)
    @ccall libwasmer.wasm_ref_as_table_const(arg1::Ptr{wasm_ref_t})::Ptr{wasm_table_t}
end

const wasm_table_size_t = UInt32

function wasm_table_new(arg1, arg2, init)
    @ccall libwasmer.wasm_table_new(arg1::Ptr{wasm_store_t}, arg2::Ptr{wasm_tabletype_t}, init::Ptr{wasm_ref_t})::Ptr{wasm_table_t}
end

function wasm_table_type(arg1)
    @ccall libwasmer.wasm_table_type(arg1::Ptr{wasm_table_t})::Ptr{wasm_tabletype_t}
end

function wasm_table_get(arg1, index)
    @ccall libwasmer.wasm_table_get(arg1::Ptr{wasm_table_t}, index::wasm_table_size_t)::Ptr{wasm_ref_t}
end

function wasm_table_set(arg1, index, arg3)
    @ccall libwasmer.wasm_table_set(arg1::Ptr{wasm_table_t}, index::wasm_table_size_t, arg3::Ptr{wasm_ref_t})::Bool
end

function wasm_table_size(arg1)
    @ccall libwasmer.wasm_table_size(arg1::Ptr{wasm_table_t})::wasm_table_size_t
end

function wasm_table_grow(arg1, delta, init)
    @ccall libwasmer.wasm_table_grow(arg1::Ptr{wasm_table_t}, delta::wasm_table_size_t, init::Ptr{wasm_ref_t})::Bool
end

mutable struct wasm_memory_t end

function wasm_memory_delete(arg1)
    @ccall libwasmer.wasm_memory_delete(arg1::Ptr{wasm_memory_t})::Cvoid
end

function wasm_memory_copy(arg1)
    @ccall libwasmer.wasm_memory_copy(arg1::Ptr{wasm_memory_t})::Ptr{wasm_memory_t}
end

function wasm_memory_same(arg1, arg2)
    @ccall libwasmer.wasm_memory_same(arg1::Ptr{wasm_memory_t}, arg2::Ptr{wasm_memory_t})::Bool
end

function wasm_memory_get_host_info(arg1)
    @ccall libwasmer.wasm_memory_get_host_info(arg1::Ptr{wasm_memory_t})::Ptr{Cvoid}
end

function wasm_memory_set_host_info(arg1, arg2)
    @ccall libwasmer.wasm_memory_set_host_info(arg1::Ptr{wasm_memory_t}, arg2::Ptr{Cvoid})::Cvoid
end

function wasm_memory_set_host_info_with_finalizer(arg1, arg2, arg3)
    @ccall libwasmer.wasm_memory_set_host_info_with_finalizer(arg1::Ptr{wasm_memory_t}, arg2::Ptr{Cvoid}, arg3::Ptr{Cvoid})::Cvoid
end

function wasm_memory_as_ref(arg1)
    @ccall libwasmer.wasm_memory_as_ref(arg1::Ptr{wasm_memory_t})::Ptr{wasm_ref_t}
end

function wasm_ref_as_memory(arg1)
    @ccall libwasmer.wasm_ref_as_memory(arg1::Ptr{wasm_ref_t})::Ptr{wasm_memory_t}
end

function wasm_memory_as_ref_const(arg1)
    @ccall libwasmer.wasm_memory_as_ref_const(arg1::Ptr{wasm_memory_t})::Ptr{wasm_ref_t}
end

function wasm_ref_as_memory_const(arg1)
    @ccall libwasmer.wasm_ref_as_memory_const(arg1::Ptr{wasm_ref_t})::Ptr{wasm_memory_t}
end

const wasm_memory_pages_t = UInt32

function wasm_memory_new(arg1, arg2)
    @ccall libwasmer.wasm_memory_new(arg1::Ptr{wasm_store_t}, arg2::Ptr{wasm_memorytype_t})::Ptr{wasm_memory_t}
end

function wasm_memory_type(arg1)
    @ccall libwasmer.wasm_memory_type(arg1::Ptr{wasm_memory_t})::Ptr{wasm_memorytype_t}
end

function wasm_memory_data(arg1)
    @ccall libwasmer.wasm_memory_data(arg1::Ptr{wasm_memory_t})::Ptr{byte_t}
end

function wasm_memory_data_size(arg1)
    @ccall libwasmer.wasm_memory_data_size(arg1::Ptr{wasm_memory_t})::Csize_t
end

function wasm_memory_size(arg1)
    @ccall libwasmer.wasm_memory_size(arg1::Ptr{wasm_memory_t})::wasm_memory_pages_t
end

function wasm_memory_grow(arg1, delta)
    @ccall libwasmer.wasm_memory_grow(arg1::Ptr{wasm_memory_t}, delta::wasm_memory_pages_t)::Bool
end

mutable struct wasm_extern_t end

function wasm_extern_delete(arg1)
    @ccall libwasmer.wasm_extern_delete(arg1::Ptr{wasm_extern_t})::Cvoid
end

function wasm_extern_copy(arg1)
    @ccall libwasmer.wasm_extern_copy(arg1::Ptr{wasm_extern_t})::Ptr{wasm_extern_t}
end

function wasm_extern_same(arg1, arg2)
    @ccall libwasmer.wasm_extern_same(arg1::Ptr{wasm_extern_t}, arg2::Ptr{wasm_extern_t})::Bool
end

function wasm_extern_get_host_info(arg1)
    @ccall libwasmer.wasm_extern_get_host_info(arg1::Ptr{wasm_extern_t})::Ptr{Cvoid}
end

function wasm_extern_set_host_info(arg1, arg2)
    @ccall libwasmer.wasm_extern_set_host_info(arg1::Ptr{wasm_extern_t}, arg2::Ptr{Cvoid})::Cvoid
end

function wasm_extern_set_host_info_with_finalizer(arg1, arg2, arg3)
    @ccall libwasmer.wasm_extern_set_host_info_with_finalizer(arg1::Ptr{wasm_extern_t}, arg2::Ptr{Cvoid}, arg3::Ptr{Cvoid})::Cvoid
end

function wasm_extern_as_ref(arg1)
    @ccall libwasmer.wasm_extern_as_ref(arg1::Ptr{wasm_extern_t})::Ptr{wasm_ref_t}
end

function wasm_ref_as_extern(arg1)
    @ccall libwasmer.wasm_ref_as_extern(arg1::Ptr{wasm_ref_t})::Ptr{wasm_extern_t}
end

function wasm_extern_as_ref_const(arg1)
    @ccall libwasmer.wasm_extern_as_ref_const(arg1::Ptr{wasm_extern_t})::Ptr{wasm_ref_t}
end

function wasm_ref_as_extern_const(arg1)
    @ccall libwasmer.wasm_ref_as_extern_const(arg1::Ptr{wasm_ref_t})::Ptr{wasm_extern_t}
end

mutable struct wasm_extern_vec_t
    size::Csize_t
    data::Ptr{Ptr{wasm_extern_t}}
end

function wasm_extern_vec_new_empty(out)
    @ccall libwasmer.wasm_extern_vec_new_empty(out::Ptr{wasm_extern_vec_t})::Cvoid
end

function wasm_extern_vec_new_uninitialized(out, arg2)
    @ccall libwasmer.wasm_extern_vec_new_uninitialized(out::Ptr{wasm_extern_vec_t}, arg2::Csize_t)::Cvoid
end

function wasm_extern_vec_new(out, arg2, arg3)
    @ccall libwasmer.wasm_extern_vec_new(out::Ptr{wasm_extern_vec_t}, arg2::Csize_t, arg3::Ptr{Ptr{wasm_extern_t}})::Cvoid
end

function wasm_extern_vec_copy(out, arg2)
    @ccall libwasmer.wasm_extern_vec_copy(out::Ptr{wasm_extern_vec_t}, arg2::Ptr{wasm_extern_vec_t})::Cvoid
end

function wasm_extern_vec_delete(arg1)
    @ccall libwasmer.wasm_extern_vec_delete(arg1::Ptr{wasm_extern_vec_t})::Cvoid
end

function wasm_extern_kind(arg1)
    @ccall libwasmer.wasm_extern_kind(arg1::Ptr{wasm_extern_t})::wasm_externkind_t
end

function wasm_extern_type(arg1)
    @ccall libwasmer.wasm_extern_type(arg1::Ptr{wasm_extern_t})::Ptr{wasm_externtype_t}
end

function wasm_func_as_extern(arg1)
    @ccall libwasmer.wasm_func_as_extern(arg1::Ptr{wasm_func_t})::Ptr{wasm_extern_t}
end

function wasm_global_as_extern(arg1)
    @ccall libwasmer.wasm_global_as_extern(arg1::Ptr{wasm_global_t})::Ptr{wasm_extern_t}
end

function wasm_table_as_extern(arg1)
    @ccall libwasmer.wasm_table_as_extern(arg1::Ptr{wasm_table_t})::Ptr{wasm_extern_t}
end

function wasm_memory_as_extern(arg1)
    @ccall libwasmer.wasm_memory_as_extern(arg1::Ptr{wasm_memory_t})::Ptr{wasm_extern_t}
end

function wasm_extern_as_func(arg1)
    @ccall libwasmer.wasm_extern_as_func(arg1::Ptr{wasm_extern_t})::Ptr{wasm_func_t}
end

function wasm_extern_as_global(arg1)
    @ccall libwasmer.wasm_extern_as_global(arg1::Ptr{wasm_extern_t})::Ptr{wasm_global_t}
end

function wasm_extern_as_table(arg1)
    @ccall libwasmer.wasm_extern_as_table(arg1::Ptr{wasm_extern_t})::Ptr{wasm_table_t}
end

function wasm_extern_as_memory(arg1)
    @ccall libwasmer.wasm_extern_as_memory(arg1::Ptr{wasm_extern_t})::Ptr{wasm_memory_t}
end

function wasm_func_as_extern_const(arg1)
    @ccall libwasmer.wasm_func_as_extern_const(arg1::Ptr{wasm_func_t})::Ptr{wasm_extern_t}
end

function wasm_global_as_extern_const(arg1)
    @ccall libwasmer.wasm_global_as_extern_const(arg1::Ptr{wasm_global_t})::Ptr{wasm_extern_t}
end

function wasm_table_as_extern_const(arg1)
    @ccall libwasmer.wasm_table_as_extern_const(arg1::Ptr{wasm_table_t})::Ptr{wasm_extern_t}
end

function wasm_memory_as_extern_const(arg1)
    @ccall libwasmer.wasm_memory_as_extern_const(arg1::Ptr{wasm_memory_t})::Ptr{wasm_extern_t}
end

function wasm_extern_as_func_const(arg1)
    @ccall libwasmer.wasm_extern_as_func_const(arg1::Ptr{wasm_extern_t})::Ptr{wasm_func_t}
end

function wasm_extern_as_global_const(arg1)
    @ccall libwasmer.wasm_extern_as_global_const(arg1::Ptr{wasm_extern_t})::Ptr{wasm_global_t}
end

function wasm_extern_as_table_const(arg1)
    @ccall libwasmer.wasm_extern_as_table_const(arg1::Ptr{wasm_extern_t})::Ptr{wasm_table_t}
end

function wasm_extern_as_memory_const(arg1)
    @ccall libwasmer.wasm_extern_as_memory_const(arg1::Ptr{wasm_extern_t})::Ptr{wasm_memory_t}
end

function wasm_instance_delete(arg1)
    @ccall libwasmer.wasm_instance_delete(arg1::Ptr{wasm_instance_t})::Cvoid
end

function wasm_instance_copy(arg1)
    @ccall libwasmer.wasm_instance_copy(arg1::Ptr{wasm_instance_t})::Ptr{wasm_instance_t}
end

function wasm_instance_same(arg1, arg2)
    @ccall libwasmer.wasm_instance_same(arg1::Ptr{wasm_instance_t}, arg2::Ptr{wasm_instance_t})::Bool
end

function wasm_instance_get_host_info(arg1)
    @ccall libwasmer.wasm_instance_get_host_info(arg1::Ptr{wasm_instance_t})::Ptr{Cvoid}
end

function wasm_instance_set_host_info(arg1, arg2)
    @ccall libwasmer.wasm_instance_set_host_info(arg1::Ptr{wasm_instance_t}, arg2::Ptr{Cvoid})::Cvoid
end

function wasm_instance_set_host_info_with_finalizer(arg1, arg2, arg3)
    @ccall libwasmer.wasm_instance_set_host_info_with_finalizer(arg1::Ptr{wasm_instance_t}, arg2::Ptr{Cvoid}, arg3::Ptr{Cvoid})::Cvoid
end

function wasm_instance_as_ref(arg1)
    @ccall libwasmer.wasm_instance_as_ref(arg1::Ptr{wasm_instance_t})::Ptr{wasm_ref_t}
end

function wasm_ref_as_instance(arg1)
    @ccall libwasmer.wasm_ref_as_instance(arg1::Ptr{wasm_ref_t})::Ptr{wasm_instance_t}
end

function wasm_instance_as_ref_const(arg1)
    @ccall libwasmer.wasm_instance_as_ref_const(arg1::Ptr{wasm_instance_t})::Ptr{wasm_ref_t}
end

function wasm_ref_as_instance_const(arg1)
    @ccall libwasmer.wasm_ref_as_instance_const(arg1::Ptr{wasm_ref_t})::Ptr{wasm_instance_t}
end

function wasm_instance_new(arg1, arg2, imports, arg4)
    @ccall libwasmer.wasm_instance_new(arg1::Ptr{wasm_store_t}, arg2::Ptr{wasm_module_t}, imports::Ptr{wasm_extern_vec_t}, arg4::Ptr{Ptr{wasm_trap_t}})::Ptr{wasm_instance_t}
end

function wasm_instance_exports(arg1, out)
    @ccall libwasmer.wasm_instance_exports(arg1::Ptr{wasm_instance_t}, out::Ptr{wasm_extern_vec_t})::Cvoid
end

# no prototype is found for this function at wasm.h:537:35, please use with caution
function wasm_valtype_new_i32()
    ccall((:wasm_valtype_new_i32, libwasmer), Ptr{wasm_valtype_t}, ())
end

# no prototype is found for this function at wasm.h:540:35, please use with caution
function wasm_valtype_new_i64()
    ccall((:wasm_valtype_new_i64, libwasmer), Ptr{wasm_valtype_t}, ())
end

# no prototype is found for this function at wasm.h:543:35, please use with caution
function wasm_valtype_new_f32()
    ccall((:wasm_valtype_new_f32, libwasmer), Ptr{wasm_valtype_t}, ())
end

# no prototype is found for this function at wasm.h:546:35, please use with caution
function wasm_valtype_new_f64()
    ccall((:wasm_valtype_new_f64, libwasmer), Ptr{wasm_valtype_t}, ())
end

# no prototype is found for this function at wasm.h:550:35, please use with caution
function wasm_valtype_new_anyref()
    ccall((:wasm_valtype_new_anyref, libwasmer), Ptr{wasm_valtype_t}, ())
end

# no prototype is found for this function at wasm.h:553:35, please use with caution
function wasm_valtype_new_funcref()
    ccall((:wasm_valtype_new_funcref, libwasmer), Ptr{wasm_valtype_t}, ())
end

# no prototype is found for this function at wasm.h:560:36, please use with caution
function wasm_functype_new_0_0()
    ccall((:wasm_functype_new_0_0, libwasmer), Ptr{wasm_functype_t}, ())
end

function wasm_functype_new_1_0(p)
    @ccall libwasmer.wasm_functype_new_1_0(p::Ptr{wasm_valtype_t})::Ptr{wasm_functype_t}
end

function wasm_functype_new_2_0(p1, p2)
    @ccall libwasmer.wasm_functype_new_2_0(p1::Ptr{wasm_valtype_t}, p2::Ptr{wasm_valtype_t})::Ptr{wasm_functype_t}
end

function wasm_functype_new_3_0(p1, p2, p3)
    @ccall libwasmer.wasm_functype_new_3_0(p1::Ptr{wasm_valtype_t}, p2::Ptr{wasm_valtype_t}, p3::Ptr{wasm_valtype_t})::Ptr{wasm_functype_t}
end

function wasm_functype_new_0_1(r)
    @ccall libwasmer.wasm_functype_new_0_1(r::Ptr{wasm_valtype_t})::Ptr{wasm_functype_t}
end

function wasm_functype_new_1_1(p, r)
    @ccall libwasmer.wasm_functype_new_1_1(p::Ptr{wasm_valtype_t}, r::Ptr{wasm_valtype_t})::Ptr{wasm_functype_t}
end

function wasm_functype_new_2_1(p1, p2, r)
    @ccall libwasmer.wasm_functype_new_2_1(p1::Ptr{wasm_valtype_t}, p2::Ptr{wasm_valtype_t}, r::Ptr{wasm_valtype_t})::Ptr{wasm_functype_t}
end

function wasm_functype_new_3_1(p1, p2, p3, r)
    @ccall libwasmer.wasm_functype_new_3_1(p1::Ptr{wasm_valtype_t}, p2::Ptr{wasm_valtype_t}, p3::Ptr{wasm_valtype_t}, r::Ptr{wasm_valtype_t})::Ptr{wasm_functype_t}
end

function wasm_functype_new_0_2(r1, r2)
    @ccall libwasmer.wasm_functype_new_0_2(r1::Ptr{wasm_valtype_t}, r2::Ptr{wasm_valtype_t})::Ptr{wasm_functype_t}
end

function wasm_functype_new_1_2(p, r1, r2)
    @ccall libwasmer.wasm_functype_new_1_2(p::Ptr{wasm_valtype_t}, r1::Ptr{wasm_valtype_t}, r2::Ptr{wasm_valtype_t})::Ptr{wasm_functype_t}
end

function wasm_functype_new_2_2(p1, p2, r1, r2)
    @ccall libwasmer.wasm_functype_new_2_2(p1::Ptr{wasm_valtype_t}, p2::Ptr{wasm_valtype_t}, r1::Ptr{wasm_valtype_t}, r2::Ptr{wasm_valtype_t})::Ptr{wasm_functype_t}
end

function wasm_functype_new_3_2(p1, p2, p3, r1, r2)
    @ccall libwasmer.wasm_functype_new_3_2(p1::Ptr{wasm_valtype_t}, p2::Ptr{wasm_valtype_t}, p3::Ptr{wasm_valtype_t}, r1::Ptr{wasm_valtype_t}, r2::Ptr{wasm_valtype_t})::Ptr{wasm_functype_t}
end

function wasm_val_init_ptr(out, p)
    @ccall libwasmer.wasm_val_init_ptr(out::Ptr{wasm_val_t}, p::Ptr{Cvoid})::Cvoid
end

function wasm_val_ptr(val)
    @ccall libwasmer.wasm_val_ptr(val::Ptr{wasm_val_t})::Ptr{Cvoid}
end

struct __JL_Ctag_2
    data::NTuple{8, UInt8}
end

function Base.getproperty(x::Ptr{__JL_Ctag_2}, f::Symbol)
    f === :i32 && return Ptr{Int32}(x + 0)
    f === :i64 && return Ptr{Int64}(x + 0)
    f === :f32 && return Ptr{float32_t}(x + 0)
    f === :f64 && return Ptr{float64_t}(x + 0)
    f === :ref && return Ptr{Ptr{wasm_ref_t}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_2, f::Symbol)
    r = Ref{__JL_Ctag_2}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_2}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_2}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const wasm_name = wasm_byte_vec_t

const wasm_name_new = wasm_byte_vec_new

const wasm_name_new_empty = wasm_byte_vec_new_empty

const wasm_name_new_new_uninitialized = wasm_byte_vec_new_uninitialized

const wasm_name_copy = wasm_byte_vec_copy

const wasm_name_delete = wasm_byte_vec_delete

const WASM_EMPTY_VEC = nothing

# Skipping MacroDefinition: WASM_INIT_VAL { . kind = WASM_ANYREF , . of = { . ref = NULL } }



# exports
const PREFIXES = ["libwasmer", "wasm_", "WASM_"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
