# return-company-aggregated-results

``` r
library(trisk.analysis)
library(magrittr)
```

## Running aggregated results

In December 2024, the TRISK model methodology was updated to enhance the
precision of stress test computations. Previously applied at the company
and technology level, stress tests now operate at the company, country,
and technology level. This increased granularity improves the accuracy
of Net Present Value (NPV) and trajectory outputs, which now reflect
country-specific variations.

The Probability of Default (PD) results remain aggregated at the company
and sector level, ensuring consistency with prior outputs for these
metrics.

The rest of this vignette demonstrates how to aggregate the results to
remove the country-level granularity, replicating the previous output
structure. This allows users to maintain backward compatibility with
prior analyses or adapt the results to specific reporting needs.

### Input Data and Configuration

The input data is included as test datasets in the package. These
datasets are used to demonstrate the process.

``` r
assets_data <- read.csv(system.file("testdata", "assets_testdata.csv", package = "trisk.model"))
scenarios_data <- read.csv(system.file("testdata", "scenarios_testdata.csv", package = "trisk.model"))
financial_features_data <- read.csv(system.file("testdata", "financial_features_testdata.csv", package = "trisk.model"))
ngfs_carbon_price_data <- read.csv(system.file("testdata", "ngfs_carbon_price_testdata.csv", package = "trisk.model"))
```

### Running the Model with Aggregation

The run_trisk_agg function executes the TRISK model and aggregates the
results to remove the country-level granularity.

``` r
outputs <- run_trisk_agg(
  assets_data = assets_data,
  scenarios_data = scenarios_data,
  financial_data = financial_features_data,
  carbon_data = ngfs_carbon_price_data,
  baseline_scenario = "NGFS2023GCAM_CP",
  target_scenario = "NGFS2023GCAM_NZ2050",
  shock_year = 2030,
  scenario_geography = "Global"
)
#> -- Retyping Dataframes. 
#> -- Processing Assets and Scenarios. 
#> -- Transforming to Trisk model input. 
#> -- Calculating baseline, target, and shock trajectories. 
#> -- Applying zero-trajectory logic to production trajectories. 
#> -- Calculating net profits.
#> Joining with `by = join_by(asset_id, company_id, sector, technology)`
#> -- Calculating market risk. 
#> -- Calculating credit risk.
```

## Examining the Outputs

### NPV Results

``` r
knitr::kable(head(outputs$npv_results)) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "100%", height = "400px")
```

| run_id                               | company_id | asset_id | company_name | asset_name | sector  | technology    | net_present_value_baseline | net_present_value_shock | net_present_value_difference | net_present_value_change |
|:-------------------------------------|:-----------|:---------|:-------------|:-----------|:--------|:--------------|---------------------------:|------------------------:|-----------------------------:|-------------------------:|
| 17f16aa3-2dfe-4eb3-9738-bcfbc4a9e007 | 101        | 101      | Company 1    | Company 1  | Oil&Gas | Gas           |                   172718.3 |            1.354928e+04 |                      -159169 |               -0.9215527 |
| 17f16aa3-2dfe-4eb3-9738-bcfbc4a9e007 | 102        | 102      | Company 2    | Company 2  | Coal    | Coal          |                 42299475.0 |            4.317748e+06 |                    -37981727 |               -0.8979243 |
| 17f16aa3-2dfe-4eb3-9738-bcfbc4a9e007 | 103        | 103      | Company 3    | Company 3  | Oil&Gas | Gas           |                 95105145.4 |            2.486475e+07 |                    -70240391 |               -0.7385551 |
| 17f16aa3-2dfe-4eb3-9738-bcfbc4a9e007 | 104        | 104      | Company 4    | Company 4  | Power   | RenewablesCap |               1016926683.7 |            1.366640e+09 |                    349713309 |                0.3438924 |
| 17f16aa3-2dfe-4eb3-9738-bcfbc4a9e007 | 105        | 105      | Company 5    | Company 5  | Power   | CoalCap       |               176175702\.5 |            1.187415e+07 |                   -164301556 |               -0.9326005 |
| 17f16aa3-2dfe-4eb3-9738-bcfbc4a9e007 | 105        | 105      | Company 5    | Company 5  | Power   | OilCap        |                 21412749.3 |            1.416673e+06 |                    -19996076 |               -0.9338397 |

### PD Results

