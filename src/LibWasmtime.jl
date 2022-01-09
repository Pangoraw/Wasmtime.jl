module LibWasmtime

using CEnum

# This file (`LibWasm.jl` not `prologue.jl`) is automatically generated using
# Clang.jl and should not be edited manually. Take a look at the `gen/` folder
# if something is to be changed.

using Pkg.Artifacts
using Pkg.BinaryPlatforms

tripletnolibc(platform) = replace(triplet(platform), "-gnu" => "")
wasmtime_folder_name(platform) =
    "wasmtime-v$release_version-$(tripletnolibc(platform))-c-api"

function get_libwasmtime_location()
    artifact_info = artifact_meta("libwasmtime", joinpath(@__DIR__, "..", "Artifacts.toml"))
    artifact_info === nothing && return nothing

    parent_path = artifact_path(Base.SHA1(artifact_info["git-tree-sha1"]))
    child_folder = readdir(parent_path)[1]
    return joinpath(
        parent_path,
        child_folder,
        "lib/libwasmtime.so"
    )
end

const libwasmtime_env_key = "LIBWASMTIME_LOCATION"
const libwasmtime = haskey(ENV, libwasmtime_env_key) ?
    ENV[libwasmtime_env_key] : get_libwasmtime_location()


const byte_t = Cchar

const wasm_byte_t = UInt8

mutable struct wasm_byte_vec_t
    size::Csize_t
    data::Ptr{wasm_byte_t}
end

function wasm_byte_vec_new(out, arg2, arg3)
    ccall((:wasm_byte_vec_new, libwasmtime), Cvoid, (Ptr{wasm_byte_vec_t}, Csize_t, Ptr{wasm_byte_t}), out, arg2, arg3)
end

function wasm_byte_vec_new_empty(out)
    ccall((:wasm_byte_vec_new_empty, libwasmtime), Cvoid, (Ptr{wasm_byte_vec_t},), out)
end

function wasm_byte_vec_new_uninitialized(out, arg2)
    ccall((:wasm_byte_vec_new_uninitialized, libwasmtime), Cvoid, (Ptr{wasm_byte_vec_t}, Csize_t), out, arg2)
end

function wasm_byte_vec_copy(out, arg2)
    ccall((:wasm_byte_vec_copy, libwasmtime), Cvoid, (Ptr{wasm_byte_vec_t}, Ptr{wasm_byte_vec_t}), out, arg2)
end

function wasm_byte_vec_delete(arg1)
    ccall((:wasm_byte_vec_delete, libwasmtime), Cvoid, (Ptr{wasm_byte_vec_t},), arg1)
end

mutable struct wasm_ref_t end

mutable struct wasm_store_t end

function assertions()
    ccall((:assertions, libwasmtime), Cvoid, ())
end

const float32_t = Cfloat

const float64_t = Cdouble

const wasm_name_t = wasm_byte_vec_t

function wasm_name_new_from_string(out, s)
    ccall((:wasm_name_new_from_string, libwasmtime), Cvoid, (Ptr{wasm_name_t}, Cstring), out, s)
end

function wasm_name_new_from_string_nt(out, s)
    ccall((:wasm_name_new_from_string_nt, libwasmtime), Cvoid, (Ptr{wasm_name_t}, Cstring), out, s)
end

mutable struct wasm_config_t end

function wasm_config_delete(arg1)
    ccall((:wasm_config_delete, libwasmtime), Cvoid, (Ptr{wasm_config_t},), arg1)
end

function wasm_config_new()
    ccall((:wasm_config_new, libwasmtime), Ptr{wasm_config_t}, ())
end

mutable struct wasm_engine_t end

function wasm_engine_delete(arg1)
    ccall((:wasm_engine_delete, libwasmtime), Cvoid, (Ptr{wasm_engine_t},), arg1)
end

function wasm_engine_new()
    ccall((:wasm_engine_new, libwasmtime), Ptr{wasm_engine_t}, ())
end

function wasm_engine_new_with_config(arg1)
    ccall((:wasm_engine_new_with_config, libwasmtime), Ptr{wasm_engine_t}, (Ptr{wasm_config_t},), arg1)
end

function wasm_store_delete(arg1)
    ccall((:wasm_store_delete, libwasmtime), Cvoid, (Ptr{wasm_store_t},), arg1)
end

function wasm_store_new(arg1)
    ccall((:wasm_store_new, libwasmtime), Ptr{wasm_store_t}, (Ptr{wasm_engine_t},), arg1)
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
    ccall((:wasm_valtype_delete, libwasmtime), Cvoid, (Ptr{wasm_valtype_t},), arg1)
end

mutable struct wasm_valtype_vec_t
    size::Csize_t
    data::Ptr{Ptr{wasm_valtype_t}}
end

function wasm_valtype_vec_new_empty(out)
    ccall((:wasm_valtype_vec_new_empty, libwasmtime), Cvoid, (Ptr{wasm_valtype_vec_t},), out)
end

function wasm_valtype_vec_new_uninitialized(out, arg2)
    ccall((:wasm_valtype_vec_new_uninitialized, libwasmtime), Cvoid, (Ptr{wasm_valtype_vec_t}, Csize_t), out, arg2)
end

function wasm_valtype_vec_new(out, arg2, arg3)
    ccall((:wasm_valtype_vec_new, libwasmtime), Cvoid, (Ptr{wasm_valtype_vec_t}, Csize_t, Ptr{Ptr{wasm_valtype_t}}), out, arg2, arg3)
end

function wasm_valtype_vec_copy(out, arg2)
    ccall((:wasm_valtype_vec_copy, libwasmtime), Cvoid, (Ptr{wasm_valtype_vec_t}, Ptr{wasm_valtype_vec_t}), out, arg2)
end

function wasm_valtype_vec_delete(arg1)
    ccall((:wasm_valtype_vec_delete, libwasmtime), Cvoid, (Ptr{wasm_valtype_vec_t},), arg1)
end

function wasm_valtype_copy(arg1)
    ccall((:wasm_valtype_copy, libwasmtime), Ptr{wasm_valtype_t}, (Ptr{wasm_valtype_t},), arg1)
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
    ccall((:wasm_valtype_new, libwasmtime), Ptr{wasm_valtype_t}, (wasm_valkind_t,), arg1)
end

function wasm_valtype_kind(arg1)
    ccall((:wasm_valtype_kind, libwasmtime), wasm_valkind_t, (Ptr{wasm_valtype_t},), arg1)
end

function wasm_valkind_is_num(k)
    ccall((:wasm_valkind_is_num, libwasmtime), Bool, (wasm_valkind_t,), k)
end

function wasm_valkind_is_ref(k)
    ccall((:wasm_valkind_is_ref, libwasmtime), Bool, (wasm_valkind_t,), k)
end

function wasm_valtype_is_num(t)
    ccall((:wasm_valtype_is_num, libwasmtime), Bool, (Ptr{wasm_valtype_t},), t)
end

function wasm_valtype_is_ref(t)
    ccall((:wasm_valtype_is_ref, libwasmtime), Bool, (Ptr{wasm_valtype_t},), t)
end

mutable struct wasm_functype_t end

function wasm_functype_delete(arg1)
    ccall((:wasm_functype_delete, libwasmtime), Cvoid, (Ptr{wasm_functype_t},), arg1)
end

mutable struct wasm_functype_vec_t
    size::Csize_t
    data::Ptr{Ptr{wasm_functype_t}}
end

function wasm_functype_vec_new_empty(out)
    ccall((:wasm_functype_vec_new_empty, libwasmtime), Cvoid, (Ptr{wasm_functype_vec_t},), out)
end

function wasm_functype_vec_new_uninitialized(out, arg2)
    ccall((:wasm_functype_vec_new_uninitialized, libwasmtime), Cvoid, (Ptr{wasm_functype_vec_t}, Csize_t), out, arg2)
end

function wasm_functype_vec_new(out, arg2, arg3)
    ccall((:wasm_functype_vec_new, libwasmtime), Cvoid, (Ptr{wasm_functype_vec_t}, Csize_t, Ptr{Ptr{wasm_functype_t}}), out, arg2, arg3)
end

function wasm_functype_vec_copy(out, arg2)
    ccall((:wasm_functype_vec_copy, libwasmtime), Cvoid, (Ptr{wasm_functype_vec_t}, Ptr{wasm_functype_vec_t}), out, arg2)
end

function wasm_functype_vec_delete(arg1)
    ccall((:wasm_functype_vec_delete, libwasmtime), Cvoid, (Ptr{wasm_functype_vec_t},), arg1)
end

function wasm_functype_copy(arg1)
    ccall((:wasm_functype_copy, libwasmtime), Ptr{wasm_functype_t}, (Ptr{wasm_functype_t},), arg1)
end

function wasm_functype_new(params, results)
    ccall((:wasm_functype_new, libwasmtime), Ptr{wasm_functype_t}, (Ptr{wasm_valtype_vec_t}, Ptr{wasm_valtype_vec_t}), params, results)
end

function wasm_functype_params(arg1)
    ccall((:wasm_functype_params, libwasmtime), Ptr{wasm_valtype_vec_t}, (Ptr{wasm_functype_t},), arg1)
end

function wasm_functype_results(arg1)
    ccall((:wasm_functype_results, libwasmtime), Ptr{wasm_valtype_vec_t}, (Ptr{wasm_functype_t},), arg1)
end

mutable struct wasm_globaltype_t end

function wasm_globaltype_delete(arg1)
    ccall((:wasm_globaltype_delete, libwasmtime), Cvoid, (Ptr{wasm_globaltype_t},), arg1)
end

mutable struct wasm_globaltype_vec_t
    size::Csize_t
    data::Ptr{Ptr{wasm_globaltype_t}}
end

function wasm_globaltype_vec_new_empty(out)
    ccall((:wasm_globaltype_vec_new_empty, libwasmtime), Cvoid, (Ptr{wasm_globaltype_vec_t},), out)
end

function wasm_globaltype_vec_new_uninitialized(out, arg2)
    ccall((:wasm_globaltype_vec_new_uninitialized, libwasmtime), Cvoid, (Ptr{wasm_globaltype_vec_t}, Csize_t), out, arg2)
end

function wasm_globaltype_vec_new(out, arg2, arg3)
    ccall((:wasm_globaltype_vec_new, libwasmtime), Cvoid, (Ptr{wasm_globaltype_vec_t}, Csize_t, Ptr{Ptr{wasm_globaltype_t}}), out, arg2, arg3)
end

function wasm_globaltype_vec_copy(out, arg2)
    ccall((:wasm_globaltype_vec_copy, libwasmtime), Cvoid, (Ptr{wasm_globaltype_vec_t}, Ptr{wasm_globaltype_vec_t}), out, arg2)
end

function wasm_globaltype_vec_delete(arg1)
    ccall((:wasm_globaltype_vec_delete, libwasmtime), Cvoid, (Ptr{wasm_globaltype_vec_t},), arg1)
end

function wasm_globaltype_copy(arg1)
    ccall((:wasm_globaltype_copy, libwasmtime), Ptr{wasm_globaltype_t}, (Ptr{wasm_globaltype_t},), arg1)
end

function wasm_globaltype_new(arg1, arg2)
    ccall((:wasm_globaltype_new, libwasmtime), Ptr{wasm_globaltype_t}, (Ptr{wasm_valtype_t}, wasm_mutability_t), arg1, arg2)
end

function wasm_globaltype_content(arg1)
    ccall((:wasm_globaltype_content, libwasmtime), Ptr{wasm_valtype_t}, (Ptr{wasm_globaltype_t},), arg1)
end

function wasm_globaltype_mutability(arg1)
    ccall((:wasm_globaltype_mutability, libwasmtime), wasm_mutability_t, (Ptr{wasm_globaltype_t},), arg1)
end

mutable struct wasm_tabletype_t end

function wasm_tabletype_delete(arg1)
    ccall((:wasm_tabletype_delete, libwasmtime), Cvoid, (Ptr{wasm_tabletype_t},), arg1)
end

mutable struct wasm_tabletype_vec_t
    size::Csize_t
    data::Ptr{Ptr{wasm_tabletype_t}}
end

function wasm_tabletype_vec_new_empty(out)
    ccall((:wasm_tabletype_vec_new_empty, libwasmtime), Cvoid, (Ptr{wasm_tabletype_vec_t},), out)
end

function wasm_tabletype_vec_new_uninitialized(out, arg2)
    ccall((:wasm_tabletype_vec_new_uninitialized, libwasmtime), Cvoid, (Ptr{wasm_tabletype_vec_t}, Csize_t), out, arg2)
end

function wasm_tabletype_vec_new(out, arg2, arg3)
    ccall((:wasm_tabletype_vec_new, libwasmtime), Cvoid, (Ptr{wasm_tabletype_vec_t}, Csize_t, Ptr{Ptr{wasm_tabletype_t}}), out, arg2, arg3)
end

function wasm_tabletype_vec_copy(out, arg2)
    ccall((:wasm_tabletype_vec_copy, libwasmtime), Cvoid, (Ptr{wasm_tabletype_vec_t}, Ptr{wasm_tabletype_vec_t}), out, arg2)
end

function wasm_tabletype_vec_delete(arg1)
    ccall((:wasm_tabletype_vec_delete, libwasmtime), Cvoid, (Ptr{wasm_tabletype_vec_t},), arg1)
end

function wasm_tabletype_copy(arg1)
    ccall((:wasm_tabletype_copy, libwasmtime), Ptr{wasm_tabletype_t}, (Ptr{wasm_tabletype_t},), arg1)
end

function wasm_tabletype_new(arg1, arg2)
    ccall((:wasm_tabletype_new, libwasmtime), Ptr{wasm_tabletype_t}, (Ptr{wasm_valtype_t}, Ptr{wasm_limits_t}), arg1, arg2)
end

