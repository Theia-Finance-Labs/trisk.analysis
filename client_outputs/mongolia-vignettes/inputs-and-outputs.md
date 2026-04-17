---
title: "inputs-and-outputs"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{inputs-and-outputs}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---




``` r
suppressPackageStartupMessages({
  suppressWarnings(library(trisk.analysis))
  suppressWarnings(library(magrittr))
})
```

# Input datasets

Load the packaged Mongolia client demo datasets.


``` r
assets_testdata <- read.csv(system.file("testdata", "assets_data_mongolia_client.csv", package = "trisk.analysis", mustWork = TRUE))
scenarios_testdata <- read.csv(system.file("testdata", "scenarios_mongolia_client.csv", package = "trisk.analysis", mustWork = TRUE))
financial_features_testdata <- read.csv(system.file("testdata", "financial_features_mongolia_client.csv", package = "trisk.analysis", mustWork = TRUE))
ngfs_carbon_price_testdata <- read.csv(system.file("testdata", "ngfs_carbon_price_mongolia_client.csv", package = "trisk.analysis", mustWork = TRUE))
```

### Assets Test Data

This dataset contains data about company assets, including production, technology, and geographical details.

#### Data Description

The `assets_testdata` dataset includes the following columns:

-   `company_id`: Unique identifier for the company.
-   `company_name`: Name of the company.
-   `asset_id`: Unique identifier for the asset.
-   `country_iso2`: ISO 3166-1 alpha-2 code for the country.
-   `asset_name`: Name of the asset.
-   `production_year`: Year of production data.
-   `emission_factor`: Emissions from production.
-   `technology`: Type of technology used.
-   `sector`: Production sector.
-   `capacity`: Asset capacity.
-   `capacity_factor`: Asset utilization percentage.
-   `production_unit`: Unit for production.

#### Data Structure


``` r
str(assets_testdata)
#> 'data.frame':	55 obs. of  12 variables:
#>  $ company_id     : int  101 101 101 101 101 101 102 102 102 102 ...
#>  $ company_name   : chr  "Company 1" "Company 1" "Company 1" "Company 1" ...
#>  $ asset_id       : int  101 101 101 101 101 101 102 102 102 102 ...
#>  $ country_iso2   : chr  "MN" "MN" "MN" "MN" ...
#>  $ asset_name     : chr  "Company 1" "Company 1" "Company 1" "Company 1" ...
#>  $ production_year: int  2024 2025 2026 2027 2028 2029 2023 2024 2025 2026 ...
#>  $ emission_factor: num  0.97 0.97 0.97 0.97 0.97 0.97 0 0 0 0 ...
#>  $ technology     : chr  "CoalCap" "CoalCap" "CoalCap" "CoalCap" ...
#>  $ sector         : chr  "Power" "Power" "Power" "Power" ...
#>  $ capacity       : int  300 300 300 450 600 600 30 30 30 30 ...
#>  $ capacity_factor: num  0.5 0.5 0.5 0.5 0.5 0.5 0.9 0.9 0.9 0.9 ...
#>  $ production_unit: chr  "MW" "MW" "MW" "MW" ...
```

#### Sample Data

<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:400px; overflow-x: scroll; width:100%; "><table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> company_id </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> company_name </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> asset_id </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> country_iso2 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> asset_name </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> production_year </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> emission_factor </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> technology </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> sector </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> capacity </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> capacity_factor </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> production_unit </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;width: 150px; "> 101 </td>
   <td style="text-align:left;width: 150px; "> Company 1 </td>
   <td style="text-align:right;width: 150px; "> 101 </td>
   <td style="text-align:left;width: 150px; "> MN </td>
   <td style="text-align:left;width: 150px; "> Company 1 </td>
   <td style="text-align:right;width: 150px; "> 2024 </td>
   <td style="text-align:right;width: 150px; "> 0.97 </td>
   <td style="text-align:left;width: 150px; "> CoalCap </td>
   <td style="text-align:left;width: 150px; "> Power </td>
   <td style="text-align:right;width: 150px; "> 300 </td>
   <td style="text-align:right;width: 150px; "> 0.5 </td>
   <td style="text-align:left;width: 150px; "> MW </td>
  </tr>
  <tr>
   <td style="text-align:right;width: 150px; "> 101 </td>
   <td style="text-align:left;width: 150px; "> Company 1 </td>
   <td style="text-align:right;width: 150px; "> 101 </td>
   <td style="text-align:left;width: 150px; "> MN </td>
   <td style="text-align:left;width: 150px; "> Company 1 </td>
   <td style="text-align:right;width: 150px; "> 2025 </td>
   <td style="text-align:right;width: 150px; "> 0.97 </td>
   <td style="text-align:left;width: 150px; "> CoalCap </td>
   <td style="text-align:left;width: 150px; "> Power </td>
   <td style="text-align:right;width: 150px; "> 300 </td>
   <td style="text-align:right;width: 150px; "> 0.5 </td>
   <td style="text-align:left;width: 150px; "> MW </td>
  </tr>
  <tr>
   <td style="text-align:right;width: 150px; "> 101 </td>
   <td style="text-align:left;width: 150px; "> Company 1 </td>
   <td style="text-align:right;width: 150px; "> 101 </td>
   <td style="text-align:left;width: 150px; "> MN </td>
   <td style="text-align:left;width: 150px; "> Company 1 </td>
   <td style="text-align:right;width: 150px; "> 2026 </td>
   <td style="text-align:right;width: 150px; "> 0.97 </td>
   <td style="text-align:left;width: 150px; "> CoalCap </td>
   <td style="text-align:left;width: 150px; "> Power </td>
   <td style="text-align:right;width: 150px; "> 300 </td>
   <td style="text-align:right;width: 150px; "> 0.5 </td>
   <td style="text-align:left;width: 150px; "> MW </td>
  </tr>
  <tr>
   <td style="text-align:right;width: 150px; "> 101 </td>
   <td style="text-align:left;width: 150px; "> Company 1 </td>
   <td style="text-align:right;width: 150px; "> 101 </td>
   <td style="text-align:left;width: 150px; "> MN </td>
   <td style="text-align:left;width: 150px; "> Company 1 </td>
   <td style="text-align:right;width: 150px; "> 2027 </td>
   <td style="text-align:right;width: 150px; "> 0.97 </td>
   <td style="text-align:left;width: 150px; "> CoalCap </td>
   <td style="text-align:left;width: 150px; "> Power </td>
   <td style="text-align:right;width: 150px; "> 450 </td>
   <td style="text-align:right;width: 150px; "> 0.5 </td>
   <td style="text-align:left;width: 150px; "> MW </td>
  </tr>
  <tr>
   <td style="text-align:right;width: 150px; "> 101 </td>
   <td style="text-align:left;width: 150px; "> Company 1 </td>
   <td style="text-align:right;width: 150px; "> 101 </td>
   <td style="text-align:left;width: 150px; "> MN </td>
   <td style="text-align:left;width: 150px; "> Company 1 </td>
   <td style="text-align:right;width: 150px; "> 2028 </td>
   <td style="text-align:right;width: 150px; "> 0.97 </td>
   <td style="text-align:left;width: 150px; "> CoalCap </td>
   <td style="text-align:left;width: 150px; "> Power </td>
   <td style="text-align:right;width: 150px; "> 600 </td>
   <td style="text-align:right;width: 150px; "> 0.5 </td>
   <td style="text-align:left;width: 150px; "> MW </td>
  </tr>
  <tr>
   <td style="text-align:right;width: 150px; "> 101 </td>
   <td style="text-align:left;width: 150px; "> Company 1 </td>
   <td style="text-align:right;width: 150px; "> 101 </td>
   <td style="text-align:left;width: 150px; "> MN </td>
   <td style="text-align:left;width: 150px; "> Company 1 </td>
   <td style="text-align:right;width: 150px; "> 2029 </td>
   <td style="text-align:right;width: 150px; "> 0.97 </td>
   <td style="text-align:left;width: 150px; "> CoalCap </td>
   <td style="text-align:left;width: 150px; "> Power </td>
   <td style="text-align:right;width: 150px; "> 600 </td>
   <td style="text-align:right;width: 150px; "> 0.5 </td>
   <td style="text-align:left;width: 150px; "> MW </td>
  </tr>
