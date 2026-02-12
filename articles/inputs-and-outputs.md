# inputs-and-outputs

``` r
library(trisk.analysis)
library(magrittr)
```

## Input datasets

Load the internal datasets

``` r
assets_testdata <- read.csv(system.file("testdata", "assets_testdata.csv", package = "trisk.model"))
scenarios_testdata <- read.csv(system.file("testdata", "scenarios_testdata.csv", package = "trisk.model"))
financial_features_testdata <- read.csv(system.file("testdata", "financial_features_testdata.csv", package = "trisk.model"))
ngfs_carbon_price_testdata <- read.csv(system.file("testdata", "ngfs_carbon_price_testdata.csv", package = "trisk.model"))
```

#### Assets Test Data

This dataset contains data about company assets, including production,
technology, and geographical details.

##### Data Description

The `assets_testdata` dataset includes the following columns:

- `company_id`: Unique identifier for the company.
- `company_name`: Name of the company.
- `asset_id`: Unique identifier for the asset.
- `country_iso2`: ISO 3166-1 alpha-2 code for the country.
- `asset_name`: Name of the asset.
- `production_year`: Year of production data.
- `emission_factor`: Emissions from production.
- `technology`: Type of technology used.
- `sector`: Production sector.
- `capacity`: Asset capacity.
- `capacity_factor`: Asset utilization percentage.
- `production_unit`: Unit for production.

##### Data Structure

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

##### Sample Data

| company_id | company_name | asset_id | country_iso2 | asset_name | production_year | emission_factor | technology | sector  | capacity | capacity_factor | production_unit |
|-----------:|:-------------|---------:|:-------------|:-----------|----------------:|----------------:|:-----------|:--------|---------:|----------------:|:----------------|
|        101 | Company 1    |      101 | DE           | Company 1  |            2022 |       0.0620259 | Gas        | Oil&Gas |     8600 |       0.5813953 | GJ              |
|        101 | Company 1    |      101 | DE           | Company 1  |            2023 |       0.0620259 | Gas        | Oil&Gas |     8600 |       0.6305814 | GJ              |
|        101 | Company 1    |      101 | DE           | Company 1  |            2024 |       0.0620259 | Gas        | Oil&Gas |     8600 |       0.7209302 | GJ              |
|        101 | Company 1    |      101 | DE           | Company 1  |            2025 |       0.0620259 | Gas        | Oil&Gas |     8600 |       0.8604651 | GJ              |
|        101 | Company 1    |      101 | DE           | Company 1  |            2026 |       0.0620259 | Gas        | Oil&Gas |     8600 |       0.9069767 | GJ              |
|        101 | Company 1    |      101 | DE           | Company 1  |            2027 |       0.0620259 | Gas        | Oil&Gas |     8600 |       1.0000000 | GJ              |

------------------------------------------------------------------------

#### Financial Features Test Data

This dataset contains financial metrics necessary for calculating stress
test outputs.

##### Data Description

The `financial_features_testdata` dataset includes the following
columns:

- `company_id`: Unique identifier for the company.
- `pd`: Probability of default for the company.
- `net_profit_margin`: Net profit margin for the company.
- `debt_equity_ratio`: Debt to equity ratio.
- `volatility`: Volatility of the company’s asset values.

##### Data Structure

``` r
str(financial_features_testdata)
#> 'data.frame':    5 obs. of  5 variables:
#>  $ company_id       : int  101 103 105 104 102
#>  $ pd               : num  0.00562 0.00398 0.00246 0.00298 0.00365
#>  $ net_profit_margin: num  0.0764 0.0717 0.0539 0.0539 0.1058
#>  $ debt_equity_ratio: num  0.13 0.128 0.119 0.11 0.104
#>  $ volatility       : num  0.259 0.251 0.236 0.251 0.317
```

##### Sample Data

| company_id |        pd | net_profit_margin | debt_equity_ratio | volatility |
|-----------:|----------:|------------------:|------------------:|-----------:|
|        101 | 0.0056224 |         0.0763542 |         0.1297317 |  0.2593230 |
|        103 | 0.0039782 |         0.0716949 |         0.1277164 |  0.2513500 |
|        105 | 0.0024568 |         0.0539341 |         0.1194000 |  0.2360043 |
|        104 | 0.0029792 |         0.0539341 |         0.1097633 |  0.2513500 |
|        102 | 0.0036483 |         0.1057878 |         0.1044025 |  0.3167116 |

