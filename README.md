# WASM.jl

A package to run WASM binary blobs.

## Backends

There is currently two supported runtime backend for running WASM blobs:
  * [Wasmtime](https://github.com/bytecodealliance/wasmtime)
  * [Wasmer](https://github.com/wasmerio/wasmer)

The backends are able to share most of the code since they all implement the [WASM engine c-api](https://github.com/WebAssembly/wasm-c-api).

## Usage

The package currently the `LIBWASM_LOCATION` environment variable to be set. It should contain the path to dynamic library of [one the backend engine](#backends).

```julia
 $ LIBWASM_LOCATION="./wasmtime/lib/libwasmtime.so" julia --project
   _       _ _(_)_     |  Documentation: https://docs.julialang.org
  (_)     | (_) (_)    |
   _ _   _| |_  __ _   |  Type "?" for help, "]?" for Pkg help.
  | | | | | | |/ _` |  |
  | | |_| | | | (_| |  |  Version 1.6.1 (2021-04-23)
 _/ |\__'_|_|_|\__'_|  |  Official https://julialang.org/ release
|__/                   |

julia> using WASM.Wasmtime
[ Info: Precompiling WASM [f519113a-1485-4b12-af44-dbf9b5a2f6b4]

julia> code = wat"(module)"
8-element WASM.Wasmtime.WasmVec{WASM.Wasmtime.LibWasm.wasm_byte_vec_t, UInt8}:
 0x00
 0x61
 0x73
 0x6d
 0x01
 0x00
 0x00

```