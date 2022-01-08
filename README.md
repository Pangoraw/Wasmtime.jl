# Wasmtime.jl

A Julia wrapper around the wasmtime runtime to run Web Assembly blobs and libraries from Julia.

## Examples

```julia
julia> using Wasmtime

julia> wat"(module)"
```

## Usage

Wastime exposes two C api. The first one is the common Web Assembly runtime C api with names starting with `Wasm` in Wasmtime.jl.
The second one is a wasmtime specific api which provides more functionality like WASI imports, fine-grained configuration
of the store features like fuel.

See the [`test` folder](https://github.com/Pangoraw/Wasmtime.jl/tree/main/test) for usage examples.
