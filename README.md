# TRISK Workflow

This repository contains a workflow for running the TRISK model to assess financial impacts based on different scenarios. The workflow is structured into several steps, each performing specific tasks, from downloading input data to running the model and analyzing the results.

## Table of Contents

- [TRISK Workflow](#trisk-workflow)
  - [Table of Contents](#table-of-contents)
  - [Introduction](#introduction)
  - [Open Source Data Download](#open-source-data-download)
    - [Usage Example](#usage-example)
  - [Simple TRISK Run](#simple-trisk-run)
    - [Usage Example](#usage-example-1)
  - [Smaller Run (Unused)](#smaller-run-unused)
    - [Usage Example](#usage-example-2)
  - [Sensitivity Analysis](#sensitivity-analysis)
    - [Usage Example](#usage-example-3)
  - [Sensitivity Analysis on Subset](#sensitivity-analysis-on-subset)
    - [Usage Example](#usage-example-4)
  - [Conclusion](#conclusion)

## Introduction

The TRISK model helps in understanding the financial impacts of different climate scenarios on specific industries or sectors. This workflow guides you through setting up and running the TRISK model, including downloading necessary data, running basic and advanced scenarios, and performing sensitivity analysis.

## Open Source Data Download

The first step in the workflow is to download the necessary input data required for running the TRISK model. This is done using the `download_trisk_inputs()` function, which fetches data from a specified endpoint and saves it to a local directory.

### Usage Example

```r
endpoint_url <- "https://crispy-datamodels-bucket.fra1.cdn.digitaloceanspaces.com"
s3_path <- "crispy-datamodels-bucket/trisk_V2/csv"
local_trisk_inputs_folder <- file.path("data-raw", "data", "trisk_inputs")

download_trisk_inputs(endpoint_url, s3_path, local_trisk_inputs_folder)
```

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

## Conclusion

This workflow provides a comprehensive approach to running and analyzing TRISK model scenarios. By following the steps outlined above, you can download the necessary data, run basic and advanced scenarios, and perform sensitivity analysis to gain insights into how different scenarios impact financial outcomes.
