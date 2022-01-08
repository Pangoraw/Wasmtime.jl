function wat2wasm(wat::AbstractString)
    out = WasmByteVec()
    @wt_check wasmtime_wat2wasm(
        wat,
        length(wat),
        out,
    )
    out
end

macro wat_str(wat::String)
    :(wat2wasm($wat))
end