function wasm_tabletype_element(arg1)
    ccall((:wasm_tabletype_element, libwasmtime), Ptr{wasm_valtype_t}, (Ptr{wasm_tabletype_t},), arg1)
end

function wasm_tabletype_limits(arg1)
    ccall((:wasm_tabletype_limits, libwasmtime), Ptr{wasm_limits_t}, (Ptr{wasm_tabletype_t},), arg1)
end

mutable struct wasm_memorytype_t end

function wasm_memorytype_delete(arg1)
    ccall((:wasm_memorytype_delete, libwasmtime), Cvoid, (Ptr{wasm_memorytype_t},), arg1)
end

mutable struct wasm_memorytype_vec_t
    size::Csize_t
    data::Ptr{Ptr{wasm_memorytype_t}}
end

function wasm_memorytype_vec_new_empty(out)
    ccall((:wasm_memorytype_vec_new_empty, libwasmtime), Cvoid, (Ptr{wasm_memorytype_vec_t},), out)
end

function wasm_memorytype_vec_new_uninitialized(out, arg2)
    ccall((:wasm_memorytype_vec_new_uninitialized, libwasmtime), Cvoid, (Ptr{wasm_memorytype_vec_t}, Csize_t), out, arg2)
end

function wasm_memorytype_vec_new(out, arg2, arg3)
    ccall((:wasm_memorytype_vec_new, libwasmtime), Cvoid, (Ptr{wasm_memorytype_vec_t}, Csize_t, Ptr{Ptr{wasm_memorytype_t}}), out, arg2, arg3)
end

function wasm_memorytype_vec_copy(out, arg2)
    ccall((:wasm_memorytype_vec_copy, libwasmtime), Cvoid, (Ptr{wasm_memorytype_vec_t}, Ptr{wasm_memorytype_vec_t}), out, arg2)
end

function wasm_memorytype_vec_delete(arg1)
    ccall((:wasm_memorytype_vec_delete, libwasmtime), Cvoid, (Ptr{wasm_memorytype_vec_t},), arg1)
end

function wasm_memorytype_copy(arg1)
    ccall((:wasm_memorytype_copy, libwasmtime), Ptr{wasm_memorytype_t}, (Ptr{wasm_memorytype_t},), arg1)
end

function wasm_memorytype_new(arg1)
    ccall((:wasm_memorytype_new, libwasmtime), Ptr{wasm_memorytype_t}, (Ptr{wasm_limits_t},), arg1)
end

function wasm_memorytype_limits(arg1)
    ccall((:wasm_memorytype_limits, libwasmtime), Ptr{wasm_limits_t}, (Ptr{wasm_memorytype_t},), arg1)
end

mutable struct wasm_externtype_t end

function wasm_externtype_delete(arg1)
    ccall((:wasm_externtype_delete, libwasmtime), Cvoid, (Ptr{wasm_externtype_t},), arg1)
end

mutable struct wasm_externtype_vec_t
    size::Csize_t
    data::Ptr{Ptr{wasm_externtype_t}}
end

function wasm_externtype_vec_new_empty(out)
    ccall((:wasm_externtype_vec_new_empty, libwasmtime), Cvoid, (Ptr{wasm_externtype_vec_t},), out)
end

function wasm_externtype_vec_new_uninitialized(out, arg2)
    ccall((:wasm_externtype_vec_new_uninitialized, libwasmtime), Cvoid, (Ptr{wasm_externtype_vec_t}, Csize_t), out, arg2)
end

function wasm_externtype_vec_new(out, arg2, arg3)
    ccall((:wasm_externtype_vec_new, libwasmtime), Cvoid, (Ptr{wasm_externtype_vec_t}, Csize_t, Ptr{Ptr{wasm_externtype_t}}), out, arg2, arg3)
end

function wasm_externtype_vec_copy(out, arg2)
    ccall((:wasm_externtype_vec_copy, libwasmtime), Cvoid, (Ptr{wasm_externtype_vec_t}, Ptr{wasm_externtype_vec_t}), out, arg2)
end

function wasm_externtype_vec_delete(arg1)
    ccall((:wasm_externtype_vec_delete, libwasmtime), Cvoid, (Ptr{wasm_externtype_vec_t},), arg1)
end

function wasm_externtype_copy(arg1)
    ccall((:wasm_externtype_copy, libwasmtime), Ptr{wasm_externtype_t}, (Ptr{wasm_externtype_t},), arg1)
end

const wasm_externkind_t = UInt8

@cenum wasm_externkind_enum::UInt32 begin
    WASM_EXTERN_FUNC = 0
    WASM_EXTERN_GLOBAL = 1
    WASM_EXTERN_TABLE = 2
    WASM_EXTERN_MEMORY = 3
end

function wasm_externtype_kind(arg1)
    ccall((:wasm_externtype_kind, libwasmtime), wasm_externkind_t, (Ptr{wasm_externtype_t},), arg1)
end

function wasm_functype_as_externtype(arg1)
    ccall((:wasm_functype_as_externtype, libwasmtime), Ptr{wasm_externtype_t}, (Ptr{wasm_functype_t},), arg1)
end

function wasm_globaltype_as_externtype(arg1)
    ccall((:wasm_globaltype_as_externtype, libwasmtime), Ptr{wasm_externtype_t}, (Ptr{wasm_globaltype_t},), arg1)
end

function wasm_tabletype_as_externtype(arg1)
    ccall((:wasm_tabletype_as_externtype, libwasmtime), Ptr{wasm_externtype_t}, (Ptr{wasm_tabletype_t},), arg1)
end

function wasm_memorytype_as_externtype(arg1)
    ccall((:wasm_memorytype_as_externtype, libwasmtime), Ptr{wasm_externtype_t}, (Ptr{wasm_memorytype_t},), arg1)
end

function wasm_externtype_as_functype(arg1)
    ccall((:wasm_externtype_as_functype, libwasmtime), Ptr{wasm_functype_t}, (Ptr{wasm_externtype_t},), arg1)
end

function wasm_externtype_as_globaltype(arg1)
    ccall((:wasm_externtype_as_globaltype, libwasmtime), Ptr{wasm_globaltype_t}, (Ptr{wasm_externtype_t},), arg1)
end

function wasm_externtype_as_tabletype(arg1)
    ccall((:wasm_externtype_as_tabletype, libwasmtime), Ptr{wasm_tabletype_t}, (Ptr{wasm_externtype_t},), arg1)
end

function wasm_externtype_as_memorytype(arg1)
    ccall((:wasm_externtype_as_memorytype, libwasmtime), Ptr{wasm_memorytype_t}, (Ptr{wasm_externtype_t},), arg1)
end

function wasm_functype_as_externtype_const(arg1)
    ccall((:wasm_functype_as_externtype_const, libwasmtime), Ptr{wasm_externtype_t}, (Ptr{wasm_functype_t},), arg1)
end

function wasm_globaltype_as_externtype_const(arg1)
    ccall((:wasm_globaltype_as_externtype_const, libwasmtime), Ptr{wasm_externtype_t}, (Ptr{wasm_globaltype_t},), arg1)
end

function wasm_tabletype_as_externtype_const(arg1)
    ccall((:wasm_tabletype_as_externtype_const, libwasmtime), Ptr{wasm_externtype_t}, (Ptr{wasm_tabletype_t},), arg1)
end

function wasm_memorytype_as_externtype_const(arg1)
    ccall((:wasm_memorytype_as_externtype_const, libwasmtime), Ptr{wasm_externtype_t}, (Ptr{wasm_memorytype_t},), arg1)
end

function wasm_externtype_as_functype_const(arg1)
    ccall((:wasm_externtype_as_functype_const, libwasmtime), Ptr{wasm_functype_t}, (Ptr{wasm_externtype_t},), arg1)
end

function wasm_externtype_as_globaltype_const(arg1)
    ccall((:wasm_externtype_as_globaltype_const, libwasmtime), Ptr{wasm_globaltype_t}, (Ptr{wasm_externtype_t},), arg1)
end

function wasm_externtype_as_tabletype_const(arg1)
    ccall((:wasm_externtype_as_tabletype_const, libwasmtime), Ptr{wasm_tabletype_t}, (Ptr{wasm_externtype_t},), arg1)
end

function wasm_externtype_as_memorytype_const(arg1)
    ccall((:wasm_externtype_as_memorytype_const, libwasmtime), Ptr{wasm_memorytype_t}, (Ptr{wasm_externtype_t},), arg1)
end

mutable struct wasm_importtype_t end

function wasm_importtype_delete(arg1)
    ccall((:wasm_importtype_delete, libwasmtime), Cvoid, (Ptr{wasm_importtype_t},), arg1)
end

mutable struct wasm_importtype_vec_t
    size::Csize_t
    data::Ptr{Ptr{wasm_importtype_t}}
end

function wasm_importtype_vec_new_empty(out)
    ccall((:wasm_importtype_vec_new_empty, libwasmtime), Cvoid, (Ptr{wasm_importtype_vec_t},), out)
end

function wasm_importtype_vec_new_uninitialized(out, arg2)
    ccall((:wasm_importtype_vec_new_uninitialized, libwasmtime), Cvoid, (Ptr{wasm_importtype_vec_t}, Csize_t), out, arg2)
end

function wasm_importtype_vec_new(out, arg2, arg3)
    ccall((:wasm_importtype_vec_new, libwasmtime), Cvoid, (Ptr{wasm_importtype_vec_t}, Csize_t, Ptr{Ptr{wasm_importtype_t}}), out, arg2, arg3)
end

function wasm_importtype_vec_copy(out, arg2)
    ccall((:wasm_importtype_vec_copy, libwasmtime), Cvoid, (Ptr{wasm_importtype_vec_t}, Ptr{wasm_importtype_vec_t}), out, arg2)
end

function wasm_importtype_vec_delete(arg1)
    ccall((:wasm_importtype_vec_delete, libwasmtime), Cvoid, (Ptr{wasm_importtype_vec_t},), arg1)
end

function wasm_importtype_copy(arg1)
    ccall((:wasm_importtype_copy, libwasmtime), Ptr{wasm_importtype_t}, (Ptr{wasm_importtype_t},), arg1)
end

function wasm_importtype_new(_module, name, arg3)
    ccall((:wasm_importtype_new, libwasmtime), Ptr{wasm_importtype_t}, (Ptr{wasm_name_t}, Ptr{wasm_name_t}, Ptr{wasm_externtype_t}), _module, name, arg3)
end

function wasm_importtype_module(arg1)
    ccall((:wasm_importtype_module, libwasmtime), Ptr{wasm_name_t}, (Ptr{wasm_importtype_t},), arg1)
end

function wasm_importtype_name(arg1)
    ccall((:wasm_importtype_name, libwasmtime), Ptr{wasm_name_t}, (Ptr{wasm_importtype_t},), arg1)
end

function wasm_importtype_type(arg1)
    ccall((:wasm_importtype_type, libwasmtime), Ptr{wasm_externtype_t}, (Ptr{wasm_importtype_t},), arg1)
end

mutable struct wasm_exporttype_t end

function wasm_exporttype_delete(arg1)
    ccall((:wasm_exporttype_delete, libwasmtime), Cvoid, (Ptr{wasm_exporttype_t},), arg1)
end

mutable struct wasm_exporttype_vec_t
    size::Csize_t
    data::Ptr{Ptr{wasm_exporttype_t}}
end

function wasm_exporttype_vec_new_empty(out)
    ccall((:wasm_exporttype_vec_new_empty, libwasmtime), Cvoid, (Ptr{wasm_exporttype_vec_t},), out)
end

function wasm_exporttype_vec_new_uninitialized(out, arg2)
    ccall((:wasm_exporttype_vec_new_uninitialized, libwasmtime), Cvoid, (Ptr{wasm_exporttype_vec_t}, Csize_t), out, arg2)
end

function wasm_exporttype_vec_new(out, arg2, arg3)
    ccall((:wasm_exporttype_vec_new, libwasmtime), Cvoid, (Ptr{wasm_exporttype_vec_t}, Csize_t, Ptr{Ptr{wasm_exporttype_t}}), out, arg2, arg3)
end

function wasm_exporttype_vec_copy(out, arg2)
    ccall((:wasm_exporttype_vec_copy, libwasmtime), Cvoid, (Ptr{wasm_exporttype_vec_t}, Ptr{wasm_exporttype_vec_t}), out, arg2)
end

function wasm_exporttype_vec_delete(arg1)
    ccall((:wasm_exporttype_vec_delete, libwasmtime), Cvoid, (Ptr{wasm_exporttype_vec_t},), arg1)
end

function wasm_exporttype_copy(arg1)
    ccall((:wasm_exporttype_copy, libwasmtime), Ptr{wasm_exporttype_t}, (Ptr{wasm_exporttype_t},), arg1)
end

function wasm_exporttype_new(arg1, arg2)
    ccall((:wasm_exporttype_new, libwasmtime), Ptr{wasm_exporttype_t}, (Ptr{wasm_name_t}, Ptr{wasm_externtype_t}), arg1, arg2)
end

function wasm_exporttype_name(arg1)
    ccall((:wasm_exporttype_name, libwasmtime), Ptr{wasm_name_t}, (Ptr{wasm_exporttype_t},), arg1)
end

function wasm_exporttype_type(arg1)
    ccall((:wasm_exporttype_type, libwasmtime), Ptr{wasm_externtype_t}, (Ptr{wasm_exporttype_t},), arg1)
end

struct __JL_Ctag_4
    data::NTuple{8, UInt8}
end

