# 2. Inputs and outputs

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

## Overview

This vignette is the reference for *what TRISK consumes and what it
produces*. TRISK is a climate transition stress test: it compares each
company’s value and default risk under a baseline scenario against a
more ambitious (shock) scenario, so a credit analyst can see how a
low-carbon transition reprices a book of counterparties. To run it you
supply four reference datasets plus the model parameters; you get back
three result tables (NPV, PD, and company trajectories). The sections
below enumerate each input schema, show how to obtain production inputs,
run a minimal example on the bundled test data, and explain how to read
every output column.

## Inputs

TRISK requires four reference datasets, all shipped as test data inside
`trisk.model`. In production you swap these for the downloaded inputs
(see *Obtaining inputs* below) and for your own portfolio file (a list
of `company_id`s you hold exposure to, used downstream to filter
results).

| Input | Argument | Grain | Purpose |
|----|----|----|----|
| Assets | `assets_data` | company / asset / year | Physical production capacity and emissions |
| Scenarios | `scenarios_data` | scenario / sector / technology / year | Price and production pathways per climate scenario |
| Financial features | `financial_data` | company | Starting PD and balance-sheet ratios |
| NGFS carbon price | `carbon_data` | model / scenario / year | Optional carbon tax trajectories |
| Portfolio | (downstream) | company | The counterparties you hold; filters results |

Load the bundled test datasets:

``` r

assets_testdata <- read.csv(system.file("testdata", "assets_testdata.csv", package = "trisk.model"))
scenarios_testdata <- read.csv(system.file("testdata", "scenarios_testdata.csv", package = "trisk.model"))
financial_features_testdata <- read.csv(system.file("testdata", "financial_features_testdata.csv", package = "trisk.model"))
ngfs_carbon_price_testdata <- read.csv(system.file("testdata", "ngfs_carbon_price_testdata.csv", package = "trisk.model"))
```

### Assets

Company production assets: capacity, technology, sector and location.
This is the physical exposure TRISK reprices.

- `company_id`, `company_name`: company identifiers.
- `asset_id`, `asset_name`: asset identifiers.
- `country_iso2`: ISO 3166-1 alpha-2 country code.
- `production_year`: year of the production record.
- `emission_factor`: emissions per unit of production.
- `technology`, `sector`: technology and production sector.
- `capacity`, `capacity_factor`: installed capacity and utilisation.
- `production_unit`: unit of production.

``` r

str(assets_testdata)
#> 'data.frame':    42 obs. of  12 variables:
#>  $ company_id     : int  101 101 101 101 101 101 102 102 102 102 ...
#>  $ company_name   : chr  "Company 1" "Company 1" "Company 1" "Company 1" ...
#>  $ asset_id       : int  101 101 101 101 101 101 102 102 102 102 ...
#>  $ country_iso2   : chr  "DE" "DE" "DE" "DE" ...
#>  $ asset_name     : chr  "Company 1" "Company 1" "Company 1" "Company 1" ...
#>  $ production_year: int  2022 2023 2024 2025 2026 2027 2022 2023 2024 2025 ...
#>  $ emission_factor: num  0.062 0.062 0.062 0.062 0.062 ...
#>  $ technology     : chr  "Gas" "Gas" "Gas" "Gas" ...
#>  $ sector         : chr  "Oil&Gas" "Oil&Gas" "Oil&Gas" "Oil&Gas" ...
#>  $ capacity       : num  8600 8600 8600 8600 8600 ...
#>  $ capacity_factor: num  0.581 0.631 0.721 0.86 0.907 ...
#>  $ production_unit: chr  "GJ" "GJ" "GJ" "GJ" ...
```

| company_id | company_name | asset_id | country_iso2 | asset_name | production_year | emission_factor | technology | sector | capacity | capacity_factor | production_unit |
|---:|:---|---:|:---|:---|---:|---:|:---|:---|---:|---:|:---|
| 101 | Company 1 | 101 | DE | Company 1 | 2022 | 0.0620259 | Gas | Oil&Gas | 8600 | 0.5813953 | GJ |
| 101 | Company 1 | 101 | DE | Company 1 | 2023 | 0.0620259 | Gas | Oil&Gas | 8600 | 0.6305814 | GJ |
| 101 | Company 1 | 101 | DE | Company 1 | 2024 | 0.0620259 | Gas | Oil&Gas | 8600 | 0.7209302 | GJ |
| 101 | Company 1 | 101 | DE | Company 1 | 2025 | 0.0620259 | Gas | Oil&Gas | 8600 | 0.8604651 | GJ |
| 101 | Company 1 | 101 | DE | Company 1 | 2026 | 0.0620259 | Gas | Oil&Gas | 8600 | 0.9069767 | GJ |
| 101 | Company 1 | 101 | DE | Company 1 | 2027 | 0.0620259 | Gas | Oil&Gas | 8600 | 1.0000000 | GJ |

