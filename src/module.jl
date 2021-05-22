mutable struct WasmModule
    wasm_module_ptr::Ptr{wasm_module_t}

    WasmModule(module_ptr::Ptr{wasm_module_t}) = finalizer(new(module_ptr)) do wasm_module
        wasm_module_delete(wasm_module.wasm_module_ptr)
    end
end
function WasmModule(store::WasmStore, wasm_byte_vec::WasmByteVec)
    wasm_module_ptr = wasm_module_new(store.wasm_store_ptr, wasm_byte_vec)
    wasm_module_ptr == C_NULL && error("Failed to create wasm module")

    WasmModule(wasm_module_ptr)
end

function WasmFunc(store::WasmStore, func::Function, return_type, input_types)
    params_vec = WasmPtrVec(collect(Ptr{wasm_valtype_t}, map(julia_type_to_valtype, input_types)))
    results_vec = WasmPtrVec([julia_type_to_valtype(return_type)])

    func_type = wasm_functype_new(params_vec, results_vec)
    @assert func_type != C_NULL "Failed to create functype"

    function jl_side_host(args::Ptr{wasm_val_vec_t}, results::Ptr{wasm_val_vec_t})::Ptr{wasm_trap_t}
        # TODO: support passing the arguments
        res = func()
        wasm_res = Ref(convert(wasm_val_t, res))
        data_ptr = unsafe_load(results).data
        wasm_val_copy(data_ptr, Base.pointer_from_objref(wasm_res))

        C_NULL
    end

    # Create a pointer to jl_side_host(args, results)
    func_ptr = Base.@cfunction($jl_side_host, Ptr{wasm_trap_t}, (Ptr{wasm_val_vec_t}, Ptr{wasm_val_vec_t}))

    host_func = wasm_func_new(store.wasm_store_ptr, func_type, func_ptr)
    wasm_functype_delete(func_type)

    host_func, func_ptr
end

function name_vec_ptr_to_str(name_vec_ptr::Ptr{wasm_name_t})
    @assert name_vec_ptr != C_NULL "Failed to convert wasm_name" 
    name_vec = Base.unsafe_load(name_vec_ptr)
    name = unsafe_string(name_vec.data, name_vec.size)
    wasm_name_delete(name_vec_ptr)

    name
end

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

struct WasmImports
    wasm_module::WasmModule
    wasm_imports::Vector{WasmImport}

    function WasmImports(wasm_module::WasmModule)
        wasm_imports_vec = WasmPtrVec(wasm_importtype_t)
        wasm_module_imports(wasm_module.wasm_module_ptr, wasm_imports_vec)
        wasm_imports = map(WasmImport, wasm_imports_vec)

        new(wasm_module, wasm_imports)
    end
end
imports(wasm_module::WasmModule) = WasmImports(wasm_module)