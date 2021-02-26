### A Pluto.jl notebook ###
# v0.12.21

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
	using Pkg
	Pkg.activate("..")
	Pkg.instantiate()
	using ACCESS
	using CSV
	using StatsPlots
	using Measurements
	using CCDReduction
	using PlutoUI
	using BenchmarkTools
	using Glob, FITSIO, DataFramesMeta
	using Statistics
end

# ╔═╡ edbe9545-e948-4cdb-94c9-eea816b8cb7e
md"""
# 🪐 ACCESS Notebook
"""

# ╔═╡ 24519e4d-5cfc-4ff7-acec-632088d84757
TableOfContents()

# ╔═╡ a457660a-7167-11eb-0eb6-adcef9cf0bb9
md"""## $(@bind run_data_info CheckBox()) Data info

View header information
"""

# ╔═╡ c452dfb6-7167-11eb-3b93-dba356a52ec3
if run_data_info
	const DATA_DIR = "/home/mango/data/WASP50/wasp50_ut161211"
	df = fitscollection(
		DATA_DIR;
		recursive=false,
		exclude=r"^((?!ift[0-9]{4}c4.fits).)*$",
		exclude_key=("", "COMMENT"),
	)
	
	# Select header items to show
	cols = [
		"FILENAME",
		"OBJECT",
		"DISPERSR",
		"SLITMASK",
		"SPEED",
		"FILTER",
		"EXPTIME",
		"BINNING",
		"UT-DATE",
		"UT-TIME",
		"RA",
		"DEC",
		"EQUINOX",
		"EPOCH",
		"AIRMASS",
		"OBSERVER",
	]
	night_log = select(df, cols)
	
	#CSV.write("/home/mango/Desktop/test.csv", night_log; delim="    ")
end

# ╔═╡ a4eadc9c-cb5d-4c76-a313-3e207182f70c
if run_data_info
	with_terminal() do
		for df in groupby(night_log, "OBJECT")
			println(
				unique(df[!, "OBJECT"]),
				" ",
				length(df[!, "OBJECT"]),
				" ",
				df[1, "FILENAME"]
			)
			for col in ["SLITMASK", "DISPERSR", "FILTER", "EXPTIME"]
				println(col, unique(df[!, col]))
			end
			println()
		end
	end
end

# ╔═╡ d4214693-34a5-44c3-9ba5-898b703e9503
# begin
# 	# 724 ± 7, HAT-P-26
# 	# 136 ± 7, c01
# 	# 880 ± 7, c03
# 	# 510 ± 7, c05
# 	spec_2ds = []
# 	for df in eachrow(df_sci)
# 		get_2D_spectra!(spec_2ds, df; x_cen=510)
# 	end
# end

# ╔═╡ 56819d41-5e06-463b-b927-969eac0c6da9
# begin
# 	top_5s = []
	
# 	for spec_2d in spec_2ds
# 		top_5 = partialsort(vec(spec_2d), 1:5; rev=true)
# 		push!(top_5s, top_5)
# 	end
# end

# ╔═╡ 0b96bbab-fd2d-4cea-967b-b19293c9ac82
# let
# 	title = "c05"
# 	p = scatter(
# 		ylims = (0, 65_000),
# 		xlabel = "Science frame",
# 		ylabel = "Top 5 counts",
# 		legend = false,
# 		title = title,
# 	)

# 	for (i, top_5) in enumerate(top_5s)
# 		scatter!(p, fill(i, 5), top_5s[i], c=pal[4])
# 	end
	
# 	savefig(p, "/home/mango/Desktop/$(title)_top5.png")
	
# 	p
# end

# ╔═╡ 9cb16d97-6116-4c94-a1ec-356f1a97ee15
# function get_2D_spectra!(spec_2ds, df; x_cen=0, app=7)
# 	FITS(df.path) do f
# 		data = read(f[1])[x_cen-app÷2 : x_cen+app÷2, :]
# 		push!(spec_2ds, data)
# 	end
# end

# ╔═╡ 5031a1ce-7803-11eb-15b8-4f3d867409b4
md"""
### $(@bind run_init_spec CheckBox()) Intitial Extracted spectra
From spec.fits files
"""

# ╔═╡ 4903d454-7811-11eb-1cc2-4d1fa33da6e1
@bind data_dir Select(readdir("/home/mango/data/data_reductions/WASP50"))

# ╔═╡ b93d53f6-7809-11eb-1924-47c439b506a9
@bind extr_spec_key Select([
	"Wavelength",
	"Simple extracted object spectrum",
	"Simple extracted flat spectrum",
	"Pixel sensitivity (obtained by the flat)",
	"Simple extracted object spectrum/pixel sensitivity",
	"Sky flag (0 = note uneven sky, 1 = probably uneven profile,
		2 = Sky_Base failed)",
	"Optimally extracted object spectrum",
	"Optimally extracted object spectrum/pixel sensitivity",
])

# ╔═╡ c34212e6-780a-11eb-035b-d3d3b4750145
if run_init_spec
	df_spec = fitscollection(
		"/home/mango/data/data_reductions/WASP50/$data_dir";
		recursive=false,
		#exclude=r"^((?!ift[0-9]{4}c4.fits).)*$",
		#exclude_key=("", "COMMENT"),
	)

	# p = plot()
	# plot!(
	# 	p,
	# 	extracted_spectra_med,
	# 	ribbon = σ,
	# 	#label = label,
	# 	legend = :topright,
	# )
