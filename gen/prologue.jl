# This file (`LibWasm.jl` not `prologue.jl`) is automatically generated using
# Clang.jl and should not be edited manually. Take a look at the `gen/` folder
# if something is to be changed.

using Pkg.Artifacts
using Pkg.BinaryPlatforms

tripletnolibc(platform) = replace(triplet(platform), "-gnu" => "")
wasmtime_folder_name(platform) =
    "wasmtime-v$release_version-$(tripletnolibc(platform))-c-api"

function get_libwasmtime_location()
    artifact_info = artifact_meta("libwasmtime", joinpath(@__DIR__, "..", "Artifacts.toml"))
    artifact_info === nothing && return nothing

    parent_path = artifact_path(Base.SHA1(artifact_info["git-tree-sha1"]))
    child_folder = readdir(parent_path)[1]
    return joinpath(
        parent_path,
        child_folder,
        "lib/libwasmtime.so"
    )
end

const libwasmtime_env_key = "LIBWASMTIME_LOCATION"
const libwasmtime = haskey(ENV, libwasmtime_env_key) ?
    ENV[libwasmtime_env_key] : get_libwasmtime_location()
