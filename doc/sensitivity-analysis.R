## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(trisk.analysis)
library(magrittr)

## -----------------------------------------------------------------------------
assets_testdata <- read.csv(system.file("testdata", "assets_testdata.csv", package = "trisk.model"))
scenarios_testdata <- read.csv(system.file("testdata", "scenarios_testdata.csv", package = "trisk.model"))
financial_features_testdata <- read.csv(system.file("testdata", "financial_features_testdata.csv", package = "trisk.model"))
ngfs_carbon_price_testdata <- read.csv(system.file("testdata", "ngfs_carbon_price_testdata.csv", package = "trisk.model"))

## -----------------------------------------------------------------------------
run_params <- list(
  list(
    scenario_geography = "Global",
    baseline_scenario = "NGFS2023GCAM_CP",
    target_scenario = "NGFS2023GCAM_NZ2050",
    shock_year = 2030 # SHOCK YEAR 1
  ),
  list(
    scenario_geography = "Global",
    baseline_scenario = "NGFS2023GCAM_CP",
    target_scenario = "NGFS2023GCAM_NZ2050",
    shock_year = 2025 # SHOCK YEAR 2
  )
)

## -----------------------------------------------------------------------------
sensitivity_analysis_results <- run_trisk_sa(
  assets_data = assets_testdata,
  scenarios_data = scenarios_testdata,
  financial_data = financial_features_testdata,
  carbon_data = ngfs_carbon_price_testdata,
  run_params = run_params
)

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(head(sensitivity_analysis_results$npv)) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "100%", height = "400px")

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(head(sensitivity_analysis_results$pd)) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "100%", height = "400px")

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(head(sensitivity_analysis_results$trajectories)) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "100%", height = "400px")

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(head(sensitivity_analysis_results$params)) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "100%", height = "400px")

## -----------------------------------------------------------------------------
plot_multi_trajectories(sensitivity_analysis_results$trajectories)

## -----------------------------------------------------------------------------
# Run sensitivity analysis across multiple TRISK runs
sensitivity_analysis_results <- run_trisk_sa(
  assets_data = assets_testdata,
  scenarios_data = scenarios_testdata,
  financial_data = financial_features_testdata,
  carbon_data = ngfs_carbon_price_testdata,
  run_params = run_params,
  country_iso2 = c("DE") # FILTER ASSETS ON COUNTRIES
)