</tbody>
</table></div>



------------------------------------------------------------------------

### Financial Features Test Data

This dataset contains financial metrics necessary for calculating stress test outputs.

#### Data Description

The `financial_features_testdata` dataset includes the following columns:

-   `company_id`: Unique identifier for the company.
-   `pd`: Probability of default for the company.
-   `net_profit_margin`: Net profit margin for the company.
-   `debt_equity_ratio`: Debt to equity ratio.
-   `volatility`: Volatility of the company's asset values.

#### Data Structure


``` r
str(financial_features_testdata)
#> 'data.frame':	8 obs. of  5 variables:
#>  $ company_id       : int  101 102 103 104 105 106 107 108
#>  $ pd               : num  0.03 0.03 0.03 0.03 0.06 0.02 0.03 0.19
#>  $ net_profit_margin: num  0.07 0.16 0.07 0.28 0.26 0.05 0.12 0.22
#>  $ debt_equity_ratio: num  0.14 0.05 0.9 0.05 1.7 1.51 0.37 0.14
#>  $ volatility       : num  0.02 0.34 0.09 0.04 0.22 0.03 0.14 0.39
```

#### Sample Data

<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:400px; overflow-x: scroll; width:100%; "><table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> company_id </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> pd </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> net_profit_margin </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> debt_equity_ratio </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> volatility </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 101 </td>
   <td style="text-align:right;"> 0.03 </td>
   <td style="text-align:right;"> 0.07 </td>
   <td style="text-align:right;"> 0.14 </td>
   <td style="text-align:right;"> 0.02 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 102 </td>
   <td style="text-align:right;"> 0.03 </td>
   <td style="text-align:right;"> 0.16 </td>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 0.34 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 103 </td>
   <td style="text-align:right;"> 0.03 </td>
   <td style="text-align:right;"> 0.07 </td>
   <td style="text-align:right;"> 0.90 </td>
   <td style="text-align:right;"> 0.09 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 104 </td>
   <td style="text-align:right;"> 0.03 </td>
   <td style="text-align:right;"> 0.28 </td>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 0.04 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 105 </td>
   <td style="text-align:right;"> 0.06 </td>
   <td style="text-align:right;"> 0.26 </td>
   <td style="text-align:right;"> 1.70 </td>
   <td style="text-align:right;"> 0.22 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 106 </td>
   <td style="text-align:right;"> 0.02 </td>
   <td style="text-align:right;"> 0.05 </td>
   <td style="text-align:right;"> 1.51 </td>
   <td style="text-align:right;"> 0.03 </td>
  </tr>
</tbody>
</table></div>



------------------------------------------------------------------------

### NGFS Carbon Price Test Data

This dataset provides carbon pricing data used in the stress test scenarios.

#### Data Description

The `ngfs_carbon_price_testdata` dataset includes the following columns:

-   `year`: Year of the carbon price.
-   `model`: Model used to generate the carbon price.
-   `scenario`: Scenario name.
-   `scenario_geography`: Geographic region for the scenario.
-   `variable`: The variable measured (e.g., carbon price).
-   `unit`: Unit of the variable.
-   `carbon_tax`: The amount of carbon tax applied in the scenario.

#### Data Structure


``` r
str(ngfs_carbon_price_testdata)
#> 'data.frame':	1376 obs. of  7 variables:
#>  $ year              : int  2015 2016 2017 2018 2019 2020 2021 2022 2023 2024 ...
#>  $ model             : chr  "GCAM 5.3+ NGFS" "GCAM 5.3+ NGFS" "GCAM 5.3+ NGFS" "GCAM 5.3+ NGFS" ...
#>  $ scenario          : chr  "B2DS" "B2DS" "B2DS" "B2DS" ...
#>  $ scenario_geography: chr  "Global" "Global" "Global" "Global" ...
#>  $ variable          : chr  "Price|Carbon" "Price|Carbon" "Price|Carbon" "Price|Carbon" ...
#>  $ unit              : chr  "US$2010/t CO2" "US$2010/t CO2" "US$2010/t CO2" "US$2010/t CO2" ...
#>  $ carbon_tax        : num  0 0 0 0 0 0 0 0 0 0 ...
```