``` r
knitr::kable(head(outputs$pd_results)) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "100%", height = "400px")
```

| run_id                               | company_id | company_name | sector  | term | pd_baseline |  pd_shock |
|:-------------------------------------|:-----------|:-------------|:--------|-----:|------------:|----------:|
| 17f16aa3-2dfe-4eb3-9738-bcfbc4a9e007 | 101        | Company 1    | Oil&Gas |    1 |   0.0000000 | 0.0005908 |
| 17f16aa3-2dfe-4eb3-9738-bcfbc4a9e007 | 101        | Company 1    | Oil&Gas |    2 |   0.0000000 | 0.0120293 |
| 17f16aa3-2dfe-4eb3-9738-bcfbc4a9e007 | 101        | Company 1    | Oil&Gas |    3 |   0.0000011 | 0.0350054 |
| 17f16aa3-2dfe-4eb3-9738-bcfbc4a9e007 | 101        | Company 1    | Oil&Gas |    4 |   0.0000237 | 0.0614358 |
| 17f16aa3-2dfe-4eb3-9738-bcfbc4a9e007 | 101        | Company 1    | Oil&Gas |    5 |   0.0001502 | 0.0874772 |
| 17f16aa3-2dfe-4eb3-9738-bcfbc4a9e007 | 102        | Company 2    | Coal    |    1 |   0.0000000 | 0.0001410 |

### Company Trajectories

``` r
knitr::kable(head(outputs$company_trajectories)) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "100%", height = "400px")
```

| run_id                               | asset_id | asset_name | company_id | company_name | year | sector  | technology | scenario_price_baseline | price_shock_scenario | production_baseline_scenario | production_target_scenario | production_shock_scenario | production_plan_company_technology | net_profits_baseline_scenario | net_profits_shock_scenario | discounted_net_profits_baseline_scenario | discounted_net_profits_shock_scenario |
|:-------------------------------------|:---------|:-----------|:-----------|:-------------|-----:|:--------|:-----------|------------------------:|---------------------:|-----------------------------:|---------------------------:|--------------------------:|-----------------------------------:|------------------------------:|---------------------------:|-----------------------------------------:|--------------------------------------:|
| 17f16aa3-2dfe-4eb3-9738-bcfbc4a9e007 | 101      | Company 1  | 101        | Company 1    | 2022 | Oil&Gas | Gas        |                5.867116 |             5.867116 |                         5000 |                   5000.000 |                      5000 |                               5000 |                      2239.895 |                   2239.895 |                                 2239.895 |                              2239.895 |
| 17f16aa3-2dfe-4eb3-9738-bcfbc4a9e007 | 101      | Company 1  | 101        | Company 1    | 2023 | Oil&Gas | Gas        |                5.898569 |             5.898569 |                         5423 |                   5001.354 |                      5423 |                               5423 |                      2442.414 |                   2442.414 |                                 2282.630 |                              2282.630 |
| 17f16aa3-2dfe-4eb3-9738-bcfbc4a9e007 | 101      | Company 1  | 101        | Company 1    | 2024 | Oil&Gas | Gas        |                5.930022 |             5.930022 |                         6200 |                   5002.708 |                      6200 |                               6200 |                      2807.250 |                   2807.250 |                                 2451.961 |                              2451.961 |
| 17f16aa3-2dfe-4eb3-9738-bcfbc4a9e007 | 101      | Company 1  | 101        | Company 1    | 2025 | Oil&Gas | Gas        |                5.961475 |             5.961475 |                         7400 |                   5004.062 |                      7400 |                               7400 |                      3368.360 |                   3368.360 |                                 2749.585 |                              2749.585 |
| 17f16aa3-2dfe-4eb3-9738-bcfbc4a9e007 | 101      | Company 1  | 101        | Company 1    | 2026 | Oil&Gas | Gas        |                5.945170 |             5.945170 |                         7800 |                   4862.620 |                      7800 |                               7800 |                      3540.723 |                   3540.723 |                                 2701.201 |                              2701.201 |
| 17f16aa3-2dfe-4eb3-9738-bcfbc4a9e007 | 101      | Company 1  | 101        | Company 1    | 2027 | Oil&Gas | Gas        |                5.928866 |             5.928866 |                         8600 |                   4721.178 |                      8600 |                               8600 |                      3893.168 |                   3893.168 |                                 2775.775 |                              2775.775 |