function Base.getproperty(x::Ptr{__JL_Ctag_4}, f::Symbol)
    f === :i32 && return Ptr{Int32}(x + 0)
    f === :i64 && return Ptr{Int64}(x + 0)
    f === :f32 && return Ptr{float32_t}(x + 0)
    f === :f64 && return Ptr{float64_t}(x + 0)
    f === :ref && return Ptr{Ptr{wasm_ref_t}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::__JL_Ctag_4, f::Symbol)
    r = Ref{__JL_Ctag_4}(x)
    ptr = Base.unsafe_convert(Ptr{__JL_Ctag_4}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{__JL_Ctag_4}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

struct wasm_val_t
    data::NTuple{16, UInt8}
end

function Base.getproperty(x::Ptr{wasm_val_t}, f::Symbol)
    f === :kind && return Ptr{wasm_valkind_t}(x + 0)
    f === :of && return Ptr{__JL_Ctag_4}(x + 8)
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
    ccall((:wasm_val_delete, libwasmtime), Cvoid, (Ptr{wasm_val_t},), v)
end

function wasm_val_copy(out, arg2)
    ccall((:wasm_val_copy, libwasmtime), Cvoid, (Ptr{wasm_val_t}, Ptr{wasm_val_t}), out, arg2)
end

mutable struct wasm_val_vec_t
    size::Csize_t
    data::Ptr{wasm_val_t}
end

function wasm_val_vec_new_empty(out)
    ccall((:wasm_val_vec_new_empty, libwasmtime), Cvoid, (Ptr{wasm_val_vec_t},), out)
end

function wasm_val_vec_new_uninitialized(out, arg2)
    ccall((:wasm_val_vec_new_uninitialized, libwasmtime), Cvoid, (Ptr{wasm_val_vec_t}, Csize_t), out, arg2)
end

function wasm_val_vec_new(out, arg2, arg3)
    ccall((:wasm_val_vec_new, libwasmtime), Cvoid, (Ptr{wasm_val_vec_t}, Csize_t, Ptr{wasm_val_t}), out, arg2, arg3)
end

function wasm_val_vec_copy(out, arg2)
    ccall((:wasm_val_vec_copy, libwasmtime), Cvoid, (Ptr{wasm_val_vec_t}, Ptr{wasm_val_vec_t}), out, arg2)
end

function wasm_val_vec_delete(arg1)
    ccall((:wasm_val_vec_delete, libwasmtime), Cvoid, (Ptr{wasm_val_vec_t},), arg1)
end

function wasm_ref_delete(arg1)
    ccall((:wasm_ref_delete, libwasmtime), Cvoid, (Ptr{wasm_ref_t},), arg1)
end

function wasm_ref_copy(arg1)
    ccall((:wasm_ref_copy, libwasmtime), Ptr{wasm_ref_t}, (Ptr{wasm_ref_t},), arg1)
end

function wasm_ref_same(arg1, arg2)
    ccall((:wasm_ref_same, libwasmtime), Bool, (Ptr{wasm_ref_t}, Ptr{wasm_ref_t}), arg1, arg2)
end

function wasm_ref_get_host_info(arg1)
    ccall((:wasm_ref_get_host_info, libwasmtime), Ptr{Cvoid}, (Ptr{wasm_ref_t},), arg1)
end

function wasm_ref_set_host_info(arg1, arg2)
    ccall((:wasm_ref_set_host_info, libwasmtime), Cvoid, (Ptr{wasm_ref_t}, Ptr{Cvoid}), arg1, arg2)
end

function wasm_ref_set_host_info_with_finalizer(arg1, arg2, arg3)
    ccall((:wasm_ref_set_host_info_with_finalizer, libwasmtime), Cvoid, (Ptr{wasm_ref_t}, Ptr{Cvoid}, Ptr{Cvoid}), arg1, arg2, arg3)
end

mutable struct wasm_frame_t end

function wasm_frame_delete(arg1)
    ccall((:wasm_frame_delete, libwasmtime), Cvoid, (Ptr{wasm_frame_t},), arg1)
end

mutable struct wasm_frame_vec_t
    size::Csize_t
    data::Ptr{Ptr{wasm_frame_t}}
end

function wasm_frame_vec_new_empty(out)
    ccall((:wasm_frame_vec_new_empty, libwasmtime), Cvoid, (Ptr{wasm_frame_vec_t},), out)
end

function wasm_frame_vec_new_uninitialized(out, arg2)
    ccall((:wasm_frame_vec_new_uninitialized, libwasmtime), Cvoid, (Ptr{wasm_frame_vec_t}, Csize_t), out, arg2)
end

function wasm_frame_vec_new(out, arg2, arg3)
    ccall((:wasm_frame_vec_new, libwasmtime), Cvoid, (Ptr{wasm_frame_vec_t}, Csize_t, Ptr{Ptr{wasm_frame_t}}), out, arg2, arg3)
end

function wasm_frame_vec_copy(out, arg2)
    ccall((:wasm_frame_vec_copy, libwasmtime), Cvoid, (Ptr{wasm_frame_vec_t}, Ptr{wasm_frame_vec_t}), out, arg2)
end

function wasm_frame_vec_delete(arg1)
    ccall((:wasm_frame_vec_delete, libwasmtime), Cvoid, (Ptr{wasm_frame_vec_t},), arg1)
end

function wasm_frame_copy(arg1)
    ccall((:wasm_frame_copy, libwasmtime), Ptr{wasm_frame_t}, (Ptr{wasm_frame_t},), arg1)
end

mutable struct wasm_instance_t end

function wasm_frame_instance(arg1)
    ccall((:wasm_frame_instance, libwasmtime), Ptr{wasm_instance_t}, (Ptr{wasm_frame_t},), arg1)
end

function wasm_frame_func_index(arg1)
    ccall((:wasm_frame_func_index, libwasmtime), UInt32, (Ptr{wasm_frame_t},), arg1)
end

function wasm_frame_func_offset(arg1)
    ccall((:wasm_frame_func_offset, libwasmtime), Csize_t, (Ptr{wasm_frame_t},), arg1)
end

function wasm_frame_module_offset(arg1)
    ccall((:wasm_frame_module_offset, libwasmtime), Csize_t, (Ptr{wasm_frame_t},), arg1)
end

const wasm_message_t = wasm_name_t

mutable struct wasm_trap_t end

function wasm_trap_delete(arg1)
    ccall((:wasm_trap_delete, libwasmtime), Cvoid, (Ptr{wasm_trap_t},), arg1)
end

function wasm_trap_copy(arg1)
    ccall((:wasm_trap_copy, libwasmtime), Ptr{wasm_trap_t}, (Ptr{wasm_trap_t},), arg1)
end

function wasm_trap_same(arg1, arg2)
    ccall((:wasm_trap_same, libwasmtime), Bool, (Ptr{wasm_trap_t}, Ptr{wasm_trap_t}), arg1, arg2)
end

function wasm_trap_get_host_info(arg1)
    ccall((:wasm_trap_get_host_info, libwasmtime), Ptr{Cvoid}, (Ptr{wasm_trap_t},), arg1)
end

function wasm_trap_set_host_info(arg1, arg2)
    ccall((:wasm_trap_set_host_info, libwasmtime), Cvoid, (Ptr{wasm_trap_t}, Ptr{Cvoid}), arg1, arg2)
end

function wasm_trap_set_host_info_with_finalizer(arg1, arg2, arg3)
    ccall((:wasm_trap_set_host_info_with_finalizer, libwasmtime), Cvoid, (Ptr{wasm_trap_t}, Ptr{Cvoid}, Ptr{Cvoid}), arg1, arg2, arg3)
end

function wasm_trap_as_ref(arg1)
    ccall((:wasm_trap_as_ref, libwasmtime), Ptr{wasm_ref_t}, (Ptr{wasm_trap_t},), arg1)
end

function wasm_ref_as_trap(arg1)
    ccall((:wasm_ref_as_trap, libwasmtime), Ptr{wasm_trap_t}, (Ptr{wasm_ref_t},), arg1)
end

function wasm_trap_as_ref_const(arg1)
    ccall((:wasm_trap_as_ref_const, libwasmtime), Ptr{wasm_ref_t}, (Ptr{wasm_trap_t},), arg1)
end

function wasm_ref_as_trap_const(arg1)
    ccall((:wasm_ref_as_trap_const, libwasmtime), Ptr{wasm_trap_t}, (Ptr{wasm_ref_t},), arg1)
end

function wasm_trap_new(store, arg2)
    ccall((:wasm_trap_new, libwasmtime), Ptr{wasm_trap_t}, (Ptr{wasm_store_t}, Ptr{wasm_message_t}), store, arg2)
end

function wasm_trap_message(arg1, out)
    ccall((:wasm_trap_message, libwasmtime), Cvoid, (Ptr{wasm_trap_t}, Ptr{wasm_message_t}), arg1, out)
end

function wasm_trap_origin(arg1)
    ccall((:wasm_trap_origin, libwasmtime), Ptr{wasm_frame_t}, (Ptr{wasm_trap_t},), arg1)
end

function wasm_trap_trace(arg1, out)
    ccall((:wasm_trap_trace, libwasmtime), Cvoid, (Ptr{wasm_trap_t}, Ptr{wasm_frame_vec_t}), arg1, out)
end

mutable struct wasm_foreign_t end

function wasm_foreign_delete(arg1)
    ccall((:wasm_foreign_delete, libwasmtime), Cvoid, (Ptr{wasm_foreign_t},), arg1)
end

function wasm_foreign_copy(arg1)
    ccall((:wasm_foreign_copy, libwasmtime), Ptr{wasm_foreign_t}, (Ptr{wasm_foreign_t},), arg1)
end

function wasm_foreign_same(arg1, arg2)
    ccall((:wasm_foreign_same, libwasmtime), Bool, (Ptr{wasm_foreign_t}, Ptr{wasm_foreign_t}), arg1, arg2)
end

function wasm_foreign_get_host_info(arg1)
    ccall((:wasm_foreign_get_host_info, libwasmtime), Ptr{Cvoid}, (Ptr{wasm_foreign_t},), arg1)
end

function wasm_foreign_set_host_info(arg1, arg2)
    ccall((:wasm_foreign_set_host_info, libwasmtime), Cvoid, (Ptr{wasm_foreign_t}, Ptr{Cvoid}), arg1, arg2)
end

function wasm_foreign_set_host_info_with_finalizer(arg1, arg2, arg3)
    ccall((:wasm_foreign_set_host_info_with_finalizer, libwasmtime), Cvoid, (Ptr{wasm_foreign_t}, Ptr{Cvoid}, Ptr{Cvoid}), arg1, arg2, arg3)
end

function wasm_foreign_as_ref(arg1)
    ccall((:wasm_foreign_as_ref, libwasmtime), Ptr{wasm_ref_t}, (Ptr{wasm_foreign_t},), arg1)
end

function wasm_ref_as_foreign(arg1)
    ccall((:wasm_ref_as_foreign, libwasmtime), Ptr{wasm_foreign_t}, (Ptr{wasm_ref_t},), arg1)
end

function wasm_foreign_as_ref_const(arg1)
    ccall((:wasm_foreign_as_ref_const, libwasmtime), Ptr{wasm_ref_t}, (Ptr{wasm_foreign_t},), arg1)
end

function wasm_ref_as_foreign_const(arg1)
    ccall((:wasm_ref_as_foreign_const, libwasmtime), Ptr{wasm_foreign_t}, (Ptr{wasm_ref_t},), arg1)
end

function wasm_foreign_new(arg1)
    ccall((:wasm_foreign_new, libwasmtime), Ptr{wasm_foreign_t}, (Ptr{wasm_store_t},), arg1)
end

mutable struct wasm_module_t end

function wasm_module_delete(arg1)
    ccall((:wasm_module_delete, libwasmtime), Cvoid, (Ptr{wasm_module_t},), arg1)
end

function wasm_module_copy(arg1)
    ccall((:wasm_module_copy, libwasmtime), Ptr{wasm_module_t}, (Ptr{wasm_module_t},), arg1)
end

function wasm_module_same(arg1, arg2)
    ccall((:wasm_module_same, libwasmtime), Bool, (Ptr{wasm_module_t}, Ptr{wasm_module_t}), arg1, arg2)
end

function wasm_module_get_host_info(arg1)
    ccall((:wasm_module_get_host_info, libwasmtime), Ptr{Cvoid}, (Ptr{wasm_module_t},), arg1)
end

function wasm_module_set_host_info(arg1, arg2)
    ccall((:wasm_module_set_host_info, libwasmtime), Cvoid, (Ptr{wasm_module_t}, Ptr{Cvoid}), arg1, arg2)
end

function wasm_module_set_host_info_with_finalizer(arg1, arg2, arg3)
    ccall((:wasm_module_set_host_info_with_finalizer, libwasmtime), Cvoid, (Ptr{wasm_module_t}, Ptr{Cvoid}, Ptr{Cvoid}), arg1, arg2, arg3)
end

function wasm_module_as_ref(arg1)
    ccall((:wasm_module_as_ref, libwasmtime), Ptr{wasm_ref_t}, (Ptr{wasm_module_t},), arg1)
end

function wasm_ref_as_module(arg1)
    ccall((:wasm_ref_as_module, libwasmtime), Ptr{wasm_module_t}, (Ptr{wasm_ref_t},), arg1)
end

function wasm_module_as_ref_const(arg1)
    ccall((:wasm_module_as_ref_const, libwasmtime), Ptr{wasm_ref_t}, (Ptr{wasm_module_t},), arg1)
end

function wasm_ref_as_module_const(arg1)
    ccall((:wasm_ref_as_module_const, libwasmtime), Ptr{wasm_module_t}, (Ptr{wasm_ref_t},), arg1)
end

mutable struct wasm_shared_module_t end

function wasm_shared_module_delete(arg1)
    ccall((:wasm_shared_module_delete, libwasmtime), Cvoid, (Ptr{wasm_shared_module_t},), arg1)
end

function wasm_module_share(arg1)
    ccall((:wasm_module_share, libwasmtime), Ptr{wasm_shared_module_t}, (Ptr{wasm_module_t},), arg1)
end

function wasm_module_obtain(arg1, arg2)
    ccall((:wasm_module_obtain, libwasmtime), Ptr{wasm_module_t}, (Ptr{wasm_store_t}, Ptr{wasm_shared_module_t}), arg1, arg2)
end

function wasm_module_new(arg1, binary)
    ccall((:wasm_module_new, libwasmtime), Ptr{wasm_module_t}, (Ptr{wasm_store_t}, Ptr{wasm_byte_vec_t}), arg1, binary)
end

function wasm_module_validate(arg1, binary)
    ccall((:wasm_module_validate, libwasmtime), Bool, (Ptr{wasm_store_t}, Ptr{wasm_byte_vec_t}), arg1, binary)
end

function wasm_module_imports(arg1, out)
    ccall((:wasm_module_imports, libwasmtime), Cvoid, (Ptr{wasm_module_t}, Ptr{wasm_importtype_vec_t}), arg1, out)
end

function wasm_module_exports(arg1, out)
    ccall((:wasm_module_exports, libwasmtime), Cvoid, (Ptr{wasm_module_t}, Ptr{wasm_exporttype_vec_t}), arg1, out)
end

function wasm_module_serialize(arg1, out)
    ccall((:wasm_module_serialize, libwasmtime), Cvoid, (Ptr{wasm_module_t}, Ptr{wasm_byte_vec_t}), arg1, out)
end

function wasm_module_deserialize(arg1, arg2)
    ccall((:wasm_module_deserialize, libwasmtime), Ptr{wasm_module_t}, (Ptr{wasm_store_t}, Ptr{wasm_byte_vec_t}), arg1, arg2)
end

mutable struct wasm_func_t end

function wasm_func_delete(arg1)
    ccall((:wasm_func_delete, libwasmtime), Cvoid, (Ptr{wasm_func_t},), arg1)
end

function wasm_func_copy(arg1)
    ccall((:wasm_func_copy, libwasmtime), Ptr{wasm_func_t}, (Ptr{wasm_func_t},), arg1)
end

function wasm_func_same(arg1, arg2)
    ccall((:wasm_func_same, libwasmtime), Bool, (Ptr{wasm_func_t}, Ptr{wasm_func_t}), arg1, arg2)
end

function wasm_func_get_host_info(arg1)
    ccall((:wasm_func_get_host_info, libwasmtime), Ptr{Cvoid}, (Ptr{wasm_func_t},), arg1)
end

function wasm_func_set_host_info(arg1, arg2)
    ccall((:wasm_func_set_host_info, libwasmtime), Cvoid, (Ptr{wasm_func_t}, Ptr{Cvoid}), arg1, arg2)
end

function wasm_func_set_host_info_with_finalizer(arg1, arg2, arg3)
    ccall((:wasm_func_set_host_info_with_finalizer, libwasmtime), Cvoid, (Ptr{wasm_func_t}, Ptr{Cvoid}, Ptr{Cvoid}), arg1, arg2, arg3)
end

function wasm_func_as_ref(arg1)
    ccall((:wasm_func_as_ref, libwasmtime), Ptr{wasm_ref_t}, (Ptr{wasm_func_t},), arg1)
end

function wasm_ref_as_func(arg1)
    ccall((:wasm_ref_as_func, libwasmtime), Ptr{wasm_func_t}, (Ptr{wasm_ref_t},), arg1)
end

function wasm_func_as_ref_const(arg1)
    ccall((:wasm_func_as_ref_const, libwasmtime), Ptr{wasm_ref_t}, (Ptr{wasm_func_t},), arg1)
end

function wasm_ref_as_func_const(arg1)
    ccall((:wasm_ref_as_func_const, libwasmtime), Ptr{wasm_func_t}, (Ptr{wasm_ref_t},), arg1)
end

# typedef own wasm_trap_t * ( * wasm_func_callback_t ) ( const wasm_val_vec_t * args , own wasm_val_vec_t * results )
const wasm_func_callback_t = Ptr{Cvoid}

# typedef own wasm_trap_t * ( * wasm_func_callback_with_env_t ) ( void * env , const wasm_val_vec_t * args , wasm_val_vec_t * results )
const wasm_func_callback_with_env_t = Ptr{Cvoid}

function wasm_func_new(arg1, arg2, arg3)
    ccall((:wasm_func_new, libwasmtime), Ptr{wasm_func_t}, (Ptr{wasm_store_t}, Ptr{wasm_functype_t}, wasm_func_callback_t), arg1, arg2, arg3)
end

function wasm_func_new_with_env(arg1, type, arg3, env, finalizer)
    ccall((:wasm_func_new_with_env, libwasmtime), Ptr{wasm_func_t}, (Ptr{wasm_store_t}, Ptr{wasm_functype_t}, wasm_func_callback_with_env_t, Ptr{Cvoid}, Ptr{Cvoid}), arg1, type, arg3, env, finalizer)
end

function wasm_func_type(arg1)
    ccall((:wasm_func_type, libwasmtime), Ptr{wasm_functype_t}, (Ptr{wasm_func_t},), arg1)
end

function wasm_func_param_arity(arg1)
    ccall((:wasm_func_param_arity, libwasmtime), Csize_t, (Ptr{wasm_func_t},), arg1)
end

function wasm_func_result_arity(arg1)
    ccall((:wasm_func_result_arity, libwasmtime), Csize_t, (Ptr{wasm_func_t},), arg1)
end

function wasm_func_call(arg1, args, results)
    ccall((:wasm_func_call, libwasmtime), Ptr{wasm_trap_t}, (Ptr{wasm_func_t}, Ptr{wasm_val_vec_t}, Ptr{wasm_val_vec_t}), arg1, args, results)
end

mutable struct wasm_global_t end

function wasm_global_delete(arg1)
    ccall((:wasm_global_delete, libwasmtime), Cvoid, (Ptr{wasm_global_t},), arg1)
end

function wasm_global_copy(arg1)
    ccall((:wasm_global_copy, libwasmtime), Ptr{wasm_global_t}, (Ptr{wasm_global_t},), arg1)
end

function wasm_global_same(arg1, arg2)
    ccall((:wasm_global_same, libwasmtime), Bool, (Ptr{wasm_global_t}, Ptr{wasm_global_t}), arg1, arg2)
end

function wasm_global_get_host_info(arg1)
    ccall((:wasm_global_get_host_info, libwasmtime), Ptr{Cvoid}, (Ptr{wasm_global_t},), arg1)
end

function wasm_global_set_host_info(arg1, arg2)
    ccall((:wasm_global_set_host_info, libwasmtime), Cvoid, (Ptr{wasm_global_t}, Ptr{Cvoid}), arg1, arg2)
end

function wasm_global_set_host_info_with_finalizer(arg1, arg2, arg3)
    ccall((:wasm_global_set_host_info_with_finalizer, libwasmtime), Cvoid, (Ptr{wasm_global_t}, Ptr{Cvoid}, Ptr{Cvoid}), arg1, arg2, arg3)
end

function wasm_global_as_ref(arg1)
    ccall((:wasm_global_as_ref, libwasmtime), Ptr{wasm_ref_t}, (Ptr{wasm_global_t},), arg1)
end

function wasm_ref_as_global(arg1)
    ccall((:wasm_ref_as_global, libwasmtime), Ptr{wasm_global_t}, (Ptr{wasm_ref_t},), arg1)
end

function wasm_global_as_ref_const(arg1)
    ccall((:wasm_global_as_ref_const, libwasmtime), Ptr{wasm_ref_t}, (Ptr{wasm_global_t},), arg1)
end

function wasm_ref_as_global_const(arg1)
    ccall((:wasm_ref_as_global_const, libwasmtime), Ptr{wasm_global_t}, (Ptr{wasm_ref_t},), arg1)
end

function wasm_global_new(arg1, arg2, arg3)
    ccall((:wasm_global_new, libwasmtime), Ptr{wasm_global_t}, (Ptr{wasm_store_t}, Ptr{wasm_globaltype_t}, Ptr{wasm_val_t}), arg1, arg2, arg3)
end

function wasm_global_type(arg1)
    ccall((:wasm_global_type, libwasmtime), Ptr{wasm_globaltype_t}, (Ptr{wasm_global_t},), arg1)
end

function wasm_global_get(arg1, out)
    ccall((:wasm_global_get, libwasmtime), Cvoid, (Ptr{wasm_global_t}, Ptr{wasm_val_t}), arg1, out)
end

function wasm_global_set(arg1, arg2)
    ccall((:wasm_global_set, libwasmtime), Cvoid, (Ptr{wasm_global_t}, Ptr{wasm_val_t}), arg1, arg2)
end

mutable struct wasm_table_t end

function wasm_table_delete(arg1)
    ccall((:wasm_table_delete, libwasmtime), Cvoid, (Ptr{wasm_table_t},), arg1)
end

function wasm_table_copy(arg1)
    ccall((:wasm_table_copy, libwasmtime), Ptr{wasm_table_t}, (Ptr{wasm_table_t},), arg1)
end

function wasm_table_same(arg1, arg2)
    ccall((:wasm_table_same, libwasmtime), Bool, (Ptr{wasm_table_t}, Ptr{wasm_table_t}), arg1, arg2)
end

function wasm_table_get_host_info(arg1)
    ccall((:wasm_table_get_host_info, libwasmtime), Ptr{Cvoid}, (Ptr{wasm_table_t},), arg1)
end

function wasm_table_set_host_info(arg1, arg2)
    ccall((:wasm_table_set_host_info, libwasmtime), Cvoid, (Ptr{wasm_table_t}, Ptr{Cvoid}), arg1, arg2)
end

function wasm_table_set_host_info_with_finalizer(arg1, arg2, arg3)
    ccall((:wasm_table_set_host_info_with_finalizer, libwasmtime), Cvoid, (Ptr{wasm_table_t}, Ptr{Cvoid}, Ptr{Cvoid}), arg1, arg2, arg3)
end

function wasm_table_as_ref(arg1)
    ccall((:wasm_table_as_ref, libwasmtime), Ptr{wasm_ref_t}, (Ptr{wasm_table_t},), arg1)
end

function wasm_ref_as_table(arg1)
    ccall((:wasm_ref_as_table, libwasmtime), Ptr{wasm_table_t}, (Ptr{wasm_ref_t},), arg1)
end

function wasm_table_as_ref_const(arg1)
    ccall((:wasm_table_as_ref_const, libwasmtime), Ptr{wasm_ref_t}, (Ptr{wasm_table_t},), arg1)
end

function wasm_ref_as_table_const(arg1)
    ccall((:wasm_ref_as_table_const, libwasmtime), Ptr{wasm_table_t}, (Ptr{wasm_ref_t},), arg1)
end

const wasm_table_size_t = UInt32

function wasm_table_new(arg1, arg2, init)
    ccall((:wasm_table_new, libwasmtime), Ptr{wasm_table_t}, (Ptr{wasm_store_t}, Ptr{wasm_tabletype_t}, Ptr{wasm_ref_t}), arg1, arg2, init)
end

function wasm_table_type(arg1)
    ccall((:wasm_table_type, libwasmtime), Ptr{wasm_tabletype_t}, (Ptr{wasm_table_t},), arg1)
end

function wasm_table_get(arg1, index)
    ccall((:wasm_table_get, libwasmtime), Ptr{wasm_ref_t}, (Ptr{wasm_table_t}, wasm_table_size_t), arg1, index)
end

function wasm_table_set(arg1, index, arg3)
    ccall((:wasm_table_set, libwasmtime), Bool, (Ptr{wasm_table_t}, wasm_table_size_t, Ptr{wasm_ref_t}), arg1, index, arg3)
end

function wasm_table_size(arg1)
    ccall((:wasm_table_size, libwasmtime), wasm_table_size_t, (Ptr{wasm_table_t},), arg1)
end

function wasm_table_grow(arg1, delta, init)
    ccall((:wasm_table_grow, libwasmtime), Bool, (Ptr{wasm_table_t}, wasm_table_size_t, Ptr{wasm_ref_t}), arg1, delta, init)
end

mutable struct wasm_memory_t end

function wasm_memory_delete(arg1)
    ccall((:wasm_memory_delete, libwasmtime), Cvoid, (Ptr{wasm_memory_t},), arg1)
end

function wasm_memory_copy(arg1)
    ccall((:wasm_memory_copy, libwasmtime), Ptr{wasm_memory_t}, (Ptr{wasm_memory_t},), arg1)
end

function wasm_memory_same(arg1, arg2)
    ccall((:wasm_memory_same, libwasmtime), Bool, (Ptr{wasm_memory_t}, Ptr{wasm_memory_t}), arg1, arg2)
end

function wasm_memory_get_host_info(arg1)
    ccall((:wasm_memory_get_host_info, libwasmtime), Ptr{Cvoid}, (Ptr{wasm_memory_t},), arg1)
end

function wasm_memory_set_host_info(arg1, arg2)
    ccall((:wasm_memory_set_host_info, libwasmtime), Cvoid, (Ptr{wasm_memory_t}, Ptr{Cvoid}), arg1, arg2)
end

function wasm_memory_set_host_info_with_finalizer(arg1, arg2, arg3)
    ccall((:wasm_memory_set_host_info_with_finalizer, libwasmtime), Cvoid, (Ptr{wasm_memory_t}, Ptr{Cvoid}, Ptr{Cvoid}), arg1, arg2, arg3)
end

function wasm_memory_as_ref(arg1)
    ccall((:wasm_memory_as_ref, libwasmtime), Ptr{wasm_ref_t}, (Ptr{wasm_memory_t},), arg1)
end

function wasm_ref_as_memory(arg1)
    ccall((:wasm_ref_as_memory, libwasmtime), Ptr{wasm_memory_t}, (Ptr{wasm_ref_t},), arg1)
end

function wasm_memory_as_ref_const(arg1)
    ccall((:wasm_memory_as_ref_const, libwasmtime), Ptr{wasm_ref_t}, (Ptr{wasm_memory_t},), arg1)
end

function wasm_ref_as_memory_const(arg1)
    ccall((:wasm_ref_as_memory_const, libwasmtime), Ptr{wasm_memory_t}, (Ptr{wasm_ref_t},), arg1)
end

const wasm_memory_pages_t = UInt32

function wasm_memory_new(arg1, arg2)
    ccall((:wasm_memory_new, libwasmtime), Ptr{wasm_memory_t}, (Ptr{wasm_store_t}, Ptr{wasm_memorytype_t}), arg1, arg2)
end

function wasm_memory_type(arg1)
    ccall((:wasm_memory_type, libwasmtime), Ptr{wasm_memorytype_t}, (Ptr{wasm_memory_t},), arg1)
end

function wasm_memory_data(arg1)
    ccall((:wasm_memory_data, libwasmtime), Ptr{byte_t}, (Ptr{wasm_memory_t},), arg1)
end

function wasm_memory_data_size(arg1)
    ccall((:wasm_memory_data_size, libwasmtime), Csize_t, (Ptr{wasm_memory_t},), arg1)
end

function wasm_memory_size(arg1)
    ccall((:wasm_memory_size, libwasmtime), wasm_memory_pages_t, (Ptr{wasm_memory_t},), arg1)
end

function wasm_memory_grow(arg1, delta)
    ccall((:wasm_memory_grow, libwasmtime), Bool, (Ptr{wasm_memory_t}, wasm_memory_pages_t), arg1, delta)
end

mutable struct wasm_extern_t end

function wasm_extern_delete(arg1)
    ccall((:wasm_extern_delete, libwasmtime), Cvoid, (Ptr{wasm_extern_t},), arg1)
end

function wasm_extern_copy(arg1)
    ccall((:wasm_extern_copy, libwasmtime), Ptr{wasm_extern_t}, (Ptr{wasm_extern_t},), arg1)
end

function wasm_extern_same(arg1, arg2)
    ccall((:wasm_extern_same, libwasmtime), Bool, (Ptr{wasm_extern_t}, Ptr{wasm_extern_t}), arg1, arg2)
end

function wasm_extern_get_host_info(arg1)
    ccall((:wasm_extern_get_host_info, libwasmtime), Ptr{Cvoid}, (Ptr{wasm_extern_t},), arg1)
end

function wasm_extern_set_host_info(arg1, arg2)
    ccall((:wasm_extern_set_host_info, libwasmtime), Cvoid, (Ptr{wasm_extern_t}, Ptr{Cvoid}), arg1, arg2)
end

function wasm_extern_set_host_info_with_finalizer(arg1, arg2, arg3)
    ccall((:wasm_extern_set_host_info_with_finalizer, libwasmtime), Cvoid, (Ptr{wasm_extern_t}, Ptr{Cvoid}, Ptr{Cvoid}), arg1, arg2, arg3)
end

function wasm_extern_as_ref(arg1)
    ccall((:wasm_extern_as_ref, libwasmtime), Ptr{wasm_ref_t}, (Ptr{wasm_extern_t},), arg1)
end

function wasm_ref_as_extern(arg1)
    ccall((:wasm_ref_as_extern, libwasmtime), Ptr{wasm_extern_t}, (Ptr{wasm_ref_t},), arg1)
end

function wasm_extern_as_ref_const(arg1)
    ccall((:wasm_extern_as_ref_const, libwasmtime), Ptr{wasm_ref_t}, (Ptr{wasm_extern_t},), arg1)
end

function wasm_ref_as_extern_const(arg1)
    ccall((:wasm_ref_as_extern_const, libwasmtime), Ptr{wasm_extern_t}, (Ptr{wasm_ref_t},), arg1)
end

mutable struct wasm_extern_vec_t
    size::Csize_t
    data::Ptr{Ptr{wasm_extern_t}}
end

function wasm_extern_vec_new_empty(out)
    ccall((:wasm_extern_vec_new_empty, libwasmtime), Cvoid, (Ptr{wasm_extern_vec_t},), out)
end

function wasm_extern_vec_new_uninitialized(out, arg2)
    ccall((:wasm_extern_vec_new_uninitialized, libwasmtime), Cvoid, (Ptr{wasm_extern_vec_t}, Csize_t), out, arg2)
end

function wasm_extern_vec_new(out, arg2, arg3)
    ccall((:wasm_extern_vec_new, libwasmtime), Cvoid, (Ptr{wasm_extern_vec_t}, Csize_t, Ptr{Ptr{wasm_extern_t}}), out, arg2, arg3)
end

function wasm_extern_vec_copy(out, arg2)
    ccall((:wasm_extern_vec_copy, libwasmtime), Cvoid, (Ptr{wasm_extern_vec_t}, Ptr{wasm_extern_vec_t}), out, arg2)
end

function wasm_extern_vec_delete(arg1)
    ccall((:wasm_extern_vec_delete, libwasmtime), Cvoid, (Ptr{wasm_extern_vec_t},), arg1)
end

function wasm_extern_kind(arg1)
    ccall((:wasm_extern_kind, libwasmtime), wasm_externkind_t, (Ptr{wasm_extern_t},), arg1)
end

function wasm_extern_type(arg1)
    ccall((:wasm_extern_type, libwasmtime), Ptr{wasm_externtype_t}, (Ptr{wasm_extern_t},), arg1)
end

function wasm_func_as_extern(arg1)
    ccall((:wasm_func_as_extern, libwasmtime), Ptr{wasm_extern_t}, (Ptr{wasm_func_t},), arg1)
end

function wasm_global_as_extern(arg1)
    ccall((:wasm_global_as_extern, libwasmtime), Ptr{wasm_extern_t}, (Ptr{wasm_global_t},), arg1)
end

function wasm_table_as_extern(arg1)
    ccall((:wasm_table_as_extern, libwasmtime), Ptr{wasm_extern_t}, (Ptr{wasm_table_t},), arg1)
end

function wasm_memory_as_extern(arg1)
    ccall((:wasm_memory_as_extern, libwasmtime), Ptr{wasm_extern_t}, (Ptr{wasm_memory_t},), arg1)
end

function wasm_extern_as_func(arg1)
    ccall((:wasm_extern_as_func, libwasmtime), Ptr{wasm_func_t}, (Ptr{wasm_extern_t},), arg1)
end

function wasm_extern_as_global(arg1)
    ccall((:wasm_extern_as_global, libwasmtime), Ptr{wasm_global_t}, (Ptr{wasm_extern_t},), arg1)
end

function wasm_extern_as_table(arg1)
    ccall((:wasm_extern_as_table, libwasmtime), Ptr{wasm_table_t}, (Ptr{wasm_extern_t},), arg1)
end

function wasm_extern_as_memory(arg1)
    ccall((:wasm_extern_as_memory, libwasmtime), Ptr{wasm_memory_t}, (Ptr{wasm_extern_t},), arg1)
end

function wasm_func_as_extern_const(arg1)
    ccall((:wasm_func_as_extern_const, libwasmtime), Ptr{wasm_extern_t}, (Ptr{wasm_func_t},), arg1)
end

function wasm_global_as_extern_const(arg1)
    ccall((:wasm_global_as_extern_const, libwasmtime), Ptr{wasm_extern_t}, (Ptr{wasm_global_t},), arg1)
end

function wasm_table_as_extern_const(arg1)
    ccall((:wasm_table_as_extern_const, libwasmtime), Ptr{wasm_extern_t}, (Ptr{wasm_table_t},), arg1)
end

function wasm_memory_as_extern_const(arg1)
    ccall((:wasm_memory_as_extern_const, libwasmtime), Ptr{wasm_extern_t}, (Ptr{wasm_memory_t},), arg1)
end

function wasm_extern_as_func_const(arg1)
    ccall((:wasm_extern_as_func_const, libwasmtime), Ptr{wasm_func_t}, (Ptr{wasm_extern_t},), arg1)
end

function wasm_extern_as_global_const(arg1)
    ccall((:wasm_extern_as_global_const, libwasmtime), Ptr{wasm_global_t}, (Ptr{wasm_extern_t},), arg1)
end

function wasm_extern_as_table_const(arg1)
    ccall((:wasm_extern_as_table_const, libwasmtime), Ptr{wasm_table_t}, (Ptr{wasm_extern_t},), arg1)
end

function wasm_extern_as_memory_const(arg1)
    ccall((:wasm_extern_as_memory_const, libwasmtime), Ptr{wasm_memory_t}, (Ptr{wasm_extern_t},), arg1)
end

function wasm_instance_delete(arg1)
    ccall((:wasm_instance_delete, libwasmtime), Cvoid, (Ptr{wasm_instance_t},), arg1)
end

function wasm_instance_copy(arg1)
    ccall((:wasm_instance_copy, libwasmtime), Ptr{wasm_instance_t}, (Ptr{wasm_instance_t},), arg1)
end

function wasm_instance_same(arg1, arg2)
    ccall((:wasm_instance_same, libwasmtime), Bool, (Ptr{wasm_instance_t}, Ptr{wasm_instance_t}), arg1, arg2)
end

function wasm_instance_get_host_info(arg1)
    ccall((:wasm_instance_get_host_info, libwasmtime), Ptr{Cvoid}, (Ptr{wasm_instance_t},), arg1)
end

function wasm_instance_set_host_info(arg1, arg2)
    ccall((:wasm_instance_set_host_info, libwasmtime), Cvoid, (Ptr{wasm_instance_t}, Ptr{Cvoid}), arg1, arg2)
end

function wasm_instance_set_host_info_with_finalizer(arg1, arg2, arg3)
    ccall((:wasm_instance_set_host_info_with_finalizer, libwasmtime), Cvoid, (Ptr{wasm_instance_t}, Ptr{Cvoid}, Ptr{Cvoid}), arg1, arg2, arg3)
end

function wasm_instance_as_ref(arg1)
    ccall((:wasm_instance_as_ref, libwasmtime), Ptr{wasm_ref_t}, (Ptr{wasm_instance_t},), arg1)
end

function wasm_ref_as_instance(arg1)
    ccall((:wasm_ref_as_instance, libwasmtime), Ptr{wasm_instance_t}, (Ptr{wasm_ref_t},), arg1)
end

function wasm_instance_as_ref_const(arg1)
    ccall((:wasm_instance_as_ref_const, libwasmtime), Ptr{wasm_ref_t}, (Ptr{wasm_instance_t},), arg1)
end

function wasm_ref_as_instance_const(arg1)
    ccall((:wasm_ref_as_instance_const, libwasmtime), Ptr{wasm_instance_t}, (Ptr{wasm_ref_t},), arg1)
end

function wasm_instance_new(arg1, arg2, imports, arg4)
    ccall((:wasm_instance_new, libwasmtime), Ptr{wasm_instance_t}, (Ptr{wasm_store_t}, Ptr{wasm_module_t}, Ptr{wasm_extern_vec_t}, Ptr{Ptr{wasm_trap_t}}), arg1, arg2, imports, arg4)
end

function wasm_instance_exports(arg1, out)
    ccall((:wasm_instance_exports, libwasmtime), Cvoid, (Ptr{wasm_instance_t}, Ptr{wasm_extern_vec_t}), arg1, out)
end

function wasm_valtype_new_i32()
    ccall((:wasm_valtype_new_i32, libwasmtime), Ptr{wasm_valtype_t}, ())
end

function wasm_valtype_new_i64()
    ccall((:wasm_valtype_new_i64, libwasmtime), Ptr{wasm_valtype_t}, ())
end

function wasm_valtype_new_f32()
    ccall((:wasm_valtype_new_f32, libwasmtime), Ptr{wasm_valtype_t}, ())
end

function wasm_valtype_new_f64()
    ccall((:wasm_valtype_new_f64, libwasmtime), Ptr{wasm_valtype_t}, ())
end

function wasm_valtype_new_anyref()
    ccall((:wasm_valtype_new_anyref, libwasmtime), Ptr{wasm_valtype_t}, ())
end

function wasm_valtype_new_funcref()
    ccall((:wasm_valtype_new_funcref, libwasmtime), Ptr{wasm_valtype_t}, ())
end

function wasm_functype_new_0_0()
    ccall((:wasm_functype_new_0_0, libwasmtime), Ptr{wasm_functype_t}, ())
end

function wasm_functype_new_1_0(p)
    ccall((:wasm_functype_new_1_0, libwasmtime), Ptr{wasm_functype_t}, (Ptr{wasm_valtype_t},), p)
end

function wasm_functype_new_2_0(p1, p2)
    ccall((:wasm_functype_new_2_0, libwasmtime), Ptr{wasm_functype_t}, (Ptr{wasm_valtype_t}, Ptr{wasm_valtype_t}), p1, p2)
end

function wasm_functype_new_3_0(p1, p2, p3)
    ccall((:wasm_functype_new_3_0, libwasmtime), Ptr{wasm_functype_t}, (Ptr{wasm_valtype_t}, Ptr{wasm_valtype_t}, Ptr{wasm_valtype_t}), p1, p2, p3)
end

function wasm_functype_new_0_1(r)
    ccall((:wasm_functype_new_0_1, libwasmtime), Ptr{wasm_functype_t}, (Ptr{wasm_valtype_t},), r)
end

function wasm_functype_new_1_1(p, r)
    ccall((:wasm_functype_new_1_1, libwasmtime), Ptr{wasm_functype_t}, (Ptr{wasm_valtype_t}, Ptr{wasm_valtype_t}), p, r)
end

function wasm_functype_new_2_1(p1, p2, r)
    ccall((:wasm_functype_new_2_1, libwasmtime), Ptr{wasm_functype_t}, (Ptr{wasm_valtype_t}, Ptr{wasm_valtype_t}, Ptr{wasm_valtype_t}), p1, p2, r)
end

function wasm_functype_new_3_1(p1, p2, p3, r)
    ccall((:wasm_functype_new_3_1, libwasmtime), Ptr{wasm_functype_t}, (Ptr{wasm_valtype_t}, Ptr{wasm_valtype_t}, Ptr{wasm_valtype_t}, Ptr{wasm_valtype_t}), p1, p2, p3, r)
end

function wasm_functype_new_0_2(r1, r2)
    ccall((:wasm_functype_new_0_2, libwasmtime), Ptr{wasm_functype_t}, (Ptr{wasm_valtype_t}, Ptr{wasm_valtype_t}), r1, r2)
end

function wasm_functype_new_1_2(p, r1, r2)
    ccall((:wasm_functype_new_1_2, libwasmtime), Ptr{wasm_functype_t}, (Ptr{wasm_valtype_t}, Ptr{wasm_valtype_t}, Ptr{wasm_valtype_t}), p, r1, r2)
end

function wasm_functype_new_2_2(p1, p2, r1, r2)
    ccall((:wasm_functype_new_2_2, libwasmtime), Ptr{wasm_functype_t}, (Ptr{wasm_valtype_t}, Ptr{wasm_valtype_t}, Ptr{wasm_valtype_t}, Ptr{wasm_valtype_t}), p1, p2, r1, r2)
end

function wasm_functype_new_3_2(p1, p2, p3, r1, r2)
    ccall((:wasm_functype_new_3_2, libwasmtime), Ptr{wasm_functype_t}, (Ptr{wasm_valtype_t}, Ptr{wasm_valtype_t}, Ptr{wasm_valtype_t}, Ptr{wasm_valtype_t}, Ptr{wasm_valtype_t}), p1, p2, p3, r1, r2)
end

function wasm_val_init_ptr(out, p)
    ccall((:wasm_val_init_ptr, libwasmtime), Cvoid, (Ptr{wasm_val_t}, Ptr{Cvoid}), out, p)
end

function wasm_val_ptr(val)
    ccall((:wasm_val_ptr, libwasmtime), Ptr{Cvoid}, (Ptr{wasm_val_t},), val)
end

mutable struct wasmtime_error end

const wasmtime_error_t = wasmtime_error

function wasmtime_error_delete(error)
    ccall((:wasmtime_error_delete, libwasmtime), Cvoid, (Ptr{wasmtime_error_t},), error)
end

function wasmtime_error_message(error, message)
    ccall((:wasmtime_error_message, libwasmtime), Cvoid, (Ptr{wasmtime_error_t}, Ptr{wasm_name_t}), error, message)
end

const wasmtime_strategy_t = UInt8

@cenum wasmtime_strategy_enum::UInt32 begin
    WASMTIME_STRATEGY_AUTO = 0
    WASMTIME_STRATEGY_CRANELIFT = 1
end

const wasmtime_opt_level_t = UInt8

@cenum wasmtime_opt_level_enum::UInt32 begin
    WASMTIME_OPT_LEVEL_NONE = 0
    WASMTIME_OPT_LEVEL_SPEED = 1
    WASMTIME_OPT_LEVEL_SPEED_AND_SIZE = 2
end

const wasmtime_profiling_strategy_t = UInt8

@cenum wasmtime_profiling_strategy_enum::UInt32 begin
    WASMTIME_PROFILING_STRATEGY_NONE = 0
    WASMTIME_PROFILING_STRATEGY_JITDUMP = 1
    WASMTIME_PROFILING_STRATEGY_VTUNE = 2
end

function wasmtime_config_debug_info_set(arg1, arg2)
    ccall((:wasmtime_config_debug_info_set, libwasmtime), Cvoid, (Ptr{wasm_config_t}, Bool), arg1, arg2)
end

function wasmtime_config_interruptable_set(arg1, arg2)
    ccall((:wasmtime_config_interruptable_set, libwasmtime), Cvoid, (Ptr{wasm_config_t}, Bool), arg1, arg2)
end

function wasmtime_config_consume_fuel_set(arg1, arg2)
    ccall((:wasmtime_config_consume_fuel_set, libwasmtime), Cvoid, (Ptr{wasm_config_t}, Bool), arg1, arg2)
end

function wasmtime_config_max_wasm_stack_set(arg1, arg2)
    ccall((:wasmtime_config_max_wasm_stack_set, libwasmtime), Cvoid, (Ptr{wasm_config_t}, Csize_t), arg1, arg2)
end

function wasmtime_config_wasm_threads_set(arg1, arg2)
    ccall((:wasmtime_config_wasm_threads_set, libwasmtime), Cvoid, (Ptr{wasm_config_t}, Bool), arg1, arg2)
end

function wasmtime_config_wasm_reference_types_set(arg1, arg2)
    ccall((:wasmtime_config_wasm_reference_types_set, libwasmtime), Cvoid, (Ptr{wasm_config_t}, Bool), arg1, arg2)
end

function wasmtime_config_wasm_simd_set(arg1, arg2)
    ccall((:wasmtime_config_wasm_simd_set, libwasmtime), Cvoid, (Ptr{wasm_config_t}, Bool), arg1, arg2)
end

function wasmtime_config_wasm_bulk_memory_set(arg1, arg2)
    ccall((:wasmtime_config_wasm_bulk_memory_set, libwasmtime), Cvoid, (Ptr{wasm_config_t}, Bool), arg1, arg2)
end

function wasmtime_config_wasm_multi_value_set(arg1, arg2)
    ccall((:wasmtime_config_wasm_multi_value_set, libwasmtime), Cvoid, (Ptr{wasm_config_t}, Bool), arg1, arg2)
end

function wasmtime_config_wasm_multi_memory_set(arg1, arg2)
    ccall((:wasmtime_config_wasm_multi_memory_set, libwasmtime), Cvoid, (Ptr{wasm_config_t}, Bool), arg1, arg2)
end

function wasmtime_config_wasm_module_linking_set(arg1, arg2)
    ccall((:wasmtime_config_wasm_module_linking_set, libwasmtime), Cvoid, (Ptr{wasm_config_t}, Bool), arg1, arg2)
end

function wasmtime_config_wasm_memory64_set(arg1, arg2)
    ccall((:wasmtime_config_wasm_memory64_set, libwasmtime), Cvoid, (Ptr{wasm_config_t}, Bool), arg1, arg2)
end

function wasmtime_config_strategy_set(arg1, arg2)
    ccall((:wasmtime_config_strategy_set, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasm_config_t}, wasmtime_strategy_t), arg1, arg2)
