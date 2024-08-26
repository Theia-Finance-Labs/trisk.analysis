# TRISK Analysis 

This repository contains a workflow for running the TRISK model to assess financial impacts of a transition towards a low-carbon economy based on different climate scenarios. The workflow is structured into several steps, each performing specific tasks, from downloading input data to running the model and analyzing the results.

## Table of Contents

- [TRISK Analysis](#trisk-analysis)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Installation](#installation)
    - [Installation Steps](#installation-steps)
  - [Open Source Data Download](#open-source-data-download)
    - [Usage Example](#usage-example)
    - [Parameters](#parameters)
    - [Output](#output)
  - [Simple TRISK Run](#simple-trisk-run)
    - [Usage Example](#usage-example-1)
    - [Parameters](#parameters-1)
    - [Output](#output-1)
  - [Smaller Run (Unused)](#smaller-run-unused)
    - [Usage Example](#usage-example-2)
    - [Parameters](#parameters-2)
    - [Output](#output-2)
  - [Sensitivity Analysis](#sensitivity-analysis)
    - [Usage Example](#usage-example-3)
    - [Parameters](#parameters-3)
    - [Output](#output-3)
  - [Sensitivity Analysis on Subset](#sensitivity-analysis-on-subset)
    - [Usage Example](#usage-example-4)
    - [Parameters](#parameters-4)
    - [Output](#output-4)

## Introduction

The TRISK model helps in understanding the financial impacts of different climate scenarios on specific industries or sectors. This workflow guides you through setting up and running the TRISK model, including downloading necessary data, running basic and advanced scenarios, and performing sensitivity analysis.

## Installation

To get started, you'll need to install two key packages from GitHub: `trisk.analysis` and `trisk.model`. These packages provide the necessary functions and data structures to run the TRISK model.

### Installation Steps

1. Install `trisk.analysis`:
    ```r
    devtools::install_github("Theia-Finance-Labs/trisk.analysis")
    ```

2. Install `trisk.model`:
    ```r
    devtools::install_github("Theia-Finance-Labs/trisk.model")
    ```

After installing these packages, you can proceed to use the functions provided by these packages to execute the TRISK model workflow.

## Open Source Data Download

The first step in the workflow is to download the necessary input data required for running the TRISK model. This is done using the `download_trisk_inputs()` function, which fetches data from a specified endpoint and saves it to a local directory.

### Usage Example

```r
endpoint_url <- "https://scenarios-repository.fra1.cdn.digitaloceanspaces.com"
s3_path <- "mock_trisk_inputs"
local_trisk_inputs_folder <- file.path("data-raw", "data", "trisk_inputs")

download_trisk_inputs(endpoint_url, s3_path, local_trisk_inputs_folder)
```

### Parameters

- `endpoint_url`: The base URL of the endpoint from which the data files will be downloaded.
- `s3_path`: The specific path within the endpoint where the data files are located.
- `local_trisk_inputs_folder`: The local folder path where the downloaded files will be saved.

### Output

The function does not return a value but downloads several CSV files (`assets.csv`, `financial_features.csv`, `scenarios.csv`, `ngfs_carbon_price.csv`) and saves them to the specified local folder.

## Simple TRISK Run

This section demonstrates a basic TRISK model run, where the model is executed for a specific baseline scenario and target scenario. The time taken for the run is recorded, and the latest results are printed.

### Usage Example

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

### Parameters

- `input_path`: The path to the folder containing the input data files required for the TRISK model.
- `output_path`: The path where the model's output files will be saved.
- `baseline_scenario`: The baseline scenario to be used in the model run (e.g., "Steel_baseline").
- `target_scenario`: The target scenario to be used in the model run (e.g., "Steel_NZ").
- `scenario_geography`: The geographic scope of the scenario (e.g., "Global").

### Output

- The time taken for the TRISK run is printed.
- The latest results for various metrics (Net Present Value (`npv`), Probability of Default (`pd`), company trajectories, and parameters) are printed using the `get_latest_trisk_result()` function.

## Smaller Run (Unused)

This section outlines a smaller, more focused run of the TRISK model using a filtered dataset. This run is not actively used but can be leveraged for specific analysis needs.

### Usage Example

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

### Parameters

- `input_path`: The path to the folder containing the input data files required for the TRISK model.
- `run_params`: A list of parameters required for running the TRISK model, including `scenario_geography`, `baseline_scenario`, `target_scenario`, and `shock_year`.
- `country_iso2`: (Optional) A character vector of ISO2 country codes to filter the assets.
- `sector`: (Optional) A character vector of sectors to filter the assets.
- `technology`: (Optional) A character vector of technologies to filter the assets.
- `company_name`: (Optional) A character vector of company names to filter the assets.

### Output

A list of tibbles is returned containing the results of the TRISK model run:
- `npv`: Net Present Value results.
- `pd`: Probability of Default results.
- `trajectories`: Company trajectories.
- `params`: Model parameters used in the run.

## Sensitivity Analysis

The sensitivity analysis section allows for multiple TRISK model runs with varying parameters to assess how changes in input assumptions affect the results.

### Usage Example

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

### Parameters

- `input_path`: The path to the folder containing the input data files required for the TRISK model.
- `run_params`: A list of parameter sets where each set contains the required parameters for a single TRISK model run (e.g., `scenario_geography`, `baseline_scenario`, `target_scenario`, `shock_year`).
- `...`: Additional arguments for filtering assets, such as `country_iso2`, `sector`, `technology`, and `company_name`.

### Output

A list of tibbles is returned containing the combined results for all runs:
- `npv`: Net Present Value results.
- `pd`: Probability of Default results.
- `trajectories`: Company trajectories.
- `params`: Model parameters used in the runs.

## Sensitivity Analysis on Subset

This section demonstrates how to perform a sensitivity analysis on a filtered subset of assets, further refining the scope of the analysis.

### Usage Example

```r
sensitivity_analysis_results_on_filtered_assets <- run_trisk_sa(
    input_path = local_trisk_inputs_folder, 
    run_params = run_params,
    country_iso2 = c("US", "AR"),
    sector = "Steel",
    technology = c("EAF-DRI", "BOF-BF")
)

sensitivity_analysis_results_on_filtered_assets["npv"]
sensitivity_analysis_results_on_filtered_assets["pd"]
sensitivity_analysis_results_on_filtered_assets["trajectories"]
sensitivity_analysis_results_on_filtered_assets["params"]
```

### Parameters

- `input_path`: The path to the folder containing the input data files required for the TRISK model.
- `run_params`: A list of parameter sets where each set contains the required parameters for a single TRISK model run.
- `country_iso2`: (Optional) A character vector of ISO2 country codes to filter the assets.
- `sector`: (Optional) A character vector of sectors to filter the assets.
- `technology`: (Optional) A character vector of technologies to filter the assets.

### Output

A list of tibbles is returned containing the results of the sensitivity analysis for the filtered subset of assets:
- `npv`: Net Present Value results.
- `pd`: Probability of Default results.
- `trajectories`: Company trajectories.
- `params`: Model parameters used in the runs.

