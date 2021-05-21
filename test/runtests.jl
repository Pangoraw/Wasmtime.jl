using Wasmer
using Test

@testset "wat2wasm" begin
    exception = try
        wat"invalid wasm code"
    catch e
        e
    end

    exception_msg = string(exception)
    @test occursin("invalid wasm code", exception_msg)
end

@testset "Basic export" begin
    wasm_code = wat"""
        (module
            (type $sum_t (func (param i32 i32) (result i32)))
            (func $sum_f (type $sum_t) (param $x i32) (param $y i32) (result i32)
            local.get $x
            local.get $y
            i32.add)
            (export "sum" (func $sum_f)))
    """

    engine = WasmEngine()
    store = WasmStore(engine)
    wasm_module = WasmModule(store, wasm_code)
    instance = WasmInstance(store, wasm_module)
    wasm_exports = exports(instance)
    sum_function = wasm_exports.sum

    result, = sum_function(Int32(2), Int32(2))
    result = Base.convert(Int32, result)

    @test result == Int32(4)
end
