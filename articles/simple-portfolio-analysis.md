# simple-portfolio-analysis

``` r
library(trisk.analysis)
library(dplyr)
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union
```

## Run TRISK on a simple portfolio

This vignette shows how to use
[`run_trisk_on_simple_portfolio()`](../reference/run_trisk_on_simple_portfolio.md)
with a minimal portfolio schema:

- `company_id`
- `company_name`
- `exposure_value_usd`
- `term`
- `loss_given_default`

Compared to
[`run_trisk_on_portfolio()`](../reference/run_trisk_on_portfolio.md), no
`country_iso2` column is required.

### Load model inputs

``` r
assets_testdata <- read.csv(system.file("testdata", "assets_testdata.csv", package = "trisk.model", mustWork = TRUE))
scenarios_testdata <- read.csv(system.file("testdata", "scenarios_testdata.csv", package = "trisk.model", mustWork = TRUE))
financial_features_testdata <- read.csv(system.file("testdata", "financial_features_testdata.csv", package = "trisk.model", mustWork = TRUE))
ngfs_carbon_price_testdata <- read.csv(system.file("testdata", "ngfs_carbon_price_testdata.csv", package = "trisk.model", mustWork = TRUE))
```

### Load simple portfolio input

``` r
simple_portfolio <- read.csv(
  system.file("testdata", "simple_portfolio.csv", package = "trisk.analysis", mustWork = TRUE)
)
simple_portfolio
#>   company_id company_name exposure_value_usd term loss_given_default
#> 1        101         <NA>            2222222    2                0.7
#> 2        101         <NA>            3333333    3                0.7
#> 3        101         <NA>            4444444    4                0.7
#> 4        102     Company1            6227364    1                0.7
#> 5        103     Company2            3728364    5                0.5
#> 6        104     Company3            9263702    4                0.4
```

### Run the model

``` r
baseline_scenario <- "NGFS2023GCAM_CP"
target_scenario <- "NGFS2023GCAM_NZ2050"
scenario_geography <- "Global"

simple_results <- run_trisk_on_simple_portfolio(
  assets_data = assets_testdata,
  scenarios_data = scenarios_testdata,
  financial_data = financial_features_testdata,
  carbon_data = ngfs_carbon_price_testdata,
  portfolio_data = simple_portfolio,
  baseline_scenario = baseline_scenario,
  target_scenario = target_scenario,
  scenario_geography = scenario_geography
)
#> -- Start Trisk-- Retyping Dataframes. 
#> -- Processing Assets and Scenarios. 
#> -- Transforming to Trisk model input. 
#> -- Calculating baseline, target, and shock trajectories. 
#> -- Applying zero-trajectory logic to production trajectories. 
#> -- Calculating net profits.
#> Joining with `by = join_by(asset_id, company_id, sector, technology)`
#> -- Calculating market risk. 
#> -- Calculating credit risk.

portfolio_results_tech_detail <- simple_results$portfolio_results_tech_detail
portfolio_results <- simple_results$portfolio_results
```

### NPV-based exposure allocation

[`run_trisk_on_simple_portfolio()`](../reference/run_trisk_on_simple_portfolio.md)
adds `exposure_value_usd_share`, computed from baseline NPV shares at
company/sector/technology level:

1.  compute baseline NPV share per run;
2.  allocate exposure with that share;
3.  average after dropping `run_id`;
4.  re-scale so exposure totals match the original portfolio exposure.

``` r
portfolio_results_tech_detail |>
  dplyr::select(
    company_id, term, sector, technology,
    exposure_value_usd_share,
    net_present_value_baseline
  ) |>
  utils::head(10)
#>   company_id term  sector    technology exposure_value_usd_share
#> 1        101    2 Oil&Gas           Gas                  2222222
#> 2        101    3 Oil&Gas           Gas                  3333333
#> 3        101    4 Oil&Gas           Gas                  4444444
#> 4        102    1    Coal          Coal                  6227364
#> 5        103    5 Oil&Gas           Gas                  3728364
#> 6        104    4   Power RenewablesCap                  9263702
#>   net_present_value_baseline
#> 1                   172718.3
#> 2                   172718.3
#> 3                   172718.3
#> 4                 42299475.0
#> 5                 95105145.4
#> 6               1016926683.7
```

Because `exposure_value_usd_share` is computed after dropping `run_id`,
it is constant across runs for a given
`(company_id, term, sector, technology)`.

``` r
exposure_share_check <- portfolio_results_tech_detail |>
  dplyr::distinct(
    company_id, term, sector, technology,
    exposure_value_usd_share
  ) |>
  dplyr::group_by(company_id, term) |>
  dplyr::summarise(allocated_exposure = sum(exposure_value_usd_share, na.rm = TRUE), .groups = "drop") |>
  dplyr::left_join(
    portfolio_results |>
      dplyr::group_by(company_id, term) |>
      dplyr::summarise(original_exposure = sum(exposure_value_usd, na.rm = TRUE), .groups = "drop"),
    by = c("company_id", "term")
  ) |>
  dplyr::mutate(gap = allocated_exposure - original_exposure)

exposure_share_check
#> # A tibble: 6 × 5
#>   company_id  term allocated_exposure original_exposure   gap
#>   <chr>      <int>              <dbl>             <int> <dbl>
#> 1 101            2            2222222           2222222     0
#> 2 101            3            3333333           3333333     0
#> 3 101            4            4444444           4444444     0
#> 4 102            1            6227364           6227364     0
#> 5 103            5            3728364           3728364     0
#> 6 104            4            9263702           9263702     0
```

In the last table, `gap` should be close to zero (floating-point
tolerance).