#### Sample Data

<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:400px; overflow-x: scroll; width:100%; "><table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> year </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> model </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> scenario </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> scenario_geography </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> variable </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> unit </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> carbon_tax </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:right;"> 2015 </td>
   <td style="text-align:left;"> GCAM 5.3+ NGFS </td>
   <td style="text-align:left;"> B2DS </td>
   <td style="text-align:left;"> Global </td>
   <td style="text-align:left;"> Price&amp;#124;Carbon </td>
   <td style="text-align:left;"> US$2010/t CO2 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2016 </td>
   <td style="text-align:left;"> GCAM 5.3+ NGFS </td>
   <td style="text-align:left;"> B2DS </td>
   <td style="text-align:left;"> Global </td>
   <td style="text-align:left;"> Price&amp;#124;Carbon </td>
   <td style="text-align:left;"> US$2010/t CO2 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2017 </td>
   <td style="text-align:left;"> GCAM 5.3+ NGFS </td>
   <td style="text-align:left;"> B2DS </td>
   <td style="text-align:left;"> Global </td>
   <td style="text-align:left;"> Price&amp;#124;Carbon </td>
   <td style="text-align:left;"> US$2010/t CO2 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2018 </td>
   <td style="text-align:left;"> GCAM 5.3+ NGFS </td>
   <td style="text-align:left;"> B2DS </td>
   <td style="text-align:left;"> Global </td>
   <td style="text-align:left;"> Price&amp;#124;Carbon </td>
   <td style="text-align:left;"> US$2010/t CO2 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2019 </td>
   <td style="text-align:left;"> GCAM 5.3+ NGFS </td>
   <td style="text-align:left;"> B2DS </td>
   <td style="text-align:left;"> Global </td>
   <td style="text-align:left;"> Price&amp;#124;Carbon </td>
   <td style="text-align:left;"> US$2010/t CO2 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:right;"> 2020 </td>
   <td style="text-align:left;"> GCAM 5.3+ NGFS </td>
   <td style="text-align:left;"> B2DS </td>
   <td style="text-align:left;"> Global </td>
   <td style="text-align:left;"> Price&amp;#124;Carbon </td>
   <td style="text-align:left;"> US$2010/t CO2 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
</tbody>
</table></div>



------------------------------------------------------------------------

### Scenarios Test Data

This dataset contains scenario-specific data including price paths, capacity factors, and other relevant information.

#### Data Description

The `scenarios_testdata` dataset includes the following columns:

-   `scenario_geography`: Region relevant to the scenario.
-   `scenario`: Scenario name.
-   `scenario_pathway`: Specific pathway for the scenario.
-   `scenario_type`: Type of scenario (e.g., baseline, shock).
-   `sector`: Sector of production.
-   `technology`: Type of technology.
-   `scenario_year`: Year of the scenario data.
-   `scenario_price`: Price in the scenario.
-   `price_unit`: Unit for the price.
-   `pathway_unit`: Unit of the pathway.
-   `technology_type`: Type of technology involved (carbon or renewable).

#### Data Structure


``` r
str(scenarios_testdata)
#> 'data.frame':	1404 obs. of  14 variables:
#>  $ scenario                : chr  "NGFS2024GCAM_CP" "NGFS2024GCAM_CP" "NGFS2024GCAM_CP" "NGFS2024GCAM_CP" ...
#>  $ scenario_type           : chr  "baseline" "baseline" "baseline" "baseline" ...
#>  $ scenario_geography      : chr  "Asia" "Asia" "Asia" "Asia" ...
#>  $ sector                  : chr  "Coal" "Coal" "Coal" "Coal" ...
#>  $ technology              : chr  "Coal" "Coal" "Coal" "Coal" ...
#>  $ scenario_year           : int  2023 2024 2025 2026 2027 2028 2029 2030 2031 2032 ...
#>  $ price_unit              : chr  "$/tonnes" "$/tonnes" "$/tonnes" "$/tonnes" ...
#>  $ scenario_price          : num  59.5 59.3 59.2 59.4 59.5 ...
#>  $ pathway_unit            : chr  "EJ/yr" "EJ/yr" "EJ/yr" "EJ/yr" ...
#>  $ scenario_pathway        : num  130 131 132 132 133 ...
#>  $ technology_type         : chr  "carbontech" "carbontech" "carbontech" "carbontech" ...
#>  $ country_iso2_list       : chr  "AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN" "AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN" "AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN" "AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN" ...
#>  $ scenario_provider       : chr  "NGFS2024GCAM" "NGFS2024GCAM" "NGFS2024GCAM" "NGFS2024GCAM" ...
#>  $ scenario_capacity_factor: num  1 1 1 1 1 1 1 1 1 1 ...
```

#### Sample Data

