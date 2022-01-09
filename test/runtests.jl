using Wasmtime
using Test

@testset "Call foreign" begin
    engine = WasmEngine()
    store = Wasmtime.WasmtimeStore(engine)
    code = wat"""
    (module
        (func $add (param $lhs i32) (param $rhs i32) (result i32)
            local.get $lhs
            local.get $rhs
            i32.add)
        (export "add" (func $add))
    )
    """
    modu = Wasmtime.WasmtimeModule(engine, code)

    instance = Wasmtime.WasmtimeInstance(store, modu)
    add = exports(instance).add

    res = add(Int32(1), Int32(2))

    @test res == Int32(3)
end

# include("./table.jl")
include("./import_export.jl")
include("./wat2wasm.jl")
include("./wasi.jl")
