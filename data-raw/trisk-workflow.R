library(trisk.model)
devtools::load_all()

# BASIC EXAMPLE

endpoint_url <- "https://crispy-datamodels-bucket.fra1.cdn.digitaloceanspaces.com"
s3_path <- "crispy-datamodels-bucket/trisk_V2/csv"
local_trisk_inputs_folder <- file.path("workspace","trisk_inputs")

download_trisk_inputs(endpoint_url, s3_path, local_trisk_inputs_folder)


trisk_output_path <- file.path("workspace","trisk_outputs")

run_trisk(
  input_path = local_trisk_inputs_folder,
  output_path=trisk_output_path,
  baseline_scenario="Steel_baseline",
  target_scenario="Steel_NZ",
  scenario_geography="Global"
)


# SENSITIVITY ANALYSIS

run_params <- list(
  list(
    scenario_geography = "Global",
    baseline_scenario = "Steel_baseline",
    target_scenario = "Steel_NZ",
    shock_year = 2030
  ),
  list(
    scenario_geography = "Global",
    baseline_scenario = "Steel_baseline",
    target_scenario = "Steel_NZ",
    shock_year = 2025
  )
)


sensitivity_analysis_results <- run_trisk_and_collect_results(
  input_path=local_trisk_inputs_folder, 
  run_params=run_params
)

sensitivity_analysis_results["npv"]
sensitivity_analysis_results["pd"]
sensitivity_analysis_results["trajectories"]
sensitivity_analysis_results["params"]







