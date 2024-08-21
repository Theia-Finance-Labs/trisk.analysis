# trisk-workflow.R
# The main script, calling functions from other scripts

# Load necessary libraries and functions
library(trisk.model)
devtools::load_all()

# OPEN SOURCE DATA DOWNLOAD
# Download TRISK input data from the specified endpoint
endpoint_url <- "https://crispy-datamodels-bucket.fra1.cdn.digitaloceanspaces.com"
s3_path <- "crispy-datamodels-bucket/trisk_V2/csv"
local_trisk_inputs_folder <- file.path("data-raw", "data", "trisk_inputs")

download_trisk_inputs(endpoint_url, s3_path, local_trisk_inputs_folder)

# Set output path for TRISK results
trisk_output_path <- file.path("data-raw", "data", "trisk_outputs")

# SIMPLE TRISK RUN
# Run the TRISK model for a baseline and target scenario, and measure execution time
start_time <- Sys.time()

run_trisk(
  input_path = local_trisk_inputs_folder,
  output_path = trisk_output_path,
  baseline_scenario = "Steel_baseline",
  target_scenario = "Steel_NZ",
  scenario_geography = "Global"
)

end_time <- Sys.time()

time_taken <- end_time - start_time
print(time_taken)

# Print the latest TRISK results for different result types
print(get_latest_trisk_result(trisk_output_path = trisk_output_path, result_type = "npv"))
print(get_latest_trisk_result(trisk_output_path = trisk_output_path, result_type = "pd"))
print(get_latest_trisk_result(trisk_output_path = trisk_output_path, result_type = "trajectories"))
print(get_latest_trisk_result(trisk_output_path = trisk_output_path, result_type = "params"))

# SMALLER RUN (unused)
# Run the TRISK model with a smaller filtered dataset (currently unused)
single_run_params <- list(
  scenario_geography = "Global",
  baseline_scenario = "Steel_baseline",
  target_scenario = "Steel_NZ",
  shock_year = 2030
)

single_filtered_results <- run_trisk_single_filtered(
  input_path = local_trisk_inputs_folder,
  run_params = single_run_params,
  country_iso2 = c("US", "AR"),
  sector = "Steel",
  technology = c("EAF-DRI", "BOF-BF"),
  company_name = NULL
)

# Print the filtered TRISK results for different result types
print(single_filtered_results["npv"])
print(single_filtered_results["pd"])
print(single_filtered_results["trajectories"])
print(single_filtered_results["params"])

# SENSITIVITY ANALYSIS
# Run sensitivity analysis by varying parameters across multiple TRISK runs
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

sensitivity_analysis_results <- run_trisk_sa(
  input_path = local_trisk_inputs_folder,
  run_params = run_params
)

# Print sensitivity analysis results for different result types
sensitivity_analysis_results["npv"]
sensitivity_analysis_results["pd"]
sensitivity_analysis_results["trajectories"]
sensitivity_analysis_results["params"]

# SENSITIVITY ANALYSIS ON SUBSET
# Run sensitivity analysis on a subset of assets, filtered by country, sector, and technology
sensitivity_analysis_results_on_filtered_assets <- run_trisk_sa(
  input_path = local_trisk_inputs_folder,
  run_params = run_params,
  country_iso2 = c("US", "AR"),
  sector = "Steel",
  technology = c("EAF-DRI", "BOF-BF")
)

# Print sensitivity analysis results for the filtered subset
sensitivity_analysis_results_on_filtered_assets["npv"]
sensitivity_analysis_results_on_filtered_assets["pd"]
sensitivity_analysis_results_on_filtered_assets["trajectories"]
sensitivity_analysis_results_on_filtered_assets["params"]