<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:400px; overflow-x: scroll; width:200%; "><table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> scenario </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> scenario_type </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> scenario_geography </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> sector </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> technology </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> scenario_year </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> price_unit </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> scenario_price </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> pathway_unit </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> scenario_pathway </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> technology_type </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> country_iso2_list </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> scenario_provider </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> scenario_capacity_factor </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2023 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 59.45475 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 129.9051 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2024 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 59.32724 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 130.7499 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2025 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 59.19973 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 131.5947 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2026 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 59.37441 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 132.2555 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2027 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 59.54909 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 132.9163 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2028 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 59.72377 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 133.5771 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2029 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 59.89845 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 134.2379 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2030 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 60.07313 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 134.8986 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2031 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 60.37517 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 135.2292 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2032 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 60.67722 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 135.5597 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2033 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 60.97927 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 135.8902 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2034 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 61.28132 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 136.2208 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2035 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 61.58336 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 136.5513 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2036 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 61.70931 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 136.8480 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2037 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 61.83526 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 137.1448 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2038 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 61.96121 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 137.4415 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2039 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 62.08716 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 137.7383 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2040 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 62.21311 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 138.0350 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2041 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 62.35454 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 138.1301 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2042 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 62.49597 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 138.2252 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2043 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 62.63741 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 138.3202 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2044 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 62.77884 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 138.4153 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2045 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 62.92027 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 138.5104 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2046 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 62.99204 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 138.4079 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2047 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 63.06382 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 138.3054 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2048 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 63.13559 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 138.2029 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2049 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 63.20737 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 138.1005 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2050 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 63.27914 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 137.9980 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2051 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 63.37012 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 137.9077 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2052 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 63.46110 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 137.8175 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2053 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 63.55209 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 137.7272 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2054 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 63.64307 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 137.6369 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2055 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 63.73405 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 137.5466 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2056 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 63.63724 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 137.1823 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2057 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 63.54044 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 136.8180 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2058 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 63.44364 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 136.4537 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2059 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 63.34683 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 136.0894 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2060 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 63.25003 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 135.7250 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2061 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 63.10003 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 135.1854 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2062 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 62.95002 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 134.6459 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2063 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 62.80002 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 134.1063 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2064 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 62.65002 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 133.5667 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2065 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 62.50001 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 133.0271 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2066 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 62.38081 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 132.4139 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2067 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 62.26161 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 131.8007 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2068 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 62.14241 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 131.1875 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2069 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 62.02321 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 130.5743 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2070 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 61.90401 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 129.9611 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2071 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 61.76104 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 129.2269 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> NGFS2024GCAM_CP </td>
   <td style="text-align:left;"> baseline </td>
   <td style="text-align:left;"> Asia </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2072 </td>
   <td style="text-align:left;"> $/tonnes </td>
   <td style="text-align:right;"> 61.61808 </td>
   <td style="text-align:left;"> EJ/yr </td>
   <td style="text-align:right;"> 128.4926 </td>
   <td style="text-align:left;"> carbontech </td>
   <td style="text-align:left;"> AF,BD,BT,BN,KH,CN,HK,MO,KP,TL,IN,ID,LA,MY,MV,MN,MM,NP,PK,PG,PH,KR,SG,LK,TW,TH,VN </td>
   <td style="text-align:left;"> NGFS2024GCAM </td>
   <td style="text-align:right;"> 1 </td>
  </tr>
</tbody>
</table></div>



# Trisk run

### Parameters

Trisk takes several parameters in input, allowing to adjust the model's assumptions.

-   `baseline_scenario`: String specifying the name of the baseline scenario.
-   `target_scenario`: String specifying the name of the shock scenario.
-   `scenario_geography`: Character vector indicating which geographical region(s) to calculate results for.
-   `carbon_price_model`: Character vector specifying which NGFS model to use for carbon prices.
-   `risk_free_rate`: Numeric value for the risk-free interest rate.
-   `discount_rate`: Numeric value for the discount rate of dividends per year in the DCF.
-   `growth_rate`: Numeric value for the terminal growth rate of profits beyond the final year in the DCF.
-   `div_netprofit_prop_coef`: Numeric coefficient determining how strongly future dividends propagate to company value.
-   `shock_year`: Numeric value specifying the year when the shock is applied.
-   `market_passthrough`: Numeric value representing the firm's ability to pass carbon tax onto the consumer.

Those parameters have an impact on trajectories


``` r
baseline_scenario <- "NGFS2024GCAM_CP"
target_scenario <- "NGFS2024GCAM_DT"
scenario_geography <- "Asia"
shock_year <- 2030
```

Those parameters will have an impact on internal NPV and PD computations. The values below use a central Mongolia case; the sensitivity vignette expands this to multiple shock years, model families, discount rates, and risk-free rates.


``` r
carbon_price_model <- "no_carbon_tax"
risk_free_rate <- 0.04
discount_rate <- 0.10
growth_rate <- 0.03
div_netprofit_prop_coef <- 1
shock_year <- 2030
market_passthrough <- 0
```

### Run and return aggregated result

The function `run_trisk_agg()` runs the Trisk model using the provided input and returns the outputs, with NPVs aggregated per company over technology.


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
<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:400px; overflow-x: scroll; width:100%; "><table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> run_id </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> company_id </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> asset_id </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> company_name </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> asset_name </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> sector </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> technology </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> net_present_value_baseline </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> net_present_value_shock </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> net_present_value_difference </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> net_present_value_change </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> ac6fd50f-f36a-4619-a560-7002c4ad7ceb </td>
   <td style="text-align:left;"> 101 </td>
   <td style="text-align:left;"> 101 </td>
   <td style="text-align:left;"> Company 1 </td>
   <td style="text-align:left;"> Company 1 </td>
   <td style="text-align:left;"> Power </td>
   <td style="text-align:left;"> CoalCap </td>
   <td style="text-align:right;"> 135981288 </td>
   <td style="text-align:right;"> 16406000 </td>
   <td style="text-align:right;"> -119575288 </td>
   <td style="text-align:right;"> -0.8793510 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ac6fd50f-f36a-4619-a560-7002c4ad7ceb </td>
   <td style="text-align:left;"> 102 </td>
   <td style="text-align:left;"> 102 </td>
   <td style="text-align:left;"> Company 2 </td>
   <td style="text-align:left;"> Company 2 </td>
   <td style="text-align:left;"> Power </td>
   <td style="text-align:left;"> RenewablesCap </td>
   <td style="text-align:right;"> 64143567 </td>
   <td style="text-align:right;"> 71242547 </td>
   <td style="text-align:right;"> 7098980 </td>
   <td style="text-align:right;"> 0.1106733 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ac6fd50f-f36a-4619-a560-7002c4ad7ceb </td>
   <td style="text-align:left;"> 103 </td>
   <td style="text-align:left;"> 103 </td>
   <td style="text-align:left;"> Company 3 </td>
   <td style="text-align:left;"> Company 3 </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 2227663620 </td>
   <td style="text-align:right;"> 850136432 </td>
   <td style="text-align:right;"> -1377527188 </td>
   <td style="text-align:right;"> -0.6183731 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ac6fd50f-f36a-4619-a560-7002c4ad7ceb </td>
   <td style="text-align:left;"> 104 </td>
   <td style="text-align:left;"> 104 </td>
   <td style="text-align:left;"> Company 4 </td>
   <td style="text-align:left;"> Company 4 </td>
   <td style="text-align:left;"> Power </td>
   <td style="text-align:left;"> RenewablesCap </td>
   <td style="text-align:right;"> 207872671 </td>
   <td style="text-align:right;"> 230878625 </td>
   <td style="text-align:right;"> 23005954 </td>
   <td style="text-align:right;"> 0.1106733 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ac6fd50f-f36a-4619-a560-7002c4ad7ceb </td>
   <td style="text-align:left;"> 105 </td>
   <td style="text-align:left;"> 105 </td>
   <td style="text-align:left;"> Company 5 </td>
   <td style="text-align:left;"> Company 5 </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:right;"> 164365895 </td>
   <td style="text-align:right;"> 62726452 </td>
   <td style="text-align:right;"> -101639443 </td>
   <td style="text-align:right;"> -0.6183731 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> ac6fd50f-f36a-4619-a560-7002c4ad7ceb </td>
   <td style="text-align:left;"> 106 </td>
   <td style="text-align:left;"> 106 </td>
   <td style="text-align:left;"> Company 6 </td>
   <td style="text-align:left;"> Company 6 </td>
   <td style="text-align:left;"> Power </td>
   <td style="text-align:left;"> CoalCap </td>
   <td style="text-align:right;"> 15625176 </td>
   <td style="text-align:right;"> 2605046 </td>
   <td style="text-align:right;"> -13020131 </td>
   <td style="text-align:right;"> -0.8332790 </td>
  </tr>
