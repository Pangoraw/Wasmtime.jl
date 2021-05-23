using Clang.Generators
using Clang.LibClang.Clang_jll

cd(@__DIR__)

# Location of the extracted wasmer.tar.gz
wasmer_location = get(ENV, "WASMER_LOCATION", "../wasmer")

options = load_options(joinpath(@__DIR__, "generator.toml"))

# add compiler flags
args = get_default_args()

headers = [joinpath(wasmer_location, "include/wasm.h")]

# create context
ctx = create_context(headers, args, options)

# build without printing so we can do custom rewriting
build!(ctx, BUILDSTAGE_NO_PRINTING)

# custom rewriter
function rewrite!(e::Expr)
    Meta.isexpr(e, :const) || return e

    eq = e.args[1]
    if eq.head === :(=) && eq.args[1] === :WASM_EMPTY_VEC
      e.args[1].args[2] = nothing
    elseif eq.head === :(=) && eq.args[1] === :wasm_name && eq.args[2] === :wasm_byte_vec
      e.args[1].args[2] = :wasm_byte_vec_t
    elseif eq.head === :(=) && eq.args[1] === :wasm_byte_t
      e.args[1].args[2] = :UInt8
    end

    return e
end

function rewrite!(dag::ExprDAG)
    for node in get_nodes(dag)
        for expr in get_exprs(node)
            rewrite!(expr)
        end
    end
end

rewrite!(ctx.dag)

# print
build!(ctx, BUILDSTAGE_PRINTING_ONLY)

