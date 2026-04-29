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
| 7342a777-fe92-4913-b2ca-f766ec855a44 | 101        | 101      | Company 1    | Company 1  | Oil&Gas | Gas           |                   51951.82 |                13549.28 |                    -38402.54 |               -0.7391952 |
| 7342a777-fe92-4913-b2ca-f766ec855a44 | 102        | 102      | Company 2    | Company 2  | Coal    | Coal          |                13648160.57 |              4317747.56 |                  -9330413.02 |               -0.6836389 |
| 7342a777-fe92-4913-b2ca-f766ec855a44 | 103        | 103      | Company 3    | Company 3  | Oil&Gas | Gas           |                27724344.25 |             12420187.12 |                 -15304157.13 |               -0.5520115 |
| 7342a777-fe92-4913-b2ca-f766ec855a44 | 104        | 104      | Company 4    | Company 4  | Power   | RenewablesCap |              141635910\.26 |           202554984\.40 |                  60919074.14 |                0.4301104 |
| 7342a777-fe92-4913-b2ca-f766ec855a44 | 105        | 105      | Company 5    | Company 5  | Power   | CoalCap       |                57418851.27 |             11874146.56 |                 -45544704.71 |               -0.7932013 |
| 7342a777-fe92-4913-b2ca-f766ec855a44 | 105        | 105      | Company 5    | Company 5  | Power   | OilCap        |                 6210907.85 |              1416673.16 |                  -4794234.69 |               -0.7719056 |

### PD Results

``` r
knitr::kable(head(outputs$pd_results)) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "100%", height = "400px")
```

| run_id                               | company_id | company_name | sector  | term | pd_baseline |  pd_shock |
|:-------------------------------------|:-----------|:-------------|:--------|-----:|------------:|----------:|
| 7342a777-fe92-4913-b2ca-f766ec855a44 | 101        | Company 1    | Oil&Gas |    1 |   0.0000000 | 0.0000000 |
| 7342a777-fe92-4913-b2ca-f766ec855a44 | 101        | Company 1    | Oil&Gas |    2 |   0.0000000 | 0.0000214 |
| 7342a777-fe92-4913-b2ca-f766ec855a44 | 101        | Company 1    | Oil&Gas |    3 |   0.0000011 | 0.0004647 |
| 7342a777-fe92-4913-b2ca-f766ec855a44 | 101        | Company 1    | Oil&Gas |    4 |   0.0000237 | 0.0022474 |
| 7342a777-fe92-4913-b2ca-f766ec855a44 | 101        | Company 1    | Oil&Gas |    5 |   0.0001502 | 0.0059057 |
| 7342a777-fe92-4913-b2ca-f766ec855a44 | 101        | Company 1    | Oil&Gas |    6 |   0.0005218 | 0.0113956 |

### Company Trajectories

``` r
knitr::kable(head(outputs$company_trajectories)) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "100%", height = "400px")
```

| run_id                               | asset_id | asset_name | company_id | company_name | year | sector  | technology | scenario_price_baseline | price_shock_scenario | production_baseline_scenario | production_target_scenario | production_shock_scenario | production_plan_company_technology | net_profits_baseline_scenario | net_profits_shock_scenario | discounted_net_profits_baseline_scenario | discounted_net_profits_shock_scenario |
|:-------------------------------------|:---------|:-----------|:-----------|:-------------|-----:|:--------|:-----------|------------------------:|---------------------:|-----------------------------:|---------------------------:|--------------------------:|-----------------------------------:|------------------------------:|---------------------------:|-----------------------------------------:|--------------------------------------:|
| 7342a777-fe92-4913-b2ca-f766ec855a44 | 101      | Company 1  | 101        | Company 1    | 2022 | Oil&Gas | Gas        |                5.867116 |             5.867116 |                         5000 |                   5000.000 |                      5000 |                               5000 |                      2239.895 |                   2239.895 |                                 2239.895 |                              2239.895 |
| 7342a777-fe92-4913-b2ca-f766ec855a44 | 101      | Company 1  | 101        | Company 1    | 2023 | Oil&Gas | Gas        |                5.898569 |             5.898569 |                         5423 |                   5001.354 |                      5423 |                               5423 |                      2442.414 |                   2442.414 |                                 2282.630 |                              2282.630 |
| 7342a777-fe92-4913-b2ca-f766ec855a44 | 101      | Company 1  | 101        | Company 1    | 2024 | Oil&Gas | Gas        |                5.930022 |             5.930022 |                         6200 |                   5002.708 |                      6200 |                               6200 |                      2807.250 |                   2807.250 |                                 2451.961 |                              2451.961 |
| 7342a777-fe92-4913-b2ca-f766ec855a44 | 101      | Company 1  | 101        | Company 1    | 2025 | Oil&Gas | Gas        |                5.961475 |             5.961475 |                         7400 |                   5004.062 |                      7400 |                               7400 |                      3368.360 |                   3368.360 |                                 2749.585 |                              2749.585 |
| 7342a777-fe92-4913-b2ca-f766ec855a44 | 101      | Company 1  | 101        | Company 1    | 2026 | Oil&Gas | Gas        |                5.945170 |             5.945170 |                         7800 |                   4862.620 |                      7800 |                               7800 |                      3540.723 |                   3540.723 |                                 2701.201 |                              2701.201 |
| 7342a777-fe92-4913-b2ca-f766ec855a44 | 101      | Company 1  | 101        | Company 1    | 2027 | Oil&Gas | Gas        |                5.928866 |             5.928866 |                         8600 |                   4721.178 |                      8600 |                               8600 |                      3893.168 |                   3893.168 |                                 2775.775 |                              2775.775 |
