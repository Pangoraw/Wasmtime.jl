const wasmer_location = get(ENV, "WASMER_LOCATION", "../wasmer")
const libwasmer = joinpath(wasmer_location, "lib/libwasmer.so")
