# download-scenarios

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
library(fs)
```

## Download the data

Data will be downloaded from this endpoint:

``` r
print(
  paste0(trisk.analysis:::TRISK_DATA_INPUT_ENDPOINT, "/", trisk.analysis:::TRISK_DATA_S3_PREFIX)
)
#> [1] "https://storage.googleapis.com/crispy-public-data/trisk_inputs"
```

Choose the folder where to download the data

``` r
trisk_inputs_folder <- file.path(".", "trisk_inputs")
```

Download the data using the provided function.

``` r
if (!is_CRAN) {
  download_success <- download_trisk_inputs(local_save_folder = trisk_inputs_folder, skip_confirmation = TRUE)
}
#> Download completed.
```

The previous function downloads those 4 files :

    #> ./trisk_inputs
    #> └── scenarios.csv

## Descriptive statistics

Load the downloaded scenario data

``` r
if (!is_CRAN) {
  scenarios <- read.csv(file.path(trisk_inputs_folder, "scenarios.csv"))
}
```

### Sectors covered by scenarios

``` r
if (!is_CRAN) {
  scenarios <- read.csv(file.path(trisk_inputs_folder, "scenarios.csv"))
  number_of_scenario_per_sector <- scenarios %>%
    distinct(scenario, sector, technology) %>%
    group_by(sector, technology) %>%
    summarise(n_scenarios = n())
}
#> `summarise()` has regrouped the output.
#> ℹ Summaries were computed grouped by sector and technology.
#> ℹ Output is grouped by sector.
#> ℹ Use `summarise(.groups = "drop_last")` to silence this message.
#> ℹ Use `summarise(.by = c(sector, technology))` for per-operation grouping
#>   (`?dplyr::dplyr_by`) instead.
```

| sector     | technology    | n_scenarios |
|:-----------|:--------------|------------:|
| Automotive | Electric      |           8 |
| Automotive | FuelCell      |           8 |
| Automotive | Hybrid        |           8 |
| Automotive | ICE           |           8 |
| Cement     | Cement        |          21 |
| Coal       | Coal          |          44 |
| Oil&Gas    | Gas           |          44 |
| Oil&Gas    | Oil           |          44 |
| Power      | CoalCap       |         104 |
| Power      | GasCap        |         104 |
| Power      | HydroCap      |         104 |
| Power      | NuclearCap    |         104 |
| Power      | OilCap        |         104 |
| Power      | RenewablesCap |         104 |
| Steel      | BF-BOF        |           2 |
| Steel      | BF-EAF        |           2 |
| Steel      | BF-OHF        |           2 |
| Steel      | BOF           |           2 |
| Steel      | DRI-BOF       |           2 |
| Steel      | DRI-EAF       |           2 |
| Steel      | EAF           |           2 |

This table lists different sector and technology combinations and shows
how many scenarios can be run for each one. The Coal and Oil & Gas
sectors focus on raw material exploration, while the Power sector
involves generating electricity through various technologies.
Technologies ending in “Cap” refer to the power capacity for specific
types of power plants (for example, “CoalCap” is for electricity from
coal-fired plants).

For the steel sector, the technologies are based on specific production
processes:

BOF: Basic Oxygen Furnace BF: Blast Furnace DRI: Direct Reduced Iron
EAF: Electric Arc Furnace MM: Mini Mill OHF: Open Hearth Furnace

The number of scenarios for each sector can vary a lot because of data
limitations. For the Power sector, there are several scenario providers,
like the International Energy Agency (IEA) and the Network for Greening
the Financial System (NGFS), who offer multiple options. However, the
steel sector has fewer sources with detailed technology breakdowns, so
the model mainly relies on scenarios from the Mission Possible
Partnership (MPP).

``` r
if (!is_CRAN) {
  sectors_covered_by_scenarios <- scenarios %>%
    distinct(sector, scenario) %>%
    arrange(sector, scenario)
}
```

| sector     | scenario                        |
|:-----------|:--------------------------------|
| Automotive | GECO2021_1.5C-Unif              |
| Automotive | GECO2021_CurPol                 |
| Automotive | GECO2021_NDC-LTS                |
| Automotive | GECO2023_1.5C                   |
| Automotive | GECO2023_CurPol                 |
| Automotive | GECO2023_NDC-LTS                |
| Automotive | IPR2023Automotive_FPS           |
| Automotive | IPR2023Automotive_baseline      |
| Cement     | NGFS2024GCAM_B2DS               |
| Cement     | NGFS2024GCAM_CP                 |
| Cement     | NGFS2024GCAM_DT                 |
| Cement     | NGFS2024GCAM_FW                 |
| Cement     | NGFS2024GCAM_LD                 |
| Cement     | NGFS2024GCAM_NDC                |
| Cement     | NGFS2024GCAM_NZ2050             |
| Cement     | NGFS2024MESSAGE_B2DS            |
| Cement     | NGFS2024MESSAGE_CP              |
| Cement     | NGFS2024MESSAGE_DT              |
| Cement     | NGFS2024MESSAGE_FW              |
| Cement     | NGFS2024MESSAGE_LD              |
| Cement     | NGFS2024MESSAGE_NDC             |
| Cement     | NGFS2024MESSAGE_NZ2050          |
| Cement     | NGFS2024REMIND_B2DS             |
| Cement     | NGFS2024REMIND_CP               |
| Cement     | NGFS2024REMIND_DT               |
| Cement     | NGFS2024REMIND_FW               |
| Cement     | NGFS2024REMIND_LD               |
| Cement     | NGFS2024REMIND_NDC              |
| Cement     | NGFS2024REMIND_NZ2050           |
| Coal       | IPR2023_FPS                     |
| Coal       | IPR2023_baseline                |
| Coal       | NGFS2023GCAM_B2DS               |
| Coal       | NGFS2023GCAM_CP                 |
| Coal       | NGFS2023GCAM_DT                 |
| Coal       | NGFS2023GCAM_FW                 |
| Coal       | NGFS2023GCAM_LD                 |
| Coal       | NGFS2023GCAM_NDC                |
| Coal       | NGFS2023GCAM_NZ2050             |
| Coal       | NGFS2023MESSAGE_B2DS            |
| Coal       | NGFS2023MESSAGE_CP              |
| Coal       | NGFS2023MESSAGE_DT              |
| Coal       | NGFS2023MESSAGE_FW              |
| Coal       | NGFS2023MESSAGE_LD              |
| Coal       | NGFS2023MESSAGE_NDC             |
| Coal       | NGFS2023MESSAGE_NZ2050          |
| Coal       | NGFS2023REMIND_B2DS             |
| Coal       | NGFS2023REMIND_CP               |
| Coal       | NGFS2023REMIND_DT               |
| Coal       | NGFS2023REMIND_FW               |
| Coal       | NGFS2023REMIND_LD               |
| Coal       | NGFS2023REMIND_NDC              |
| Coal       | NGFS2023REMIND_NZ2050           |
| Coal       | NGFS2024GCAM_B2DS               |
| Coal       | NGFS2024GCAM_CP                 |
| Coal       | NGFS2024GCAM_DT                 |
| Coal       | NGFS2024GCAM_FW                 |
| Coal       | NGFS2024GCAM_LD                 |
| Coal       | NGFS2024GCAM_NDC                |
| Coal       | NGFS2024GCAM_NZ2050             |
| Coal       | NGFS2024MESSAGE_B2DS            |
| Coal       | NGFS2024MESSAGE_CP              |
| Coal       | NGFS2024MESSAGE_DT              |
| Coal       | NGFS2024MESSAGE_FW              |
| Coal       | NGFS2024MESSAGE_LD              |
| Coal       | NGFS2024MESSAGE_NDC             |
| Coal       | NGFS2024MESSAGE_NZ2050          |
| Coal       | NGFS2024REMIND_B2DS             |
| Coal       | NGFS2024REMIND_CP               |
| Coal       | NGFS2024REMIND_DT               |
| Coal       | NGFS2024REMIND_FW               |
| Coal       | NGFS2024REMIND_LD               |
| Coal       | NGFS2024REMIND_NDC              |
| Coal       | NGFS2024REMIND_NZ2050           |
| Oil&Gas    | IPR2023_FPS                     |
| Oil&Gas    | IPR2023_baseline                |
| Oil&Gas    | NGFS2023GCAM_B2DS               |
| Oil&Gas    | NGFS2023GCAM_CP                 |
| Oil&Gas    | NGFS2023GCAM_DT                 |
| Oil&Gas    | NGFS2023GCAM_FW                 |
| Oil&Gas    | NGFS2023GCAM_LD                 |
| Oil&Gas    | NGFS2023GCAM_NDC                |
| Oil&Gas    | NGFS2023GCAM_NZ2050             |
| Oil&Gas    | NGFS2023MESSAGE_B2DS            |
| Oil&Gas    | NGFS2023MESSAGE_CP              |
| Oil&Gas    | NGFS2023MESSAGE_DT              |
| Oil&Gas    | NGFS2023MESSAGE_FW              |
| Oil&Gas    | NGFS2023MESSAGE_LD              |
| Oil&Gas    | NGFS2023MESSAGE_NDC             |
| Oil&Gas    | NGFS2023MESSAGE_NZ2050          |
| Oil&Gas    | NGFS2023REMIND_B2DS             |
| Oil&Gas    | NGFS2023REMIND_CP               |
| Oil&Gas    | NGFS2023REMIND_DT               |
| Oil&Gas    | NGFS2023REMIND_FW               |
| Oil&Gas    | NGFS2023REMIND_LD               |
| Oil&Gas    | NGFS2023REMIND_NDC              |
| Oil&Gas    | NGFS2023REMIND_NZ2050           |
| Oil&Gas    | NGFS2024GCAM_B2DS               |
| Oil&Gas    | NGFS2024GCAM_CP                 |
| Oil&Gas    | NGFS2024GCAM_DT                 |
| Oil&Gas    | NGFS2024GCAM_FW                 |
| Oil&Gas    | NGFS2024GCAM_LD                 |
| Oil&Gas    | NGFS2024GCAM_NDC                |
| Oil&Gas    | NGFS2024GCAM_NZ2050             |
| Oil&Gas    | NGFS2024MESSAGE_B2DS            |
| Oil&Gas    | NGFS2024MESSAGE_CP              |
| Oil&Gas    | NGFS2024MESSAGE_DT              |
| Oil&Gas    | NGFS2024MESSAGE_FW              |
| Oil&Gas    | NGFS2024MESSAGE_LD              |
| Oil&Gas    | NGFS2024MESSAGE_NDC             |
| Oil&Gas    | NGFS2024MESSAGE_NZ2050          |
| Oil&Gas    | NGFS2024REMIND_B2DS             |
| Oil&Gas    | NGFS2024REMIND_CP               |
| Oil&Gas    | NGFS2024REMIND_DT               |
| Oil&Gas    | NGFS2024REMIND_FW               |
| Oil&Gas    | NGFS2024REMIND_LD               |
| Oil&Gas    | NGFS2024REMIND_NDC              |
| Oil&Gas    | NGFS2024REMIND_NZ2050           |
| Power      | IPR2021_FPS                     |
| Power      | IPR2021_RPS                     |
| Power      | IPR2021_baseline                |
| Power      | IPR2023_FPS                     |
| Power      | IPR2023_baseline                |
| Power      | NGFS2021_GCAM_B2DS              |
| Power      | NGFS2021_GCAM_CP                |
| Power      | NGFS2021_GCAM_DT                |
| Power      | NGFS2021_GCAM_NDC               |
| Power      | NGFS2021_GCAM_NZ2050            |
| Power      | NGFS2021_MESSAGE_B2DS           |
| Power      | NGFS2021_MESSAGE_CP             |
| Power      | NGFS2021_MESSAGE_DT             |
| Power      | NGFS2021_MESSAGE_NDC            |
| Power      | NGFS2021_MESSAGE_NZ2050         |
| Power      | NGFS2021_REMIND_B2DS            |
| Power      | NGFS2021_REMIND_CP              |
| Power      | NGFS2021_REMIND_DT              |
| Power      | NGFS2021_REMIND_NDC             |
| Power      | NGFS2021_REMIND_NZ2050          |
| Power      | NGFS2023GCAM_B2DS               |
| Power      | NGFS2023GCAM_CP                 |
| Power      | NGFS2023GCAM_DT                 |
| Power      | NGFS2023GCAM_FW                 |
| Power      | NGFS2023GCAM_LD                 |
| Power      | NGFS2023GCAM_NDC                |
| Power      | NGFS2023GCAM_NZ2050             |
| Power      | NGFS2023MESSAGE_B2DS            |
| Power      | NGFS2023MESSAGE_CP              |
| Power      | NGFS2023MESSAGE_DT              |
| Power      | NGFS2023MESSAGE_FW              |
| Power      | NGFS2023MESSAGE_LD              |
| Power      | NGFS2023MESSAGE_NDC             |
| Power      | NGFS2023MESSAGE_NZ2050          |
| Power      | NGFS2023REMIND_B2DS             |
| Power      | NGFS2023REMIND_CP               |
| Power      | NGFS2023REMIND_DT               |
| Power      | NGFS2023REMIND_FW               |
| Power      | NGFS2023REMIND_LD               |
| Power      | NGFS2023REMIND_NDC              |
| Power      | NGFS2023REMIND_NZ2050           |
| Power      | NGFS2023_GCAM_B2DS              |
| Power      | NGFS2023_GCAM_CP                |
| Power      | NGFS2023_GCAM_DT                |
| Power      | NGFS2023_GCAM_FW                |
| Power      | NGFS2023_GCAM_LD                |
| Power      | NGFS2023_GCAM_NDC               |
| Power      | NGFS2023_GCAM_NZ2050            |
| Power      | NGFS2023_MESSAGE_B2DS           |
| Power      | NGFS2023_MESSAGE_CP             |
| Power      | NGFS2023_MESSAGE_DT             |
| Power      | NGFS2023_MESSAGE_FW             |
| Power      | NGFS2023_MESSAGE_LD             |
| Power      | NGFS2023_MESSAGE_NDC            |
| Power      | NGFS2023_MESSAGE_NZ2050         |
| Power      | NGFS2023_REMIND_B2DS            |
| Power      | NGFS2023_REMIND_CP              |
| Power      | NGFS2023_REMIND_DT              |
| Power      | NGFS2023_REMIND_FW              |
| Power      | NGFS2023_REMIND_LD              |
| Power      | NGFS2023_REMIND_NDC             |
| Power      | NGFS2023_REMIND_NZ2050          |
| Power      | NGFS2024GCAM_B2DS               |
| Power      | NGFS2024GCAM_CP                 |
| Power      | NGFS2024GCAM_DT                 |
| Power      | NGFS2024GCAM_FW                 |
| Power      | NGFS2024GCAM_LD                 |
| Power      | NGFS2024GCAM_NDC                |
| Power      | NGFS2024GCAM_NZ2050             |
| Power      | NGFS2024MESSAGE_B2DS            |
| Power      | NGFS2024MESSAGE_CP              |
| Power      | NGFS2024MESSAGE_DT              |
| Power      | NGFS2024MESSAGE_FW              |
| Power      | NGFS2024MESSAGE_LD              |
| Power      | NGFS2024MESSAGE_NDC             |
| Power      | NGFS2024MESSAGE_NZ2050          |
| Power      | NGFS2024REMIND_B2DS             |
| Power      | NGFS2024REMIND_CP               |
| Power      | NGFS2024REMIND_DT               |
| Power      | NGFS2024REMIND_FW               |
| Power      | NGFS2024REMIND_LD               |
| Power      | NGFS2024REMIND_NDC              |
| Power      | NGFS2024REMIND_NZ2050           |
| Power      | NGFS2024_GCAM_B2DS              |
| Power      | NGFS2024_GCAM_CP                |
| Power      | NGFS2024_GCAM_DT                |
| Power      | NGFS2024_GCAM_FW                |
| Power      | NGFS2024_GCAM_LD                |
| Power      | NGFS2024_GCAM_NDC               |
| Power      | NGFS2024_GCAM_NZ2050            |
| Power      | NGFS2024_MESSAGE_B2DS           |
| Power      | NGFS2024_MESSAGE_CP             |
| Power      | NGFS2024_MESSAGE_DT             |
| Power      | NGFS2024_MESSAGE_FW             |
| Power      | NGFS2024_MESSAGE_LD             |
| Power      | NGFS2024_MESSAGE_NDC            |
| Power      | NGFS2024_MESSAGE_NZ2050         |
| Power      | NGFS2024_REMIND_B2DS            |
| Power      | NGFS2024_REMIND_CP              |
| Power      | NGFS2024_REMIND_DT              |
| Power      | NGFS2024_REMIND_FW              |
| Power      | NGFS2024_REMIND_LD              |
| Power      | NGFS2024_REMIND_NDC             |
| Power      | NGFS2024_REMIND_NZ2050          |
| Steel      | mission_possible_Steel_NZ       |
| Steel      | mission_possible_Steel_baseline |

This table shows the different scenarios available for each sector. It’s
designed to highlight two main points: first, that we can’t use every
scenario for each sector due to data constraints, and second, that there
can still be plenty of scenarios to choose from for a given sector
analysis.

The scenario names follow a specific structure, starting with the
institution providing the scenario, then the data vintage, and finally
the scenario name itself.

For example, the “WEO2023_STEPS” scenario is provided by the World
Energy Outlook from the International Energy Agency. The data for this
scenario is from 2023, and “STEPS” stands for “Stated Policies
Scenario,” which represents a business-as-usual approach based on
current policies.

On the other hand, the “NGFS2023GCAM_NZ2050” scenario is given by the
Network for Greening the Financial System (NGFS), with data also from
2023. For NGFS scenarios, we include the underlying model used to
calculate the scenario—in this case, “GCAM.” NGFS provides scenarios
using three different models, allowing comparisons of scenarios with the
same assumptions but different modeling approaches. “NZ2050” refers to
the “Net Zero 2050” scenario, an ambitious scenario aiming to reach net
zero emissions by 2050.

As shown in the table, there are multiple scenarios integrated into the
stress test. Overall, we cover scenarios from six providers: NGFS, WEO,
Inevitable Policy Response (IPR), Oxford Institute of New Economic
Thinking (Oxford), the Global Energy and Climate Outlook from the EU
(GECO), and the Mission Possible Partnership (Steel). For each provider,
we may have data from different years and sometimes multiple scenarios
to choose from.

How to choose within this portfolio of scenarios is further explained in
the next table.

### Available parameters

``` r
if (!is_CRAN) {
  available_parameters <- get_available_parameters(scenarios)
}
```

| scenario_provider | scenario_geography  | baseline_scenario               | target_scenario           |
|:------------------|:--------------------|:--------------------------------|:--------------------------|
| IPR2021           | Global              | IPR2021_baseline                | IPR2021_FPS               |
| IPR2021           | Global              | IPR2021_baseline                | IPR2021_RPS               |
| NGFS2021_GCAM     | Global              | NGFS2021_GCAM_CP                | NGFS2021_GCAM_B2DS        |
| NGFS2021_GCAM     | Global              | NGFS2021_GCAM_CP                | NGFS2021_GCAM_DT          |
| NGFS2021_GCAM     | Global              | NGFS2021_GCAM_CP                | NGFS2021_GCAM_NZ2050      |
| NGFS2021_GCAM     | Global              | NGFS2021_GCAM_NDC               | NGFS2021_GCAM_B2DS        |
| NGFS2021_GCAM     | Global              | NGFS2021_GCAM_NDC               | NGFS2021_GCAM_DT          |
| NGFS2021_GCAM     | Global              | NGFS2021_GCAM_NDC               | NGFS2021_GCAM_NZ2050      |
| NGFS2021_MESSAGE  | Global              | NGFS2021_MESSAGE_CP             | NGFS2021_MESSAGE_B2DS     |
| NGFS2021_MESSAGE  | Global              | NGFS2021_MESSAGE_CP             | NGFS2021_MESSAGE_DT       |
| NGFS2021_MESSAGE  | Global              | NGFS2021_MESSAGE_CP             | NGFS2021_MESSAGE_NZ2050   |
| NGFS2021_MESSAGE  | Global              | NGFS2021_MESSAGE_NDC            | NGFS2021_MESSAGE_B2DS     |
| NGFS2021_MESSAGE  | Global              | NGFS2021_MESSAGE_NDC            | NGFS2021_MESSAGE_DT       |
| NGFS2021_MESSAGE  | Global              | NGFS2021_MESSAGE_NDC            | NGFS2021_MESSAGE_NZ2050   |
| NGFS2021_REMIND   | Global              | NGFS2021_REMIND_CP              | NGFS2021_REMIND_B2DS      |
| NGFS2021_REMIND   | Global              | NGFS2021_REMIND_CP              | NGFS2021_REMIND_DT        |
| NGFS2021_REMIND   | Global              | NGFS2021_REMIND_CP              | NGFS2021_REMIND_NZ2050    |
| NGFS2021_REMIND   | Global              | NGFS2021_REMIND_NDC             | NGFS2021_REMIND_B2DS      |
| NGFS2021_REMIND   | Global              | NGFS2021_REMIND_NDC             | NGFS2021_REMIND_DT        |
| NGFS2021_REMIND   | Global              | NGFS2021_REMIND_NDC             | NGFS2021_REMIND_NZ2050    |
| NGFS2023_GCAM     | Global              | NGFS2023_GCAM_CP                | NGFS2023_GCAM_B2DS        |
| NGFS2023_GCAM     | Global              | NGFS2023_GCAM_CP                | NGFS2023_GCAM_DT          |
| NGFS2023_GCAM     | Global              | NGFS2023_GCAM_CP                | NGFS2023_GCAM_LD          |
| NGFS2023_GCAM     | Global              | NGFS2023_GCAM_CP                | NGFS2023_GCAM_NZ2050      |
| NGFS2023_GCAM     | Global              | NGFS2023_GCAM_FW                | NGFS2023_GCAM_B2DS        |
| NGFS2023_GCAM     | Global              | NGFS2023_GCAM_FW                | NGFS2023_GCAM_DT          |
| NGFS2023_GCAM     | Global              | NGFS2023_GCAM_FW                | NGFS2023_GCAM_LD          |
| NGFS2023_GCAM     | Global              | NGFS2023_GCAM_FW                | NGFS2023_GCAM_NZ2050      |
| NGFS2023_GCAM     | Global              | NGFS2023_GCAM_NDC               | NGFS2023_GCAM_B2DS        |
| NGFS2023_GCAM     | Global              | NGFS2023_GCAM_NDC               | NGFS2023_GCAM_DT          |
| NGFS2023_GCAM     | Global              | NGFS2023_GCAM_NDC               | NGFS2023_GCAM_LD          |
| NGFS2023_GCAM     | Global              | NGFS2023_GCAM_NDC               | NGFS2023_GCAM_NZ2050      |
| NGFS2023_MESSAGE  | Global              | NGFS2023_MESSAGE_CP             | NGFS2023_MESSAGE_B2DS     |
| NGFS2023_MESSAGE  | Global              | NGFS2023_MESSAGE_CP             | NGFS2023_MESSAGE_DT       |
| NGFS2023_MESSAGE  | Global              | NGFS2023_MESSAGE_CP             | NGFS2023_MESSAGE_LD       |
| NGFS2023_MESSAGE  | Global              | NGFS2023_MESSAGE_CP             | NGFS2023_MESSAGE_NZ2050   |
| NGFS2023_MESSAGE  | Global              | NGFS2023_MESSAGE_FW             | NGFS2023_MESSAGE_B2DS     |
| NGFS2023_MESSAGE  | Global              | NGFS2023_MESSAGE_FW             | NGFS2023_MESSAGE_DT       |
| NGFS2023_MESSAGE  | Global              | NGFS2023_MESSAGE_FW             | NGFS2023_MESSAGE_LD       |
| NGFS2023_MESSAGE  | Global              | NGFS2023_MESSAGE_FW             | NGFS2023_MESSAGE_NZ2050   |
| NGFS2023_MESSAGE  | Global              | NGFS2023_MESSAGE_NDC            | NGFS2023_MESSAGE_B2DS     |
| NGFS2023_MESSAGE  | Global              | NGFS2023_MESSAGE_NDC            | NGFS2023_MESSAGE_DT       |
| NGFS2023_MESSAGE  | Global              | NGFS2023_MESSAGE_NDC            | NGFS2023_MESSAGE_LD       |
| NGFS2023_MESSAGE  | Global              | NGFS2023_MESSAGE_NDC            | NGFS2023_MESSAGE_NZ2050   |
| NGFS2023_REMIND   | Global              | NGFS2023_REMIND_CP              | NGFS2023_REMIND_B2DS      |
| NGFS2023_REMIND   | Global              | NGFS2023_REMIND_CP              | NGFS2023_REMIND_DT        |
| NGFS2023_REMIND   | Global              | NGFS2023_REMIND_CP              | NGFS2023_REMIND_LD        |
| NGFS2023_REMIND   | Global              | NGFS2023_REMIND_CP              | NGFS2023_REMIND_NZ2050    |
| NGFS2023_REMIND   | Global              | NGFS2023_REMIND_FW              | NGFS2023_REMIND_B2DS      |
| NGFS2023_REMIND   | Global              | NGFS2023_REMIND_FW              | NGFS2023_REMIND_DT        |
| NGFS2023_REMIND   | Global              | NGFS2023_REMIND_FW              | NGFS2023_REMIND_LD        |
| NGFS2023_REMIND   | Global              | NGFS2023_REMIND_FW              | NGFS2023_REMIND_NZ2050    |
| NGFS2023_REMIND   | Global              | NGFS2023_REMIND_NDC             | NGFS2023_REMIND_B2DS      |
| NGFS2023_REMIND   | Global              | NGFS2023_REMIND_NDC             | NGFS2023_REMIND_DT        |
| NGFS2023_REMIND   | Global              | NGFS2023_REMIND_NDC             | NGFS2023_REMIND_LD        |
| NGFS2023_REMIND   | Global              | NGFS2023_REMIND_NDC             | NGFS2023_REMIND_NZ2050    |
| NGFS2024_GCAM     | Global              | NGFS2024_GCAM_CP                | NGFS2024_GCAM_B2DS        |
| NGFS2024_GCAM     | Global              | NGFS2024_GCAM_CP                | NGFS2024_GCAM_DT          |
| NGFS2024_GCAM     | Global              | NGFS2024_GCAM_CP                | NGFS2024_GCAM_LD          |
| NGFS2024_GCAM     | Global              | NGFS2024_GCAM_CP                | NGFS2024_GCAM_NZ2050      |
| NGFS2024_GCAM     | Global              | NGFS2024_GCAM_FW                | NGFS2024_GCAM_B2DS        |
| NGFS2024_GCAM     | Global              | NGFS2024_GCAM_FW                | NGFS2024_GCAM_DT          |
| NGFS2024_GCAM     | Global              | NGFS2024_GCAM_FW                | NGFS2024_GCAM_LD          |
| NGFS2024_GCAM     | Global              | NGFS2024_GCAM_FW                | NGFS2024_GCAM_NZ2050      |
| NGFS2024_GCAM     | Global              | NGFS2024_GCAM_NDC               | NGFS2024_GCAM_B2DS        |
| NGFS2024_GCAM     | Global              | NGFS2024_GCAM_NDC               | NGFS2024_GCAM_DT          |
| NGFS2024_GCAM     | Global              | NGFS2024_GCAM_NDC               | NGFS2024_GCAM_LD          |
| NGFS2024_GCAM     | Global              | NGFS2024_GCAM_NDC               | NGFS2024_GCAM_NZ2050      |
| NGFS2024_MESSAGE  | Global              | NGFS2024_MESSAGE_CP             | NGFS2024_MESSAGE_B2DS     |
| NGFS2024_MESSAGE  | Global              | NGFS2024_MESSAGE_CP             | NGFS2024_MESSAGE_DT       |
| NGFS2024_MESSAGE  | Global              | NGFS2024_MESSAGE_CP             | NGFS2024_MESSAGE_LD       |
| NGFS2024_MESSAGE  | Global              | NGFS2024_MESSAGE_CP             | NGFS2024_MESSAGE_NZ2050   |
| NGFS2024_MESSAGE  | Global              | NGFS2024_MESSAGE_FW             | NGFS2024_MESSAGE_B2DS     |
| NGFS2024_MESSAGE  | Global              | NGFS2024_MESSAGE_FW             | NGFS2024_MESSAGE_DT       |
| NGFS2024_MESSAGE  | Global              | NGFS2024_MESSAGE_FW             | NGFS2024_MESSAGE_LD       |
| NGFS2024_MESSAGE  | Global              | NGFS2024_MESSAGE_FW             | NGFS2024_MESSAGE_NZ2050   |
| NGFS2024_MESSAGE  | Global              | NGFS2024_MESSAGE_NDC            | NGFS2024_MESSAGE_B2DS     |
| NGFS2024_MESSAGE  | Global              | NGFS2024_MESSAGE_NDC            | NGFS2024_MESSAGE_DT       |
| NGFS2024_MESSAGE  | Global              | NGFS2024_MESSAGE_NDC            | NGFS2024_MESSAGE_LD       |
| NGFS2024_MESSAGE  | Global              | NGFS2024_MESSAGE_NDC            | NGFS2024_MESSAGE_NZ2050   |
| NGFS2024_REMIND   | Global              | NGFS2024_REMIND_CP              | NGFS2024_REMIND_B2DS      |
| NGFS2024_REMIND   | Global              | NGFS2024_REMIND_CP              | NGFS2024_REMIND_DT        |
| NGFS2024_REMIND   | Global              | NGFS2024_REMIND_CP              | NGFS2024_REMIND_LD        |
| NGFS2024_REMIND   | Global              | NGFS2024_REMIND_CP              | NGFS2024_REMIND_NZ2050    |
| NGFS2024_REMIND   | Global              | NGFS2024_REMIND_FW              | NGFS2024_REMIND_B2DS      |
| NGFS2024_REMIND   | Global              | NGFS2024_REMIND_FW              | NGFS2024_REMIND_DT        |
| NGFS2024_REMIND   | Global              | NGFS2024_REMIND_FW              | NGFS2024_REMIND_LD        |
| NGFS2024_REMIND   | Global              | NGFS2024_REMIND_FW              | NGFS2024_REMIND_NZ2050    |
| NGFS2024_REMIND   | Global              | NGFS2024_REMIND_NDC             | NGFS2024_REMIND_B2DS      |
| NGFS2024_REMIND   | Global              | NGFS2024_REMIND_NDC             | NGFS2024_REMIND_DT        |
| NGFS2024_REMIND   | Global              | NGFS2024_REMIND_NDC             | NGFS2024_REMIND_LD        |
| NGFS2024_REMIND   | Global              | NGFS2024_REMIND_NDC             | NGFS2024_REMIND_NZ2050    |
| mission_possible  | Global              | mission_possible_Steel_baseline | mission_possible_Steel_NZ |
| GECO2021          | Global              | GECO2021_CurPol                 | GECO2021_1.5C-Unif        |
| GECO2021          | Global              | GECO2021_CurPol                 | GECO2021_NDC-LTS          |
| NGFS2023GCAM      | Asia                | NGFS2023GCAM_CP                 | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | Asia                | NGFS2023GCAM_CP                 | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | Asia                | NGFS2023GCAM_CP                 | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | Asia                | NGFS2023GCAM_CP                 | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | China               | NGFS2023GCAM_CP                 | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | China               | NGFS2023GCAM_CP                 | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | China               | NGFS2023GCAM_CP                 | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | China               | NGFS2023GCAM_CP                 | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | Global              | NGFS2023GCAM_CP                 | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | Global              | NGFS2023GCAM_CP                 | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | Global              | NGFS2023GCAM_CP                 | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | Global              | NGFS2023GCAM_CP                 | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | India               | NGFS2023GCAM_CP                 | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | India               | NGFS2023GCAM_CP                 | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | India               | NGFS2023GCAM_CP                 | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | India               | NGFS2023GCAM_CP                 | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | Indonesia           | NGFS2023GCAM_CP                 | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | Indonesia           | NGFS2023GCAM_CP                 | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | Indonesia           | NGFS2023GCAM_CP                 | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | Indonesia           | NGFS2023GCAM_CP                 | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | LatinAmerica        | NGFS2023GCAM_CP                 | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | LatinAmerica        | NGFS2023GCAM_CP                 | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | LatinAmerica        | NGFS2023GCAM_CP                 | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | LatinAmerica        | NGFS2023GCAM_CP                 | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | MiddleEastAndAfrica | NGFS2023GCAM_CP                 | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | MiddleEastAndAfrica | NGFS2023GCAM_CP                 | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | MiddleEastAndAfrica | NGFS2023GCAM_CP                 | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | MiddleEastAndAfrica | NGFS2023GCAM_CP                 | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | OecdAndEu           | NGFS2023GCAM_CP                 | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | OecdAndEu           | NGFS2023GCAM_CP                 | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | OecdAndEu           | NGFS2023GCAM_CP                 | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | OecdAndEu           | NGFS2023GCAM_CP                 | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | ReformingEconomies  | NGFS2023GCAM_CP                 | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | ReformingEconomies  | NGFS2023GCAM_CP                 | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | ReformingEconomies  | NGFS2023GCAM_CP                 | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | ReformingEconomies  | NGFS2023GCAM_CP                 | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | SoutheastAsia       | NGFS2023GCAM_CP                 | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | SoutheastAsia       | NGFS2023GCAM_CP                 | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | SoutheastAsia       | NGFS2023GCAM_CP                 | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | SoutheastAsia       | NGFS2023GCAM_CP                 | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | UnitedStates        | NGFS2023GCAM_CP                 | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | UnitedStates        | NGFS2023GCAM_CP                 | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | UnitedStates        | NGFS2023GCAM_CP                 | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | UnitedStates        | NGFS2023GCAM_CP                 | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | Asia                | NGFS2023GCAM_FW                 | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | Asia                | NGFS2023GCAM_FW                 | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | Asia                | NGFS2023GCAM_FW                 | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | Asia                | NGFS2023GCAM_FW                 | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | China               | NGFS2023GCAM_FW                 | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | China               | NGFS2023GCAM_FW                 | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | China               | NGFS2023GCAM_FW                 | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | China               | NGFS2023GCAM_FW                 | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | Global              | NGFS2023GCAM_FW                 | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | Global              | NGFS2023GCAM_FW                 | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | Global              | NGFS2023GCAM_FW                 | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | Global              | NGFS2023GCAM_FW                 | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | India               | NGFS2023GCAM_FW                 | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | India               | NGFS2023GCAM_FW                 | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | India               | NGFS2023GCAM_FW                 | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | India               | NGFS2023GCAM_FW                 | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | Indonesia           | NGFS2023GCAM_FW                 | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | Indonesia           | NGFS2023GCAM_FW                 | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | Indonesia           | NGFS2023GCAM_FW                 | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | Indonesia           | NGFS2023GCAM_FW                 | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | LatinAmerica        | NGFS2023GCAM_FW                 | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | LatinAmerica        | NGFS2023GCAM_FW                 | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | LatinAmerica        | NGFS2023GCAM_FW                 | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | LatinAmerica        | NGFS2023GCAM_FW                 | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | MiddleEastAndAfrica | NGFS2023GCAM_FW                 | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | MiddleEastAndAfrica | NGFS2023GCAM_FW                 | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | MiddleEastAndAfrica | NGFS2023GCAM_FW                 | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | MiddleEastAndAfrica | NGFS2023GCAM_FW                 | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | OecdAndEu           | NGFS2023GCAM_FW                 | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | OecdAndEu           | NGFS2023GCAM_FW                 | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | OecdAndEu           | NGFS2023GCAM_FW                 | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | OecdAndEu           | NGFS2023GCAM_FW                 | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | ReformingEconomies  | NGFS2023GCAM_FW                 | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | ReformingEconomies  | NGFS2023GCAM_FW                 | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | ReformingEconomies  | NGFS2023GCAM_FW                 | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | ReformingEconomies  | NGFS2023GCAM_FW                 | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | SoutheastAsia       | NGFS2023GCAM_FW                 | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | SoutheastAsia       | NGFS2023GCAM_FW                 | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | SoutheastAsia       | NGFS2023GCAM_FW                 | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | SoutheastAsia       | NGFS2023GCAM_FW                 | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | UnitedStates        | NGFS2023GCAM_FW                 | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | UnitedStates        | NGFS2023GCAM_FW                 | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | UnitedStates        | NGFS2023GCAM_FW                 | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | UnitedStates        | NGFS2023GCAM_FW                 | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | Asia                | NGFS2023GCAM_NDC                | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | Asia                | NGFS2023GCAM_NDC                | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | Asia                | NGFS2023GCAM_NDC                | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | Asia                | NGFS2023GCAM_NDC                | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | China               | NGFS2023GCAM_NDC                | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | China               | NGFS2023GCAM_NDC                | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | China               | NGFS2023GCAM_NDC                | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | China               | NGFS2023GCAM_NDC                | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | Global              | NGFS2023GCAM_NDC                | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | Global              | NGFS2023GCAM_NDC                | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | Global              | NGFS2023GCAM_NDC                | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | Global              | NGFS2023GCAM_NDC                | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | India               | NGFS2023GCAM_NDC                | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | India               | NGFS2023GCAM_NDC                | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | India               | NGFS2023GCAM_NDC                | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | India               | NGFS2023GCAM_NDC                | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | Indonesia           | NGFS2023GCAM_NDC                | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | Indonesia           | NGFS2023GCAM_NDC                | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | Indonesia           | NGFS2023GCAM_NDC                | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | Indonesia           | NGFS2023GCAM_NDC                | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | LatinAmerica        | NGFS2023GCAM_NDC                | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | LatinAmerica        | NGFS2023GCAM_NDC                | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | LatinAmerica        | NGFS2023GCAM_NDC                | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | LatinAmerica        | NGFS2023GCAM_NDC                | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | MiddleEastAndAfrica | NGFS2023GCAM_NDC                | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | MiddleEastAndAfrica | NGFS2023GCAM_NDC                | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | MiddleEastAndAfrica | NGFS2023GCAM_NDC                | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | MiddleEastAndAfrica | NGFS2023GCAM_NDC                | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | OecdAndEu           | NGFS2023GCAM_NDC                | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | OecdAndEu           | NGFS2023GCAM_NDC                | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | OecdAndEu           | NGFS2023GCAM_NDC                | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | OecdAndEu           | NGFS2023GCAM_NDC                | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | ReformingEconomies  | NGFS2023GCAM_NDC                | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | ReformingEconomies  | NGFS2023GCAM_NDC                | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | ReformingEconomies  | NGFS2023GCAM_NDC                | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | ReformingEconomies  | NGFS2023GCAM_NDC                | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | SoutheastAsia       | NGFS2023GCAM_NDC                | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | SoutheastAsia       | NGFS2023GCAM_NDC                | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | SoutheastAsia       | NGFS2023GCAM_NDC                | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | SoutheastAsia       | NGFS2023GCAM_NDC                | NGFS2023GCAM_NZ2050       |
| NGFS2023GCAM      | UnitedStates        | NGFS2023GCAM_NDC                | NGFS2023GCAM_B2DS         |
| NGFS2023GCAM      | UnitedStates        | NGFS2023GCAM_NDC                | NGFS2023GCAM_DT           |
| NGFS2023GCAM      | UnitedStates        | NGFS2023GCAM_NDC                | NGFS2023GCAM_LD           |
| NGFS2023GCAM      | UnitedStates        | NGFS2023GCAM_NDC                | NGFS2023GCAM_NZ2050       |
| NGFS2023MESSAGE   | Asia                | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_B2DS      |
| NGFS2023MESSAGE   | Asia                | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_DT        |
| NGFS2023MESSAGE   | Asia                | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_LD        |
| NGFS2023MESSAGE   | Asia                | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_NZ2050    |
| NGFS2023MESSAGE   | China               | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_B2DS      |
| NGFS2023MESSAGE   | China               | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_DT        |
| NGFS2023MESSAGE   | China               | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_LD        |
| NGFS2023MESSAGE   | China               | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_NZ2050    |
| NGFS2023MESSAGE   | Global              | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_B2DS      |
| NGFS2023MESSAGE   | Global              | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_DT        |
| NGFS2023MESSAGE   | Global              | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_LD        |
| NGFS2023MESSAGE   | Global              | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_NZ2050    |
| NGFS2023MESSAGE   | LatinAmerica        | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_B2DS      |
| NGFS2023MESSAGE   | LatinAmerica        | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_DT        |
| NGFS2023MESSAGE   | LatinAmerica        | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_LD        |
| NGFS2023MESSAGE   | LatinAmerica        | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_NZ2050    |
| NGFS2023MESSAGE   | MiddleEastAndAfrica | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_B2DS      |
| NGFS2023MESSAGE   | MiddleEastAndAfrica | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_DT        |
| NGFS2023MESSAGE   | MiddleEastAndAfrica | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_LD        |
| NGFS2023MESSAGE   | MiddleEastAndAfrica | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_NZ2050    |
| NGFS2023MESSAGE   | OecdAndEu           | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_B2DS      |
| NGFS2023MESSAGE   | OecdAndEu           | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_DT        |
| NGFS2023MESSAGE   | OecdAndEu           | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_LD        |
| NGFS2023MESSAGE   | OecdAndEu           | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_NZ2050    |
| NGFS2023MESSAGE   | ReformingEconomies  | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_B2DS      |
| NGFS2023MESSAGE   | ReformingEconomies  | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_DT        |
| NGFS2023MESSAGE   | ReformingEconomies  | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_LD        |
| NGFS2023MESSAGE   | ReformingEconomies  | NGFS2023MESSAGE_CP              | NGFS2023MESSAGE_NZ2050    |
| NGFS2023MESSAGE   | Asia                | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_B2DS      |
| NGFS2023MESSAGE   | Asia                | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_DT        |
| NGFS2023MESSAGE   | Asia                | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_LD        |
| NGFS2023MESSAGE   | Asia                | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_NZ2050    |
| NGFS2023MESSAGE   | China               | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_B2DS      |
| NGFS2023MESSAGE   | China               | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_DT        |
| NGFS2023MESSAGE   | China               | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_LD        |
| NGFS2023MESSAGE   | China               | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_NZ2050    |
| NGFS2023MESSAGE   | Global              | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_B2DS      |
| NGFS2023MESSAGE   | Global              | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_DT        |
| NGFS2023MESSAGE   | Global              | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_LD        |
| NGFS2023MESSAGE   | Global              | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_NZ2050    |
| NGFS2023MESSAGE   | LatinAmerica        | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_B2DS      |
| NGFS2023MESSAGE   | LatinAmerica        | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_DT        |
| NGFS2023MESSAGE   | LatinAmerica        | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_LD        |
| NGFS2023MESSAGE   | LatinAmerica        | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_NZ2050    |
| NGFS2023MESSAGE   | MiddleEastAndAfrica | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_B2DS      |
| NGFS2023MESSAGE   | MiddleEastAndAfrica | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_DT        |
| NGFS2023MESSAGE   | MiddleEastAndAfrica | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_LD        |
| NGFS2023MESSAGE   | MiddleEastAndAfrica | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_NZ2050    |
| NGFS2023MESSAGE   | OecdAndEu           | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_B2DS      |
| NGFS2023MESSAGE   | OecdAndEu           | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_DT        |
| NGFS2023MESSAGE   | OecdAndEu           | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_LD        |
| NGFS2023MESSAGE   | OecdAndEu           | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_NZ2050    |
| NGFS2023MESSAGE   | ReformingEconomies  | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_B2DS      |
| NGFS2023MESSAGE   | ReformingEconomies  | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_DT        |
| NGFS2023MESSAGE   | ReformingEconomies  | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_LD        |
| NGFS2023MESSAGE   | ReformingEconomies  | NGFS2023MESSAGE_FW              | NGFS2023MESSAGE_NZ2050    |
| NGFS2023MESSAGE   | Asia                | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_B2DS      |
| NGFS2023MESSAGE   | Asia                | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_DT        |
| NGFS2023MESSAGE   | Asia                | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_LD        |
| NGFS2023MESSAGE   | Asia                | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_NZ2050    |
| NGFS2023MESSAGE   | China               | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_B2DS      |
| NGFS2023MESSAGE   | China               | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_DT        |
| NGFS2023MESSAGE   | China               | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_LD        |
| NGFS2023MESSAGE   | China               | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_NZ2050    |
| NGFS2023MESSAGE   | Global              | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_B2DS      |
| NGFS2023MESSAGE   | Global              | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_DT        |
| NGFS2023MESSAGE   | Global              | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_LD        |
| NGFS2023MESSAGE   | Global              | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_NZ2050    |
| NGFS2023MESSAGE   | LatinAmerica        | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_B2DS      |
| NGFS2023MESSAGE   | LatinAmerica        | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_DT        |
| NGFS2023MESSAGE   | LatinAmerica        | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_LD        |
| NGFS2023MESSAGE   | LatinAmerica        | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_NZ2050    |
| NGFS2023MESSAGE   | MiddleEastAndAfrica | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_B2DS      |
| NGFS2023MESSAGE   | MiddleEastAndAfrica | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_DT        |
| NGFS2023MESSAGE   | MiddleEastAndAfrica | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_LD        |
| NGFS2023MESSAGE   | MiddleEastAndAfrica | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_NZ2050    |
| NGFS2023MESSAGE   | OecdAndEu           | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_B2DS      |
| NGFS2023MESSAGE   | OecdAndEu           | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_DT        |
| NGFS2023MESSAGE   | OecdAndEu           | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_LD        |
| NGFS2023MESSAGE   | OecdAndEu           | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_NZ2050    |
| NGFS2023MESSAGE   | ReformingEconomies  | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_B2DS      |
| NGFS2023MESSAGE   | ReformingEconomies  | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_DT        |
| NGFS2023MESSAGE   | ReformingEconomies  | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_LD        |
| NGFS2023MESSAGE   | ReformingEconomies  | NGFS2023MESSAGE_NDC             | NGFS2023MESSAGE_NZ2050    |
| NGFS2023REMIND    | Asia                | NGFS2023REMIND_CP               | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | Asia                | NGFS2023REMIND_CP               | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | Asia                | NGFS2023REMIND_CP               | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | Asia                | NGFS2023REMIND_CP               | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | China               | NGFS2023REMIND_CP               | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | China               | NGFS2023REMIND_CP               | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | China               | NGFS2023REMIND_CP               | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | China               | NGFS2023REMIND_CP               | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | Global              | NGFS2023REMIND_CP               | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | Global              | NGFS2023REMIND_CP               | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | Global              | NGFS2023REMIND_CP               | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | Global              | NGFS2023REMIND_CP               | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | India               | NGFS2023REMIND_CP               | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | India               | NGFS2023REMIND_CP               | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | India               | NGFS2023REMIND_CP               | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | India               | NGFS2023REMIND_CP               | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | LatinAmerica        | NGFS2023REMIND_CP               | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | LatinAmerica        | NGFS2023REMIND_CP               | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | LatinAmerica        | NGFS2023REMIND_CP               | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | LatinAmerica        | NGFS2023REMIND_CP               | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | MiddleEastAndAfrica | NGFS2023REMIND_CP               | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | MiddleEastAndAfrica | NGFS2023REMIND_CP               | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | MiddleEastAndAfrica | NGFS2023REMIND_CP               | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | MiddleEastAndAfrica | NGFS2023REMIND_CP               | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | OecdAndEu           | NGFS2023REMIND_CP               | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | OecdAndEu           | NGFS2023REMIND_CP               | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | OecdAndEu           | NGFS2023REMIND_CP               | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | OecdAndEu           | NGFS2023REMIND_CP               | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | ReformingEconomies  | NGFS2023REMIND_CP               | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | ReformingEconomies  | NGFS2023REMIND_CP               | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | ReformingEconomies  | NGFS2023REMIND_CP               | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | ReformingEconomies  | NGFS2023REMIND_CP               | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | UnitedStates        | NGFS2023REMIND_CP               | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | UnitedStates        | NGFS2023REMIND_CP               | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | UnitedStates        | NGFS2023REMIND_CP               | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | UnitedStates        | NGFS2023REMIND_CP               | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | Asia                | NGFS2023REMIND_FW               | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | Asia                | NGFS2023REMIND_FW               | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | Asia                | NGFS2023REMIND_FW               | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | Asia                | NGFS2023REMIND_FW               | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | China               | NGFS2023REMIND_FW               | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | China               | NGFS2023REMIND_FW               | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | China               | NGFS2023REMIND_FW               | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | China               | NGFS2023REMIND_FW               | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | Global              | NGFS2023REMIND_FW               | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | Global              | NGFS2023REMIND_FW               | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | Global              | NGFS2023REMIND_FW               | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | Global              | NGFS2023REMIND_FW               | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | India               | NGFS2023REMIND_FW               | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | India               | NGFS2023REMIND_FW               | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | India               | NGFS2023REMIND_FW               | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | India               | NGFS2023REMIND_FW               | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | LatinAmerica        | NGFS2023REMIND_FW               | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | LatinAmerica        | NGFS2023REMIND_FW               | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | LatinAmerica        | NGFS2023REMIND_FW               | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | LatinAmerica        | NGFS2023REMIND_FW               | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | MiddleEastAndAfrica | NGFS2023REMIND_FW               | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | MiddleEastAndAfrica | NGFS2023REMIND_FW               | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | MiddleEastAndAfrica | NGFS2023REMIND_FW               | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | MiddleEastAndAfrica | NGFS2023REMIND_FW               | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | OecdAndEu           | NGFS2023REMIND_FW               | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | OecdAndEu           | NGFS2023REMIND_FW               | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | OecdAndEu           | NGFS2023REMIND_FW               | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | OecdAndEu           | NGFS2023REMIND_FW               | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | ReformingEconomies  | NGFS2023REMIND_FW               | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | ReformingEconomies  | NGFS2023REMIND_FW               | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | ReformingEconomies  | NGFS2023REMIND_FW               | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | ReformingEconomies  | NGFS2023REMIND_FW               | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | UnitedStates        | NGFS2023REMIND_FW               | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | UnitedStates        | NGFS2023REMIND_FW               | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | UnitedStates        | NGFS2023REMIND_FW               | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | UnitedStates        | NGFS2023REMIND_FW               | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | Asia                | NGFS2023REMIND_NDC              | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | Asia                | NGFS2023REMIND_NDC              | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | Asia                | NGFS2023REMIND_NDC              | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | Asia                | NGFS2023REMIND_NDC              | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | China               | NGFS2023REMIND_NDC              | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | China               | NGFS2023REMIND_NDC              | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | China               | NGFS2023REMIND_NDC              | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | China               | NGFS2023REMIND_NDC              | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | Global              | NGFS2023REMIND_NDC              | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | Global              | NGFS2023REMIND_NDC              | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | Global              | NGFS2023REMIND_NDC              | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | Global              | NGFS2023REMIND_NDC              | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | India               | NGFS2023REMIND_NDC              | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | India               | NGFS2023REMIND_NDC              | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | India               | NGFS2023REMIND_NDC              | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | India               | NGFS2023REMIND_NDC              | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | LatinAmerica        | NGFS2023REMIND_NDC              | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | LatinAmerica        | NGFS2023REMIND_NDC              | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | LatinAmerica        | NGFS2023REMIND_NDC              | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | LatinAmerica        | NGFS2023REMIND_NDC              | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | MiddleEastAndAfrica | NGFS2023REMIND_NDC              | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | MiddleEastAndAfrica | NGFS2023REMIND_NDC              | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | MiddleEastAndAfrica | NGFS2023REMIND_NDC              | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | MiddleEastAndAfrica | NGFS2023REMIND_NDC              | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | OecdAndEu           | NGFS2023REMIND_NDC              | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | OecdAndEu           | NGFS2023REMIND_NDC              | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | OecdAndEu           | NGFS2023REMIND_NDC              | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | OecdAndEu           | NGFS2023REMIND_NDC              | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | ReformingEconomies  | NGFS2023REMIND_NDC              | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | ReformingEconomies  | NGFS2023REMIND_NDC              | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | ReformingEconomies  | NGFS2023REMIND_NDC              | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | ReformingEconomies  | NGFS2023REMIND_NDC              | NGFS2023REMIND_NZ2050     |
| NGFS2023REMIND    | UnitedStates        | NGFS2023REMIND_NDC              | NGFS2023REMIND_B2DS       |
| NGFS2023REMIND    | UnitedStates        | NGFS2023REMIND_NDC              | NGFS2023REMIND_DT         |
| NGFS2023REMIND    | UnitedStates        | NGFS2023REMIND_NDC              | NGFS2023REMIND_LD         |
| NGFS2023REMIND    | UnitedStates        | NGFS2023REMIND_NDC              | NGFS2023REMIND_NZ2050     |
| IPR2023           | Brazil              | IPR2023_baseline                | IPR2023_FPS               |
| IPR2023           | Global              | IPR2023_baseline                | IPR2023_FPS               |
| IPR2023           | India               | IPR2023_baseline                | IPR2023_FPS               |
| IPR2023           | Japan               | IPR2023_baseline                | IPR2023_FPS               |
| IPR2023           | Russia              | IPR2023_baseline                | IPR2023_FPS               |
| IPR2023           | UnitedStates        | IPR2023_baseline                | IPR2023_FPS               |
| IPR2023Automotive | Global              | IPR2023Automotive_baseline      | IPR2023Automotive_FPS     |
| GECO2023          | Global              | GECO2023_CurPol                 | GECO2023_1.5C             |
| GECO2023          | Global              | GECO2023_CurPol                 | GECO2023_NDC-LTS          |
| NGFS2024GCAM      | Asia                | NGFS2024GCAM_CP                 | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | Asia                | NGFS2024GCAM_CP                 | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | Asia                | NGFS2024GCAM_CP                 | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | Asia                | NGFS2024GCAM_CP                 | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | China               | NGFS2024GCAM_CP                 | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | China               | NGFS2024GCAM_CP                 | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | China               | NGFS2024GCAM_CP                 | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | China               | NGFS2024GCAM_CP                 | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | Global              | NGFS2024GCAM_CP                 | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | Global              | NGFS2024GCAM_CP                 | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | Global              | NGFS2024GCAM_CP                 | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | Global              | NGFS2024GCAM_CP                 | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | India               | NGFS2024GCAM_CP                 | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | India               | NGFS2024GCAM_CP                 | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | India               | NGFS2024GCAM_CP                 | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | India               | NGFS2024GCAM_CP                 | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | Indonesia           | NGFS2024GCAM_CP                 | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | Indonesia           | NGFS2024GCAM_CP                 | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | Indonesia           | NGFS2024GCAM_CP                 | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | Indonesia           | NGFS2024GCAM_CP                 | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | LatinAmerica        | NGFS2024GCAM_CP                 | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | LatinAmerica        | NGFS2024GCAM_CP                 | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | LatinAmerica        | NGFS2024GCAM_CP                 | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | LatinAmerica        | NGFS2024GCAM_CP                 | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | MiddleEastAndAfrica | NGFS2024GCAM_CP                 | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | MiddleEastAndAfrica | NGFS2024GCAM_CP                 | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | MiddleEastAndAfrica | NGFS2024GCAM_CP                 | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | MiddleEastAndAfrica | NGFS2024GCAM_CP                 | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | OecdAndEu           | NGFS2024GCAM_CP                 | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | OecdAndEu           | NGFS2024GCAM_CP                 | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | OecdAndEu           | NGFS2024GCAM_CP                 | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | OecdAndEu           | NGFS2024GCAM_CP                 | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | ReformingEconomies  | NGFS2024GCAM_CP                 | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | ReformingEconomies  | NGFS2024GCAM_CP                 | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | ReformingEconomies  | NGFS2024GCAM_CP                 | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | ReformingEconomies  | NGFS2024GCAM_CP                 | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | SoutheastAsia       | NGFS2024GCAM_CP                 | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | SoutheastAsia       | NGFS2024GCAM_CP                 | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | SoutheastAsia       | NGFS2024GCAM_CP                 | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | SoutheastAsia       | NGFS2024GCAM_CP                 | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | UnitedStates        | NGFS2024GCAM_CP                 | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | UnitedStates        | NGFS2024GCAM_CP                 | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | UnitedStates        | NGFS2024GCAM_CP                 | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | UnitedStates        | NGFS2024GCAM_CP                 | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | Asia                | NGFS2024GCAM_FW                 | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | Asia                | NGFS2024GCAM_FW                 | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | Asia                | NGFS2024GCAM_FW                 | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | Asia                | NGFS2024GCAM_FW                 | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | China               | NGFS2024GCAM_FW                 | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | China               | NGFS2024GCAM_FW                 | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | China               | NGFS2024GCAM_FW                 | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | China               | NGFS2024GCAM_FW                 | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | Global              | NGFS2024GCAM_FW                 | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | Global              | NGFS2024GCAM_FW                 | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | Global              | NGFS2024GCAM_FW                 | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | Global              | NGFS2024GCAM_FW                 | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | India               | NGFS2024GCAM_FW                 | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | India               | NGFS2024GCAM_FW                 | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | India               | NGFS2024GCAM_FW                 | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | India               | NGFS2024GCAM_FW                 | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | Indonesia           | NGFS2024GCAM_FW                 | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | Indonesia           | NGFS2024GCAM_FW                 | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | Indonesia           | NGFS2024GCAM_FW                 | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | Indonesia           | NGFS2024GCAM_FW                 | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | LatinAmerica        | NGFS2024GCAM_FW                 | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | LatinAmerica        | NGFS2024GCAM_FW                 | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | LatinAmerica        | NGFS2024GCAM_FW                 | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | LatinAmerica        | NGFS2024GCAM_FW                 | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | MiddleEastAndAfrica | NGFS2024GCAM_FW                 | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | MiddleEastAndAfrica | NGFS2024GCAM_FW                 | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | MiddleEastAndAfrica | NGFS2024GCAM_FW                 | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | MiddleEastAndAfrica | NGFS2024GCAM_FW                 | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | OecdAndEu           | NGFS2024GCAM_FW                 | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | OecdAndEu           | NGFS2024GCAM_FW                 | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | OecdAndEu           | NGFS2024GCAM_FW                 | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | OecdAndEu           | NGFS2024GCAM_FW                 | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | ReformingEconomies  | NGFS2024GCAM_FW                 | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | ReformingEconomies  | NGFS2024GCAM_FW                 | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | ReformingEconomies  | NGFS2024GCAM_FW                 | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | ReformingEconomies  | NGFS2024GCAM_FW                 | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | SoutheastAsia       | NGFS2024GCAM_FW                 | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | SoutheastAsia       | NGFS2024GCAM_FW                 | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | SoutheastAsia       | NGFS2024GCAM_FW                 | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | SoutheastAsia       | NGFS2024GCAM_FW                 | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | UnitedStates        | NGFS2024GCAM_FW                 | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | UnitedStates        | NGFS2024GCAM_FW                 | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | UnitedStates        | NGFS2024GCAM_FW                 | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | UnitedStates        | NGFS2024GCAM_FW                 | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | Asia                | NGFS2024GCAM_NDC                | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | Asia                | NGFS2024GCAM_NDC                | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | Asia                | NGFS2024GCAM_NDC                | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | Asia                | NGFS2024GCAM_NDC                | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | China               | NGFS2024GCAM_NDC                | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | China               | NGFS2024GCAM_NDC                | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | China               | NGFS2024GCAM_NDC                | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | China               | NGFS2024GCAM_NDC                | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | Global              | NGFS2024GCAM_NDC                | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | Global              | NGFS2024GCAM_NDC                | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | Global              | NGFS2024GCAM_NDC                | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | Global              | NGFS2024GCAM_NDC                | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | India               | NGFS2024GCAM_NDC                | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | India               | NGFS2024GCAM_NDC                | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | India               | NGFS2024GCAM_NDC                | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | India               | NGFS2024GCAM_NDC                | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | Indonesia           | NGFS2024GCAM_NDC                | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | Indonesia           | NGFS2024GCAM_NDC                | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | Indonesia           | NGFS2024GCAM_NDC                | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | Indonesia           | NGFS2024GCAM_NDC                | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | LatinAmerica        | NGFS2024GCAM_NDC                | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | LatinAmerica        | NGFS2024GCAM_NDC                | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | LatinAmerica        | NGFS2024GCAM_NDC                | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | LatinAmerica        | NGFS2024GCAM_NDC                | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | MiddleEastAndAfrica | NGFS2024GCAM_NDC                | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | MiddleEastAndAfrica | NGFS2024GCAM_NDC                | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | MiddleEastAndAfrica | NGFS2024GCAM_NDC                | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | MiddleEastAndAfrica | NGFS2024GCAM_NDC                | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | OecdAndEu           | NGFS2024GCAM_NDC                | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | OecdAndEu           | NGFS2024GCAM_NDC                | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | OecdAndEu           | NGFS2024GCAM_NDC                | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | OecdAndEu           | NGFS2024GCAM_NDC                | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | ReformingEconomies  | NGFS2024GCAM_NDC                | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | ReformingEconomies  | NGFS2024GCAM_NDC                | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | ReformingEconomies  | NGFS2024GCAM_NDC                | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | ReformingEconomies  | NGFS2024GCAM_NDC                | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | SoutheastAsia       | NGFS2024GCAM_NDC                | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | SoutheastAsia       | NGFS2024GCAM_NDC                | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | SoutheastAsia       | NGFS2024GCAM_NDC                | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | SoutheastAsia       | NGFS2024GCAM_NDC                | NGFS2024GCAM_NZ2050       |
| NGFS2024GCAM      | UnitedStates        | NGFS2024GCAM_NDC                | NGFS2024GCAM_B2DS         |
| NGFS2024GCAM      | UnitedStates        | NGFS2024GCAM_NDC                | NGFS2024GCAM_DT           |
| NGFS2024GCAM      | UnitedStates        | NGFS2024GCAM_NDC                | NGFS2024GCAM_LD           |
| NGFS2024GCAM      | UnitedStates        | NGFS2024GCAM_NDC                | NGFS2024GCAM_NZ2050       |
| NGFS2024MESSAGE   | Asia                | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_B2DS      |
| NGFS2024MESSAGE   | Asia                | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_DT        |
| NGFS2024MESSAGE   | Asia                | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_LD        |
| NGFS2024MESSAGE   | Asia                | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_NZ2050    |
| NGFS2024MESSAGE   | China               | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_B2DS      |
| NGFS2024MESSAGE   | China               | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_DT        |
| NGFS2024MESSAGE   | China               | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_LD        |
| NGFS2024MESSAGE   | China               | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_NZ2050    |
| NGFS2024MESSAGE   | Global              | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_B2DS      |
| NGFS2024MESSAGE   | Global              | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_DT        |
| NGFS2024MESSAGE   | Global              | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_LD        |
| NGFS2024MESSAGE   | Global              | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_NZ2050    |
| NGFS2024MESSAGE   | LatinAmerica        | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_B2DS      |
| NGFS2024MESSAGE   | LatinAmerica        | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_DT        |
| NGFS2024MESSAGE   | LatinAmerica        | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_LD        |
| NGFS2024MESSAGE   | LatinAmerica        | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_NZ2050    |
| NGFS2024MESSAGE   | MiddleEastAndAfrica | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_B2DS      |
| NGFS2024MESSAGE   | MiddleEastAndAfrica | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_DT        |
| NGFS2024MESSAGE   | MiddleEastAndAfrica | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_LD        |
| NGFS2024MESSAGE   | MiddleEastAndAfrica | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_NZ2050    |
| NGFS2024MESSAGE   | OecdAndEu           | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_B2DS      |
| NGFS2024MESSAGE   | OecdAndEu           | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_DT        |
| NGFS2024MESSAGE   | OecdAndEu           | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_LD        |
| NGFS2024MESSAGE   | OecdAndEu           | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_NZ2050    |
| NGFS2024MESSAGE   | ReformingEconomies  | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_B2DS      |
| NGFS2024MESSAGE   | ReformingEconomies  | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_DT        |
| NGFS2024MESSAGE   | ReformingEconomies  | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_LD        |
| NGFS2024MESSAGE   | ReformingEconomies  | NGFS2024MESSAGE_CP              | NGFS2024MESSAGE_NZ2050    |
| NGFS2024MESSAGE   | Asia                | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_B2DS      |
| NGFS2024MESSAGE   | Asia                | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_DT        |
| NGFS2024MESSAGE   | Asia                | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_LD        |
| NGFS2024MESSAGE   | Asia                | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_NZ2050    |
| NGFS2024MESSAGE   | China               | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_B2DS      |
| NGFS2024MESSAGE   | China               | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_DT        |
| NGFS2024MESSAGE   | China               | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_LD        |
| NGFS2024MESSAGE   | China               | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_NZ2050    |
| NGFS2024MESSAGE   | Global              | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_B2DS      |
| NGFS2024MESSAGE   | Global              | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_DT        |
| NGFS2024MESSAGE   | Global              | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_LD        |
| NGFS2024MESSAGE   | Global              | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_NZ2050    |
| NGFS2024MESSAGE   | LatinAmerica        | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_B2DS      |
| NGFS2024MESSAGE   | LatinAmerica        | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_DT        |
| NGFS2024MESSAGE   | LatinAmerica        | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_LD        |
| NGFS2024MESSAGE   | LatinAmerica        | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_NZ2050    |
| NGFS2024MESSAGE   | MiddleEastAndAfrica | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_B2DS      |
| NGFS2024MESSAGE   | MiddleEastAndAfrica | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_DT        |
| NGFS2024MESSAGE   | MiddleEastAndAfrica | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_LD        |
| NGFS2024MESSAGE   | MiddleEastAndAfrica | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_NZ2050    |
| NGFS2024MESSAGE   | OecdAndEu           | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_B2DS      |
| NGFS2024MESSAGE   | OecdAndEu           | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_DT        |
| NGFS2024MESSAGE   | OecdAndEu           | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_LD        |
| NGFS2024MESSAGE   | OecdAndEu           | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_NZ2050    |
| NGFS2024MESSAGE   | ReformingEconomies  | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_B2DS      |
| NGFS2024MESSAGE   | ReformingEconomies  | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_DT        |
| NGFS2024MESSAGE   | ReformingEconomies  | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_LD        |
| NGFS2024MESSAGE   | ReformingEconomies  | NGFS2024MESSAGE_FW              | NGFS2024MESSAGE_NZ2050    |
| NGFS2024MESSAGE   | Asia                | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_B2DS      |
| NGFS2024MESSAGE   | Asia                | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_DT        |
| NGFS2024MESSAGE   | Asia                | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_LD        |
| NGFS2024MESSAGE   | Asia                | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_NZ2050    |
| NGFS2024MESSAGE   | China               | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_B2DS      |
| NGFS2024MESSAGE   | China               | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_DT        |
| NGFS2024MESSAGE   | China               | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_LD        |
| NGFS2024MESSAGE   | China               | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_NZ2050    |
| NGFS2024MESSAGE   | Global              | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_B2DS      |
| NGFS2024MESSAGE   | Global              | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_DT        |
| NGFS2024MESSAGE   | Global              | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_LD        |
| NGFS2024MESSAGE   | Global              | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_NZ2050    |
| NGFS2024MESSAGE   | LatinAmerica        | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_B2DS      |
| NGFS2024MESSAGE   | LatinAmerica        | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_DT        |
| NGFS2024MESSAGE   | LatinAmerica        | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_LD        |
| NGFS2024MESSAGE   | LatinAmerica        | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_NZ2050    |
| NGFS2024MESSAGE   | MiddleEastAndAfrica | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_B2DS      |
| NGFS2024MESSAGE   | MiddleEastAndAfrica | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_DT        |
| NGFS2024MESSAGE   | MiddleEastAndAfrica | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_LD        |
| NGFS2024MESSAGE   | MiddleEastAndAfrica | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_NZ2050    |
| NGFS2024MESSAGE   | OecdAndEu           | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_B2DS      |
| NGFS2024MESSAGE   | OecdAndEu           | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_DT        |
| NGFS2024MESSAGE   | OecdAndEu           | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_LD        |
| NGFS2024MESSAGE   | OecdAndEu           | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_NZ2050    |
| NGFS2024MESSAGE   | ReformingEconomies  | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_B2DS      |
| NGFS2024MESSAGE   | ReformingEconomies  | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_DT        |
| NGFS2024MESSAGE   | ReformingEconomies  | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_LD        |
| NGFS2024MESSAGE   | ReformingEconomies  | NGFS2024MESSAGE_NDC             | NGFS2024MESSAGE_NZ2050    |
| NGFS2024REMIND    | Asia                | NGFS2024REMIND_CP               | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | Asia                | NGFS2024REMIND_CP               | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | Asia                | NGFS2024REMIND_CP               | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | Asia                | NGFS2024REMIND_CP               | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | China               | NGFS2024REMIND_CP               | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | China               | NGFS2024REMIND_CP               | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | China               | NGFS2024REMIND_CP               | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | China               | NGFS2024REMIND_CP               | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | Global              | NGFS2024REMIND_CP               | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | Global              | NGFS2024REMIND_CP               | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | Global              | NGFS2024REMIND_CP               | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | Global              | NGFS2024REMIND_CP               | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | India               | NGFS2024REMIND_CP               | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | India               | NGFS2024REMIND_CP               | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | India               | NGFS2024REMIND_CP               | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | India               | NGFS2024REMIND_CP               | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | LatinAmerica        | NGFS2024REMIND_CP               | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | LatinAmerica        | NGFS2024REMIND_CP               | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | LatinAmerica        | NGFS2024REMIND_CP               | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | LatinAmerica        | NGFS2024REMIND_CP               | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | MiddleEastAndAfrica | NGFS2024REMIND_CP               | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | MiddleEastAndAfrica | NGFS2024REMIND_CP               | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | MiddleEastAndAfrica | NGFS2024REMIND_CP               | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | MiddleEastAndAfrica | NGFS2024REMIND_CP               | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | OecdAndEu           | NGFS2024REMIND_CP               | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | OecdAndEu           | NGFS2024REMIND_CP               | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | OecdAndEu           | NGFS2024REMIND_CP               | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | OecdAndEu           | NGFS2024REMIND_CP               | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | ReformingEconomies  | NGFS2024REMIND_CP               | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | ReformingEconomies  | NGFS2024REMIND_CP               | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | ReformingEconomies  | NGFS2024REMIND_CP               | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | ReformingEconomies  | NGFS2024REMIND_CP               | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | UnitedStates        | NGFS2024REMIND_CP               | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | UnitedStates        | NGFS2024REMIND_CP               | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | UnitedStates        | NGFS2024REMIND_CP               | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | UnitedStates        | NGFS2024REMIND_CP               | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | Asia                | NGFS2024REMIND_FW               | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | Asia                | NGFS2024REMIND_FW               | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | Asia                | NGFS2024REMIND_FW               | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | Asia                | NGFS2024REMIND_FW               | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | China               | NGFS2024REMIND_FW               | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | China               | NGFS2024REMIND_FW               | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | China               | NGFS2024REMIND_FW               | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | China               | NGFS2024REMIND_FW               | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | Global              | NGFS2024REMIND_FW               | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | Global              | NGFS2024REMIND_FW               | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | Global              | NGFS2024REMIND_FW               | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | Global              | NGFS2024REMIND_FW               | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | India               | NGFS2024REMIND_FW               | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | India               | NGFS2024REMIND_FW               | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | India               | NGFS2024REMIND_FW               | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | India               | NGFS2024REMIND_FW               | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | LatinAmerica        | NGFS2024REMIND_FW               | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | LatinAmerica        | NGFS2024REMIND_FW               | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | LatinAmerica        | NGFS2024REMIND_FW               | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | LatinAmerica        | NGFS2024REMIND_FW               | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | MiddleEastAndAfrica | NGFS2024REMIND_FW               | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | MiddleEastAndAfrica | NGFS2024REMIND_FW               | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | MiddleEastAndAfrica | NGFS2024REMIND_FW               | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | MiddleEastAndAfrica | NGFS2024REMIND_FW               | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | OecdAndEu           | NGFS2024REMIND_FW               | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | OecdAndEu           | NGFS2024REMIND_FW               | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | OecdAndEu           | NGFS2024REMIND_FW               | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | OecdAndEu           | NGFS2024REMIND_FW               | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | ReformingEconomies  | NGFS2024REMIND_FW               | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | ReformingEconomies  | NGFS2024REMIND_FW               | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | ReformingEconomies  | NGFS2024REMIND_FW               | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | ReformingEconomies  | NGFS2024REMIND_FW               | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | UnitedStates        | NGFS2024REMIND_FW               | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | UnitedStates        | NGFS2024REMIND_FW               | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | UnitedStates        | NGFS2024REMIND_FW               | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | UnitedStates        | NGFS2024REMIND_FW               | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | Asia                | NGFS2024REMIND_NDC              | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | Asia                | NGFS2024REMIND_NDC              | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | Asia                | NGFS2024REMIND_NDC              | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | Asia                | NGFS2024REMIND_NDC              | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | China               | NGFS2024REMIND_NDC              | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | China               | NGFS2024REMIND_NDC              | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | China               | NGFS2024REMIND_NDC              | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | China               | NGFS2024REMIND_NDC              | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | Global              | NGFS2024REMIND_NDC              | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | Global              | NGFS2024REMIND_NDC              | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | Global              | NGFS2024REMIND_NDC              | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | Global              | NGFS2024REMIND_NDC              | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | India               | NGFS2024REMIND_NDC              | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | India               | NGFS2024REMIND_NDC              | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | India               | NGFS2024REMIND_NDC              | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | India               | NGFS2024REMIND_NDC              | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | LatinAmerica        | NGFS2024REMIND_NDC              | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | LatinAmerica        | NGFS2024REMIND_NDC              | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | LatinAmerica        | NGFS2024REMIND_NDC              | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | LatinAmerica        | NGFS2024REMIND_NDC              | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | MiddleEastAndAfrica | NGFS2024REMIND_NDC              | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | MiddleEastAndAfrica | NGFS2024REMIND_NDC              | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | MiddleEastAndAfrica | NGFS2024REMIND_NDC              | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | MiddleEastAndAfrica | NGFS2024REMIND_NDC              | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | OecdAndEu           | NGFS2024REMIND_NDC              | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | OecdAndEu           | NGFS2024REMIND_NDC              | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | OecdAndEu           | NGFS2024REMIND_NDC              | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | OecdAndEu           | NGFS2024REMIND_NDC              | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | ReformingEconomies  | NGFS2024REMIND_NDC              | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | ReformingEconomies  | NGFS2024REMIND_NDC              | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | ReformingEconomies  | NGFS2024REMIND_NDC              | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | ReformingEconomies  | NGFS2024REMIND_NDC              | NGFS2024REMIND_NZ2050     |
| NGFS2024REMIND    | UnitedStates        | NGFS2024REMIND_NDC              | NGFS2024REMIND_B2DS       |
| NGFS2024REMIND    | UnitedStates        | NGFS2024REMIND_NDC              | NGFS2024REMIND_DT         |
| NGFS2024REMIND    | UnitedStates        | NGFS2024REMIND_NDC              | NGFS2024REMIND_LD         |
| NGFS2024REMIND    | UnitedStates        | NGFS2024REMIND_NDC              | NGFS2024REMIND_NZ2050     |

This table breaks down the different options for the scenarios we
discussed earlier. The first column again shows the scenario provider
and the vintage (year). The “scenario_geography” column captures the
regional detail available within each scenario provider.

Next, you’ll see “baseline_scenario” and “target_scenario.” These two
columns separate scenarios into baseline—status quo scenarios—and target
scenarios—ambitious scenarios aiming to achieve specific goals. For
example, the IEA STEPS scenario we discussed earlier is a baseline
scenario, while the NetZero2050 scenario is a target scenario.

The table also shows how scenarios can be combined in our stress test.
It’s important to note that a general rule is to select a baseline and
target scenario from the same provider.

If you’re choosing a specific scenario for your analysis, here are some
factors to consider:

1.  Data vintage: Some scenarios aren’t updated as frequently, while
    others provide more recent data that may be more relevant for your
    analysis.

2.  Geography options: Not all scenarios offer detailed regional
    choices. If you need more than just a global view, some scenarios
    (like the NGFSGCAM scenarios) provide better options for focusing
    the stress test on a specific region or country.

3.  Type of target scenario: There are various target scenarios
    available. Some providers only have one, while others offer
    multiple. For example, NGFS provides both B2DS (Below 2°C) and
    NZ2050 (Net Zero 2050) scenarios, which both aim to limit global
    warming, but with different levels of ambition.

4.  Different scenario narratives: Most of the scenarios are very
    straight forward and can be categorized into business as usual
    scenarios or target scenarios. However, some scenarios, especially
    from NGFS, have slightly different narratives. For instance, the
    NGFS “LD” (Low Demand) scenario also aims for net zero and limits
    global temperature rise, but it’s based not just on strict climate
    policies (like B2DS or NZ2050) but on assumptions of rapidly
    declining energy demand. These scenarios are useful for specific
    analyses, but it’s worth familiarizing yourself with the different
    narratives. For NGFS scenarios, you can read more about them on
    their website: <https://www.ngfs.net/en>

## Run Trisk on a geography

When choosing a geography different than “Global”, the input assets
dataframe is filtered on the geography’s countries, and the scenarios is
filtered to use the pathways defined in this geography. This means that
only the assets located in the countries covered by this geography will
be considered for analysis, on geography-specific pathways.

``` r
if (!is_CRAN) {
  assets_data <- read.csv(system.file("testdata", "assets_testdata.csv", package = "trisk.model"))
  scenarios_data <- read.csv(file.path(trisk_inputs_folder, "scenarios.csv"))
  financial_features_data <- read.csv(system.file("testdata", "financial_features_testdata.csv", package = "trisk.model"))
  ngfs_carbon_price_data <- read.csv(system.file("testdata", "ngfs_carbon_price_testdata.csv", package = "trisk.model"))
  
  assets_data <- assets_data %>% dplyr::filter(.data$production_year >= min(scenarios_data$scenario_year))
  }