------------------------------------------------------------------------

#### NGFS Carbon Price Test Data

This dataset provides carbon pricing data used in the stress test
scenarios.

##### Data Description

The `ngfs_carbon_price_testdata` dataset includes the following columns:

- `year`: Year of the carbon price.
- `model`: Model used to generate the carbon price.
- `scenario`: Scenario name.
- `scenario_geography`: Geographic region for the scenario.
- `variable`: The variable measured (e.g., carbon price).
- `unit`: Unit of the variable.
- `carbon_tax`: The amount of carbon tax applied in the scenario.

##### Data Structure

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

##### Sample Data

| year | model          | scenario | scenario_geography | variable          | unit           | carbon_tax |
|-----:|:---------------|:---------|:-------------------|:------------------|:---------------|-----------:|
| 2015 | GCAM 5.3+ NGFS | B2DS     | Global             | Price&#124;Carbon | US\$2010/t CO2 |          0 |
| 2016 | GCAM 5.3+ NGFS | B2DS     | Global             | Price&#124;Carbon | US\$2010/t CO2 |          0 |
| 2017 | GCAM 5.3+ NGFS | B2DS     | Global             | Price&#124;Carbon | US\$2010/t CO2 |          0 |
| 2018 | GCAM 5.3+ NGFS | B2DS     | Global             | Price&#124;Carbon | US\$2010/t CO2 |          0 |
| 2019 | GCAM 5.3+ NGFS | B2DS     | Global             | Price&#124;Carbon | US\$2010/t CO2 |          0 |
| 2020 | GCAM 5.3+ NGFS | B2DS     | Global             | Price&#124;Carbon | US\$2010/t CO2 |          0 |

------------------------------------------------------------------------

#### Scenarios Test Data

This dataset contains scenario-specific data including price paths,
capacity factors, and other relevant information.

##### Data Description

The `scenarios_testdata` dataset includes the following columns:

- `scenario_geography`: Region relevant to the scenario.
- `scenario`: Scenario name.
- `scenario_pathway`: Specific pathway for the scenario.
- `scenario_type`: Type of scenario (e.g., baseline, shock).
- `sector`: Sector of production.
- `technology`: Type of technology.
- `scenario_year`: Year of the scenario data.
- `scenario_price`: Price in the scenario.
- `price_unit`: Unit for the price.
- `pathway_unit`: Unit of the pathway.
- `technology_type`: Type of technology involved (carbon or renewable).

##### Data Structure

