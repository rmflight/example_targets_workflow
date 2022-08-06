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
             format = "file"),
  
  # actually read data in
  # This is drake style target definition, which I prefer, and can be done
  # for most other types of targets outside of documents.
  lipid_measurements = readr::read_csv(measurement_file),
  lipid_metadata = readr::read_csv(metadata_file),
  
  # next we want to explore the data and evaluate if there is any funny 
  # things we need to worry about.
  # I prefer to do that in an rmarkdown or quarto document.
  # Use tflow::use_rmd("document") to set this up.
  tar_render(exploration, "doc/exploration.Rmd")
)