### Scenarios

Price and production pathways per climate scenario. Each TRISK run picks
one baseline and one target scenario from this table.

- `scenario_geography`: region the pathway applies to.
- `scenario`, `scenario_pathway`, `scenario_type`: scenario name,
  pathway and type (baseline or shock).
- `sector`, `technology`, `technology_type`: technology classification
  (carbon or renewable).
- `scenario_year`: year of the pathway record.
- `scenario_price`, `price_unit`, `pathway_unit`: price and units.
- `scenario_capacity_factor`, `country_iso2_list`, `scenario_provider`:
  capacity factor, the countries the geography aggregates, and the
  IAM/source that produced the pathway.

``` r

str(scenarios_testdata)
#> 'data.frame':    2766 obs. of  14 variables:
#>  $ scenario                : chr  "NGFS2023GCAM_CP" "NGFS2023GCAM_CP" "NGFS2023GCAM_CP" "NGFS2023GCAM_CP" ...
#>  $ scenario_type           : chr  "baseline" "baseline" "baseline" "baseline" ...
#>  $ scenario_geography      : chr  "Global" "Global" "Global" "Global" ...
#>  $ sector                  : chr  "Coal" "Coal" "Coal" "Coal" ...
#>  $ technology              : chr  "Coal" "Coal" "Coal" "Coal" ...
#>  $ scenario_year           : int  2022 2023 2024 2025 2026 2027 2028 2029 2030 2031 ...
#>  $ price_unit              : chr  "$/tonnes" "$/tonnes" "$/tonnes" "$/tonnes" ...
#>  $ scenario_price          : num  57 57.4 57.7 58 58.4 ...
#>  $ pathway_unit            : chr  "EJ/yr" "EJ/yr" "EJ/yr" "EJ/yr" ...
#>  $ scenario_pathway        : num  159 160 161 162 162 ...
#>  $ technology_type         : chr  "carbontech" "carbontech" "carbontech" "carbontech" ...
#>  $ scenario_capacity_factor: num  1 1 1 1 1 1 1 1 1 1 ...
#>  $ country_iso2_list       : logi  NA NA NA NA NA NA ...
#>  $ scenario_provider       : chr  "NGFS2023GCAM" "NGFS2023GCAM" "NGFS2023GCAM" "NGFS2023GCAM" ...
```

| scenario | scenario_type | scenario_geography | sector | technology | scenario_year | price_unit | scenario_price | pathway_unit | scenario_pathway | technology_type | scenario_capacity_factor | country_iso2_list | scenario_provider |
|:---|:---|:---|:---|:---|---:|:---|---:|:---|---:|:---|---:|:---|:---|
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2022 | \$/tonnes | 57.03917 | EJ/yr | 159.4468 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2023 | \$/tonnes | 57.35451 | EJ/yr | 160.4324 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2024 | \$/tonnes | 57.66985 | EJ/yr | 161.4180 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2025 | \$/tonnes | 57.98520 | EJ/yr | 162.4035 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2026 | \$/tonnes | 58.41776 | EJ/yr | 162.4545 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2027 | \$/tonnes | 58.85032 | EJ/yr | 162.5055 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2028 | \$/tonnes | 59.28289 | EJ/yr | 162.5565 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2029 | \$/tonnes | 59.71545 | EJ/yr | 162.6075 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2030 | \$/tonnes | 60.14802 | EJ/yr | 162.6585 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2031 | \$/tonnes | 60.53991 | EJ/yr | 163.5647 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2032 | \$/tonnes | 60.93181 | EJ/yr | 164.4709 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2033 | \$/tonnes | 61.32370 | EJ/yr | 165.3771 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2034 | \$/tonnes | 61.71560 | EJ/yr | 166.2833 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2035 | \$/tonnes | 62.10749 | EJ/yr | 167.1895 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2036 | \$/tonnes | 62.28684 | EJ/yr | 167.6793 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2037 | \$/tonnes | 62.46619 | EJ/yr | 168.1691 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2038 | \$/tonnes | 62.64553 | EJ/yr | 168.6589 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2039 | \$/tonnes | 62.82488 | EJ/yr | 169.1487 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2040 | \$/tonnes | 63.00422 | EJ/yr | 169.6385 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2041 | \$/tonnes | 63.11835 | EJ/yr | 169.6492 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2042 | \$/tonnes | 63.23248 | EJ/yr | 169.6599 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2043 | \$/tonnes | 63.34661 | EJ/yr | 169.6706 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2044 | \$/tonnes | 63.46074 | EJ/yr | 169.6813 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2045 | \$/tonnes | 63.57487 | EJ/yr | 169.6920 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2046 | \$/tonnes | 63.60577 | EJ/yr | 169.3689 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2047 | \$/tonnes | 63.63667 | EJ/yr | 169.0457 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2048 | \$/tonnes | 63.66757 | EJ/yr | 168.7226 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2049 | \$/tonnes | 63.69847 | EJ/yr | 168.3994 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2050 | \$/tonnes | 63.72937 | EJ/yr | 168.0763 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2051 | \$/tonnes | 63.73330 | EJ/yr | 167.9941 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2052 | \$/tonnes | 63.73723 | EJ/yr | 167.9119 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2053 | \$/tonnes | 63.74115 | EJ/yr | 167.8298 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2054 | \$/tonnes | 63.74508 | EJ/yr | 167.7476 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2055 | \$/tonnes | 63.74900 | EJ/yr | 167.6655 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2056 | \$/tonnes | 63.66008 | EJ/yr | 167.3440 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2057 | \$/tonnes | 63.57115 | EJ/yr | 167.0226 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2058 | \$/tonnes | 63.48223 | EJ/yr | 166.7011 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2059 | \$/tonnes | 63.39331 | EJ/yr | 166.3796 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2060 | \$/tonnes | 63.30438 | EJ/yr | 166.0582 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2061 | \$/tonnes | 63.18854 | EJ/yr | 165.4385 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2062 | \$/tonnes | 63.07270 | EJ/yr | 164.8189 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2063 | \$/tonnes | 62.95686 | EJ/yr | 164.1992 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2064 | \$/tonnes | 62.84101 | EJ/yr | 163.5796 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2065 | \$/tonnes | 62.72517 | EJ/yr | 162.9599 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2066 | \$/tonnes | 62.58408 | EJ/yr | 161.8002 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2067 | \$/tonnes | 62.44300 | EJ/yr | 160.6404 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2068 | \$/tonnes | 62.30191 | EJ/yr | 159.4807 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2069 | \$/tonnes | 62.16082 | EJ/yr | 158.3210 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2070 | \$/tonnes | 62.01973 | EJ/yr | 157.1612 | carbontech | 1 | NA | NGFS2023GCAM |
| NGFS2023GCAM_CP | baseline | Global | Coal | Coal | 2071 | \$/tonnes | 61.87448 | EJ/yr | 156.1628 | carbontech | 1 | NA | NGFS2023GCAM |

