
# PARAMS
# Set search space parameters for mlrMBO

param.set <- makeParamSet(

  # Heat Transfer procs X
  makeIntegerParam("ht_procs_x", lower = 1, upper = 4),
  # Heat Transfer procs
  makeIntegerParam("ht_procs_y", lower = 1, upper = 4),
  # Stage Write procs
  makeIntegerParam("sw_procs", lower = 1, upper = 16)
)
