struct Models{T <: Dict{Any, Any}} # Any, Any because Python
    clear::T
    haze::T
    spot::T
    spot_haze::T
end

struct Retrievals{T <: Models}
    Na::T
    K::T
    TiO::T
    Na_K::T
    Na_TiO::T
    K_TiO::T
    Na_K_TiO::T
end

const models = collect(fieldnames(Models))
const species = collect(fieldnames(Retrievals))

function load_retrieval_data(BASE_DIR, model_types)
    retrieval_data = Retrievals(
        (
            Models(
                load_pickle("$(BASE_DIR)/$(model_types.clear)_$(sp)/retrieval.pkl"),
                load_pickle("$(BASE_DIR)/$(model_types.haze)_$(sp)/retrieval.pkl"),
                load_pickle("$(BASE_DIR)/$(model_types.spot)_$(sp)/retrieval.pkl"),
                load_pickle("$(BASE_DIR)/$(model_types.spot_haze)_$(sp)/retrieval.pkl"),
            ) for sp in fieldnames(Retrievals)
        )...
    )
end

function get_evidences(retrieval_data)
    N_species, N_models = length(species), length(models)
    evidences = Array{Measurement{Float64}}(undef, N_species, N_models)

    for (i, model) in enumerate(models)
        for (j, sp) in enumerate(species)
            retr = getfield(getfield(retrieval_data, sp), model)
            evidences[j, i] = retr["lnZ"] ± retr["lnZerr"]
        end
    end

    return evidences
end
