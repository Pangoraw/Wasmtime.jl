abstract type AbstractWasmExport end

mutable struct WasmExports{I,E<:AbstractWasmExport}
    wasm_instance::I # I may either be a WamsInstance or a WasmtimeModule
    wasm_exports::Dict{Symbol,E}
end

Base.haskey(wasm_exports::WasmExports, k::Symbol) = haskey(wasm_exports.wasm_exports, k)
function Base.getproperty(wasm_exports::WasmExports, f::Symbol)
    if f ∈ fieldnames(WasmExports)
        return getfield(wasm_exports, f)
    end

    return wasm_exports.wasm_exports[f]
end
