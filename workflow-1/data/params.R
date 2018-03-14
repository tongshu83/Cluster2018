
# PARAMS
# Set search space parameters for mlrMBO

param.set <- makeParamSet(
#   makeIntegerParam("epochs", lower = 2, upper = 6),
#   makeDiscreteParam("dense", values = c("1000 500 100 50"))

  # Heat Transfer procs
  makeIntegerParam("ht_procs", lower = 1, upper = 10),
  # Stage Write procs
  makeIntegerParam("sw_procs", lower = 1, upper = 10)
)
