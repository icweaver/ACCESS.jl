module ACCESS

using DataFrames: DataFrame
using PyCall: @py_str

export load_pickle, sub_dict, DataFrame

include("load.jl")

function __init__()
    py"""
    import pickle

    def load_pickle(fpath):
        with open(fpath, "rb") as f:
            data = pickle.load(f)
        return data
    """
end
load_pickle(s) = py"load_pickle"(s)

end # module
