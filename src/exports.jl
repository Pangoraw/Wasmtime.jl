abstract type AbstractWasmExport end

mutable struct WasmExports{I,E}
    wasm_instance::I # I may either be a WasmInstance or a WasmtimeModule
    wasm_exports::Vector{E}
end

function Base.getproperty(wasm_exports::WasmExports, f::Symbol)
    if f ∈ fieldnames(WasmExports)
        return getfield(wasm_exports, f)
    end

    lookup_name = string(f)
    export_index =
        findfirst(wasm_export -> name(wasm_export) == lookup_name, wasm_exports.wasm_exports)
    @assert export_index !== nothing "Export $f not found"

    wasm_exports.wasm_exports[export_index]
end
