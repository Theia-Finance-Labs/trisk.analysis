# Getting started

## Installation

Install the development version from GitHub:

``` r

# install.packages("pak")
pak::pak("Theia-Finance-Labs/trisk.analysis")
```

## What is trisk.analysis

`trisk.analysis` measures **climate transition risk** at the level of
individual companies and the portfolios built from them — wherever
transition risk has to be placed on a book of exposures, whether by
banks, central banks and supervisors, or asset managers.

The underlying TRISK engine (`trisk.model`) is an asset-level
transition-risk stress test: it feeds climate scenarios into a
microeconomic model of the firm and uses company- and asset-level data
to value how scenario-driven declines in high-carbon production and
stranded-asset exposure adjust a company’s value relative to a
business-as-usual baseline. TRISK turns those scenario assumptions into
shocked **net present values (NPVs)** and **probabilities of default
(PDs)**.

This package wraps that engine so you can run it directly on a
portfolio, allocate the shocks onto your own exposures — loans or equity
holdings — and blend them with your internal PD/EL estimates. The worked
vignettes below follow a **bank** credit-risk workflow; other
institution types can adapt the same steps.

## Reading path

The worked vignettes build up a bank credit-risk analysis end to end —
from the inputs and outputs, through running TRISK on a portfolio, to
blending the shocks into your own expected loss. Work through them in
order:

1.  [`vignette("bank_1_inputs-and-outputs")`](../articles/bank_1_inputs-and-outputs.md)
    — what TRISK consumes (assets, scenarios, financial features, carbon
    prices), how to set up your `trisk_inputs/` data folder, and what it
    produces (NPV and PD results).
2.  [`vignette("bank_2_simple-portfolio-analysis")`](../articles/bank_2_simple-portfolio-analysis.md)
    — run TRISK on a loan book and map the shocks onto your exposures
    (the simple and full runners).
3.  [`vignette("bank_3_sensitivity-analysis")`](../articles/bank_3_sensitivity-analysis.md)
    — sweep scenario assumptions to see how results move across
    baselines and shock scenarios.
4.  [`vignette("bank_4_pd-el-integration")`](../articles/bank_4_pd-el-integration.md)
    — blend TRISK shocks with your own PD/EL to get climate-adjusted
    expected loss.

## A first run

The smallest end-to-end run: load the four bundled `trisk.model` inputs
and a bundled portfolio, then call
[`run_trisk_on_simple_portfolio()`](../reference/run_trisk_on_simple_portfolio.md).

``` r

library(trisk.analysis)
```

``` r

assets <- read.csv(system.file("testdata", "assets_testdata.csv", package = "trisk.model", mustWork = TRUE))
# NGFS 2024 scenarios start in 2023; bundled assets reach 2022, and TRISK errors
# on assets outside the scenario window, so scope to 2023 onward.
assets <- assets[assets$production_year >= 2023, ]
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
  baseline_scenario = "NGFS2024GCAM_CP",
  target_scenario = "NGFS2024GCAM_NZ2050",
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

### All model parameters

[`run_trisk_on_simple_portfolio()`](../reference/run_trisk_on_simple_portfolio.md)
forwards any extra arguments to the TRISK engine
([`trisk.model::run_trisk_model()`](https://rdrr.io/pkg/trisk.model/man/run_trisk_model.html)).
Only the scenarios above are required; every other argument has a
default, shown here with its meaning. Set them to match your own
cost-of-capital assumptions and the prevailing market curve at your
analysis date.

``` r

results <- run_trisk_on_simple_portfolio(
  assets_data        = assets,
  scenarios_data     = scenarios,
  financial_data     = financial_features,
  carbon_data        = ngfs_carbon_price,
  portfolio_data     = portfolio,
  baseline_scenario  = "NGFS2024GCAM_CP",       # business-as-usual scenario
  target_scenario    = "NGFS2024GCAM_NZ2050",   # shock (policy) scenario
  scenario_geography = "Global",                # region(s) to compute results for
  carbon_price_model = "no_carbon_tax",         # NGFS carbon-price pathway ("no_carbon_tax" to skip)
  risk_free_rate     = 0.045,                   # risk-free rate (Merton PD model)
  discount_rate      = 0.09,                    # DCF discount rate on dividends
  growth_rate        = 0.03,                    # terminal growth rate of profits
  div_netprofit_prop_coef = 1,                  # dividend pass-through coefficient
  shock_year         = 2030,                    # year the policy shock is applied
  market_passthrough = 0                        # firm's ability to pass carbon cost to consumers
)
```

See
[`vignette("bank_1_inputs-and-outputs")`](../articles/bank_1_inputs-and-outputs.md)
for fuller definitions of each parameter.

## Where to go next

Start with
[`vignette("bank_1_inputs-and-outputs")`](../articles/bank_1_inputs-and-outputs.md)
to set up your inputs and understand the data, then
[`vignette("bank_2_simple-portfolio-analysis")`](../articles/bank_2_simple-portfolio-analysis.md)
to run TRISK on your own portfolio.
