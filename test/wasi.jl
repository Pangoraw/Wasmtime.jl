using Downloads

@testset "WASI - Cowsay" begin mktempdir() do tmp_dir
    # TODO: Find a better way to provide the files
    location = joinpath(tmp_dir, "cowsay.wasm")
    Downloads.download("https://registry-cdn.wapm.io/contents/_/cowsay/0.2.0/target/wasm32-wasi/release/cowsay.wasm", location)

    wasm_code = open(location, "r") do f
        read(f)
    end |> Wasmtime.WasmVec

    engine = WasmEngine()
    store = WasmStore(engine)
    wasm_module = WasmModule(store, wasm_code)

    msg = "Meuuuh!"
    stdin_path = joinpath(tmp_dir, "./stdin.txt")
    stdout_path = joinpath(tmp_dir, "./stdout.txt")
    open(stdin_path, "w") do file
        write(file, msg)
    end

    # TODO: Fix program name and argv's
    wasi_config = Wasmtime.WasiConfig("wasi_unstable")
    Wasmtime.wasi_config_inherit_stderr(wasi_config)
    Wasmtime.wasi_config_set_stdout_file(wasi_config, stdout_path)
    Wasmtime.wasi_config_set_stdin_file(wasi_config, stdin_path)
    Wasmtime.wasi_config_inherit_env(wasi_config)

    wasi_env = Wasmtime.WasiEnv(store, wasi_config)

    wasi_imports = Wasmtime.wasi_get_imports(
        store,
        wasm_module,
        wasi_env
    )

    instance = WasmInstance(store, wasm_module, wasi_imports)
    instance_exports = exports(instance)
    main_func = instance_exports._start

    main_func()

    result = open(f -> read(f, String), stdout_path, "r")

    expected = raw"""
     _________
    < Meuuuh! >
     ---------
            \   ^__^
             \  (oo)\_______
                (__)\       )\/\
                   ||----w |
                    ||     ||
    """

    @test result == expected
end
end