function norm_data(A; dims=1, use_MAD=false)
    A = Matrix{Float64}(A)

    if use_MAD
        return (A .- median(A, dims=dims)) ./ mapslices(mad, A, dims=1)
    else
        return (A .- mean(A, dims=dims)) ./ std(A, dims=dims, corrected=false)
    end
end

function classic_PCA(data; dims=1, standardize=true)
    A = standardize ? norm_data(data, dims=dims, use_MAD=true) : copy(data)
    U, S, V = svd(cov(A))
    return V, S, A * V
end
