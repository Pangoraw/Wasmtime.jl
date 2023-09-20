# Wasmtime.jl

A Julia wrapper around the wasmtime runtime to run Web Assembly blobs and libraries from Julia.

## Examples

```julia
julia> using Wasmtime

julia> code = wat"""
           (module
               (memory 1)

               ;; adds two consecutive f32 located at
               ;; address $ptr in memory
               (func $sum (param $ptr i32)
                          (result f32)
                   local.get $ptr
                   f32.load
                   local.get 0
                   i32.const 4
                   i32.add
                   f32.load
                   f32.add
               )

               (export "sum" (func $sum))
               (export "memory" (memory 0))
           )
       """;

julia> engine = WasmEngine(); store = Wasmtime.WasmtimeStore(engine);

julia> module_ = Wasmtime.WasmtimeModule(engine, code);

julia> instance = Wasmtime.WasmtimeInstance(store, module_);

julia> (; memory, sum) = exports(instance);

julia> buf = reinterpret(Float32, memory); # memory is an AbstractVector{UInt8}

julia> buf[1] = 32.5f0; buf[2] = 3f0;

julia> sum(Int32(0))
35.5f0

julia> buf[1] + buf[2]
35.5f0
```

## Usage

Wastime exposes two C api. The first one is the common Web Assembly runtime C api with names starting with `Wasm` in Wasmtime.jl.
The second one is a wasmtime specific api which provides more functionality like WASI imports, fine-grained configuration
of the store features like fuel.

See the [`test` folder](https://github.com/Pangoraw/Wasmtime.jl/tree/main/test) for usage examples.