```

``` r
baseline_scenario <- "NGFS2024GCAM_CP"
target_scenario <- "NGFS2024GCAM_NZ2050"
scenario_geography <- "Global" # CHANGE GEOGRAPHY
```

``` r
if (!is_CRAN) {
  st_results <- run_trisk_model(
    assets_data = assets_data,
    scenarios_data = scenarios_data,
    financial_data = financial_features_data,
    carbon_data = ngfs_carbon_price_data,
    baseline_scenario = baseline_scenario,
    target_scenario = target_scenario,
    scenario_geography = scenario_geography
  )
}
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

| run_id                               | company_id | asset_id | company_name | asset_name | sector  | technology    | country_iso2 | net_present_value_baseline | net_present_value_shock | net_present_value_difference | net_present_value_change |
|:-------------------------------------|:-----------|:---------|:-------------|:-----------|:--------|:--------------|:-------------|---------------------------:|------------------------:|-----------------------------:|-------------------------:|
| e9e899c9-fd04-4618-86c2-183b4e4ace72 | 101        | 101      | Company 1    | Company 1  | Oil&Gas | Gas           | DE           |                   170552.1 |            1.435333e+04 |                    -156198.8 |               -0.9158420 |
| e9e899c9-fd04-4618-86c2-183b4e4ace72 | 102        | 102      | Company 2    | Company 2  | Coal    | Coal          | DE           |                 40752136.0 |            4.444817e+06 |                  -36307319.5 |               -0.8909305 |
| e9e899c9-fd04-4618-86c2-183b4e4ace72 | 103        | 103      | Company 3    | Company 3  | Oil&Gas | Gas           | DE           |                 90346782.8 |            1.417870e+07 |                  -76168083.6 |               -0.8430636 |
| e9e899c9-fd04-4618-86c2-183b4e4ace72 | 104        | 104      | Company 4    | Company 4  | Power   | RenewablesCap | DE           |               971773152\.9 |            1.341067e+09 |                 369293854\.6 |                0.3800206 |
| e9e899c9-fd04-4618-86c2-183b4e4ace72 | 105        | 105      | Company 5    | Company 5  | Power   | CoalCap       | DE           |               183696970\.9 |            1.399611e+07 |                 -169700860.1 |               -0.9238087 |
| e9e899c9-fd04-4618-86c2-183b4e4ace72 | 105        | 105      | Company 5    | Company 5  | Power   | OilCap        | DE           |                 29258901.9 |            1.811617e+06 |                  -27447285.1 |               -0.9380832 |
| e9e899c9-fd04-4618-86c2-183b4e4ace72 | 105        | 105      | Company 5    | Company 5  | Power   | RenewablesCap | DE           |               169753857\.8 |            4.111428e+08 |                 241388980\.8 |                1.4219941 |

