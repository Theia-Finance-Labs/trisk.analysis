# 2. Bank portfolio analysis — start here

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
library(magrittr)
```

This is the **entry point for a bank** running TRISK on its own loan
book. It shows the five inputs TRISK needs, where your data goes, and a
first end-to-end run. The vignettes that follow ([Inputs and
outputs](inputs-and-outputs.md), [Run on a
portfolio](run-on-a-portfolio.md), [Sensitivity
analysis](sensitivity-analysis.md), [PD & EL
integration](pd-el-integration.md)) go deeper; start here.

## The five inputs

TRISK takes **five inputs**. The first four describe the world; the
fifth is **your portfolio**.

| Input | Argument | What it is | Who provides it |
|----|----|----|----|
| Assets | `assets_data` | Physical/production assets per company | **You** |
| Scenarios | `scenarios_data` | Climate-scenario price & production pathways | Download (full set) / sample bundled |
| NGFS carbon price | `carbon_data` | Carbon-price trajectories | Sample bundled |
| Financial features | `financial_data` | Per-company financials (PD, margins, leverage, volatility) | **You** |
| **Portfolio** | `portfolio_data` | **Your loan book — `portfolio_ids.csv`** | **You** |

## Set up your input folder

Run this **once** to create a `trisk_inputs/` folder in your working
directory, pre-filled with blank templates and filled samples plus a
README:

``` r

setup_trisk_inputs()
```

It creates:

    trisk_inputs/
      README.md           # required files, column schemas, portfolio modes
      templates/          # blank, header-only CSVs to fill in
        assets.csv  scenarios.csv  ngfs_carbon_price.csv
        financial_features.csv  portfolio_ids.csv
      samples/            # the bundled example data, as a worked reference
        (same five files, filled)

> The folder lives in **your project directory**, never inside the
> installed package — the package library is read-only on many systems
> and is overwritten on every update, so your data must live in your own
> project.

Fill the templates (or copy a `samples/` file and edit it), save each as
`trisk_inputs/<input>.csv`, then point the reads below at those files.
For the full production scenario library, run
`download_trisk_inputs(local_save_folder = "trisk_inputs")` — it
currently fetches `scenarios.csv`; you supply `assets.csv`,
`financial_features.csv` and `ngfs_carbon_price.csv` yourself, starting
from the bundled samples.

## Your portfolio is the centre: `portfolio_ids`

`portfolio_ids.csv` is the **main** portfolio input. One row per loan,
keyed by `company_id`:

``` r

portfolio_ids_testdata <- read.csv(
  system.file("testdata", "portfolio_ids_testdata.csv", package = "trisk.analysis")
)
```

| company_id | company_name | sector | technology | country_iso2 | exposure_value_usd | term | loss_given_default |
|---:|:---|:---|:---|:---|---:|---:|---:|
| 101 | NA | Oil&Gas | Gas | DE | 1839267 | 3 | 0.7 |
| 102 | NA | Coal | Coal | DE | 6227364 | 1 | 0.7 |
| 103 | NA | Oil&Gas | Gas | DE | 3728364 | 5 | 0.5 |
| 104 | NA | Power | RenewablesCap | DE | 9263702 | 4 | 0.4 |

Matching companies by `company_id` is the recommended path. Two
alternatives are available as **options**:

- **`portfolio_names.csv`** — same columns, but companies are
  fuzzy-matched by `company_name` when you do not have `company_id`.
- **`portfolio_countries.csv`** — match by `country_iso2` only
  (country-level aggregation) when neither id nor name is available.

For the [Sensitivity analysis](sensitivity-analysis.md) and [PD & EL
integration](pd-el-integration.md) workflows, add an `internal_pd`
column (your own PD per company, in `[0, 1]`) — that is the
`portfolio_ids_internal_pd` variant those vignettes use.

## A first run on placeholder data

The CSVs loaded here are **placeholders** (sample data bundled with the
packages). Replace them with your own files in `trisk_inputs/` once you
have filled the templates — the commented block shows the swap.

``` r

# --- PLACEHOLDERS: sample data shipped with the packages ---
assets_data    <- read.csv(system.file("testdata", "assets_testdata.csv",             package = "trisk.model"))
scenarios_data <- read.csv(system.file("testdata", "scenarios_testdata.csv",          package = "trisk.model"))
carbon_data    <- read.csv(system.file("testdata", "ngfs_carbon_price_testdata.csv",  package = "trisk.model"))
financial_data <- read.csv(system.file("testdata", "financial_features_testdata.csv", package = "trisk.model"))
portfolio_data <- read.csv(system.file("testdata", "portfolio_ids_testdata.csv",      package = "trisk.analysis")) # MAIN portfolio input

# --- PRODUCTION: replace the placeholders above with your own data ---
# assets_data    <- read.csv("trisk_inputs/assets.csv")
# scenarios_data <- read.csv("trisk_inputs/scenarios.csv")
# carbon_data    <- read.csv("trisk_inputs/ngfs_carbon_price.csv")
# financial_data <- read.csv("trisk_inputs/financial_features.csv")
# portfolio_data <- read.csv("trisk_inputs/portfolio_ids.csv")   # or portfolio_names.csv / portfolio_countries.csv
```

Pick a baseline and a target scenario (from the same provider), then
run:

``` r

analysis_data <- run_trisk_on_portfolio(
  assets_data        = assets_data,
  scenarios_data     = scenarios_data,
  financial_data     = financial_data,
  carbon_data        = carbon_data,
  portfolio_data     = portfolio_data,
  baseline_scenario  = "NGFS2023GCAM_CP",
  target_scenario    = "NGFS2023GCAM_NZ2050",
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
```

| company_id | sector | technology | term | pd_baseline | pd_shock | net_present_value_baseline | net_present_value_shock |
|:---|:---|:---|---:|---:|---:|---:|---:|
| 101 | Oil&Gas | Gas | 3 | 1.10e-06 | 0.0004647 | 51951.82 | 13549.28 |
| 102 | Coal | Coal | 1 | 0.00e+00 | 0.0000000 | 13648160.57 | 4317747.56 |
| 103 | Oil&Gas | Gas | 5 | 8.09e-05 | 0.0012524 | 27724344.25 | 12420187.12 |
| 104 | Power | RenewablesCap | 4 | 3.20e-06 | 0.0000003 | 141635910\.26 | 202554984\.40 |

That is a full TRISK run on your portfolio. From here:

- **[Inputs and outputs](inputs-and-outputs.md)** — every input column
  and every output table, in detail.
- **[Run on a portfolio](run-on-a-portfolio.md)** — the simple vs full
  runners, exposure allocation, and the plotting helpers.
- **[Sensitivity analysis](sensitivity-analysis.md)** — sweep shock
  year, IAM and ambition, read through a bank-impact lens.
- **[PD & EL integration](pd-el-integration.md)** — recombine TRISK PDs
  with your internal PDs and translate to expected-loss basis points.