</tbody>
</table></div>




### Run and return results with country granularity

The function `run_trisk_model()` runs the Trisk model using the provided input and returns the outputs, with NPVs disaggregated per country.


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

# Output datasets

### NPV results

#### Data Description

The `npv_results` dataset includes the following columns:

-   `run_id`: Unique identifier for the simulation run.
-   `company_id`: Unique identifier for the company.
-   `asset_id`: Unique identifier for the asset.
-   `company_name`: Name of the company.
-   `asset_name`: Name of the asset.
-   `country_iso2`: ISO 3166-1 alpha-2 code for the country.
-   `sector`: Sector in which the company operates (e.g., Oil&Gas, Coal, Power).
-   `technology`: Type of technology used by the company (e.g., Gas, CoalCap, RenewablesCap).
-   `net_present_value_baseline`: Net present value (NPV) under the baseline scenario.
-   `net_present_value_shock`: Net present value (NPV) under the shock scenario.

#### Data Structure


``` r
str(npv_results)
#> tibble [8 × 12] (S3: tbl_df/tbl/data.frame)
#>  $ run_id                      : chr [1:8] "3686377e-de60-48ae-bdff-2019ea1e616f" "3686377e-de60-48ae-bdff-2019ea1e616f" "3686377e-de60-48ae-bdff-2019ea1e616f" "3686377e-de60-48ae-bdff-2019ea1e616f" ...
#>  $ company_id                  : chr [1:8] "101" "102" "103" "104" ...
#>  $ asset_id                    : chr [1:8] "101" "102" "103" "104" ...
#>  $ company_name                : chr [1:8] "Company 1" "Company 2" "Company 3" "Company 4" ...
#>  $ asset_name                  : chr [1:8] "Company 1" "Company 2" "Company 3" "Company 4" ...
#>  $ sector                      : chr [1:8] "Power" "Power" "Coal" "Power" ...
#>  $ technology                  : chr [1:8] "CoalCap" "RenewablesCap" "Coal" "RenewablesCap" ...
#>  $ country_iso2                : chr [1:8] "MN" "MN" "MN" "MN" ...
#>  $ net_present_value_baseline  : num [1:8] 1.36e+08 6.41e+07 2.23e+09 2.08e+08 1.64e+08 ...
#>  $ net_present_value_shock     : num [1:8] 1.64e+07 7.12e+07 8.50e+08 2.31e+08 6.27e+07 ...
#>  $ net_present_value_difference: num [1:8] -1.20e+08 7.10e+06 -1.38e+09 2.30e+07 -1.02e+08 ...
#>  $ net_present_value_change    : num [1:8] -0.879 0.111 -0.618 0.111 -0.618 ...
```

#### Sample Data

<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:400px; overflow-x: scroll; width:100%; "><table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> run_id </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> company_id </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> asset_id </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> company_name </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> asset_name </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> sector </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> technology </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> country_iso2 </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> net_present_value_baseline </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> net_present_value_shock </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> net_present_value_difference </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> net_present_value_change </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 3686377e-de60-48ae-bdff-2019ea1e616f </td>
   <td style="text-align:left;"> 101 </td>
   <td style="text-align:left;"> 101 </td>
   <td style="text-align:left;"> Company 1 </td>
   <td style="text-align:left;"> Company 1 </td>
   <td style="text-align:left;"> Power </td>
   <td style="text-align:left;"> CoalCap </td>
   <td style="text-align:left;"> MN </td>
   <td style="text-align:right;"> 135981288 </td>
   <td style="text-align:right;"> 16406000 </td>
   <td style="text-align:right;"> -119575288 </td>
   <td style="text-align:right;"> -0.8793510 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3686377e-de60-48ae-bdff-2019ea1e616f </td>
   <td style="text-align:left;"> 102 </td>
   <td style="text-align:left;"> 102 </td>
   <td style="text-align:left;"> Company 2 </td>
   <td style="text-align:left;"> Company 2 </td>
   <td style="text-align:left;"> Power </td>
   <td style="text-align:left;"> RenewablesCap </td>
   <td style="text-align:left;"> MN </td>
   <td style="text-align:right;"> 64143567 </td>
   <td style="text-align:right;"> 71242547 </td>
   <td style="text-align:right;"> 7098980 </td>
   <td style="text-align:right;"> 0.1106733 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3686377e-de60-48ae-bdff-2019ea1e616f </td>
   <td style="text-align:left;"> 103 </td>
   <td style="text-align:left;"> 103 </td>
   <td style="text-align:left;"> Company 3 </td>
   <td style="text-align:left;"> Company 3 </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> MN </td>
   <td style="text-align:right;"> 2227663620 </td>
   <td style="text-align:right;"> 850136432 </td>
   <td style="text-align:right;"> -1377527188 </td>
   <td style="text-align:right;"> -0.6183731 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3686377e-de60-48ae-bdff-2019ea1e616f </td>
   <td style="text-align:left;"> 104 </td>
   <td style="text-align:left;"> 104 </td>
   <td style="text-align:left;"> Company 4 </td>
   <td style="text-align:left;"> Company 4 </td>
   <td style="text-align:left;"> Power </td>
   <td style="text-align:left;"> RenewablesCap </td>
   <td style="text-align:left;"> MN </td>
   <td style="text-align:right;"> 207872671 </td>
   <td style="text-align:right;"> 230878625 </td>
   <td style="text-align:right;"> 23005954 </td>
   <td style="text-align:right;"> 0.1106733 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3686377e-de60-48ae-bdff-2019ea1e616f </td>
   <td style="text-align:left;"> 105 </td>
   <td style="text-align:left;"> 105 </td>
   <td style="text-align:left;"> Company 5 </td>
   <td style="text-align:left;"> Company 5 </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> Coal </td>
   <td style="text-align:left;"> MN </td>
   <td style="text-align:right;"> 164365895 </td>
   <td style="text-align:right;"> 62726452 </td>
   <td style="text-align:right;"> -101639443 </td>
   <td style="text-align:right;"> -0.6183731 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3686377e-de60-48ae-bdff-2019ea1e616f </td>
   <td style="text-align:left;"> 106 </td>
   <td style="text-align:left;"> 106 </td>
   <td style="text-align:left;"> Company 6 </td>
   <td style="text-align:left;"> Company 6 </td>
   <td style="text-align:left;"> Power </td>
   <td style="text-align:left;"> CoalCap </td>
   <td style="text-align:left;"> MN </td>
   <td style="text-align:right;"> 15625176 </td>
   <td style="text-align:right;"> 2605046 </td>
   <td style="text-align:right;"> -13020131 </td>
   <td style="text-align:right;"> -0.8332790 </td>
  </tr>