## Run Trisk with carbon tax

``` r
if (!is_CRAN) {
  available_carbon_taxes <- ngfs_carbon_price_data %>%
    distinct(model)
  print(available_carbon_taxes)
}
#>                                  model
#> 1                       GCAM 5.3+ NGFS
#> 2                   flat_carbon_tax_50
#> 3             increasing_carbon_tax_50
#> 4 independent_increasing_carbon_tax_50
#> 5                        no_carbon_tax
```

This table shows the different carbon tax options you can choose from. A
carbon tax is an additional mechanism that can be applied to company
profits, based on their CO2 emissions from production.

We’ve implemented one carbon tax rate from the NGFS GCAM scenario, along
with a few others that follow a more straightforward approach. For
example, “flat_carbon_tax_50” is a tax of \$50 per ton of CO2 that
remains constant over time. “independent_increasing_carbon_tax_50” is a
tax that starts at \$50 per ton in 2025 and then increases
exponentially.

These carbon prices are designed to illustrate the amplification effect
a carbon tax can have on outcomes. If you’d prefer different assumptions
for the carbon tax trajectory, there’s always the option to include your
own in the model.

It is then possible to choose a carbon tax and a passthrough, to adjust
its impact on NPV:

``` r
carbon_price_model <- "GCAM 5.3+ NGFS"
market_passthrough <- 0.3
```

``` r
if (!is_CRAN) {
  st_results <- run_trisk_model(
    assets_data = assets_data,
    scenarios_data = scenarios_data,
    financial_data = financial_features_data,
    carbon_data = ngfs_carbon_price_data,
    baseline_scenario = baseline_scenario,
    target_scenario = target_scenario,
    scenario_geography = scenario_geography,
    carbon_price_model = carbon_price_model,
    market_passthrough = market_passthrough
  )
}
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
