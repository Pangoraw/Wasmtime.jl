function throw_error_message(wasm_error::Ptr{wasmtime_error_t})
    message_buf = WasmByteVec()
    wasmtime_error_message(
        wasm_error,
        message_buf,
    )
    error_msg = unsafe_string(message_buf.data, message_buf.size)
    @ccall libwasmtime.wasmtime_error_delete(wasm_error::Ptr{wasmtime_error_t})::Cvoid

    error(error_msg)
end

macro wt_check(call)
    quote
        wt_err = $(esc(call))
        if wt_err != C_NULL
            throw_error_message(wt_err)
        end
    end
end