</tbody>
</table></div>



### PD results

#### Data Description

The `pd_results` dataset includes the following columns:

-   `run_id`: Unique identifier for the simulation run.
-   `company_id`: Unique identifier for the company.
-   `company_name`: Name of the company.
-   `sector`: Sector in which the company operates (e.g., Oil&Gas, Coal).
-   `term`: Time period for the probability of default (PD) calculation.
-   `pd_baseline`: Probability of default (PD) under the baseline scenario.
-   `pd_shock`: Probability of default (PD) under the shock scenario.

#### Data Structure


``` r
str(pd_results)
#> tibble [40 × 7] (S3: tbl_df/tbl/data.frame)
#>  $ run_id      : chr [1:40] "3686377e-de60-48ae-bdff-2019ea1e616f" "3686377e-de60-48ae-bdff-2019ea1e616f" "3686377e-de60-48ae-bdff-2019ea1e616f" "3686377e-de60-48ae-bdff-2019ea1e616f" ...
#>  $ company_id  : chr [1:40] "101" "101" "101" "101" ...
#>  $ company_name: chr [1:40] "Company 1" "Company 1" "Company 1" "Company 1" ...
#>  $ sector      : chr [1:40] "Power" "Power" "Power" "Power" ...
#>  $ term        : int [1:40] 1 2 3 4 5 1 2 3 4 5 ...
#>  $ pd_baseline : num [1:40] 0 0 0 0 0 ...
#>  $ pd_shock    : num [1:40] 0 0 0 0 0 ...
```

#### Sample Data

<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:400px; overflow-x: scroll; width:100%; "><table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> run_id </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> company_id </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> company_name </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> sector </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> term </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> pd_baseline </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> pd_shock </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 3686377e-de60-48ae-bdff-2019ea1e616f </td>
   <td style="text-align:left;"> 101 </td>
   <td style="text-align:left;"> Company 1 </td>
   <td style="text-align:left;"> Power </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3686377e-de60-48ae-bdff-2019ea1e616f </td>
   <td style="text-align:left;"> 101 </td>
   <td style="text-align:left;"> Company 1 </td>
   <td style="text-align:left;"> Power </td>
   <td style="text-align:right;"> 2 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3686377e-de60-48ae-bdff-2019ea1e616f </td>
   <td style="text-align:left;"> 101 </td>
   <td style="text-align:left;"> Company 1 </td>
   <td style="text-align:left;"> Power </td>
   <td style="text-align:right;"> 3 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3686377e-de60-48ae-bdff-2019ea1e616f </td>
   <td style="text-align:left;"> 101 </td>
   <td style="text-align:left;"> Company 1 </td>
   <td style="text-align:left;"> Power </td>
   <td style="text-align:right;"> 4 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3686377e-de60-48ae-bdff-2019ea1e616f </td>
   <td style="text-align:left;"> 101 </td>
   <td style="text-align:left;"> Company 1 </td>
   <td style="text-align:left;"> Power </td>
   <td style="text-align:right;"> 5 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3686377e-de60-48ae-bdff-2019ea1e616f </td>
   <td style="text-align:left;"> 102 </td>
   <td style="text-align:left;"> Company 2 </td>
   <td style="text-align:left;"> Power </td>
   <td style="text-align:right;"> 1 </td>
   <td style="text-align:right;"> 0 </td>
   <td style="text-align:right;"> 0 </td>
  </tr>
</tbody>
</table></div>



### Company trajectories results

#### Data Description

The `company_trajectories` dataset includes the following columns:

-   `run_id`: Unique identifier for the simulation run.
-   `asset_id`: Unique identifier for the asset.
-   `asset_name`: Name of the asset.
-   `company_id`: Unique identifier for the company.
-   `company_name`: Name of the company.
-   `year`: Year of the scenario data.
-   `sector`: Sector in which the company operates (e.g., Oil&Gas, Coal).
-   `technology`: Type of technology used by the company.
-   `production_plan_company_technology`: Production plan for the company’s technology.
-   `production_baseline_scenario`: Production output under the baseline scenario.
-   `production_target_scenario`: Production output under the target scenario.
-   `production_shock_scenario`: Production output under the shock scenario.
-   `pd`: Probability of default for the company.
-   `net_profit_margin`: Net profit margin for the company.
-   `debt_equity_ratio`: Debt to equity ratio for the company.
-   `volatility`: Volatility of the company’s asset values.
-   `scenario_price_baseline`: Price under the baseline scenario.
-   `price_shock_scenario`: Price under the shock scenario.
-   `net_profits_baseline_scenario`: Net profits under the baseline scenario.
-   `net_profits_shock_scenario`: Net profits under the shock scenario.
-   `discounted_net_profits_baseline_scenario`: Discounted net profits under the baseline scenario.
-   `discounted_net_profits_shock_scenario`: Discounted net profits under the shock scenario.