end

function wasmtime_config_cranelift_debug_verifier_set(arg1, arg2)
    ccall((:wasmtime_config_cranelift_debug_verifier_set, libwasmtime), Cvoid, (Ptr{wasm_config_t}, Bool), arg1, arg2)
end

function wasmtime_config_cranelift_opt_level_set(arg1, arg2)
    ccall((:wasmtime_config_cranelift_opt_level_set, libwasmtime), Cvoid, (Ptr{wasm_config_t}, wasmtime_opt_level_t), arg1, arg2)
end

function wasmtime_config_profiler_set(arg1, arg2)
    ccall((:wasmtime_config_profiler_set, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasm_config_t}, wasmtime_profiling_strategy_t), arg1, arg2)
end

function wasmtime_config_static_memory_maximum_size_set(arg1, arg2)
    ccall((:wasmtime_config_static_memory_maximum_size_set, libwasmtime), Cvoid, (Ptr{wasm_config_t}, UInt64), arg1, arg2)
end

function wasmtime_config_static_memory_guard_size_set(arg1, arg2)
    ccall((:wasmtime_config_static_memory_guard_size_set, libwasmtime), Cvoid, (Ptr{wasm_config_t}, UInt64), arg1, arg2)
end

function wasmtime_config_dynamic_memory_guard_size_set(arg1, arg2)
    ccall((:wasmtime_config_dynamic_memory_guard_size_set, libwasmtime), Cvoid, (Ptr{wasm_config_t}, UInt64), arg1, arg2)
