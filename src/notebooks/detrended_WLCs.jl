### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 67ce08a4-9a04-11eb-2800-d5325a874022
begin
	using Revise
	using Pkg
	Pkg.activate("../..")
	Pkg.instantiate()
	using ACCESS
	using CSV
	using DelimitedFiles
	using StatsPlots
	using Measurements
	using CCDReduction
	using PlutoUI
	using BenchmarkTools
	using Glob, FITSIO, DataFramesMeta
	using Statistics
	using Unitful, UnitfulAstro
	using MultivariateStats, LinearAlgebra, StatsBase
end

# ╔═╡ 94595695-b439-4032-924d-fba32a481199
TableOfContents()

# ╔═╡ 67366046-900f-43c9-9ede-359bca71ef55
base_dir = "/home/mango/data/data_detrending/WASP50b/out_l/WASP50/w50_131219/white-light"

# ╔═╡ 670ad85c-6ab7-4652-ab78-ea83b2993927
lc_path = "$base_dir/lc.dat"

# ╔═╡ 4a438e18-edb9-4992-b859-70a5bf31834b
BMA_results_path = "$base_dir/results.dat"

# ╔═╡ eef8fa8c-4989-4721-bcc9-42167bbfd325
comps_path = "$base_dir/comps.dat"

# ╔═╡ b33bdd2a-d4c6-44ca-ab14-fc67552e3f2c
eparams_path = "$base_dir/../eparams.dat"

# ╔═╡ 099a0f42-70c6-499d-a7dd-fb6d1d8832f4
md"""
## Raw data
"""

# ╔═╡ 763e1621-7922-4bc7-ad7d-6d6888ed778d
lc_data = CSV.File(lc_path, header=["t", "f", "f_index"])

# ╔═╡ ea2d99ac-feb6-4b3a-bee0-72c60c070755
begin
	idx = lc_data.f_index .== 0;
	t, f = lc_data.t[idx], lc_data.f[idx]
end

# ╔═╡ 92bb0deb-d2b9-4826-ad50-6a4c11a86c59
md"""
## External params
"""

# ╔═╡ 13cb7356-6e36-4565-b586-f05e3fab4b2f
eparams = CSV.read(eparams_path, DataFrame, normalizenames=true)

# ╔═╡ e85b316c-f0a3-4892-964b-53e7577cac25
X = norm_data(eparams, dims=1)

# ╔═╡ a119f4b6-ab36-493b-b732-a055f09cdc54
md"""
## Comp stars
"""

# ╔═╡ c04b2b40-d3dd-47ed-bee7-a4e42ece3f96
comps = CSV.read(comps_path, DataFrame, header=false)

# ╔═╡ c4f1f656-ce41-4319-a394-cae2094fdd14
Xc = norm_data(comps, dims=1)

# ╔═╡ 51aebd47-156c-4bf7-b991-f1c4ff0ee8b5
plot_params(A, A_names) = plot(A, label=reshape(names(A_names), (1, :)))

# ╔═╡ 29a716f5-740a-4e5e-abea-f902b6d195f0
plot_params(X, eparams)

# ╔═╡ d621bf6d-c6ab-4626-89fd-6f5d5ac68a47
plot_params(Xc, comps)

# ╔═╡ 519cd15e-e6a0-4d7f-b9c7-40be545fa373
md"""
## PCA
"""

# ╔═╡ c52b38fb-bd77-4176-a570-0923aa99cc07
V, S, A = classic_PCA(Xc)

# ╔═╡ 83760c7c-fe94-4b4b-a7c9-ca20c051a973
# 	# Load pickle
# 	gpts_pkl_to_dict = load_pickle(


# )
# 	# Show keys
# 	println(keys(gpts_pkl_to_dict))

# 	# Load specified params
# 	const gpts_params = ["p", "t0", "P", "rho", "inc", "b", "aRs", "q1"]
# 	gpts_params_dict = sub_dict(
# 		gpts_pkl_to_dict, gpts_params
# 	)

# 	# Add desired offsets
# 	gpts_params_dict[:t0] .-= 2.45485e6; gpts_params_dict

# 	# Load into DataFrame
# 	df_gpts = DataFrame(gpts_params_dict)

# ╔═╡ 030a5a05-8009-4a3d-8e83-a1979fadf9f4
import DarkMode

# ╔═╡ 23987d7b-187d-47d8-a3d3-99c1a9fa8b8c
#DarkMode.enable()

# ╔═╡ be317a00-2c87-4b38-8ab5-fb4cf7c32bf2
begin
	const pal = palette(
		[
			"#f5d300", # yellow
			"#d55e00", # orange
			"#08f7fe", # cyan
			"#0173b2", # blue
			"#b2df8a", # light green
			"#029e73", # green
		]
	)
	theme(:dark)
	default(
		titlefont = "Lato",
		guidefont = "Lato",
		markerstrokewidth = 0,
		palette = pal,
		dpi = 250,
		fmt = :png,
	)
end

# ╔═╡ Cell order:
# ╟─94595695-b439-4032-924d-fba32a481199
# ╠═67366046-900f-43c9-9ede-359bca71ef55
# ╠═670ad85c-6ab7-4652-ab78-ea83b2993927
# ╠═4a438e18-edb9-4992-b859-70a5bf31834b
# ╠═eef8fa8c-4989-4721-bcc9-42167bbfd325
# ╠═b33bdd2a-d4c6-44ca-ab14-fc67552e3f2c
# ╟─099a0f42-70c6-499d-a7dd-fb6d1d8832f4
# ╠═763e1621-7922-4bc7-ad7d-6d6888ed778d
# ╠═ea2d99ac-feb6-4b3a-bee0-72c60c070755
# ╟─92bb0deb-d2b9-4826-ad50-6a4c11a86c59
# ╠═13cb7356-6e36-4565-b586-f05e3fab4b2f
# ╠═e85b316c-f0a3-4892-964b-53e7577cac25
# ╠═29a716f5-740a-4e5e-abea-f902b6d195f0
# ╟─a119f4b6-ab36-493b-b732-a055f09cdc54
# ╠═c04b2b40-d3dd-47ed-bee7-a4e42ece3f96
# ╠═c4f1f656-ce41-4319-a394-cae2094fdd14
# ╠═d621bf6d-c6ab-4626-89fd-6f5d5ac68a47
# ╠═51aebd47-156c-4bf7-b991-f1c4ff0ee8b5
# ╟─519cd15e-e6a0-4d7f-b9c7-40be545fa373
# ╠═c52b38fb-bd77-4176-a570-0923aa99cc07
# ╠═83760c7c-fe94-4b4b-a7c9-ca20c051a973
# ╠═67ce08a4-9a04-11eb-2800-d5325a874022
# ╠═030a5a05-8009-4a3d-8e83-a1979fadf9f4
# ╠═23987d7b-187d-47d8-a3d3-99c1a9fa8b8c
# ╠═be317a00-2c87-4b38-8ab5-fb4cf7c32bf2