### Financial features

Per-company starting financials. The `pd` here is the pre-stress
probability of default that TRISK shocks.

- `company_id`: company identifier.
- `pd`: starting probability of default.
- `net_profit_margin`, `debt_equity_ratio`, `volatility`: balance-sheet
  inputs to the valuation and Merton PD model.

``` r

str(financial_features_testdata)
#> 'data.frame':    5 obs. of  5 variables:
#>  $ company_id       : int  101 103 105 104 102
#>  $ pd               : num  0.00562 0.00398 0.00246 0.00298 0.00365
#>  $ net_profit_margin: num  0.0764 0.0717 0.0539 0.0539 0.1058
#>  $ debt_equity_ratio: num  0.13 0.128 0.119 0.11 0.104
#>  $ volatility       : num  0.259 0.251 0.236 0.251 0.317
```

| company_id |        pd | net_profit_margin | debt_equity_ratio | volatility |
|-----------:|----------:|------------------:|------------------:|-----------:|
|        101 | 0.0056224 |         0.0763542 |         0.1297317 |  0.2593230 |
|        103 | 0.0039782 |         0.0716949 |         0.1277164 |  0.2513500 |
|        105 | 0.0024568 |         0.0539341 |         0.1194000 |  0.2360043 |
|        104 | 0.0029792 |         0.0539341 |         0.1097633 |  0.2513500 |
|        102 | 0.0036483 |         0.1057878 |         0.1044025 |  0.3167116 |

### NGFS carbon price

Optional carbon tax trajectories applied to company profits. Used only
when you select a `carbon_price_model` other than `no_carbon_tax`.

- `year`, `model`, `scenario`: carbon price record keys.
- `scenario_geography`, `variable`, `unit`: region and units.
- `carbon_tax`: tax amount per ton of CO2.

``` r

str(ngfs_carbon_price_testdata)
#> 'data.frame':    1376 obs. of  7 variables:
#>  $ year              : int  2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 ...
#>  $ model             : chr  "GCAM 5.3+ NGFS" "GCAM 5.3+ NGFS" "GCAM 5.3+ NGFS" "GCAM 5.3+ NGFS" ...
#>  $ scenario          : chr  "B2DS" "B2DS" "B2DS" "B2DS" ...
#>  $ scenario_geography: chr  "Global" "Global" "Global" "Global" ...
#>  $ variable          : chr  "Price|Carbon" "Price|Carbon" "Price|Carbon" "Price|Carbon" ...
#>  $ unit              : chr  "US$2010/t CO2" "US$2010/t CO2" "US$2010/t CO2" "US$2010/t CO2" ...
#>  $ carbon_tax        : num  0 0 0 0 0 0 0 0 0 0 ...
```

