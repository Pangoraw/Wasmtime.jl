mutable struct wasmtime_error_t end

function throw_error_message(wasm_error::Ptr{wasmtime_error_t})
    message_buf = WasmByteVec()
    @ccall libwasmtime.wasmtime_error_message(
        wasm_error::Ptr{wasmtime_error_t},
        message_buf::Ptr{wasm_byte_vec_t},
    )::Cvoid
    error_msg = unsafe_string(message_buf.data, message_buf.size)
    @ccall libwasmtime.wasmtime_error_delete(wasm_error::Ptr{wasmtime_error_t})::Cvoid

    error(error_msg)
end

function wat2wasm(wat::AbstractString)
    out = WasmByteVec()
    wasm_error = @ccall libwasmtime.wasmtime_wat2wasm(
        wat::Cstring,
        length(wat)::Csize_t,
        out::Ptr{wasm_byte_vec_t},
    )::Ptr{wasmtime_error_t}
    if wasm_error != C_NULL
        throw_error_message(wasm_error)
    end

    out
end

macro wat_str(wat::String)
    :(wat2wasm($wat))
end
