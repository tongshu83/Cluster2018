
# PARAMS
# Set search space parameters for mlrMBO

param.set <- makeParamSet(

  # Heat Transfer procs X
  makeIntegerParam("ht_procs_x", lower = 3, upper = 3),
  # Heat Transfer procs
  makeIntegerParam("ht_procs_y", lower = 3, upper = 3),
  # Stage Write procs
  makeIntegerParam("sw_procs", lower = 4, upper = 4)
)
