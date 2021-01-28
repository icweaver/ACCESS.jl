### A Pluto.jl notebook ###
# v0.12.20

using Markdown
using InteractiveUtils

# This Pluto notebook uses @bind for interactivity. When running this notebook outside of Pluto, the following 'mock version' of @bind gives bound variables a default value (instead of an error).
macro bind(def, element)
    quote
        local el = $(esc(element))
        global $(esc(def)) = Core.applicable(Base.get, el) ? Base.get(el) : missing
        el
    end
end

# ╔═╡ 773a7b60-5a6c-11eb-0a88-1de623c4a412
begin
	using Revise
	using ACCESS
end

# ╔═╡ df49009b-0f51-419b-b84c-99ea3610aa6c
using PlutoUI

# ╔═╡ edbe9545-e948-4cdb-94c9-eea816b8cb7e
md"""
# 🪐 ACCESS Notebook
"""

# ╔═╡ 24519e4d-5cfc-4ff7-acec-632088d84757
TableOfContents()

# ╔═╡ f9cbabb3-7a98-46fd-adee-0ea2a1e53284
md"""## $(@bind run_GPT_WLC CheckBox()) GPT WLC

Visualize GPT data stored in `GPT_DET_WLC`
"""

# ╔═╡ 1061134b-a53c-4abb-96b5-b95def13f02b
if run_GPT_WLC
	# Load pickle
	gpts_pkl_to_dict = load_pickle(
	"Projects/HATP23b/data_detrending/out_c/HATP23b/hp23b_160621_custom/white-light/BMA_posteriors.pkl"
)
	# Show keys
	println(keys(gpts_pkl_to_dict))
	
	# Load specified params
	const gpts_params = ["p", "t0", "P", "rho", "inc", "b", "aRs", "q1"]
	gpts_params_dict = sub_dict(
		gpts_pkl_to_dict, gpts_params
	)
	
	# Add desired offsets
	gpts_params_dict[:t0] .-= 2.45485e6; gpts_params_dict
	
	# Load into DataFrame
	df_gpts = DataFrame(gpts_params_dict)
end

# ╔═╡ 2a9ead8e-619d-11eb-15ee-43f8d97c4f19
md"""## $(@bind run_retrievals CheckBox()) `exoretrievals`

Summarize Bayesian evidences returned by `exoretrievals`
"""

# ╔═╡ 4ffdfbc0-619d-11eb-1506-65e1a4efabb7
if run_retrievals
	const BASE_DIR = "data_retrievals/spot_lower_bound"
	const model_types = (
		clear = "HATP23_E1_NoHet_FitP0_NoClouds_NoHaze_fitR0",
		haze = "HATP23_E1_NoHet_FitP0_NoClouds_Haze_fitR0",
		spot = "HATP23_E1_Het_FitP0_NoClouds_NoHaze_fitR0",
		spot_haze = "HATP23_E1_Het_FitP0_NoClouds_Haze_fitR0",
	)
	
	retrieval_data = load_retrieval_data(BASE_DIR, model_types)
	
	Z = get_evidences(retrieval_data)
	
	min_Z, min_Z_loc = findmin(Z)
	
	ΔlnZ = Z .- min_Z
end

# ╔═╡ 84b6b120-61a9-11eb-2bc8-df73e542a46d
if run_retrievals
	species = names(Z, 1)
	models = names(Z, 2)
	ΔlnZ_mat = hcat(Symbol.(species), ΔlnZ.array)
	min_model = species[min_Z_loc[1]], models[min_Z_loc[2]]
	md"Lowest evidence: $(min_model)"
end

# ╔═╡ 4ebb0012-61a9-11eb-1513-678e52371305
md"""
### Copy paste ``\LaTeX`` table
"""

# ╔═╡ 14d5c3b2-61a8-11eb-349f-cb24dc8b57ea
if run_retrievals
	with_terminal() do
		lap(ΔlnZ_mat)
	end
end

# ╔═╡ a7f5ccb5-3a63-4197-91cf-942d894f58ba
md"""
## Packages
"""

# ╔═╡ Cell order:
# ╟─edbe9545-e948-4cdb-94c9-eea816b8cb7e
# ╟─24519e4d-5cfc-4ff7-acec-632088d84757
# ╟─f9cbabb3-7a98-46fd-adee-0ea2a1e53284
# ╠═1061134b-a53c-4abb-96b5-b95def13f02b
# ╟─2a9ead8e-619d-11eb-15ee-43f8d97c4f19
# ╟─84b6b120-61a9-11eb-2bc8-df73e542a46d
# ╠═4ffdfbc0-619d-11eb-1506-65e1a4efabb7
# ╟─4ebb0012-61a9-11eb-1513-678e52371305
# ╟─14d5c3b2-61a8-11eb-349f-cb24dc8b57ea
# ╟─a7f5ccb5-3a63-4197-91cf-942d894f58ba
# ╠═773a7b60-5a6c-11eb-0a88-1de623c4a412
# ╠═df49009b-0f51-419b-b84c-99ea3610aa6c
