# TRISK Analysis

This repository contains a workflow for running the TRISK model to assess financial impacts of a transition towards a low-carbon economy based on different climate scenarios.

- [TRISK Analysis](#trisk-analysis)
  - [Introduction](#introduction)
  - [Installation](#installation)
  - [Main Functions](#main-functions)
    - [download\_trisk\_inputs()](#download_trisk_inputs)
      - [Usage Example](#usage-example)
      - [Parameters](#parameters)
    - [run\_trisk()](#run_trisk)
      - [Usage Example](#usage-example-1)
      - [Parameters](#parameters-1)
    - [run\_trisk\_single\_filtered()](#run_trisk_single_filtered)
      - [Usage Example](#usage-example-2)
      - [Parameters](#parameters-2)
    - [run\_trisk\_sa()](#run_trisk_sa)
      - [Usage Example](#usage-example-3)
      - [Parameters](#parameters-3)

## Introduction

The TRISK model helps in understanding the financial impacts of different climate scenarios on specific industries or sectors. This workflow guides you through setting up and running the TRISK model, including downloading necessary data, running basic and advanced scenarios, and performing sensitivity analysis.

## Installation

To get started, install the required packages from GitHub:

```r
devtools::install_github("Theia-Finance-Labs/trisk.analysis")
```

## Main Functions

### download_trisk_inputs()

Downloads the necessary input data required for running the TRISK model.


The function downloads several CSV files (`assets.csv`, `financial_features.csv`, `scenarios.csv`, `ngfs_carbon_price.csv`) and saves them to the specified local folder.

#### Usage Example

```r
endpoint_url <- "https://scenarios-repository.fra1.cdn.digitaloceanspaces.com"
s3_path <- "mock_trisk_inputs"
local_trisk_inputs_folder <- file.path("data-raw", "data", "trisk_inputs")

download_trisk_inputs(endpoint_url, s3_path, local_trisk_inputs_folder)
```

#### Parameters

- `endpoint_url`: The base URL of the endpoint from which the data files will be downloaded.
- `s3_path`: The specific path within the endpoint where the data files are located.
- `local_trisk_inputs_folder`: The local folder path where the downloaded files will be saved.


### run_trisk()

Executes a basic TRISK model run for a specific baseline scenario and target scenario.
- The time taken for the TRISK run is printed.
- The latest results for various metrics (Net Present Value (`npv`), Probability of Default (`pd`), company trajectories, and parameters) are printed using the `get_latest_trisk_result()` function.


#### Usage Example

```r
trisk_output_path <- file.path("data-raw", "data", "trisk_outputs")

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

print(get_latest_trisk_result(trisk_output_path = trisk_output_path, result_type = "npv"))
print(get_latest_trisk_result(trisk_output_path = trisk_output_path, result_type = "pd"))
print(get_latest_trisk_result(trisk_output_path = trisk_output_path, result_type = "trajectories"))
print(get_latest_trisk_result(trisk_output_path = trisk_output_path, result_type = "params"))
```

#### Parameters

- `input_path`: The path to the folder containing the input data files required for the TRISK model.
- `output_path`: The path where the model's output files will be saved.
- `baseline_scenario`: The baseline scenario to be used in the model run (e.g., "Steel_baseline").
- `target_scenario`: The target scenario to be used in the model run (e.g., "Steel_NZ").
- `scenario_geography`: The geographic scope of the scenario (e.g., "Global").

### run_trisk_single_filtered()

Runs the TRISK model on a filtered dataset. 


Returns a list of tibbles containing the results of the TRISK model run:
- `npv`: Net Present Value results.
- `pd`: Probability of Default results.
- `trajectories`: Company trajectories.
- `params`: Model parameters used in the run.

#### Usage Example

```r
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

print(single_filtered_results["npv"])
print(single_filtered_results["pd"])
print(single_filtered_results["trajectories"])
print(single_filtered_results["params"])
```

#### Parameters

- `input_path`: The path to the folder containing the input data files required for the TRISK model.
- `run_params`: A list of parameters required for running the TRISK model, including `scenario_geography`, `baseline_scenario`, `target_scenario`, and `shock_year`.
- `country_iso2`: (Optional) A character vector of ISO2 country codes to filter the assets.
- `sector`: (Optional) A character vector of sectors to filter the assets.
- `technology`: (Optional) A character vector of technologies to filter the assets.
- `company_name`: (Optional) A character vector of company names to filter the assets.


### run_trisk_sa()

Performs sensitivity analysis with multiple TRISK model runs.

Returns a list of tibbles containing the combined results for all runs:
- `npv`: Net Present Value results.
- `pd`: Probability of Default results.
- `trajectories`: Company trajectories.
- `params`: Model parameters used in the runs.

#### Usage Example

```r
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

sensitivity_analysis_results["npv"]
sensitivity_analysis_results["pd"]
sensitivity_analysis_results["trajectories"]
sensitivity_analysis_results["params"]
```

#### Parameters

- `input_path`: The path to the folder containing the input data files required for the TRISK model.
- `run_params`: A list of parameter sets where each set contains the required parameters for a single TRISK model run (e.g., `scenario_geography`, `baseline_scenario`, `target_scenario`, `shock_year`).
- `...`: Additional arguments for filtering assets, such as `country_iso2`, `sector`, `technology`, and `company_name`.