end

function wasmtime_config_cache_config_load(arg1, arg2)
    ccall((:wasmtime_config_cache_config_load, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasm_config_t}, Cstring), arg1, arg2)
end

mutable struct wasmtime_moduletype end

const wasmtime_moduletype_t = wasmtime_moduletype

function wasmtime_moduletype_delete(ty)
    ccall((:wasmtime_moduletype_delete, libwasmtime), Cvoid, (Ptr{wasmtime_moduletype_t},), ty)
end

function wasmtime_moduletype_imports(arg1, out)
    ccall((:wasmtime_moduletype_imports, libwasmtime), Cvoid, (Ptr{wasmtime_moduletype_t}, Ptr{wasm_importtype_vec_t}), arg1, out)
end

function wasmtime_moduletype_exports(arg1, out)
    ccall((:wasmtime_moduletype_exports, libwasmtime), Cvoid, (Ptr{wasmtime_moduletype_t}, Ptr{wasm_exporttype_vec_t}), arg1, out)
end

function wasmtime_moduletype_as_externtype(arg1)
    ccall((:wasmtime_moduletype_as_externtype, libwasmtime), Ptr{wasm_externtype_t}, (Ptr{wasmtime_moduletype_t},), arg1)
end

function wasmtime_externtype_as_moduletype(arg1)
    ccall((:wasmtime_externtype_as_moduletype, libwasmtime), Ptr{wasmtime_moduletype_t}, (Ptr{wasm_externtype_t},), arg1)
