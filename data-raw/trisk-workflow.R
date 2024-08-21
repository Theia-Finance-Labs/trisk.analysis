library(trisk.model)
devtools::load_all()

# OPEN SOURCE DATA DOWNLOAD

endpoint_url <- "https://crispy-datamodels-bucket.fra1.cdn.digitaloceanspaces.com"
s3_path <- "crispy-datamodels-bucket/trisk_V2/csv"
local_trisk_inputs_folder <- file.path("data-raw", "data", "trisk_inputs")

download_trisk_inputs(endpoint_url, s3_path, local_trisk_inputs_folder)


trisk_output_path <- file.path("data-raw", "data", "trisk_outputs")

# SIMPLE TRISK RUN

start_time <- Sys.time()

run_trisk(
  input_path = local_trisk_inputs_folder,
  output_path=trisk_output_path,
  baseline_scenario="Steel_baseline",
  target_scenario="Steel_NZ",
  scenario_geography="Global"
)

end_time <- Sys.time()

time_taken <- end_time - start_time
print(time_taken)

get_latest_trisk_result <- function(trisk_output_path, result_type)

# SMALLER RUN
single_run_params <-   list(
    scenario_geography = "Global",
    baseline_scenario = "Steel_baseline",
    target_scenario = "Steel_NZ",
    shock_year = 2030
  )
single_filtered_results <- run_trisk_single_filtered(
                                      input_path=local_trisk_inputs_folder, 
                                      run_params=single_run_params,
                                      country_iso2 = c("US", "AR"), 
                                      sector = "Steel", 
                                      technology = c("EAF-DRI", "BOF-BF"), 
                                      company_name = NULL)


single_filtered_results["npv"]
single_filtered_results["pd"]
single_filtered_results["trajectories"]
single_filtered_results["params"]


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


sensitivity_analysis_results <- run_trisk_sa(
  input_path=local_trisk_inputs_folder, 
  run_params=run_params
)

sensitivity_analysis_results["npv"]
sensitivity_analysis_results["pd"]
sensitivity_analysis_results["trajectories"]
sensitivity_analysis_results["params"]