``` r
str(scenarios_testdata)
#> 'data.frame':    1422 obs. of  14 variables:
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

##### Sample Data

| scenario        | scenario_type | scenario_geography | sector | technology | scenario_year | price_unit | scenario_price | pathway_unit | scenario_pathway | technology_type | scenario_capacity_factor | country_iso2_list | scenario_provider |
|:----------------|:--------------|:-------------------|:-------|:-----------|--------------:|:-----------|---------------:|:-------------|-----------------:|:----------------|-------------------------:|:------------------|:------------------|
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2022 | \$/tonnes  |       57.03917 | EJ/yr        |         159.4468 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2023 | \$/tonnes  |       57.35451 | EJ/yr        |         160.4324 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2024 | \$/tonnes  |       57.66985 | EJ/yr        |         161.4180 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2025 | \$/tonnes  |       57.98520 | EJ/yr        |         162.4035 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2026 | \$/tonnes  |       58.41776 | EJ/yr        |         162.4545 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2027 | \$/tonnes  |       58.85032 | EJ/yr        |         162.5055 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2028 | \$/tonnes  |       59.28289 | EJ/yr        |         162.5565 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2029 | \$/tonnes  |       59.71545 | EJ/yr        |         162.6075 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2030 | \$/tonnes  |       60.14802 | EJ/yr        |         162.6585 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2031 | \$/tonnes  |       60.53991 | EJ/yr        |         163.5647 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2032 | \$/tonnes  |       60.93181 | EJ/yr        |         164.4709 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2033 | \$/tonnes  |       61.32370 | EJ/yr        |         165.3771 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2034 | \$/tonnes  |       61.71560 | EJ/yr        |         166.2833 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2035 | \$/tonnes  |       62.10749 | EJ/yr        |         167.1895 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2036 | \$/tonnes  |       62.28684 | EJ/yr        |         167.6793 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2037 | \$/tonnes  |       62.46619 | EJ/yr        |         168.1691 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2038 | \$/tonnes  |       62.64553 | EJ/yr        |         168.6589 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2039 | \$/tonnes  |       62.82488 | EJ/yr        |         169.1487 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2040 | \$/tonnes  |       63.00422 | EJ/yr        |         169.6385 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2041 | \$/tonnes  |       63.11835 | EJ/yr        |         169.6492 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2042 | \$/tonnes  |       63.23248 | EJ/yr        |         169.6599 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2043 | \$/tonnes  |       63.34661 | EJ/yr        |         169.6706 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2044 | \$/tonnes  |       63.46074 | EJ/yr        |         169.6813 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2045 | \$/tonnes  |       63.57487 | EJ/yr        |         169.6920 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2046 | \$/tonnes  |       63.60577 | EJ/yr        |         169.3689 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2047 | \$/tonnes  |       63.63667 | EJ/yr        |         169.0457 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2048 | \$/tonnes  |       63.66757 | EJ/yr        |         168.7226 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2049 | \$/tonnes  |       63.69847 | EJ/yr        |         168.3994 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2050 | \$/tonnes  |       63.72937 | EJ/yr        |         168.0763 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2051 | \$/tonnes  |       63.73330 | EJ/yr        |         167.9941 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2052 | \$/tonnes  |       63.73723 | EJ/yr        |         167.9119 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2053 | \$/tonnes  |       63.74115 | EJ/yr        |         167.8298 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2054 | \$/tonnes  |       63.74508 | EJ/yr        |         167.7476 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2055 | \$/tonnes  |       63.74900 | EJ/yr        |         167.6655 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2056 | \$/tonnes  |       63.66008 | EJ/yr        |         167.3440 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2057 | \$/tonnes  |       63.57115 | EJ/yr        |         167.0226 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2058 | \$/tonnes  |       63.48223 | EJ/yr        |         166.7011 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2059 | \$/tonnes  |       63.39331 | EJ/yr        |         166.3796 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2060 | \$/tonnes  |       63.30438 | EJ/yr        |         166.0582 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2061 | \$/tonnes  |       63.18854 | EJ/yr        |         165.4385 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2062 | \$/tonnes  |       63.07270 | EJ/yr        |         164.8189 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2063 | \$/tonnes  |       62.95686 | EJ/yr        |         164.1992 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2064 | \$/tonnes  |       62.84101 | EJ/yr        |         163.5796 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2065 | \$/tonnes  |       62.72517 | EJ/yr        |         162.9599 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2066 | \$/tonnes  |       62.58408 | EJ/yr        |         161.8002 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2067 | \$/tonnes  |       62.44300 | EJ/yr        |         160.6404 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2068 | \$/tonnes  |       62.30191 | EJ/yr        |         159.4807 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2069 | \$/tonnes  |       62.16082 | EJ/yr        |         158.3210 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2070 | \$/tonnes  |       62.01973 | EJ/yr        |         157.1612 | carbontech      |                        1 | NA                | NGFS2023GCAM      |
| NGFS2023GCAM_CP | baseline      | Global             | Coal   | Coal       |          2071 | \$/tonnes  |       61.87448 | EJ/yr        |         156.1628 | carbontech      |                        1 | NA                | NGFS2023GCAM      |

## Trisk run

#### Parameters

Trisk takes several parameters in input, allowing to adjust the model’s
assumptions.

- `baseline_scenario`: String specifying the name of the baseline
  scenario.
- `target_scenario`: String specifying the name of the shock scenario.
- `scenario_geography`: Character vector indicating which geographical
  region(s) to calculate results for.
- `carbon_price_model`: Character vector specifying which NGFS model to
  use for carbon prices.
- `risk_free_rate`: Numeric value for the risk-free interest rate.
- `discount_rate`: Numeric value for the discount rate of dividends per
  year in the DCF.
- `growth_rate`: Numeric value for the terminal growth rate of profits
  beyond the final year in the DCF.
- `div_netprofit_prop_coef`: Numeric coefficient determining how
  strongly future dividends propagate to company value.
- `shock_year`: Numeric value specifying the year when the shock is
  applied.
- `market_passthrough`: Numeric value representing the firm’s ability to
  pass carbon tax onto the consumer.

Those parameters have an impact on trajectories

``` r
baseline_scenario <- "NGFS2023GCAM_CP"
target_scenario <- "NGFS2023GCAM_NZ2050"
scenario_geography <- "Global"
shock_year <- 2030
```

Those parameters will have an impact on internal NPV and PD
computations:

``` r
carbon_price_model <- "no_carbon_tax"
risk_free_rate <- 0.02
discount_rate <- 0.07
growth_rate <- 0.03
div_netprofit_prop_coef <- 1
shock_year <- 2030
market_passthrough <- 0
```

#### Run and return aggregated result

The function [`run_trisk_agg()`](../reference/run_trisk_agg.md) runs the
Trisk model using the provided input and returns the outputs, with NPVs
aggregated per company over technology.

``` r
st_results_agg <- run_trisk_agg(
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
```

Get result dataframes from function output

``` r
npv_results_agg <- st_results_agg$npv_results
pd_results_agg <- st_results_agg$pd_results
company_trajectories_agg <- st_results_agg$company_trajectories
```

NPV result sample (no country_iso2 column):

| run_id                               | company_id | asset_id | company_name | asset_name | sector  | technology    | net_present_value_baseline | net_present_value_shock | net_present_value_difference | net_present_value_change |
|:-------------------------------------|:-----------|:---------|:-------------|:-----------|:--------|:--------------|---------------------------:|------------------------:|-----------------------------:|-------------------------:|
| 3c215d91-1aee-473f-8a08-629ecf6a863c | 101        | 101      | Company 1    | Company 1  | Oil&Gas | Gas           |                   172718.3 |            1.354928e+04 |                      -159169 |               -0.9215527 |
| 3c215d91-1aee-473f-8a08-629ecf6a863c | 102        | 102      | Company 2    | Company 2  | Coal    | Coal          |                 42299475.0 |            4.317748e+06 |                    -37981727 |               -0.8979243 |
| 3c215d91-1aee-473f-8a08-629ecf6a863c | 103        | 103      | Company 3    | Company 3  | Oil&Gas | Gas           |                 95105145.4 |            2.486475e+07 |                    -70240391 |               -0.7385551 |
| 3c215d91-1aee-473f-8a08-629ecf6a863c | 104        | 104      | Company 4    | Company 4  | Power   | RenewablesCap |               1016926683.7 |            1.366640e+09 |                    349713309 |                0.3438924 |
| 3c215d91-1aee-473f-8a08-629ecf6a863c | 105        | 105      | Company 5    | Company 5  | Power   | CoalCap       |               176175702\.5 |            1.187415e+07 |                   -164301556 |               -0.9326005 |
| 3c215d91-1aee-473f-8a08-629ecf6a863c | 105        | 105      | Company 5    | Company 5  | Power   | OilCap        |                 21412749.3 |            1.416673e+06 |                    -19996076 |               -0.9338397 |

#### Run and return results with country granularity

The function [`run_trisk_model()`](../reference/run_trisk_model.md) runs
the Trisk model using the provided input and returns the outputs, with
NPVs disaggregated per country.

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
```

Get result dataframes from function output

``` r
npv_results <- st_results$npv_results
pd_results <- st_results$pd_results
company_trajectories <- st_results$company_trajectories
```

## Output datasets

#### NPV results

##### Data Description

The `npv_results` dataset includes the following columns:

- `run_id`: Unique identifier for the simulation run.
- `company_id`: Unique identifier for the company.
- `asset_id`: Unique identifier for the asset.
- `company_name`: Name of the company.
- `asset_name`: Name of the asset.
- `country_iso2`: ISO 3166-1 alpha-2 code for the country.
- `sector`: Sector in which the company operates (e.g., Oil&Gas, Coal,
  Power).
- `technology`: Type of technology used by the company (e.g., Gas,
  CoalCap, RenewablesCap).
- `net_present_value_baseline`: Net present value (NPV) under the
  baseline scenario.
- `net_present_value_shock`: Net present value (NPV) under the shock
  scenario.

##### Data Structure

``` r
str(npv_results)
#> tibble [7 × 12] (S3: tbl_df/tbl/data.frame)
#>  $ run_id                      : chr [1:7] "90f8ef0b-a9b5-4bf1-86c0-7f22320074c6" "90f8ef0b-a9b5-4bf1-86c0-7f22320074c6" "90f8ef0b-a9b5-4bf1-86c0-7f22320074c6" "90f8ef0b-a9b5-4bf1-86c0-7f22320074c6" ...
#>  $ company_id                  : chr [1:7] "101" "102" "103" "104" ...
#>  $ asset_id                    : chr [1:7] "101" "102" "103" "104" ...
#>  $ company_name                : chr [1:7] "Company 1" "Company 2" "Company 3" "Company 4" ...
#>  $ asset_name                  : chr [1:7] "Company 1" "Company 2" "Company 3" "Company 4" ...
#>  $ sector                      : chr [1:7] "Oil&Gas" "Coal" "Oil&Gas" "Power" ...
#>  $ technology                  : chr [1:7] "Gas" "Coal" "Gas" "RenewablesCap" ...
#>  $ country_iso2                : chr [1:7] "DE" "DE" "DE" "DE" ...
#>  $ net_present_value_baseline  : num [1:7] 1.73e+05 4.23e+07 9.51e+07 1.02e+09 1.76e+08 ...
#>  $ net_present_value_shock     : num [1:7] 1.35e+04 4.32e+06 2.49e+07 1.37e+09 1.19e+07 ...
#>  $ net_present_value_difference: num [1:7] -1.59e+05 -3.80e+07 -7.02e+07 3.50e+08 -1.64e+08 ...
#>  $ net_present_value_change    : num [1:7] -0.922 -0.898 -0.739 0.344 -0.933 ...
```

##### Sample Data

| run_id                               | company_id | asset_id | company_name | asset_name | sector  | technology    | country_iso2 | net_present_value_baseline | net_present_value_shock | net_present_value_difference | net_present_value_change |
|:-------------------------------------|:-----------|:---------|:-------------|:-----------|:--------|:--------------|:-------------|---------------------------:|------------------------:|-----------------------------:|-------------------------:|
| 90f8ef0b-a9b5-4bf1-86c0-7f22320074c6 | 101        | 101      | Company 1    | Company 1  | Oil&Gas | Gas           | DE           |                   172718.3 |            1.354928e+04 |                      -159169 |               -0.9215527 |
| 90f8ef0b-a9b5-4bf1-86c0-7f22320074c6 | 102        | 102      | Company 2    | Company 2  | Coal    | Coal          | DE           |                 42299475.0 |            4.317748e+06 |                    -37981727 |               -0.8979243 |
| 90f8ef0b-a9b5-4bf1-86c0-7f22320074c6 | 103        | 103      | Company 3    | Company 3  | Oil&Gas | Gas           | DE           |                 95105145.4 |            2.486475e+07 |                    -70240391 |               -0.7385551 |
| 90f8ef0b-a9b5-4bf1-86c0-7f22320074c6 | 104        | 104      | Company 4    | Company 4  | Power   | RenewablesCap | DE           |               1016926683.7 |            1.366640e+09 |                    349713309 |                0.3438924 |
| 90f8ef0b-a9b5-4bf1-86c0-7f22320074c6 | 105        | 105      | Company 5    | Company 5  | Power   | CoalCap       | DE           |               176175702\.5 |            1.187415e+07 |                   -164301556 |               -0.9326005 |
| 90f8ef0b-a9b5-4bf1-86c0-7f22320074c6 | 105        | 105      | Company 5    | Company 5  | Power   | OilCap        | DE           |                 21412749.3 |            1.416673e+06 |                    -19996076 |               -0.9338397 |

#### PD results

##### Data Description

The `pd_results` dataset includes the following columns:

- `run_id`: Unique identifier for the simulation run.
- `company_id`: Unique identifier for the company.
- `company_name`: Name of the company.
- `sector`: Sector in which the company operates (e.g., Oil&Gas, Coal).
- `term`: Time period for the probability of default (PD) calculation.
- `pd_baseline`: Probability of default (PD) under the baseline
  scenario.
- `pd_shock`: Probability of default (PD) under the shock scenario.

##### Data Structure

``` r
str(pd_results)
#> tibble [25 × 7] (S3: tbl_df/tbl/data.frame)
#>  $ run_id      : chr [1:25] "90f8ef0b-a9b5-4bf1-86c0-7f22320074c6" "90f8ef0b-a9b5-4bf1-86c0-7f22320074c6" "90f8ef0b-a9b5-4bf1-86c0-7f22320074c6" "90f8ef0b-a9b5-4bf1-86c0-7f22320074c6" ...
#>  $ company_id  : chr [1:25] "101" "101" "101" "101" ...
#>  $ company_name: chr [1:25] "Company 1" "Company 1" "Company 1" "Company 1" ...
#>  $ sector      : chr [1:25] "Oil&Gas" "Oil&Gas" "Oil&Gas" "Oil&Gas" ...
#>  $ term        : int [1:25] 1 2 3 4 5 1 2 3 4 5 ...
#>  $ pd_baseline : num [1:25] 0.00 2.82e-09 1.14e-06 2.37e-05 1.50e-04 ...
#>  $ pd_shock    : num [1:25] 0.000591 0.012029 0.035005 0.061436 0.087477 ...
```

##### Sample Data

| run_id                               | company_id | company_name | sector  | term | pd_baseline |  pd_shock |
|:-------------------------------------|:-----------|:-------------|:--------|-----:|------------:|----------:|
| 90f8ef0b-a9b5-4bf1-86c0-7f22320074c6 | 101        | Company 1    | Oil&Gas |    1 |   0.0000000 | 0.0005908 |
| 90f8ef0b-a9b5-4bf1-86c0-7f22320074c6 | 101        | Company 1    | Oil&Gas |    2 |   0.0000000 | 0.0120293 |
| 90f8ef0b-a9b5-4bf1-86c0-7f22320074c6 | 101        | Company 1    | Oil&Gas |    3 |   0.0000011 | 0.0350054 |
| 90f8ef0b-a9b5-4bf1-86c0-7f22320074c6 | 101        | Company 1    | Oil&Gas |    4 |   0.0000237 | 0.0614358 |
| 90f8ef0b-a9b5-4bf1-86c0-7f22320074c6 | 101        | Company 1    | Oil&Gas |    5 |   0.0001502 | 0.0874772 |
| 90f8ef0b-a9b5-4bf1-86c0-7f22320074c6 | 102        | Company 2    | Coal    |    1 |   0.0000000 | 0.0001410 |

#### Company trajectories results

##### Data Description

The `company_trajectories` dataset includes the following columns:

- `run_id`: Unique identifier for the simulation run.
- `asset_id`: Unique identifier for the asset.
- `asset_name`: Name of the asset.
- `company_id`: Unique identifier for the company.
- `company_name`: Name of the company.
- `year`: Year of the scenario data.
- `sector`: Sector in which the company operates (e.g., Oil&Gas, Coal).
- `technology`: Type of technology used by the company.
- `production_plan_company_technology`: Production plan for the
  company’s technology.
- `production_baseline_scenario`: Production output under the baseline
  scenario.
- `production_target_scenario`: Production output under the target
  scenario.
- `production_shock_scenario`: Production output under the shock
  scenario.
- `pd`: Probability of default for the company.
- `net_profit_margin`: Net profit margin for the company.
- `debt_equity_ratio`: Debt to equity ratio for the company.
- `volatility`: Volatility of the company’s asset values.
- `scenario_price_baseline`: Price under the baseline scenario.
- `price_shock_scenario`: Price under the shock scenario.
- `net_profits_baseline_scenario`: Net profits under the baseline
  scenario.
- `net_profits_shock_scenario`: Net profits under the shock scenario.
- `discounted_net_profits_baseline_scenario`: Discounted net profits
  under the baseline scenario.
- `discounted_net_profits_shock_scenario`: Discounted net profits under
  the shock scenario.

##### Data Structure

``` r
str(company_trajectories)
#> tibble [210 × 23] (S3: tbl_df/tbl/data.frame)
#>  $ run_id                                  : chr [1:210] "90f8ef0b-a9b5-4bf1-86c0-7f22320074c6" "90f8ef0b-a9b5-4bf1-86c0-7f22320074c6" "90f8ef0b-a9b5-4bf1-86c0-7f22320074c6" "90f8ef0b-a9b5-4bf1-86c0-7f22320074c6" ...
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

##### Sample Data

| run_id                               | asset_id | asset_name | company_id | company_name | country_iso2 | sector  | technology | year | production_plan_company_technology | production_baseline_scenario | production_target_scenario | production_shock_scenario |        pd | net_profit_margin | debt_equity_ratio | volatility | scenario_price_baseline | price_shock_scenario | net_profits_baseline_scenario | net_profits_shock_scenario | discounted_net_profits_baseline_scenario | discounted_net_profits_shock_scenario |
|:-------------------------------------|:---------|:-----------|:-----------|:-------------|:-------------|:--------|:-----------|-----:|-----------------------------------:|-----------------------------:|---------------------------:|--------------------------:|----------:|------------------:|------------------:|-----------:|------------------------:|---------------------:|------------------------------:|---------------------------:|-----------------------------------------:|--------------------------------------:|
| 90f8ef0b-a9b5-4bf1-86c0-7f22320074c6 | 101      | Company 1  | 101        | Company 1    | DE           | Oil&Gas | Gas        | 2022 |                               5000 |                         5000 |                   5000.000 |                      5000 | 0.0056224 |         0.0763542 |         0.1297317 |   0.259323 |                5.867116 |             5.867116 |                      2239.895 |                   2239.895 |                                 2239.895 |                              2239.895 |
| 90f8ef0b-a9b5-4bf1-86c0-7f22320074c6 | 101      | Company 1  | 101        | Company 1    | DE           | Oil&Gas | Gas        | 2023 |                               5423 |                         5423 |                   5001.354 |                      5423 | 0.0056224 |         0.0763542 |         0.1297317 |   0.259323 |                5.898569 |             5.898569 |                      2442.414 |                   2442.414 |                                 2282.630 |                              2282.630 |
| 90f8ef0b-a9b5-4bf1-86c0-7f22320074c6 | 101      | Company 1  | 101        | Company 1    | DE           | Oil&Gas | Gas        | 2024 |                               6200 |                         6200 |                   5002.708 |                      6200 | 0.0056224 |         0.0763542 |         0.1297317 |   0.259323 |                5.930022 |             5.930022 |                      2807.250 |                   2807.250 |                                 2451.961 |                              2451.961 |
| 90f8ef0b-a9b5-4bf1-86c0-7f22320074c6 | 101      | Company 1  | 101        | Company 1    | DE           | Oil&Gas | Gas        | 2025 |                               7400 |                         7400 |                   5004.062 |                      7400 | 0.0056224 |         0.0763542 |         0.1297317 |   0.259323 |                5.961475 |             5.961475 |                      3368.360 |                   3368.360 |                                 2749.585 |                              2749.585 |
| 90f8ef0b-a9b5-4bf1-86c0-7f22320074c6 | 101      | Company 1  | 101        | Company 1    | DE           | Oil&Gas | Gas        | 2026 |                               7800 |                         7800 |                   4862.620 |                      7800 | 0.0056224 |         0.0763542 |         0.1297317 |   0.259323 |                5.945170 |             5.945170 |                      3540.723 |                   3540.723 |                                 2701.201 |                              2701.201 |
| 90f8ef0b-a9b5-4bf1-86c0-7f22320074c6 | 101      | Company 1  | 101        | Company 1    | DE           | Oil&Gas | Gas        | 2027 |                               8600 |                         8600 |                   4721.178 |                      8600 | 0.0056224 |         0.0763542 |         0.1297317 |   0.259323 |                5.928866 |             5.928866 |                      3893.168 |                   3893.168 |                                 2775.775 |                              2775.775 |