end

mutable struct wasmtime_module end

const wasmtime_module_t = wasmtime_module

function wasmtime_module_new(engine, wasm, wasm_len, ret)
    ccall((:wasmtime_module_new, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasm_engine_t}, Ptr{UInt8}, Csize_t, Ptr{Ptr{wasmtime_module_t}}), engine, wasm, wasm_len, ret)
end

function wasmtime_module_delete(m)
    ccall((:wasmtime_module_delete, libwasmtime), Cvoid, (Ptr{wasmtime_module_t},), m)
end

function wasmtime_module_clone(m)
    ccall((:wasmtime_module_clone, libwasmtime), Ptr{wasmtime_module_t}, (Ptr{wasmtime_module_t},), m)
end

function wasmtime_module_validate(engine, wasm, wasm_len)
    ccall((:wasmtime_module_validate, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasm_engine_t}, Ptr{UInt8}, Csize_t), engine, wasm, wasm_len)
end

function wasmtime_module_type(arg1)
    ccall((:wasmtime_module_type, libwasmtime), Ptr{wasmtime_moduletype_t}, (Ptr{wasmtime_module_t},), arg1)
end

function wasmtime_module_serialize(_module, ret)
    ccall((:wasmtime_module_serialize, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasmtime_module_t}, Ptr{wasm_byte_vec_t}), _module, ret)
end

function wasmtime_module_deserialize(engine, bytes, bytes_len, ret)
    ccall((:wasmtime_module_deserialize, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasm_engine_t}, Ptr{UInt8}, Csize_t, Ptr{Ptr{wasmtime_module_t}}), engine, bytes, bytes_len, ret)
end

function wasmtime_module_deserialize_file(engine, path, ret)
    ccall((:wasmtime_module_deserialize_file, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasm_engine_t}, Cstring, Ptr{Ptr{wasmtime_module_t}}), engine, path, ret)
end

mutable struct wasmtime_store end

const wasmtime_store_t = wasmtime_store

mutable struct wasmtime_context end

const wasmtime_context_t = wasmtime_context

function wasmtime_store_new(engine, data, finalizer)
    ccall((:wasmtime_store_new, libwasmtime), Ptr{wasmtime_store_t}, (Ptr{wasm_engine_t}, Ptr{Cvoid}, Ptr{Cvoid}), engine, data, finalizer)
end

function wasmtime_store_context(store)
    ccall((:wasmtime_store_context, libwasmtime), Ptr{wasmtime_context_t}, (Ptr{wasmtime_store_t},), store)
end

function wasmtime_store_delete(store)
    ccall((:wasmtime_store_delete, libwasmtime), Cvoid, (Ptr{wasmtime_store_t},), store)
end

function wasmtime_context_get_data(context)
    ccall((:wasmtime_context_get_data, libwasmtime), Ptr{Cvoid}, (Ptr{wasmtime_context_t},), context)
end

function wasmtime_context_set_data(context, data)
    ccall((:wasmtime_context_set_data, libwasmtime), Cvoid, (Ptr{wasmtime_context_t}, Ptr{Cvoid}), context, data)
end

function wasmtime_context_gc(context)
    ccall((:wasmtime_context_gc, libwasmtime), Cvoid, (Ptr{wasmtime_context_t},), context)
end

function wasmtime_context_add_fuel(store, fuel)
    ccall((:wasmtime_context_add_fuel, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasmtime_context_t}, UInt64), store, fuel)
end

function wasmtime_context_fuel_consumed(context, fuel)
    ccall((:wasmtime_context_fuel_consumed, libwasmtime), Bool, (Ptr{wasmtime_context_t}, Ptr{UInt64}), context, fuel)
end

function wasmtime_context_consume_fuel(context, fuel, remaining)
    ccall((:wasmtime_context_consume_fuel, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasmtime_context_t}, UInt64, Ptr{UInt64}), context, fuel, remaining)
end

mutable struct wasi_config_t end

function wasmtime_context_set_wasi(context, wasi)
    ccall((:wasmtime_context_set_wasi, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasmtime_context_t}, Ptr{wasi_config_t}), context, wasi)
end

mutable struct wasmtime_interrupt_handle end

const wasmtime_interrupt_handle_t = wasmtime_interrupt_handle

function wasmtime_interrupt_handle_new(context)
    ccall((:wasmtime_interrupt_handle_new, libwasmtime), Ptr{wasmtime_interrupt_handle_t}, (Ptr{wasmtime_context_t},), context)
end

