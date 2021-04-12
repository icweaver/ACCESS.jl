"""
    norm_data(A; dims=1, use_MAD::Bool=false, corrected::Bool=false)

Computes ``\\frac{A - \\bar A}{\\sigma}``, where `dims` is 1 (the default) if `A` is
column-oriented and 2 if it is row-oriented. If `use_MAD` is `true`, ``\\bar A`` is
`median(A, dims=dims)` and ``\\sigma`` is the MAD version of the standard deviation. If
`use_MAD` is `false`, ``\\bar A`` is `mean(A, dims=dims)` and ``\\sigma`` is the standard
deviation. If `corrected` is `true` then the sum is scaled with `n-1`, whereas the sum is
scaled with `n` if `corrected` is `false`, where `n = size(A, dims)`.
"""
function norm_data(A; dims=1, use_MAD=false, corrected=false)
    A = Matrix{Float64}(A)
    if use_MAD
        return (A .- median(A, dims=dims)) ./ mapslices(mad, A, dims=dims)
    else
        return (A .- mean(A, dims=dims)) ./ std(A, dims=dims, corrected=corrected)
    end
end

"""
    classic_PCA(A; dims=1, standardize::Bool=true, corrected::Bool=false)

Performs PCA on a copy of the ``m × n`` matrix `A`. `dims` is 1 (the default) if `A` is
column-oriented and 2 if it is row-oriented. If `standardize` is `true` (the default), the
copy will be transformed using the MAD version of the standard deviation. If `corrected`
is `true` then the sum is scaled with `n-1`, whereas the sum is scaled with `n` if
`corrected` is `false`, where `n = size(A, dims)`.

Returns `(V, S, prod)`, where ``A = U Σ V^*``, with ``Σ = \\text{diagm}(S)`` being the
diagonal matrix of singular values sorted in descending order and `prod` is the matrix
multiplication of `V` and `A`, with `A` being standardized by default.
"""
function classic_PCA(A; dims=1, standardize=true, corrected=false)
    data = copy(A)
    data = standardize ? norm_data(data, dims=dims, use_MAD=true, corrected=corrected) : data
    U, S, V = svd(cov(data, dims=dims, corrected=corrected))
    prod = dims == 1 ? data * V : V' * data
    return V, S, prod
end
