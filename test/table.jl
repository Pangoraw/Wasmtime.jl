@testset "WasmTable" begin
    using WASM.Wasmtime
    using Test
    wasm_code = wat"""
    (module
        (import "js" "tbl" (table 2 anyfunc))
            (func $f42 (result i32) i32.const 42)
            (func $f83 (result i32) i32.const 83)
            (elem (i32.const 0) $f42 $f83)
    )"""

    engine = WasmEngine()
    store = WasmStore(engine)

    wasm_module = WasmModule(store, wasm_code)

    table = Wasmtime.WasmTable(store, 2 => 5)

    @test Base.unsafe_convert(Ptr{Wasmtime.wasm_func_t}, table[1]) == C_NULL
    @test Base.unsafe_convert(Ptr{Wasmtime.wasm_func_t}, table[2]) == C_NULL

    instance = WasmInstance(store, wasm_module, [table])

    @test Base.unsafe_convert(Ptr{Wasmtime.wasm_func_t}, table[1]) != C_NULL
    @test Base.unsafe_convert(Ptr{Wasmtime.wasm_func_t}, table[2]) != C_NULL

    @test Base.convert(Int32, table[1]()[1]) == 42
    @test Base.convert(Int32, table[2]()[1]) == 83
end