function wasmtime_interrupt_handle_interrupt(handle)
    ccall((:wasmtime_interrupt_handle_interrupt, libwasmtime), Cvoid, (Ptr{wasmtime_interrupt_handle_t},), handle)
end

function wasmtime_interrupt_handle_delete(handle)
    ccall((:wasmtime_interrupt_handle_delete, libwasmtime), Cvoid, (Ptr{wasmtime_interrupt_handle_t},), handle)
end

mutable struct wasmtime_func
    store_id::UInt64
    index::Csize_t
end

const wasmtime_func_t = wasmtime_func

mutable struct wasmtime_table
    store_id::UInt64
    index::Csize_t
end

const wasmtime_table_t = wasmtime_table

mutable struct wasmtime_memory
    store_id::UInt64
    index::Csize_t
end

const wasmtime_memory_t = wasmtime_memory

mutable struct wasmtime_instance
    store_id::UInt64
    index::Csize_t
end

const wasmtime_instance_t = wasmtime_instance

mutable struct wasmtime_global
    store_id::UInt64
    index::Csize_t
end

const wasmtime_global_t = wasmtime_global

const wasmtime_extern_kind_t = UInt8

struct wasmtime_extern_union
    data::NTuple{16, UInt8}
end

function Base.getproperty(x::Ptr{wasmtime_extern_union}, f::Symbol)
    f === :func && return Ptr{wasmtime_func_t}(x + 0)
    f === :_global && return Ptr{wasmtime_global_t}(x + 0)
    f === :table && return Ptr{wasmtime_table_t}(x + 0)
    f === :memory && return Ptr{wasmtime_memory_t}(x + 0)
    f === :instance && return Ptr{wasmtime_instance_t}(x + 0)
    f === :_module && return Ptr{Ptr{wasmtime_module_t}}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::wasmtime_extern_union, f::Symbol)
    r = Ref{wasmtime_extern_union}(x)
    ptr = Base.unsafe_convert(Ptr{wasmtime_extern_union}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{wasmtime_extern_union}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const wasmtime_extern_union_t = wasmtime_extern_union

mutable struct wasmtime_extern
    kind::wasmtime_extern_kind_t
    var"##pad0#278"::NTuple{7, UInt8}
    of::wasmtime_extern_union_t
    wasmtime_extern(kind, of) = new(kind, Tuple((zero(UInt8) for _ = 1:7)), of)
end

const wasmtime_extern_t = wasmtime_extern

function wasmtime_extern_delete(val)
    ccall((:wasmtime_extern_delete, libwasmtime), Cvoid, (Ptr{wasmtime_extern_t},), val)
end

function wasmtime_extern_type(context, val)
    ccall((:wasmtime_extern_type, libwasmtime), Ptr{wasm_externtype_t}, (Ptr{wasmtime_context_t}, Ptr{wasmtime_extern_t}), context, val)
end

mutable struct wasmtime_externref end

const wasmtime_externref_t = wasmtime_externref

function wasmtime_externref_new(data, finalizer)
    ccall((:wasmtime_externref_new, libwasmtime), Ptr{wasmtime_externref_t}, (Ptr{Cvoid}, Ptr{Cvoid}), data, finalizer)
end

function wasmtime_externref_data(data)
    ccall((:wasmtime_externref_data, libwasmtime), Ptr{Cvoid}, (Ptr{wasmtime_externref_t},), data)
end

function wasmtime_externref_clone(ref)
    ccall((:wasmtime_externref_clone, libwasmtime), Ptr{wasmtime_externref_t}, (Ptr{wasmtime_externref_t},), ref)
end

function wasmtime_externref_delete(ref)
    ccall((:wasmtime_externref_delete, libwasmtime), Cvoid, (Ptr{wasmtime_externref_t},), ref)
end

function wasmtime_externref_from_raw(context, raw)
    ccall((:wasmtime_externref_from_raw, libwasmtime), Ptr{wasmtime_externref_t}, (Ptr{wasmtime_context_t}, Csize_t), context, raw)
end

function wasmtime_externref_to_raw(context, ref)
    ccall((:wasmtime_externref_to_raw, libwasmtime), Csize_t, (Ptr{wasmtime_context_t}, Ptr{wasmtime_externref_t}), context, ref)
end

const wasmtime_valkind_t = UInt8

const wasmtime_v128 = NTuple{16, UInt8}

struct wasmtime_valunion
    data::NTuple{16, UInt8}
end

function Base.getproperty(x::Ptr{wasmtime_valunion}, f::Symbol)
    f === :i32 && return Ptr{Int32}(x + 0)
    f === :i64 && return Ptr{Int64}(x + 0)
    f === :f32 && return Ptr{float32_t}(x + 0)
    f === :f64 && return Ptr{float64_t}(x + 0)
    f === :funcref && return Ptr{wasmtime_func_t}(x + 0)
    f === :externref && return Ptr{Ptr{wasmtime_externref_t}}(x + 0)
    f === :v128 && return Ptr{wasmtime_v128}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::wasmtime_valunion, f::Symbol)
    r = Ref{wasmtime_valunion}(x)
    ptr = Base.unsafe_convert(Ptr{wasmtime_valunion}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{wasmtime_valunion}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const wasmtime_valunion_t = wasmtime_valunion

struct wasmtime_val_raw
    data::NTuple{16, UInt8}
end

function Base.getproperty(x::Ptr{wasmtime_val_raw}, f::Symbol)
    f === :i32 && return Ptr{Int32}(x + 0)
    f === :i64 && return Ptr{Int64}(x + 0)
    f === :f32 && return Ptr{float32_t}(x + 0)
    f === :f64 && return Ptr{float64_t}(x + 0)
    f === :v128 && return Ptr{wasmtime_v128}(x + 0)
    f === :funcref && return Ptr{Csize_t}(x + 0)
    f === :externref && return Ptr{Csize_t}(x + 0)
    return getfield(x, f)
end

function Base.getproperty(x::wasmtime_val_raw, f::Symbol)
    r = Ref{wasmtime_val_raw}(x)
    ptr = Base.unsafe_convert(Ptr{wasmtime_val_raw}, r)
    fptr = getproperty(ptr, f)
    GC.@preserve r unsafe_load(fptr)
end

function Base.setproperty!(x::Ptr{wasmtime_val_raw}, f::Symbol, v)
    unsafe_store!(getproperty(x, f), v)
end

const wasmtime_val_raw_t = wasmtime_val_raw

struct wasmtime_val
    kind::wasmtime_valkind_t
    var"##pad0#279"::NTuple{7, UInt8}
    of::wasmtime_valunion_t
    wasmtime_val(kind, of) = new(kind, Tuple((zero(UInt8) for _ = 1:7)), of)
end

const wasmtime_val_t = wasmtime_val

function wasmtime_val_delete(val)
    ccall((:wasmtime_val_delete, libwasmtime), Cvoid, (Ptr{wasmtime_val_t},), val)
end

function wasmtime_val_copy(dst, src)
    ccall((:wasmtime_val_copy, libwasmtime), Cvoid, (Ptr{wasmtime_val_t}, Ptr{wasmtime_val_t}), dst, src)
end

mutable struct wasmtime_caller end

const wasmtime_caller_t = wasmtime_caller

# typedef wasm_trap_t * ( * wasmtime_func_callback_t ) ( void * env , wasmtime_caller_t * caller , const wasmtime_val_t * args , size_t nargs , wasmtime_val_t * results , size_t nresults )
const wasmtime_func_callback_t = Ptr{Cvoid}

function wasmtime_func_new(store, type, callback, env, finalizer, ret)
    ccall((:wasmtime_func_new, libwasmtime), Cvoid, (Ptr{wasmtime_context_t}, Ptr{wasm_functype_t}, wasmtime_func_callback_t, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{wasmtime_func_t}), store, type, callback, env, finalizer, ret)
end

# typedef wasm_trap_t * ( * wasmtime_func_unchecked_callback_t ) ( void * env , wasmtime_caller_t * caller , wasmtime_val_raw_t * args_and_results )
const wasmtime_func_unchecked_callback_t = Ptr{Cvoid}

function wasmtime_func_new_unchecked(store, type, callback, env, finalizer, ret)
    ccall((:wasmtime_func_new_unchecked, libwasmtime), Cvoid, (Ptr{wasmtime_context_t}, Ptr{wasm_functype_t}, wasmtime_func_unchecked_callback_t, Ptr{Cvoid}, Ptr{Cvoid}, Ptr{wasmtime_func_t}), store, type, callback, env, finalizer, ret)
end

function wasmtime_func_type(store, func)
    ccall((:wasmtime_func_type, libwasmtime), Ptr{wasm_functype_t}, (Ptr{wasmtime_context_t}, Ptr{wasmtime_func_t}), store, func)
end

function wasmtime_func_call(store, func, args, nargs, results, nresults, trap)
    ccall((:wasmtime_func_call, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasmtime_context_t}, Ptr{wasmtime_func_t}, Ptr{wasmtime_val_t}, Csize_t, Ptr{wasmtime_val_t}, Csize_t, Ptr{Ptr{wasm_trap_t}}), store, func, args, nargs, results, nresults, trap)
end

function wasmtime_func_call_unchecked(store, func, args_and_results)
    ccall((:wasmtime_func_call_unchecked, libwasmtime), Ptr{wasm_trap_t}, (Ptr{wasmtime_context_t}, Ptr{wasmtime_func_t}, Ptr{wasmtime_val_raw_t}), store, func, args_and_results)
end

function wasmtime_caller_export_get(caller, name, name_len, item)
    ccall((:wasmtime_caller_export_get, libwasmtime), Bool, (Ptr{wasmtime_caller_t}, Cstring, Csize_t, Ptr{wasmtime_extern_t}), caller, name, name_len, item)
end

function wasmtime_caller_context(caller)
    ccall((:wasmtime_caller_context, libwasmtime), Ptr{wasmtime_context_t}, (Ptr{wasmtime_caller_t},), caller)
end

function wasmtime_func_from_raw(context, raw, ret)
    ccall((:wasmtime_func_from_raw, libwasmtime), Cvoid, (Ptr{wasmtime_context_t}, Csize_t, Ptr{wasmtime_func_t}), context, raw, ret)
end

function wasmtime_func_to_raw(context, func)
    ccall((:wasmtime_func_to_raw, libwasmtime), Csize_t, (Ptr{wasmtime_context_t}, Ptr{wasmtime_func_t}), context, func)
end

function wasmtime_global_new(store, type, val, ret)
    ccall((:wasmtime_global_new, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasmtime_context_t}, Ptr{wasm_globaltype_t}, Ptr{wasmtime_val_t}, Ptr{wasmtime_global_t}), store, type, val, ret)
end

function wasmtime_global_type(store, _global)
    ccall((:wasmtime_global_type, libwasmtime), Ptr{wasm_globaltype_t}, (Ptr{wasmtime_context_t}, Ptr{wasmtime_global_t}), store, _global)
end

function wasmtime_global_get(store, _global, out)
    ccall((:wasmtime_global_get, libwasmtime), Cvoid, (Ptr{wasmtime_context_t}, Ptr{wasmtime_global_t}, Ptr{wasmtime_val_t}), store, _global, out)
end

function wasmtime_global_set(store, _global, val)
    ccall((:wasmtime_global_set, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasmtime_context_t}, Ptr{wasmtime_global_t}, Ptr{wasmtime_val_t}), store, _global, val)
end

mutable struct wasmtime_instancetype end

const wasmtime_instancetype_t = wasmtime_instancetype

function wasmtime_instancetype_delete(ty)
    ccall((:wasmtime_instancetype_delete, libwasmtime), Cvoid, (Ptr{wasmtime_instancetype_t},), ty)
end

function wasmtime_instancetype_exports(arg1, out)
    ccall((:wasmtime_instancetype_exports, libwasmtime), Cvoid, (Ptr{wasmtime_instancetype_t}, Ptr{wasm_exporttype_vec_t}), arg1, out)
end

function wasmtime_instancetype_as_externtype(arg1)
    ccall((:wasmtime_instancetype_as_externtype, libwasmtime), Ptr{wasm_externtype_t}, (Ptr{wasmtime_instancetype_t},), arg1)
end

function wasmtime_externtype_as_instancetype(arg1)
    ccall((:wasmtime_externtype_as_instancetype, libwasmtime), Ptr{wasmtime_instancetype_t}, (Ptr{wasm_externtype_t},), arg1)
end

function wasmtime_instance_new(store, _module, imports, nimports, instance, trap)
    ccall((:wasmtime_instance_new, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasmtime_context_t}, Ptr{wasmtime_module_t}, Ptr{wasmtime_extern_t}, Csize_t, Ptr{wasmtime_instance_t}, Ptr{Ptr{wasm_trap_t}}), store, _module, imports, nimports, instance, trap)
end

function wasmtime_instance_type(store, instance)
    ccall((:wasmtime_instance_type, libwasmtime), Ptr{wasmtime_instancetype_t}, (Ptr{wasmtime_context_t}, Ptr{wasmtime_instance_t}), store, instance)
end

function wasmtime_instance_export_get(store, instance, name, name_len, item)
    ccall((:wasmtime_instance_export_get, libwasmtime), Bool, (Ptr{wasmtime_context_t}, Ptr{wasmtime_instance_t}, Cstring, Csize_t, Ptr{wasmtime_extern_t}), store, instance, name, name_len, item)
end

function wasmtime_instance_export_nth(store, instance, index, name, name_len, item)
    ccall((:wasmtime_instance_export_nth, libwasmtime), Bool, (Ptr{wasmtime_context_t}, Ptr{wasmtime_instance_t}, Csize_t, Ptr{Cstring}, Ptr{Csize_t}, Ptr{wasmtime_extern_t}), store, instance, index, name, name_len, item)
end

mutable struct wasmtime_linker end

const wasmtime_linker_t = wasmtime_linker

