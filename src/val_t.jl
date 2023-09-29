julia_type_to_valtype(julia_type)::Ptr{wasm_valtype_t} =
    julia_type_to_valkind(julia_type) |> wasm_valtype_new

# TODO: the other value types
function WasmInt32(i::Int32)
    val = Ref(wasm_val_t(tuple((zero(UInt8) for _ = 1:16)...)))
    ptr = Base.unsafe_convert(Ptr{wasm_val_t}, Base.pointer_from_objref(val))
    ptr.kind = WASM_I32
    ptr.of.i32 = i

    val[]
end
function WasmInt64(i::Int64)
    val = Ref(wasm_val_t(tuple((zero(UInt8) for _ = 1:16)...)))
    ptr = Base.unsafe_convert(Ptr{wasm_val_t}, Base.pointer_from_objref(val))
    ptr.kind = WASM_I64
    ptr.of.i64 = i

    val[]
end
function WasmFloat32(f::Float32)
    val = Ref(wasm_val_t(tuple((zero(UInt8) for _ = 1:16)...)))
    ptr = Base.unsafe_convert(Ptr{wasm_val_t}, Base.pointer_from_objref(val))
    ptr.kind = WASM_F32
    ptr.of.f32 = f

    val[]
end
function WasmFloat64(f::Float64)
    val = Ref(wasm_val_t(tuple((zero(UInt8) for _ = 1:16)...)))
    ptr = Base.unsafe_convert(Ptr{wasm_val_t}, Base.pointer_from_objref(val))
    ptr.kind = WASM_F64
    ptr.of.f64 = f

    val[]
end

"""
    v128(x)

Splats the given value to create a v128 vector with as many times the value `x`
as the `typeof(x)` allows to fit in 128 bits.
"""
function v128(x::T) where {T<:Union{Int8,UInt8,Int16,UInt16,
                                    Int32,UInt32,Int64,UInt64,
                                    Float32,Float64,Int128,UInt128}}
    sz = sizeof(T)
    x = x isa Float32 ?
        reinterpret(UInt32, x) :
        x isa Float64 ?
        reinterpret(UInt64, x) :
        x
    bytes = ntuple(i -> (x >> (8 * (i - 1))) % UInt8, sz)
    ntuple(i -> bytes[(i-1)%sz+1], 16)
end

"""
    i64x2(x₁::Int64, x₂::Int64)

Creates a simd v128 vector from two Int64.
"""
i64x2(x₁, x₂) = Tuple(reinterpret(UInt8, Int64[x₁,x₂]))
"""
    i64x2(v)::Tuple{Int64,Int64}

Interprets the byte values in the simd vector as two Int64.
"""
function i64x2(v)
    x₁, x₂ = 0, 0
    for i in 1:sizeof(Float64)
        x₁ |= Int64(v[i]) << (8 * (i-1))
        x₂ |= Int64(v[i+sizeof(Float64)]) << (8 * (i-1))
    end
    (x₁, x₂)
end

"""
    f64x2(x₁::Float64, x₂::Float64)

Creates a simd v128 vector from two Float64.
"""
f64x2(x₁, x₂) = Tuple(reinterpret(UInt8, Float64[x₁, x₂]))
"""
    f64x2(v)::Tuple{Float64,Float64}

Interprets the byte values in the simd vector as two Float64.
"""
function f64x2(v)
    x₁, x₂ = i64x2(v)
    (reinterpret(Float64,x₁),
     reinterpret(Float64,x₂))
end

