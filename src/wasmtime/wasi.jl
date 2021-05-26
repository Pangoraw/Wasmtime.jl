mutable struct wasi_config_t end
mutable struct wasi_instance_t end

mutable struct WasiConfig
    wasi_config_ptr::Ptr{wasi_config_t}
    program_name::String
    owned::Bool

    WasiConfig(wasi_config_ptr, name) =
        finalizer(wasi_config_delete, new(wasi_config_ptr, name, false))
end
WasiConfig(program_name::String) = WasiConfig(wasi_config_new(), program_name)

Base.unsafe_convert(::Type{Ptr{wasi_config_t}}, wasi_config::WasiConfig) =
    wasi_config.wasi_config_ptr

wasi_config_new() = @ccall libwasmtime.wasi_config_new()::Ptr{wasi_config_t}
wasi_config_delete(wasi_config) =
    @ccall libwasmtime.wasi_config_delete(wasi_config::Ptr{wasi_config_t})::Cvoid
wasi_config_delete(config::WasiConfig) =
    config.owned || wasi_config_delete(config.wasi_config_ptr)

wasi_config_set_argv(config, argc, argv) = @ccall libwasmtime.wasi_config_set_argv(
    config::Ptr{wasi_config_t},
    argc::Cint,
    argv::Ptr{Ptr{Cchar}},
)::Cvoid

wasi_config_inherit_argv(config) =
    @ccall libwasmtime.wasi_config_inherit_argv(config::Ptr{wasi_config_t})::Cvoid

wasi_config_set_env(config, envc, names, values) = @ccall libwasmtime.wasi_config_set_env(
    config::Ptr{wasi_config_t},
    envc::Cint,
    names::Ptr{Ptr{Cchar}},
    values::Ptr{Ptr{Cchar}},
)::Cvoid

wasi_config_inherit_env(config) =
    @ccall libwasmtime.wasi_config_inherit_env(config::Ptr{wasi_config_t})::Cvoid

wasi_config_set_stdin_file(config, path) = @ccall libwasmtime.wasi_config_set_stdin_file(
    config::Ptr{wasi_config_t},
    path::Cstring,
)::Bool

wasi_config_inherit_stdin(config) =
    @ccall libwasmtime.wasi_config_inherit_stdin(config::Ptr{wasi_config_t})::Cvoid

wasi_config_set_stdout_file(config, path) = @ccall libwasmtime.wasi_config_set_stdout_file(
    config::Ptr{wasi_config_t},
    path::Cstring,
)::Bool

wasi_config_inherit_stdout(config) =
    @ccall libwasmtime.wasi_config_inherit_stdout(config::Ptr{wasi_config_t})::Cvoid

wasi_config_set_stderr_file(config, path) = @ccall libwasmtime.wasi_config_set_stderr_file(
    config::Ptr{wasi_config_t},
    path::Cstring,
)::Bool

wasi_config_inherit_stderr(config) =
    @ccall libwasmtime.wasi_config_inherit_stderr(config::Ptr{wasi_config_t})::Cvoid

wasi_config_preopen_dir(config, path, guest_path) =
    @ccall libwasmtime.wasi_config_preopen_dir(
        config::Ptr{wasi_config_t},
        path::Cstring,
        guest_path::Cstring,
    )::Bool

function wasi_config_set_argv(config, argv)
    arr_ptr = Base.unsafe_convert.(Cstring, argv)

    GC.@preserve arr_ptr argv wasi_config_set_argv(config, length(argv), pointer(arr_ptr))
end

mutable struct WasiEnv
    wasi_instance_ptr::Ptr{wasi_instance_t}
    wasi_externs::Vector{Ptr{wasm_extern_t}}
    wasi_config::WasiConfig

    function WasiEnv(wasi_instance_ptr::Ptr{wasi_instance_t}, wasi_config::WasiConfig)
        wasi_config.owned = true
        finalizer(wasi_instance_delete, new(wasi_instance_ptr, [], wasi_config))
    end
end
function WasiEnv(store, wasi_config)
    # TODO: customize argv
    wasi_config_set_argv(wasi_config, [wasi_config.program_name])

    wasm_trap_ptr = Ref(Ptr{wasm_trap_t}())

    wasi_instance_ptr =
        wasi_instance_new(store, wasi_config.program_name, wasi_config, wasm_trap_ptr)
    if wasi_instance_ptr == C_NULL && wasm_trap_ptr[] != C_NULL
        trap_msg = WasmByteVec()
        wasm_trap_message(wasm_trap_ptr[], trap_msg)
        wasm_trap_delete(wasm_trap_ptr[])

        error_message = unsafe_string(trap_msg.data, trap_msg.size)
        error(error_message)
    end
    @assert wasi_instance_ptr != C_NULL "Failed to create WASI instance"
    @assert wasm_trap_ptr[] == C_NULL "Trapped during WASI instance creation"

    WasiEnv(wasi_instance_ptr, wasi_config)
end

Base.unsafe_convert(::Type{Ptr{wasi_instance_t}}, wasi_env::WasiEnv) =
    wasi_env.wasi_instance_ptr

wasi_instance_new(store, name, config, trap_ptr) = @ccall libwasmtime.wasi_instance_new(
    store::Ptr{wasm_store_t},
    name::Cstring,
    config::Ptr{wasi_config_t},
    trap_ptr::Ptr{Ptr{wasm_trap_t}},
)::Ptr{wasi_instance_t}

wasi_instance_delete(wasi_instance) =
    @ccall libwasmtime.wasi_instance_delete(wasi_instance::Ptr{wasi_instance_t})::Cvoid

function wasi_instance_delete(wasi_instance::WasiEnv)
    wasi_instance_delete(wasi_instance.wasi_instance_ptr)
end

function wasi_get_imports(_, wasm_module, wasi_env)
    wasm_imports_vec = imports_as_wasm_vec(wasm_module)

    wasm_externs_ptr = map(wasm_imports_vec) do wasm_import_ptr
        wasm_extern_ptr = @ccall libwasmtime.wasi_instance_bind_import(
            wasi_env::Ptr{wasi_instance_t},
            wasm_import_ptr::Ptr{wasm_importtype_t},
        )::Ptr{wasm_extern_t}
        @assert wasm_extern_ptr != C_NULL "Failed to get WASI import"
        wasm_extern_ptr
    end # Vector{Ptr{wasm_extern_t}}

    # This wasm_extern_vec_t does not own the wasm_extern_t, so we don't use the constructor to avoid calling
    # wasm_extern_vec_delete(...)
    wasi_externs = WasmVec{wasm_extern_vec_t,Ptr{wasm_extern_t}}(
        length(wasm_externs_ptr),
        pointer(wasm_externs_ptr),
    )
    # Avoid garbage collection of pointer(wasm_externs_ptr) by tying the externs to the wasi_instance_t
    wasi_env.wasi_externs = wasm_externs_ptr

    wasi_externs
end
