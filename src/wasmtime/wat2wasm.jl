mutable struct wasmtime_error_t end

function throw_error_message(error::Ptr{wasmtime_error_t})
    message_buf = WasmByteVec()
    @ccall libwasmtime.wasmtime_error_message(
        error::Ptr{wasmtime_error_t},
        message_buf::Ptr{wasm_byte_vec_t},
    )::Cvoid
    error_msg = unsafe_string(message_buf.data, message_buf.size)
    @ccall libwasmtime.wasmtime_error_delete(error::Ptr{wasmtime_error_t})::Cvoid

    error(error_msg)
end

wat2wasm(str::AbstractString) =
    wat2wasm(WasmByteVec(collect(wasm_byte_t, str)))
function wat2wasm(wat::WasmByteVec)
    out = WasmByteVec()
    error = @ccall libwasmtime.wasmtime_wat2wasm(
        wat::Ptr{wasm_byte_vec_t},
        out::Ptr{wasm_byte_vec_t}
    )::Ptr{wasmtime_error_t}
    if error != C_NULL
        throw_error_message(error)
    end

    out
end

macro wat_str(wat::String)
    :(wat2wasm($wat))
end