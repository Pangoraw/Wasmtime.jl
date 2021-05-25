@testset "Import/Export" begin
    @testset "Import function" begin
        wasm_code = wat"""
        (module
            (func $host_function (import \"\" \"host_function\") (result i32))
            (func $function (export \"guest_function\") (result i32) (call $host_function)))
        """

        engine = WasmEngine()
        store = WasmStore(engine)
        wasm_module = WasmModule(store, wasm_code)

        @test_throws Any instance = WasmInstance(store, wasm_module)

        wasm_imports = backend.imports(wasm_module)

        semaphore = Ref(32)
        function jl_side()
            # side effect on julia side
            semaphore[] = 42

            # return values
            Int32(100)
        end
        func_type = backend.WasmFunc(store, jl_side, Int32, ())

        instance = WasmInstance(store, wasm_module, [func_type])
        mod_exports = backend.exports(instance)

        guest_function = mod_exports.guest_function
        res = guest_function()

        @test res[1].kind == backend.WASM_I32
        @test res[1].of.i32 == 100
        @test semaphore[] == 42

    end

    @testset "WASI import" begin
        wasm_code = wat"""
        (module
            ;; Import the required fd_write WASI function which will write the given io vectors to stdout
            ;; The function signature for fd_write is:
            ;; (File Descriptor, *iovs, iovs_len, nwritten) -> Returns number of bytes written
            (import "wasi_unstable" "fd_write" (func $fd_write (param i32 i32 i32 i32) (result i32)))

            (memory 1)
            (export "memory" (memory 0))

            ;; Write 'hello world\n' to memory at an offset of 8 bytes
            ;; Note the trailing newline which is required for the text to appear
            (data (i32.const 8) "hello world\n")

            (func $main (export "_start")
                ;; Creating a new io vector within linear memory
                (i32.store (i32.const 0) (i32.const 8))  ;; iov.iov_base - This is a pointer to the start of the 'hello world\n' string
                (i32.store (i32.const 4) (i32.const 12))  ;; iov.iov_len - The length of the 'hello world\n' string

                (call $fd_write
                    (i32.const 1) ;; file_descriptor - 1 for stdout
                    (i32.const 0) ;; *iovs - The pointer to the iov array, which is stored at memory location 0
                    (i32.const 1) ;; iovs_len - We're printing 1 string stored in an iov - so one.
                    (i32.const 20) ;; nwritten - A place in memory to store the number of bytes written
                )
                drop ;; Discard the number of bytes written from the top of the stack
            )
        )
        """

        engine = WasmEngine()
        store = WasmStore(engine)
        wasm_module = WasmModule(store, wasm_code)

        imports = backend.imports(wasm_module)

        @test length(imports.wasm_imports) == 1
        @test imports.wasm_imports[1].import_module == "wasi_unstable"
        @test imports.wasm_imports[1].name == "fd_write"
        @test imports.wasm_imports[1].extern_kind == backend.WASM_EXTERN_FUNC
    end
end