| year | model | scenario | scenario_geography | variable | unit | carbon_tax |
|---:|:---|:---|:---|:---|:---|---:|
| 2015 | GCAM 5.3+ NGFS | B2DS | Global | Price&#124;Carbon | US\$2010/t CO2 | 0 |
| 2016 | GCAM 5.3+ NGFS | B2DS | Global | Price&#124;Carbon | US\$2010/t CO2 | 0 |
| 2017 | GCAM 5.3+ NGFS | B2DS | Global | Price&#124;Carbon | US\$2010/t CO2 | 0 |
| 2018 | GCAM 5.3+ NGFS | B2DS | Global | Price&#124;Carbon | US\$2010/t CO2 | 0 |
| 2019 | GCAM 5.3+ NGFS | B2DS | Global | Price&#124;Carbon | US\$2010/t CO2 | 0 |
| 2020 | GCAM 5.3+ NGFS | B2DS | Global | Price&#124;Carbon | US\$2010/t CO2 | 0 |

### Obtaining inputs

The test data above is small and fixed. For real analysis, download the
full production inputs (assets, scenarios, financial features and carbon
prices) from the public endpoint:

``` r

print(
  paste0(trisk.analysis:::TRISK_DATA_INPUT_ENDPOINT, "/", trisk.analysis:::TRISK_DATA_S3_PREFIX)
)
#> [1] "https://storage.googleapis.com/crispy-public-data/trisk_inputs"
```

[`download_trisk_inputs()`](../reference/download_trisk_inputs.md)
writes the four CSV files to a folder of your choice (skipped here so
the vignette has no network dependency):

``` r

trisk_inputs_folder <- file.path(".", "trisk_inputs")
if (!is_CRAN) {
  download_trisk_inputs(local_save_folder = trisk_inputs_folder, skip_confirmation = TRUE)
}
#> Download completed.
#> [1] TRUE
```

Once downloaded you read the CSVs the same way as the test data. The
production `scenarios.csv` covers many more scenarios than the bundled
sample: six providers (NGFS, WEO, IPR, Oxford, GECO and the Mission
Possible Partnership for steel), each with one or more data vintages.

Scenario names encode provider, vintage and scenario,
e.g. `WEO2023_STEPS` is the IEA World Energy Outlook 2023 “Stated
Policies” baseline; `NGFS2023GCAM_NZ2050` is the NGFS 2023 “Net Zero
2050” target run on the GCAM integrated-assessment model. As a rule,
pick the baseline and target from the *same provider*.

The bundled scenarios already expose the valid baseline/target pairings
via
[`get_available_parameters()`](../reference/get_available_parameters.md)
(run here on the test data so it needs no network):

``` r

available_parameters <- get_available_parameters(scenarios_testdata)
```

| scenario_provider | scenario_geography | baseline_scenario | target_scenario |
|:---|:---|:---|:---|
| NGFS2023GCAM | Global | NGFS2023GCAM_CP | NGFS2023GCAM_NZ2050 |
| NGFS2023_GCAM | Global | NGFS2023_GCAM_CP | NGFS2023_GCAM_B2DS |
| NGFS2023_GCAM | Global | NGFS2023_GCAM_CP | NGFS2023_GCAM_DT |
| NGFS2023_GCAM | Global | NGFS2023_GCAM_CP | NGFS2023_GCAM_NZ2050 |
| NGFS2023_MESSAGE | Global | NGFS2023_MESSAGE_CP | NGFS2023_MESSAGE_NZ2050 |
| NGFS2023_REMIND | Global | NGFS2023_REMIND_CP | NGFS2023_REMIND_NZ2050 |

When choosing a scenario consider: data vintage (newer is usually more
relevant), geography coverage (NGFS GCAM offers sub-global regions), the
target’s ambition level (e.g. NGFS B2DS below 2 degrees vs NZ2050 net
zero), and narrative — some NGFS scenarios such as “LD” (Low Demand)
reach net zero through demand assumptions rather than policy alone. See
<https://www.ngfs.net/en> for narrative detail.

## Minimal example

The smallest runnable stress test against the bundled data. The
parameters fall into two groups: scenario selection (which pathways to
compare and where) and financial assumptions (the DCF and PD model
knobs).

``` r

baseline_scenario <- "NGFS2023GCAM_CP"
target_scenario <- "NGFS2023GCAM_NZ2050"
scenario_geography <- "Global"
shock_year <- 2030

carbon_price_model <- "no_carbon_tax"
risk_free_rate <- 0.02
discount_rate <- 0.07
growth_rate <- 0.03
div_netprofit_prop_coef <- 1
market_passthrough <- 0
```

Parameter reference:

- `baseline_scenario`, `target_scenario`: the status-quo and shock
  scenario names.
- `scenario_geography`: region(s) to compute. Choosing a region other
  than `"Global"` filters assets to that region’s countries and uses
  region-specific pathways.
- `shock_year`: the year the transition shock is applied.
- `carbon_price_model`: which carbon tax trajectory to apply
  (`no_carbon_tax` to skip).