#### Data Structure


``` r
str(company_trajectories)
#> tibble [232 × 23] (S3: tbl_df/tbl/data.frame)
#>  $ run_id                                  : chr [1:232] "3686377e-de60-48ae-bdff-2019ea1e616f" "3686377e-de60-48ae-bdff-2019ea1e616f" "3686377e-de60-48ae-bdff-2019ea1e616f" "3686377e-de60-48ae-bdff-2019ea1e616f" ...
#>  $ asset_id                                : chr [1:232] "101" "101" "101" "101" ...
#>  $ asset_name                              : chr [1:232] "Company 1" "Company 1" "Company 1" "Company 1" ...
#>  $ company_id                              : chr [1:232] "101" "101" "101" "101" ...
#>  $ company_name                            : chr [1:232] "Company 1" "Company 1" "Company 1" "Company 1" ...
#>  $ country_iso2                            : chr [1:232] "MN" "MN" "MN" "MN" ...
#>  $ sector                                  : chr [1:232] "Power" "Power" "Power" "Power" ...
#>  $ technology                              : chr [1:232] "CoalCap" "CoalCap" "CoalCap" "CoalCap" ...
#>  $ year                                    : num [1:232] 2023 2024 2025 2026 2027 ...
#>  $ production_plan_company_technology      : num [1:232] 732840 736153 739475 742141 1117247 ...
#>  $ production_baseline_scenario            : num [1:232] 732840 736153 739475 742141 1117247 ...
#>  $ production_target_scenario              : num [1:232] 732840 735095 737350 736804 736259 ...
#>  $ production_shock_scenario               : num [1:232] 732840 736153 739475 742141 1117247 ...
#>  $ pd                                      : num [1:232] 0.03 0.03 0.03 0.03 0.03 0.03 0.03 0.03 0.03 0.03 ...
#>  $ net_profit_margin                       : num [1:232] 0.07 0.07 0.07 0.07 0.07 0.07 0.07 0.07 0.07 0.07 ...
#>  $ debt_equity_ratio                       : num [1:232] 0.14 0.14 0.14 0.14 0.14 0.14 0.14 0.14 0.14 0.14 ...
#>  $ volatility                              : num [1:232] 0.02 0.02 0.02 0.02 0.02 0.02 0.02 0.02 0.02 0.02 ...
#>  $ scenario_price_baseline                 : num [1:232] 67.5 67.6 67.6 67.7 67.7 ...
#>  $ price_shock_scenario                    : num [1:232] 67.5 67.6 67.6 67.7 67.7 ...
#>  $ net_profits_baseline_scenario           : num [1:232] 3462567 3481041 3499380 3514446 5294190 ...
#>  $ net_profits_shock_scenario              : num [1:232] 3462567 3481041 3499380 3514446 5294190 ...
#>  $ discounted_net_profits_baseline_scenario: num [1:232] 3462567 3164583 2892050 2640455 3616003 ...
#>  $ discounted_net_profits_shock_scenario   : num [1:232] 3462567 3164583 2892050 2640455 3616003 ...
```

#### Sample Data

<div style="border: 1px solid #ddd; padding: 0px; overflow-y: scroll; height:400px; overflow-x: scroll; width:100%; "><table class="table table-striped table-hover table-condensed" style="margin-left: auto; margin-right: auto;">
 <thead>
  <tr>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> run_id </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> asset_id </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> asset_name </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> company_id </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> company_name </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> country_iso2 </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> sector </th>
   <th style="text-align:left;position: sticky; top:0; background-color: #FFFFFF;"> technology </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> year </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> production_plan_company_technology </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> production_baseline_scenario </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> production_target_scenario </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> production_shock_scenario </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> pd </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> net_profit_margin </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> debt_equity_ratio </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> volatility </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> scenario_price_baseline </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> price_shock_scenario </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> net_profits_baseline_scenario </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> net_profits_shock_scenario </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> discounted_net_profits_baseline_scenario </th>
   <th style="text-align:right;position: sticky; top:0; background-color: #FFFFFF;"> discounted_net_profits_shock_scenario </th>
  </tr>
 </thead>
