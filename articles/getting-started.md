# 1. Getting started

## What is trisk.analysis

`trisk.analysis` helps a bank credit-risk analyst measure **climate
transition risk** on a loan book. The underlying TRISK engine
(`trisk.model`) re-prices the companies you lend to under different
climate scenarios: as carbon prices rise and demand shifts away from
high-carbon technologies, some borrowers lose value and become more
likely to default. TRISK turns those scenario assumptions into shocked
**net present values (NPVs)** and **probabilities of default (PDs)**.
This package wraps that engine so you can run it directly on a
portfolio, allocate the shocks to your exposures, and blend them with
your own internal PD/EL estimates.

## Reading path

Work through the vignettes in this order:

1.  [`vignette("inputs-and-outputs")`](../articles/inputs-and-outputs.md)
    — what TRISK consumes (assets, scenarios, financial features, carbon
    prices) and what it produces (NPV and PD results).
2.  [`vignette("run-on-a-portfolio")`](../articles/run-on-a-portfolio.md)
    — run TRISK on a bank loan book and map the shocks onto your
    exposures.
3.  [`vignette("pd-el-integration")`](../articles/pd-el-integration.md)
    — blend TRISK shocks with the bank’s own PD/EL to get
    climate-adjusted expected loss.
4.  [`vignette("sensitivity-analysis")`](../articles/sensitivity-analysis.md)
    — sweep scenario assumptions to see how results move across
    baselines and shock scenarios.

## Hello world

The smallest end-to-end run: load the four bundled `trisk.model` inputs
and a bundled portfolio, then call
[`run_trisk_on_simple_portfolio()`](../reference/run_trisk_on_simple_portfolio.md).

``` r

library(trisk.analysis)
```

``` r

assets <- read.csv(system.file("testdata", "assets_testdata.csv", package = "trisk.model", mustWork = TRUE))
scenarios <- read.csv(system.file("testdata", "scenarios_testdata.csv", package = "trisk.model", mustWork = TRUE))
financial_features <- read.csv(system.file("testdata", "financial_features_testdata.csv", package = "trisk.model", mustWork = TRUE))
ngfs_carbon_price <- read.csv(system.file("testdata", "ngfs_carbon_price_testdata.csv", package = "trisk.model", mustWork = TRUE))

portfolio <- read.csv(
  system.file("testdata", "portfolio_ids_internal_pd_testdata.csv", package = "trisk.analysis", mustWork = TRUE)
)

results <- run_trisk_on_simple_portfolio(
  assets_data = assets,
  scenarios_data = scenarios,
  financial_data = financial_features,
  carbon_data = ngfs_carbon_price,
  portfolio_data = portfolio,
  baseline_scenario = "NGFS2023GCAM_CP",
  target_scenario = "NGFS2023GCAM_NZ2050",
  scenario_geography = "Global"
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

head(results$portfolio_results)
#> # A tibble: 4 × 10
#>   company_id company_name  term loss_given_default exposure_value_usd
#>   <chr>      <lgl>        <int>              <dbl>              <int>
#> 1 101        NA               3                0.7            1839267
#> 2 102        NA               1                0.7            6227364
#> 3 103        NA               5                0.5            3728364
#> 4 104        NA               4                0.4            9263702
#> # ℹ 5 more variables: exposure_loss_shock_usd <dbl>,
#> #   exposure_change_percent <dbl>, expected_loss_baseline <dbl>,
#> #   expected_loss_shock <dbl>, expected_loss_difference <dbl>
```

Each input row comes back with its climate-shocked exposure loss and
expected loss alongside the original exposure.

## Where to go next

Start with
[`vignette("inputs-and-outputs")`](../articles/inputs-and-outputs.md) to
understand the data TRISK needs before running it on your own portfolio.