- `market_passthrough`: share of the carbon tax the firm passes to
  customers.
- `risk_free_rate`, `discount_rate`, `growth_rate`,
  `div_netprofit_prop_coef`: DCF and PD valuation assumptions.

[`run_trisk_model()`](../reference/run_trisk_model.md) runs the model
and returns results at the asset grain (one row per company / asset /
country / technology):

``` r

st_results <- run_trisk_model(
  assets_data = assets_testdata,
  scenarios_data = scenarios_testdata,
  financial_data = financial_features_testdata,
  carbon_data = ngfs_carbon_price_testdata,
  baseline_scenario = baseline_scenario,
  target_scenario = target_scenario,
  scenario_geography = scenario_geography,
  shock_year = shock_year,
  carbon_price_model = carbon_price_model,
  risk_free_rate = risk_free_rate,
  discount_rate = discount_rate,
  growth_rate = growth_rate,
  div_netprofit_prop_coef = div_netprofit_prop_coef,
  market_passthrough = market_passthrough
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

npv_results <- st_results$npv_results
pd_results <- st_results$pd_results
company_trajectories <- st_results$company_trajectories
```

### Company-aggregated results

Since December 2024 TRISK runs at the company / country / technology
grain, which improves NPV and trajectory accuracy but changes the output
shape relative to older analyses.
[`run_trisk_agg()`](../reference/run_trisk_agg.md) takes the same
arguments and aggregates NPVs per company over country and technology,
restoring the pre-2024 output structure for backward compatibility or
simpler reporting. PD results are unaffected — they are already at the
company/sector grain in both functions.

``` r

st_results_agg <- run_trisk_agg(
  assets_data = assets_testdata,
  scenarios_data = scenarios_testdata,
  financial_data = financial_features_testdata,
  carbon_data = ngfs_carbon_price_testdata,
  baseline_scenario = baseline_scenario,
  target_scenario = target_scenario,
  scenario_geography = scenario_geography,
  shock_year = shock_year
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

npv_results_agg <- st_results_agg$npv_results
```

The aggregated NPV table drops the `country_iso2` column:

| run_id | company_id | asset_id | company_name | asset_name | sector | technology | net_present_value_baseline | net_present_value_shock | net_present_value_difference | net_present_value_change |
|:---|:---|:---|:---|:---|:---|:---|---:|---:|---:|---:|
| 8d8094ba-d189-4e6e-9beb-f4fba97acecc | 101 | 101 | Company 1 | Company 1 | Oil&Gas | Gas | 51951.82 | 13549.28 | -38402.54 | -0.7391952 |
| 8d8094ba-d189-4e6e-9beb-f4fba97acecc | 102 | 102 | Company 2 | Company 2 | Coal | Coal | 13648160.57 | 4317747.56 | -9330413.02 | -0.6836389 |
| 8d8094ba-d189-4e6e-9beb-f4fba97acecc | 103 | 103 | Company 3 | Company 3 | Oil&Gas | Gas | 27724344.25 | 12420187.12 | -15304157.13 | -0.5520115 |
| 8d8094ba-d189-4e6e-9beb-f4fba97acecc | 104 | 104 | Company 4 | Company 4 | Power | RenewablesCap | 141635910\.26 | 202554984\.40 | 60919074.14 | 0.4301104 |
| 8d8094ba-d189-4e6e-9beb-f4fba97acecc | 105 | 105 | Company 5 | Company 5 | Power | CoalCap | 57418851.27 | 11874146.56 | -45544704.71 | -0.7932013 |
| 8d8094ba-d189-4e6e-9beb-f4fba97acecc | 105 | 105 | Company 5 | Company 5 | Power | OilCap | 6210907.85 | 1416673.16 | -4794234.69 | -0.7719056 |

### Adding a carbon tax

To stress profits with a carbon tax, pick a `carbon_price_model` present
in your carbon data and a `market_passthrough` between 0 and 1. The test
data ships the `GCAM 5.3+ NGFS` trajectory plus several illustrative
flat and increasing taxes:

``` r

ngfs_carbon_price_testdata %>%
  distinct(model)
#>                                  model
#> 1                       GCAM 5.3+ NGFS
#> 2                   flat_carbon_tax_50
#> 3             increasing_carbon_tax_50
#> 4 independent_increasing_carbon_tax_50
#> 5                        no_carbon_tax
```

