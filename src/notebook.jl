### A Pluto.jl notebook ###
# v0.12.18

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

# ╔═╡ a7f5ccb5-3a63-4197-91cf-942d894f58ba
md"""
## Packages
"""

# ╔═╡ Cell order:
# ╟─edbe9545-e948-4cdb-94c9-eea816b8cb7e
# ╟─24519e4d-5cfc-4ff7-acec-632088d84757
# ╟─f9cbabb3-7a98-46fd-adee-0ea2a1e53284
# ╠═1061134b-a53c-4abb-96b5-b95def13f02b
# ╟─a7f5ccb5-3a63-4197-91cf-942d894f58ba
# ╠═773a7b60-5a6c-11eb-0a88-1de623c4a412
# ╠═df49009b-0f51-419b-b84c-99ea3610aa6c
