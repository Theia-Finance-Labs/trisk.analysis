library(trisk.model)
devtools::load_all()

endpoint_url <- "https://crispy-datamodels-bucket.fra1.cdn.digitaloceanspaces.com"
s3_path <- "crispy-datamodels-bucket/trisk_V2/csv"
local_save_folder <- file.path("workspace","trisk_inputs")

download_trisk_inputs(endpoint_url, s3_path, local_save_folder)


trisk_output_path <- file.path("workspace","trisk_outputs")

run_trisk(
  input_path = local_save_folder,
  output_path=trisk_output_path,
  baseline_scenario="Steel_baseline",
  target_scenario="Steel_NZ",
  scenario_geography="Global"
)