``` r

st_results_tax <- run_trisk_model(
  assets_data = assets_testdata,
  scenarios_data = scenarios_testdata,
  financial_data = financial_features_testdata,
  carbon_data = ngfs_carbon_price_testdata,
  baseline_scenario = baseline_scenario,
  target_scenario = target_scenario,
  scenario_geography = scenario_geography,
  carbon_price_model = "GCAM 5.3+ NGFS",
  market_passthrough = 0.3
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

## Outputs and interpretation

Each run returns a list of three tables. For a credit analyst the
headline is the *difference* between baseline and shock columns: a large
drop from baseline to shock NPV, or a jump from baseline to shock PD,
flags a counterparty whose value or creditworthiness is sensitive to the
transition.

### NPV results

Net present value of each asset under both scenarios. Compare
`net_present_value_baseline` against `net_present_value_shock`: the gap
is the transition value-at-risk for that asset.

- `run_id`: identifier for the simulation run.
- `company_id`, `asset_id`, `company_name`, `asset_name`: identifiers.
- `country_iso2`: country of the asset (absent in
  [`run_trisk_agg()`](../reference/run_trisk_agg.md) output).
- `sector`, `technology`: classification (e.g. Oil&Gas, Coal, Power;
  Gas, CoalCap, RenewablesCap).
- `net_present_value_baseline`, `net_present_value_shock`: NPV under
  each scenario.
- `net_present_value_difference`, `net_present_value_change`: shock
  minus baseline (absolute) and the relative change.

``` r

str(npv_results)
#> tibble [7 × 12] (S3: tbl_df/tbl/data.frame)
#>  $ run_id                      : chr [1:7] "2a4f1e22-3476-4011-971c-4c2172652449" "2a4f1e22-3476-4011-971c-4c2172652449" "2a4f1e22-3476-4011-971c-4c2172652449" "2a4f1e22-3476-4011-971c-4c2172652449" ...
#>  $ company_id                  : chr [1:7] "101" "102" "103" "104" ...
#>  $ asset_id                    : chr [1:7] "101" "102" "103" "104" ...
#>  $ company_name                : chr [1:7] "Company 1" "Company 2" "Company 3" "Company 4" ...
#>  $ asset_name                  : chr [1:7] "Company 1" "Company 2" "Company 3" "Company 4" ...
#>  $ sector                      : chr [1:7] "Oil&Gas" "Coal" "Oil&Gas" "Power" ...
#>  $ technology                  : chr [1:7] "Gas" "Coal" "Gas" "RenewablesCap" ...
#>  $ country_iso2                : chr [1:7] "DE" "DE" "DE" "DE" ...
#>  $ net_present_value_baseline  : num [1:7] 5.20e+04 1.36e+07 2.77e+07 1.42e+08 5.74e+07 ...
#>  $ net_present_value_shock     : num [1:7] 1.35e+04 4.32e+06 1.24e+07 2.03e+08 1.19e+07 ...
#>  $ net_present_value_difference: num [1:7] -38403 -9330413 -15304157 60919074 -45544705 ...
#>  $ net_present_value_change    : num [1:7] -0.739 -0.684 -0.552 0.43 -0.793 ...
```

| run_id | company_id | asset_id | company_name | asset_name | sector | technology | country_iso2 | net_present_value_baseline | net_present_value_shock | net_present_value_difference | net_present_value_change |
|:---|:---|:---|:---|:---|:---|:---|:---|---:|---:|---:|---:|
| 2a4f1e22-3476-4011-971c-4c2172652449 | 101 | 101 | Company 1 | Company 1 | Oil&Gas | Gas | DE | 51951.82 | 13549.28 | -38402.54 | -0.7391952 |
| 2a4f1e22-3476-4011-971c-4c2172652449 | 102 | 102 | Company 2 | Company 2 | Coal | Coal | DE | 13648160.57 | 4317747.56 | -9330413.02 | -0.6836389 |
| 2a4f1e22-3476-4011-971c-4c2172652449 | 103 | 103 | Company 3 | Company 3 | Oil&Gas | Gas | DE | 27724344.25 | 12420187.12 | -15304157.13 | -0.5520115 |
| 2a4f1e22-3476-4011-971c-4c2172652449 | 104 | 104 | Company 4 | Company 4 | Power | RenewablesCap | DE | 141635910\.26 | 202554984\.40 | 60919074.14 | 0.4301104 |
| 2a4f1e22-3476-4011-971c-4c2172652449 | 105 | 105 | Company 5 | Company 5 | Power | CoalCap | DE | 57418851.27 | 11874146.56 | -45544704.71 | -0.7932013 |
| 2a4f1e22-3476-4011-971c-4c2172652449 | 105 | 105 | Company 5 | Company 5 | Power | OilCap | DE | 6210907.85 | 1416673.16 | -4794234.69 | -0.7719056 |

### PD results

Probability of default per company and term, before and after the shock.
The `pd_shock - pd_baseline` spread is the transition-driven increase in
default risk to feed into credit models.

- `run_id`, `company_id`, `company_name`: identifiers.
- `sector`: company sector.
- `term`: horizon of the PD estimate.
- `pd_baseline`, `pd_shock`: PD under each scenario.

``` r

