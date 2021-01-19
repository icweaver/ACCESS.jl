module ACCESS

using PyCall: @py_str

export load_pickle

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

# function __init__()
#     py"""
#     import numpy as np
#     import pickle
#
#     def load_pickle(fpath):
#         with open(fpath, "rb") as f:
#             data = pickle.load(f)
#         return data
#     """
# end
# load_pickle = py"load_pickle"

end # module