end

# ╔═╡ 06b86f86-780e-11eb-1e2c-27150bbb2140
if run_init_spec
	spec_index = Dict(
		"Wavelength" => 1,
		"Simple extracted object spectrum" => 2,
		"Simple extracted flat spectrum" => 3,
		"Pixel sensitivity (obtained by the flat)" => 4,
		"Simple extracted object spectrum/pixel sensitivity" => 5,
		"Sky flag (0 = note uneven sky, 1 = probably uneven profile,
		2 = Sky_Base failed)" => 6,
		"Optimally extracted object spectrum" => 7,
		"Optimally extracted object spectrum/pixel sensitivity" => 8,
	)[extr_spec_key]
	# imgs = arrays(df_spec) |> collect
	# d = imgs[1][:, 2, :]
	# extracted_spectra_med = median(d, dims=1) |> vec
	# σ = std(d, dims=1) |> vec
	
	extracted_spec_med = map(arrays(df_spec)) do arr
		median(arr[:, spec_index, :], dims=1) |> vec
	end
end;

# ╔═╡ 20af7a2e-780e-11eb-112b-e9382852c19f
#plot(extracted_spec_med, label=reshape(df_spec.name, 1, :), legend=:outertopright)
plot(
	extracted_spec_med,
	label = label=reshape(df_spec.name, 1, :),
	legend = :outertopleft,
	palette = :Paired,
	title = "$data_dir: $extr_spec_key",
)

# ╔═╡ c2437308-780f-11eb-2de2-2344288d6c14
plotly()

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
if run_retrievals
	md"""
	### Copy paste ``\LaTeX`` table
	"""
end

# ╔═╡ 14d5c3b2-61a8-11eb-349f-cb24dc8b57ea
if run_retrievals
	with_terminal() do
		lap(ΔlnZ_mat)
	end
end

# ╔═╡ 78561026-61b6-11eb-2100-153023cf94cf
if run_retrievals
	md"""
	### Evidences graph
	"""
end

# ╔═╡ 63378968-61b1-11eb-2ca4-d35d300a7b68
if run_retrievals
	groupedbar(
		species,
		ΔlnZ;
		label = reshape(models, 1, :),
		lw = 0,
		xlabel = "Species",
		ylabel = "Relative change in log-evidence",
		legend = :outertopright,
		title = BASE_DIR,
		fmt = :png,
		dpi = 250,
	)
end

# ╔═╡ a7f5ccb5-3a63-4197-91cf-942d894f58ba
md"""
## Packages
"""

# ╔═╡ 110457da-61bf-11eb-1a02-916d60cb2096
begin
	const pal = palette(["#f5d300", "#d55e00", "#08f7fe", "#0173b2", "#029e73"])
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
# ╟─edbe9545-e948-4cdb-94c9-eea816b8cb7e
# ╟─24519e4d-5cfc-4ff7-acec-632088d84757
# ╠═a457660a-7167-11eb-0eb6-adcef9cf0bb9
# ╠═c452dfb6-7167-11eb-3b93-dba356a52ec3
# ╠═a4eadc9c-cb5d-4c76-a313-3e207182f70c
# ╠═d4214693-34a5-44c3-9ba5-898b703e9503
# ╠═56819d41-5e06-463b-b927-969eac0c6da9
# ╠═0b96bbab-fd2d-4cea-967b-b19293c9ac82
# ╠═9cb16d97-6116-4c94-a1ec-356f1a97ee15
# ╟─5031a1ce-7803-11eb-15b8-4f3d867409b4
# ╟─4903d454-7811-11eb-1cc2-4d1fa33da6e1
# ╟─b93d53f6-7809-11eb-1924-47c439b506a9
# ╟─c34212e6-780a-11eb-035b-d3d3b4750145
# ╟─06b86f86-780e-11eb-1e2c-27150bbb2140
# ╟─20af7a2e-780e-11eb-112b-e9382852c19f
# ╠═c2437308-780f-11eb-2de2-2344288d6c14
# ╠═f9cbabb3-7a98-46fd-adee-0ea2a1e53284
# ╠═1061134b-a53c-4abb-96b5-b95def13f02b
# ╟─2a9ead8e-619d-11eb-15ee-43f8d97c4f19
# ╟─84b6b120-61a9-11eb-2bc8-df73e542a46d
# ╠═4ffdfbc0-619d-11eb-1506-65e1a4efabb7
# ╟─4ebb0012-61a9-11eb-1513-678e52371305
# ╟─14d5c3b2-61a8-11eb-349f-cb24dc8b57ea
# ╟─78561026-61b6-11eb-2100-153023cf94cf
# ╠═63378968-61b1-11eb-2ca4-d35d300a7b68
# ╟─a7f5ccb5-3a63-4197-91cf-942d894f58ba
# ╠═773a7b60-5a6c-11eb-0a88-1de623c4a412
# ╠═110457da-61bf-11eb-1a02-916d60cb2096
