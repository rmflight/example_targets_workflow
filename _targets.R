## Load your packages, e.g. library(targets).
source("./packages.R")

## Load your R files
lapply(list.files("./R", full.names = TRUE), source)

## tar_plan supports drake-style targets and also tar_target()
tar_plan(

  # setup the file data sources first, so if they change,
  # everything else will get rerun.
  # Because we want to indicate the type of target specifically to be
  # a "file", we use the `tar_target` format.
  tar_target(measurement_file,
             "data/sample_measurements.csv",
             format = "file"),
  tar_target(metadata_file,
             "data/sample_metadata.csv",
             format = "file")
)
