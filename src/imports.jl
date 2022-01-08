struct WasmImport
    wasm_importtype_ptr::Ptr{wasm_importtype_t}
    extern_kind::wasm_externkind_enum
    import_module::String
    name::String

    function WasmImport(wasm_importtype_ptr::Ptr{wasm_importtype_t})
        name_vec_ptr = wasm_importtype_name(wasm_importtype_ptr)
        name = name_vec_ptr_to_str(name_vec_ptr)

        import_module_ptr = wasm_importtype_module(wasm_importtype_ptr)
        import_module = name_vec_ptr_to_str(import_module_ptr)

        externtype_ptr = wasm_importtype_type(wasm_importtype_ptr)
        extern_kind = wasm_externkind_enum(wasm_externtype_kind(externtype_ptr))

        new(wasm_importtype_ptr, extern_kind, import_module, name)
    end
end

Base.unsafe_convert(::Type{Ptr{wasm_importtype_t}}, wasm_import::WasmImport) = wasm_import.wasm_importtype_ptr
Base.show(io::IO, wasm_import::WasmImport) = print(
    io,
    "WasmImport($(wasm_import.extern_kind), \"$(wasm_import.import_module)\", \"$(wasm_import.name)\")",
)

struct WasmImports{M<:AbstractWasmModule}
    wasm_module::M
    wasm_imports::Vector{WasmImport}

    function WasmImports(wasm_module::M, wasm_imports_vec) where {M<:AbstractWasmModule}
        wasm_imports = map(imp -> wasm_importtype_copy(imp) |> WasmImport, wasm_imports_vec)
        new{M}(wasm_module, wasm_imports)
    end
end


function Base.show(io::IO, wasm_imports::WasmImports)
    print(io::IO, "WasmImports(")
    show(io, wasm_imports.wasm_imports)
    print(")")
end