str(pd_results)
#> tibble [145 × 7] (S3: tbl_df/tbl/data.frame)
#>  $ run_id      : chr [1:145] "2a4f1e22-3476-4011-971c-4c2172652449" "2a4f1e22-3476-4011-971c-4c2172652449" "2a4f1e22-3476-4011-971c-4c2172652449" "2a4f1e22-3476-4011-971c-4c2172652449" ...
#>  $ company_id  : chr [1:145] "101" "101" "101" "101" ...
#>  $ company_name: chr [1:145] "Company 1" "Company 1" "Company 1" "Company 1" ...
#>  $ sector      : chr [1:145] "Oil&Gas" "Oil&Gas" "Oil&Gas" "Oil&Gas" ...
#>  $ term        : int [1:145] 1 2 3 4 5 6 7 8 9 10 ...
#>  $ pd_baseline : num [1:145] 0.00 2.82e-09 1.14e-06 2.37e-05 1.50e-04 ...
#>  $ pd_shock    : num [1:145] 2.61e-09 2.14e-05 4.65e-04 2.25e-03 5.91e-03 ...
```

| run_id | company_id | company_name | sector | term | pd_baseline | pd_shock |
|:---|:---|:---|:---|---:|---:|---:|
| 2a4f1e22-3476-4011-971c-4c2172652449 | 101 | Company 1 | Oil&Gas | 1 | 0.0000000 | 0.0000000 |
| 2a4f1e22-3476-4011-971c-4c2172652449 | 101 | Company 1 | Oil&Gas | 2 | 0.0000000 | 0.0000214 |
| 2a4f1e22-3476-4011-971c-4c2172652449 | 101 | Company 1 | Oil&Gas | 3 | 0.0000011 | 0.0004647 |
| 2a4f1e22-3476-4011-971c-4c2172652449 | 101 | Company 1 | Oil&Gas | 4 | 0.0000237 | 0.0022474 |
| 2a4f1e22-3476-4011-971c-4c2172652449 | 101 | Company 1 | Oil&Gas | 5 | 0.0001502 | 0.0059057 |
| 2a4f1e22-3476-4011-971c-4c2172652449 | 101 | Company 1 | Oil&Gas | 6 | 0.0005218 | 0.0113956 |

### Company trajectories

The year-by-year detail behind the NPV and PD numbers: production,
prices and profits along each pathway. Use this to audit *why* a
company’s value moved — for example a coal asset whose shock-scenario
production collapses while its baseline holds.

- `run_id`, `asset_id`, `asset_name`, `company_id`, `company_name`,
  `country_iso2`: identifiers.
- `year`, `sector`, `technology`: time and classification.
- `production_plan_company_technology`: the company’s own production
  plan.
- `production_baseline_scenario`, `production_target_scenario`,
  `production_shock_scenario`: production along each pathway.
- `pd`, `net_profit_margin`, `debt_equity_ratio`, `volatility`:
  carried-through financial features.
- `scenario_price_baseline`, `price_shock_scenario`: prices per
  scenario.
- `net_profits_baseline_scenario`, `net_profits_shock_scenario`: net
  profits per scenario.
- `discounted_net_profits_baseline_scenario`,
  `discounted_net_profits_shock_scenario`: discounted net profits
  feeding the NPV.

``` r

