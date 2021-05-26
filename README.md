# WasmRuntime.jl

A package to run WASM binary blobs.

## Backends

There is currently two supported runtime backend for running WASM blobs:
  * [Wasmtime](https://github.com/bytecodealliance/wasmtime)
  * [Wasmer](https://github.com/wasmerio/wasmer)

The backends are able to share most of the code since they all implement the [WASM engine c-api](https://github.com/WebAssembly/wasm-c-api).

## Usage

See the [`test` folder](https://github.com/Pangoraw/WASM.jl/tree/main/test) for usage examples.
