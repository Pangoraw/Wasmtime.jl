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

const PAGE_SIZE = 65536

@testset "Memory" begin

    engine = WasmEngine()
    store = Wasmtime.WasmtimeStore(engine)

    code = wat"""
    (module
        (memory 42)
        (export "memory" (memory 0))
    )
    """
    modu = Wasmtime.WasmtimeModule(engine, code)
    instance = Wasmtime.WasmtimeInstance(store, modu)
    mem = exports(instance).memory

    @test length(mem) == 42PAGE_SIZE

    code = wat"""
    (module
        (memory 0 1)
        (export "memory" (memory 0))
    )
    """
    modu = Wasmtime.WasmtimeModule(engine, code)
    instance = Wasmtime.WasmtimeInstance(store, modu)
    mem = exports(instance).memory

    @test length(mem) == 0

    Wasmtime.grow!(mem, 1)
    @test length(mem) == PAGE_SIZE

    # Cannot grow past max page size
    @test_throws ErrorException Wasmtime.grow!(mem, 1)

    code = wat"""
    (module
        (memory 1)
        (func (result i32)
            i32.const 0
            i32.load
        )
        (func (result f32)
            i32.const 0
            f32.load
        )
        (func (result f64)
            i32.const 0
            f64.load
        )
        (export "i32" (func 0))
        (export "f32" (func 1))
        (export "f64" (func 2))
        (export "memory" (memory 0))
    )
    """
    modu = Wasmtime.WasmtimeModule(engine, code)
    instance = Wasmtime.WasmtimeInstance(store, modu)
    mem = exports(instance).memory
    i32 = exports(instance).i32
    f32 = exports(instance).f32
    f64 = exports(instance).f64

    i32_buf = reinterpret(Int32, mem)
    f32_buf = reinterpret(Float32, mem)
    f64_buf = reinterpret(Float64, mem)

    @test i32() === Int32(0)
    i32_buf[1] = 42
    @test i32() === Int32(42)

    f32_buf[1] = 42f0
    @test f32() === 42f0

    f64_buf[1] = 42.
    @test f64() === 42.
end

@testset "passthrough" begin
    code = wat"""
    (module
        (func (param i32) (result i32)
            local.get 0)
        (func (param i64) (result i64)
            local.get 0)
        (func (param f32) (result f32)
            local.get 0)
        (func (param f64) (result f64)
            local.get 0)
        (export "i32" (func 0))
        (export "i64" (func 1))
        (export "f32" (func 2))
        (export "f64" (func 3)))
    """

    engine = WasmEngine()
    store = Wasmtime.WasmtimeStore(engine)
    modu = Wasmtime.WasmtimeModule(engine, code)
    instance = Wasmtime.WasmtimeInstance(store, modu)
    i32 = exports(instance).i32
    i64 = exports(instance).i64
    f32 = exports(instance).f32
    f64 = exports(instance).f64

    for (f,T) in zip((i32,i64,f32,f64),
                     (Int32,Int64,Float32,Float64))
        val = T(42)
        @test f(val) == val
    end
end

@testset "v128" begin
    code = wat"""
    (module
        (func (param v128) (result f32)
            local.get 0
            f32x4.extract_lane 1)
        (func (param v128) (result f32)
            local.get 0
            f32x4.extract_lane 0
            local.get 0
            f32x4.extract_lane 1
            local.get 0
            f32x4.extract_lane 2
            local.get 0
            f32x4.extract_lane 3
            f32.add
            f32.add
            f32.add)
        (export "f32x4_extract_lane" (func 0))
        (export "f32x4_sum" (func 1)))
    """

    engine = WasmEngine()
    store = Wasmtime.WasmtimeStore(engine)
    module_ = Wasmtime.WasmtimeModule(engine, code)
    instance = Wasmtime.WasmtimeInstance(store, module_)

    f = exports(instance).f32x4_extract_lane
    fsum = exports(instance).f32x4_sum

    v = Wasmtime.f32x4(1f0, Float32(π), 42f0, -32f0)

    out = f(v)
    @test Float32(π) == out

    x₁,x₂,x₃,x₄ = Wasmtime.f32x4(v)
    out = fsum(v)

    @test ((x₃+x₄)+x₂)+x₁ == out
end

# include("./table.jl")
include("./import_export.jl")
include("./wat2wasm.jl")
include("./wasi.jl")