function wasmtime_linker_new(engine)
    ccall((:wasmtime_linker_new, libwasmtime), Ptr{wasmtime_linker_t}, (Ptr{wasm_engine_t},), engine)
end

function wasmtime_linker_delete(linker)
    ccall((:wasmtime_linker_delete, libwasmtime), Cvoid, (Ptr{wasmtime_linker_t},), linker)
end

function wasmtime_linker_allow_shadowing(linker, allow_shadowing)
    ccall((:wasmtime_linker_allow_shadowing, libwasmtime), Cvoid, (Ptr{wasmtime_linker_t}, Bool), linker, allow_shadowing)
end

function wasmtime_linker_define(linker, _module, module_len, name, name_len, item)
    ccall((:wasmtime_linker_define, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasmtime_linker_t}, Cstring, Csize_t, Cstring, Csize_t, Ptr{wasmtime_extern_t}), linker, _module, module_len, name, name_len, item)
end

function wasmtime_linker_define_func(linker, _module, module_len, name, name_len, ty, cb, data, finalizer)
    ccall((:wasmtime_linker_define_func, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasmtime_linker_t}, Cstring, Csize_t, Cstring, Csize_t, Ptr{wasm_functype_t}, wasmtime_func_callback_t, Ptr{Cvoid}, Ptr{Cvoid}), linker, _module, module_len, name, name_len, ty, cb, data, finalizer)
end

function wasmtime_linker_define_func_unchecked(linker, _module, module_len, name, name_len, ty, cb, data, finalizer)
    ccall((:wasmtime_linker_define_func_unchecked, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasmtime_linker_t}, Cstring, Csize_t, Cstring, Csize_t, Ptr{wasm_functype_t}, wasmtime_func_unchecked_callback_t, Ptr{Cvoid}, Ptr{Cvoid}), linker, _module, module_len, name, name_len, ty, cb, data, finalizer)
end

function wasmtime_linker_define_wasi(linker)
    ccall((:wasmtime_linker_define_wasi, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasmtime_linker_t},), linker)
end

function wasmtime_linker_define_instance(linker, store, name, name_len, instance)
    ccall((:wasmtime_linker_define_instance, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasmtime_linker_t}, Ptr{wasmtime_context_t}, Cstring, Csize_t, Ptr{wasmtime_instance_t}), linker, store, name, name_len, instance)
end

function wasmtime_linker_instantiate(linker, store, _module, instance, trap)
    ccall((:wasmtime_linker_instantiate, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasmtime_linker_t}, Ptr{wasmtime_context_t}, Ptr{wasmtime_module_t}, Ptr{wasmtime_instance_t}, Ptr{Ptr{wasm_trap_t}}), linker, store, _module, instance, trap)
end

function wasmtime_linker_module(linker, store, name, name_len, _module)
    ccall((:wasmtime_linker_module, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasmtime_linker_t}, Ptr{wasmtime_context_t}, Cstring, Csize_t, Ptr{wasmtime_module_t}), linker, store, name, name_len, _module)
end

function wasmtime_linker_get_default(linker, store, name, name_len, func)
    ccall((:wasmtime_linker_get_default, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasmtime_linker_t}, Ptr{wasmtime_context_t}, Cstring, Csize_t, Ptr{wasmtime_func_t}), linker, store, name, name_len, func)
end

function wasmtime_linker_get(linker, store, _module, module_len, name, name_len, item)
    ccall((:wasmtime_linker_get, libwasmtime), Bool, (Ptr{wasmtime_linker_t}, Ptr{wasmtime_context_t}, Cstring, Csize_t, Cstring, Csize_t, Ptr{wasmtime_extern_t}), linker, store, _module, module_len, name, name_len, item)
end

function wasmtime_memorytype_new(min, max_present, max, is_64)
    ccall((:wasmtime_memorytype_new, libwasmtime), Ptr{wasm_memorytype_t}, (UInt64, Bool, UInt64, Bool), min, max_present, max, is_64)
end

function wasmtime_memorytype_minimum(ty)
    ccall((:wasmtime_memorytype_minimum, libwasmtime), UInt64, (Ptr{wasm_memorytype_t},), ty)
end

function wasmtime_memorytype_maximum(ty, max)
    ccall((:wasmtime_memorytype_maximum, libwasmtime), Bool, (Ptr{wasm_memorytype_t}, Ptr{UInt64}), ty, max)
end

function wasmtime_memorytype_is64(ty)
    ccall((:wasmtime_memorytype_is64, libwasmtime), Bool, (Ptr{wasm_memorytype_t},), ty)
end

function wasmtime_memory_new(store, ty, ret)
    ccall((:wasmtime_memory_new, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasmtime_context_t}, Ptr{wasm_memorytype_t}, Ptr{wasmtime_memory_t}), store, ty, ret)
end

function wasmtime_memory_type(store, memory)
    ccall((:wasmtime_memory_type, libwasmtime), Ptr{wasm_memorytype_t}, (Ptr{wasmtime_context_t}, Ptr{wasmtime_memory_t}), store, memory)
end

function wasmtime_memory_data(store, memory)
    ccall((:wasmtime_memory_data, libwasmtime), Ptr{UInt8}, (Ptr{wasmtime_context_t}, Ptr{wasmtime_memory_t}), store, memory)
end

function wasmtime_memory_data_size(store, memory)
    ccall((:wasmtime_memory_data_size, libwasmtime), Csize_t, (Ptr{wasmtime_context_t}, Ptr{wasmtime_memory_t}), store, memory)
end

function wasmtime_memory_size(store, memory)
    ccall((:wasmtime_memory_size, libwasmtime), UInt64, (Ptr{wasmtime_context_t}, Ptr{wasmtime_memory_t}), store, memory)
end

function wasmtime_memory_grow(store, memory, delta, prev_size)
    ccall((:wasmtime_memory_grow, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasmtime_context_t}, Ptr{wasmtime_memory_t}, UInt64, Ptr{UInt64}), store, memory, delta, prev_size)
end

function wasmtime_table_new(store, ty, init, table)
    ccall((:wasmtime_table_new, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasmtime_context_t}, Ptr{wasm_tabletype_t}, Ptr{wasmtime_val_t}, Ptr{wasmtime_table_t}), store, ty, init, table)
end

function wasmtime_table_type(store, table)
    ccall((:wasmtime_table_type, libwasmtime), Ptr{wasm_tabletype_t}, (Ptr{wasmtime_context_t}, Ptr{wasmtime_table_t}), store, table)
end

function wasmtime_table_get(store, table, index, val)
    ccall((:wasmtime_table_get, libwasmtime), Bool, (Ptr{wasmtime_context_t}, Ptr{wasmtime_table_t}, UInt32, Ptr{wasmtime_val_t}), store, table, index, val)
end

function wasmtime_table_set(store, table, index, value)
    ccall((:wasmtime_table_set, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasmtime_context_t}, Ptr{wasmtime_table_t}, UInt32, Ptr{wasmtime_val_t}), store, table, index, value)
end

function wasmtime_table_size(store, table)
    ccall((:wasmtime_table_size, libwasmtime), UInt32, (Ptr{wasmtime_context_t}, Ptr{wasmtime_table_t}), store, table)
end

function wasmtime_table_grow(store, table, delta, init, prev_size)
    ccall((:wasmtime_table_grow, libwasmtime), Ptr{wasmtime_error_t}, (Ptr{wasmtime_context_t}, Ptr{wasmtime_table_t}, UInt32, Ptr{wasmtime_val_t}, Ptr{UInt32}), store, table, delta, init, prev_size)
end

const wasmtime_trap_code_t = UInt8

@cenum wasmtime_trap_code_enum::UInt32 begin
    WASMTIME_TRAP_CODE_STACK_OVERFLOW = 0
    WASMTIME_TRAP_CODE_MEMORY_OUT_OF_BOUNDS = 1
    WASMTIME_TRAP_CODE_HEAP_MISALIGNED = 2
    WASMTIME_TRAP_CODE_TABLE_OUT_OF_BOUNDS = 3
    WASMTIME_TRAP_CODE_INDIRECT_CALL_TO_NULL = 4
    WASMTIME_TRAP_CODE_BAD_SIGNATURE = 5
    WASMTIME_TRAP_CODE_INTEGER_OVERFLOW = 6
    WASMTIME_TRAP_CODE_INTEGER_DIVISION_BY_ZERO = 7
    WASMTIME_TRAP_CODE_BAD_CONVERSION_TO_INTEGER = 8
    WASMTIME_TRAP_CODE_UNREACHABLE_CODE_REACHED = 9
    WASMTIME_TRAP_CODE_INTERRUPT = 10
end

function wasmtime_trap_new(msg, msg_len)
    ccall((:wasmtime_trap_new, libwasmtime), Ptr{wasm_trap_t}, (Cstring, Csize_t), msg, msg_len)
end

function wasmtime_trap_code(arg1, code)
    ccall((:wasmtime_trap_code, libwasmtime), Bool, (Ptr{wasm_trap_t}, Ptr{wasmtime_trap_code_t}), arg1, code)
end

function wasmtime_trap_exit_status(arg1, status)
    ccall((:wasmtime_trap_exit_status, libwasmtime), Bool, (Ptr{wasm_trap_t}, Ptr{Cint}), arg1, status)
end

function wasmtime_frame_func_name(arg1)
    ccall((:wasmtime_frame_func_name, libwasmtime), Ptr{wasm_name_t}, (Ptr{wasm_frame_t},), arg1)
end

function wasmtime_frame_module_name(arg1)
    ccall((:wasmtime_frame_module_name, libwasmtime), Ptr{wasm_name_t}, (Ptr{wasm_frame_t},), arg1)
end

function wasmtime_wat2wasm(wat, wat_len, ret)
    ccall((:wasmtime_wat2wasm, libwasmtime), Ptr{wasmtime_error_t}, (Cstring, Csize_t, Ptr{wasm_byte_vec_t}), wat, wat_len, ret)
end

function wasi_config_delete(arg1)
    ccall((:wasi_config_delete, libwasmtime), Cvoid, (Ptr{wasi_config_t},), arg1)
end

# no prototype is found for this function at wasi.h:47:36, please use with caution
function wasi_config_new()
    ccall((:wasi_config_new, libwasmtime), Ptr{wasi_config_t}, ())
end

function wasi_config_set_argv(config, argc, argv)
    ccall((:wasi_config_set_argv, libwasmtime), Cvoid, (Ptr{wasi_config_t}, Cint, Ptr{Cstring}), config, argc, argv)
end

function wasi_config_inherit_argv(config)
    ccall((:wasi_config_inherit_argv, libwasmtime), Cvoid, (Ptr{wasi_config_t},), config)
end

function wasi_config_set_env(config, envc, names, values)
    ccall((:wasi_config_set_env, libwasmtime), Cvoid, (Ptr{wasi_config_t}, Cint, Ptr{Cstring}, Ptr{Cstring}), config, envc, names, values)
end

function wasi_config_inherit_env(config)
    ccall((:wasi_config_inherit_env, libwasmtime), Cvoid, (Ptr{wasi_config_t},), config)
end

function wasi_config_set_stdin_file(config, path)
    ccall((:wasi_config_set_stdin_file, libwasmtime), Bool, (Ptr{wasi_config_t}, Cstring), config, path)
end

function wasi_config_inherit_stdin(config)
    ccall((:wasi_config_inherit_stdin, libwasmtime), Cvoid, (Ptr{wasi_config_t},), config)
end

function wasi_config_set_stdout_file(config, path)
    ccall((:wasi_config_set_stdout_file, libwasmtime), Bool, (Ptr{wasi_config_t}, Cstring), config, path)
end

function wasi_config_inherit_stdout(config)
    ccall((:wasi_config_inherit_stdout, libwasmtime), Cvoid, (Ptr{wasi_config_t},), config)
end

function wasi_config_set_stderr_file(config, path)
    ccall((:wasi_config_set_stderr_file, libwasmtime), Bool, (Ptr{wasi_config_t}, Cstring), config, path)
end

function wasi_config_inherit_stderr(config)
    ccall((:wasi_config_inherit_stderr, libwasmtime), Cvoid, (Ptr{wasi_config_t},), config)
end

function wasi_config_preopen_dir(config, path, guest_path)
    ccall((:wasi_config_preopen_dir, libwasmtime), Bool, (Ptr{wasi_config_t}, Cstring, Cstring), config, path, guest_path)
end

const wasm_name = wasm_byte_vec_t

const wasm_name_new = wasm_byte_vec_new

const wasm_name_new_empty = wasm_byte_vec_new_empty

const wasm_name_new_new_uninitialized = wasm_byte_vec_new_uninitialized

const wasm_name_copy = wasm_byte_vec_copy

const wasm_name_delete = wasm_byte_vec_delete

const WASM_EMPTY_VEC = nothing

# Skipping MacroDefinition: WASM_INIT_VAL { . kind = WASM_ANYREF , . of = { . ref = NULL } }

const WASMTIME_EXTERN_FUNC = 0

const WASMTIME_EXTERN_GLOBAL = 1

const WASMTIME_EXTERN_TABLE = 2

const WASMTIME_EXTERN_MEMORY = 3

const WASMTIME_EXTERN_INSTANCE = 4

const WASMTIME_EXTERN_MODULE = 5

const WASMTIME_I32 = 0

const WASMTIME_I64 = 1

const WASMTIME_F32 = 2

const WASMTIME_F64 = 3

const WASMTIME_V128 = 4

const WASMTIME_FUNCREF = 5

const WASMTIME_EXTERNREF = 6



# exports
const PREFIXES = ["libwasm", "wasmtime_", "wasm_", "WASM_", "WASMTIME_", "wasi_"]
for name in names(@__MODULE__; all=true), prefix in PREFIXES
    if startswith(string(name), prefix)
        @eval export $name
    end
end

end # module
