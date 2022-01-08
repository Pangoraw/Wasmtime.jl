mutable struct wasi_instance_t end

mutable struct WasiConfig
    wasi_config_ptr::Ptr{wasi_config_t}
    program_name::String
    owned::Bool

    WasiConfig(wasi_config_ptr, name) =
        finalizer(new(wasi_config_ptr, name, false)) do config
            config.owned || wasi_config_delete(config)
        end
end
WasiConfig(program_name::String) = WasiConfig(wasi_config_new(), program_name)

Base.unsafe_convert(::Type{Ptr{wasi_config_t}}, wasi_config::WasiConfig) =
    wasi_config.wasi_config_ptr

function set_argv!(config::WasiConfig, argv)
    @assert !config.owned "This WASI configuration is already owned by a store, it can't be modified"
    arr_ptr = Base.unsafe_convert.(Cstring, argv)

    GC.@preserve arr_ptr argv wasi_config_set_argv(config, length(argv), pointer(arr_ptr))
end