str(company_trajectories)
#> tibble [210 × 23] (S3: tbl_df/tbl/data.frame)
#>  $ run_id                                  : chr [1:210] "2a4f1e22-3476-4011-971c-4c2172652449" "2a4f1e22-3476-4011-971c-4c2172652449" "2a4f1e22-3476-4011-971c-4c2172652449" "2a4f1e22-3476-4011-971c-4c2172652449" ...
#>  $ asset_id                                : chr [1:210] "101" "101" "101" "101" ...
#>  $ asset_name                              : chr [1:210] "Company 1" "Company 1" "Company 1" "Company 1" ...
#>  $ company_id                              : chr [1:210] "101" "101" "101" "101" ...
#>  $ company_name                            : chr [1:210] "Company 1" "Company 1" "Company 1" "Company 1" ...
#>  $ country_iso2                            : chr [1:210] "DE" "DE" "DE" "DE" ...
#>  $ sector                                  : chr [1:210] "Oil&Gas" "Oil&Gas" "Oil&Gas" "Oil&Gas" ...
#>  $ technology                              : chr [1:210] "Gas" "Gas" "Gas" "Gas" ...
#>  $ year                                    : num [1:210] 2022 2023 2024 2025 2026 ...
#>  $ production_plan_company_technology      : num [1:210] 5000 5423 6200 7400 7800 ...
#>  $ production_baseline_scenario            : num [1:210] 5000 5423 6200 7400 7800 ...
#>  $ production_target_scenario              : num [1:210] 5000 5001 5003 5004 4863 ...
#>  $ production_shock_scenario               : num [1:210] 5000 5423 6200 7400 7800 ...
#>  $ pd                                      : num [1:210] 0.00562 0.00562 0.00562 0.00562 0.00562 ...
#>  $ net_profit_margin                       : num [1:210] 0.0764 0.0764 0.0764 0.0764 0.0764 ...
#>  $ debt_equity_ratio                       : num [1:210] 0.13 0.13 0.13 0.13 0.13 ...
#>  $ volatility                              : num [1:210] 0.259 0.259 0.259 0.259 0.259 ...
#>  $ scenario_price_baseline                 : num [1:210] 5.87 5.9 5.93 5.96 5.95 ...
#>  $ price_shock_scenario                    : num [1:210] 5.87 5.9 5.93 5.96 5.95 ...
#>  $ net_profits_baseline_scenario           : num [1:210] 2240 2442 2807 3368 3541 ...
#>  $ net_profits_shock_scenario              : num [1:210] 2240 2442 2807 3368 3541 ...
#>  $ discounted_net_profits_baseline_scenario: num [1:210] 2240 2283 2452 2750 2701 ...
#>  $ discounted_net_profits_shock_scenario   : num [1:210] 2240 2283 2452 2750 2701 ...
```

| run_id | asset_id | asset_name | company_id | company_name | country_iso2 | sector | technology | year | production_plan_company_technology | production_baseline_scenario | production_target_scenario | production_shock_scenario | pd | net_profit_margin | debt_equity_ratio | volatility | scenario_price_baseline | price_shock_scenario | net_profits_baseline_scenario | net_profits_shock_scenario | discounted_net_profits_baseline_scenario | discounted_net_profits_shock_scenario |
|:---|:---|:---|:---|:---|:---|:---|:---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| 2a4f1e22-3476-4011-971c-4c2172652449 | 101 | Company 1 | 101 | Company 1 | DE | Oil&Gas | Gas | 2022 | 5000 | 5000 | 5000.000 | 5000 | 0.0056224 | 0.0763542 | 0.1297317 | 0.259323 | 5.867116 | 5.867116 | 2239.895 | 2239.895 | 2239.895 | 2239.895 |
| 2a4f1e22-3476-4011-971c-4c2172652449 | 101 | Company 1 | 101 | Company 1 | DE | Oil&Gas | Gas | 2023 | 5423 | 5423 | 5001.354 | 5423 | 0.0056224 | 0.0763542 | 0.1297317 | 0.259323 | 5.898569 | 5.898569 | 2442.414 | 2442.414 | 2282.630 | 2282.630 |
| 2a4f1e22-3476-4011-971c-4c2172652449 | 101 | Company 1 | 101 | Company 1 | DE | Oil&Gas | Gas | 2024 | 6200 | 6200 | 5002.708 | 6200 | 0.0056224 | 0.0763542 | 0.1297317 | 0.259323 | 5.930022 | 5.930022 | 2807.250 | 2807.250 | 2451.961 | 2451.961 |
| 2a4f1e22-3476-4011-971c-4c2172652449 | 101 | Company 1 | 101 | Company 1 | DE | Oil&Gas | Gas | 2025 | 7400 | 7400 | 5004.062 | 7400 | 0.0056224 | 0.0763542 | 0.1297317 | 0.259323 | 5.961475 | 5.961475 | 3368.360 | 3368.360 | 2749.585 | 2749.585 |
| 2a4f1e22-3476-4011-971c-4c2172652449 | 101 | Company 1 | 101 | Company 1 | DE | Oil&Gas | Gas | 2026 | 7800 | 7800 | 4862.620 | 7800 | 0.0056224 | 0.0763542 | 0.1297317 | 0.259323 | 5.945170 | 5.945170 | 3540.723 | 3540.723 | 2701.201 | 2701.201 |
| 2a4f1e22-3476-4011-971c-4c2172652449 | 101 | Company 1 | 101 | Company 1 | DE | Oil&Gas | Gas | 2027 | 8600 | 8600 | 4721.178 | 8600 | 0.0056224 | 0.0763542 | 0.1297317 | 0.259323 | 5.928866 | 5.928866 | 3893.168 | 3893.168 | 2775.775 | 2775.775 |

## Caveats

- **Scenario coverage is uneven.** Some sectors (notably steel) have far
  fewer scenarios than power, because of upstream data limitations.
  Always pair a baseline and target from the same provider and vintage.
- **Geography filtering is implicit.** Choosing a `scenario_geography`
  other than `"Global"` silently drops assets outside that region’s
  countries — check your asset count after filtering.
- **Carbon tax requires matching data.** A `carbon_price_model` only
  takes effect if that model exists in `carbon_data`; otherwise leave it
  as `no_carbon_tax`.
- **Test data is illustrative.** The bundled datasets exist to make
  examples runnable, not to produce representative risk numbers — use
  the downloaded production inputs for real analysis.

## See also

- `getting-started` — install and run your first stress test.
- `run-on-a-portfolio` — apply TRISK to a portfolio of counterparties.
- `pd-el-integration` — turn shocked PDs into expected-loss figures.
- `sensitivity-analysis` — sweep parameters to test result stability.