"""
    i32x4(x₁::Int32, x₂::Int32, x₃::Int32, x₄::Int32)

Creates a simd v128 vector from four Int32.
"""
i32x4(x₁, x₂, x₃, x₄) = Tuple(reinterpret(UInt8, Int32[x₁, x₂, x₃, x₄]))
"""
    i32x4(v)::Tuple{Int32,Int32,Int32,Int32}

Interprets the byte values in the simd vector as four Int32.
"""
function i32x4(v)
    x₁, x₂, x₃, x₄ = zeros(Int32, 4)
    for i in 1:sizeof(Float32)
        x₁ |= Int32(v[i]) << (8 * (i-1))
        x₂ |= Int32(v[i+1sizeof(Float32)]) << (8 * (i-1))
        x₃ |= Int32(v[i+2sizeof(Float32)]) << (8 * (i-1))
        x₄ |= Int32(v[i+3sizeof(Float32)]) << (8 * (i-1))
    end
    (x₁,x₂,x₃,x₄)
end

"""
    f32x4(x₁::Float32, x₂::Float32, x₃::Float32, x₄::Float32)

Creates a simd v128 vector from four Float32.
"""
f32x4(x₁,x₂,x₃,x₄) = Tuple(reinterpret(UInt8, Float32[x₁,x₂,x₃,x₄]))
"""
    f32x4(v)::Tuple{Float32,Float32,Float32,Float32}

Interprets the byte values in the simd vector as four Float32.
"""
function f32x4(v)
    x₁, x₂, x₃, x₄ = i32x4(v)
    Tuple(reinterpret(Float32,x) for x in (x₁,x₂,x₃,x₄))
end

"""
    i16x8(x₁, x₂, x₃, x₄, x₅, x₆, x₇, x₈)

Creates a simd v128 vector from eight Int16.
"""
i16x8(x::Vararg{Int16,8}) = Tuple(reinterpret(UInt8, Int16[x...]))
"""
   i16x8(v)::NTuple{8,Int16}

Interprets the byte values in the simd vector as eight Int16.
"""
function i16x8(v)
    Tuple(reinterpret(Int16, UInt8[v...]))
end

function julia_type_to_valkind(julia_type::Type)::wasm_valkind_enum
    if julia_type == Int32
        WASM_I32
    elseif julia_type == Int64
        WASM_I64
    elseif julia_type == Float32
        WASM_F32
    elseif julia_type == Float64
        WASM_F64
    else
        error("No corresponding valkind for type $julia_type")
    end
end

function valkind_to_julia_type(valkind::wasm_valkind_enum)
    if valkind == WASM_I32
        Int32
    elseif valkind == WASM_I64
        Int64
    elseif valkind == WASM_F32
        Float32
    elseif valkind == WASM_F64
        Float64
    else
        error("No corresponding type for kind $valkind")
    end
end

Base.convert(::Type{wasm_val_t}, i::Int32) = WasmInt32(i)
Base.convert(::Type{wasm_val_t}, i::Int64) = WasmInt64(i)
Base.convert(::Type{wasm_val_t}, f::Float32) = WasmFloat32(f)
Base.convert(::Type{wasm_val_t}, f::Float64) = WasmFloat64(f)

Base.convert(::Type{wasm_val_t}, val::wasm_val_t) = val
function Base.convert(julia_type, wasm_val::wasm_val_t)
    valkind = julia_type_to_valkind(julia_type)
    @assert valkind == wasm_val.kind "Cannot convert a value of kind $(wasm_val.kind) to corresponding kind $valkind"
    ctag = Ref(wasm_val.of)
    ptr = Base.unsafe_convert(Ptr{LibWasmtime.__JL_Ctag_4}, ctag)
    jl_val = GC.@preserve ctag unsafe_load(Ptr{julia_type}(ptr))
    jl_val
end

function Base.show(io::IO, wasm_val::wasm_val_t)
    name, maybe_val = if wasm_val.kind == WASM_I32
        "WasmInt32", wasm_val.of.i32 |> string
    elseif wasm_val.kind == WASM_I64
        "WasmInt64", wasm_val.of.i64 |> string
    elseif wasm_val.kind == WASM_F32
        "WasmFloat32", wasm_val.of.f32 |> string
    elseif wasm_val.kind == WASM_F64
        "WasmFloat64", wasm_val.of.f64 |> string
    else
        "WasmAny", ""
    end

    print(io, "$name($maybe_val)")
end