<tbody>
  <tr>
   <td style="text-align:left;"> 3686377e-de60-48ae-bdff-2019ea1e616f </td>
   <td style="text-align:left;"> 101 </td>
   <td style="text-align:left;"> Company 1 </td>
   <td style="text-align:left;"> 101 </td>
   <td style="text-align:left;"> Company 1 </td>
   <td style="text-align:left;"> MN </td>
   <td style="text-align:left;"> Power </td>
   <td style="text-align:left;"> CoalCap </td>
   <td style="text-align:right;"> 2023 </td>
   <td style="text-align:right;"> 732839.9 </td>
   <td style="text-align:right;"> 732839.9 </td>
   <td style="text-align:right;"> 732839.9 </td>
   <td style="text-align:right;"> 732839.9 </td>
   <td style="text-align:right;"> 0.03 </td>
   <td style="text-align:right;"> 0.07 </td>
   <td style="text-align:right;"> 0.14 </td>
   <td style="text-align:right;"> 0.02 </td>
   <td style="text-align:right;"> 67.49802 </td>
   <td style="text-align:right;"> 67.49802 </td>
   <td style="text-align:right;"> 3462567 </td>
   <td style="text-align:right;"> 3462567 </td>
   <td style="text-align:right;"> 3462567 </td>
   <td style="text-align:right;"> 3462567 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3686377e-de60-48ae-bdff-2019ea1e616f </td>
   <td style="text-align:left;"> 101 </td>
   <td style="text-align:left;"> Company 1 </td>
   <td style="text-align:left;"> 101 </td>
   <td style="text-align:left;"> Company 1 </td>
   <td style="text-align:left;"> MN </td>
   <td style="text-align:left;"> Power </td>
   <td style="text-align:left;"> CoalCap </td>
   <td style="text-align:right;"> 2024 </td>
   <td style="text-align:right;"> 736152.6 </td>
   <td style="text-align:right;"> 736152.6 </td>
   <td style="text-align:right;"> 735094.7 </td>
   <td style="text-align:right;"> 736152.6 </td>
   <td style="text-align:right;"> 0.03 </td>
   <td style="text-align:right;"> 0.07 </td>
   <td style="text-align:right;"> 0.14 </td>
   <td style="text-align:right;"> 0.02 </td>
   <td style="text-align:right;"> 67.55280 </td>
   <td style="text-align:right;"> 67.55280 </td>
   <td style="text-align:right;"> 3481041 </td>
   <td style="text-align:right;"> 3481041 </td>
   <td style="text-align:right;"> 3164583 </td>
   <td style="text-align:right;"> 3164583 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3686377e-de60-48ae-bdff-2019ea1e616f </td>
   <td style="text-align:left;"> 101 </td>
   <td style="text-align:left;"> Company 1 </td>
   <td style="text-align:left;"> 101 </td>
   <td style="text-align:left;"> Company 1 </td>
   <td style="text-align:left;"> MN </td>
   <td style="text-align:left;"> Power </td>
   <td style="text-align:left;"> CoalCap </td>
   <td style="text-align:right;"> 2025 </td>
   <td style="text-align:right;"> 739474.8 </td>
   <td style="text-align:right;"> 739474.8 </td>
   <td style="text-align:right;"> 737349.6 </td>
   <td style="text-align:right;"> 739474.8 </td>
   <td style="text-align:right;"> 0.03 </td>
   <td style="text-align:right;"> 0.07 </td>
   <td style="text-align:right;"> 0.14 </td>
   <td style="text-align:right;"> 0.02 </td>
   <td style="text-align:right;"> 67.60358 </td>
   <td style="text-align:right;"> 67.60358 </td>
   <td style="text-align:right;"> 3499380 </td>
   <td style="text-align:right;"> 3499380 </td>
   <td style="text-align:right;"> 2892050 </td>
   <td style="text-align:right;"> 2892050 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3686377e-de60-48ae-bdff-2019ea1e616f </td>
   <td style="text-align:left;"> 101 </td>
   <td style="text-align:left;"> Company 1 </td>
   <td style="text-align:left;"> 101 </td>
   <td style="text-align:left;"> Company 1 </td>
   <td style="text-align:left;"> MN </td>
   <td style="text-align:left;"> Power </td>
   <td style="text-align:left;"> CoalCap </td>
   <td style="text-align:right;"> 2026 </td>
   <td style="text-align:right;"> 742141.4 </td>
   <td style="text-align:right;"> 742141.4 </td>
   <td style="text-align:right;"> 736804.1 </td>
   <td style="text-align:right;"> 742141.4 </td>
   <td style="text-align:right;"> 0.03 </td>
   <td style="text-align:right;"> 0.07 </td>
   <td style="text-align:right;"> 0.14 </td>
   <td style="text-align:right;"> 0.02 </td>
   <td style="text-align:right;"> 67.65067 </td>
   <td style="text-align:right;"> 67.65067 </td>
   <td style="text-align:right;"> 3514446 </td>
   <td style="text-align:right;"> 3514446 </td>
   <td style="text-align:right;"> 2640455 </td>
   <td style="text-align:right;"> 2640455 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3686377e-de60-48ae-bdff-2019ea1e616f </td>
   <td style="text-align:left;"> 101 </td>
   <td style="text-align:left;"> Company 1 </td>
   <td style="text-align:left;"> 101 </td>
   <td style="text-align:left;"> Company 1 </td>
   <td style="text-align:left;"> MN </td>
   <td style="text-align:left;"> Power </td>
   <td style="text-align:left;"> CoalCap </td>
   <td style="text-align:right;"> 2027 </td>
   <td style="text-align:right;"> 1117247.0 </td>
   <td style="text-align:right;"> 1117247.0 </td>
   <td style="text-align:right;"> 736258.6 </td>
   <td style="text-align:right;"> 1117247.0 </td>
   <td style="text-align:right;"> 0.03 </td>
   <td style="text-align:right;"> 0.07 </td>
   <td style="text-align:right;"> 0.14 </td>
   <td style="text-align:right;"> 0.02 </td>
   <td style="text-align:right;"> 67.69433 </td>
   <td style="text-align:right;"> 67.69433 </td>
   <td style="text-align:right;"> 5294190 </td>
   <td style="text-align:right;"> 5294190 </td>
   <td style="text-align:right;"> 3616003 </td>
   <td style="text-align:right;"> 3616003 </td>
  </tr>
  <tr>
   <td style="text-align:left;"> 3686377e-de60-48ae-bdff-2019ea1e616f </td>
   <td style="text-align:left;"> 101 </td>
   <td style="text-align:left;"> Company 1 </td>
   <td style="text-align:left;"> 101 </td>
   <td style="text-align:left;"> Company 1 </td>
   <td style="text-align:left;"> MN </td>
   <td style="text-align:left;"> Power </td>
   <td style="text-align:left;"> CoalCap </td>
   <td style="text-align:right;"> 2028 </td>
   <td style="text-align:right;"> 1495089.7 </td>
   <td style="text-align:right;"> 1495089.7 </td>
   <td style="text-align:right;"> 735713.2 </td>
   <td style="text-align:right;"> 1495089.7 </td>
   <td style="text-align:right;"> 0.03 </td>
   <td style="text-align:right;"> 0.07 </td>
   <td style="text-align:right;"> 0.14 </td>
   <td style="text-align:right;"> 0.02 </td>
   <td style="text-align:right;"> 67.73481 </td>
   <td style="text-align:right;"> 67.73481 </td>
   <td style="text-align:right;"> 7088873 </td>
   <td style="text-align:right;"> 7088873 </td>
   <td style="text-align:right;"> 4401632 </td>
   <td style="text-align:right;"> 4401632 </td>
  </tr>
</tbody>
</table></div>


