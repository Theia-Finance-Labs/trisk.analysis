## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(trisk.analysis)
library(magrittr)

## -----------------------------------------------------------------------------
assets_data <- read.csv(system.file("testdata", "assets_testdata.csv", package = "trisk.model"))
scenarios_data <- read.csv(system.file("testdata", "scenarios_testdata.csv", package = "trisk.model"))
financial_features_data <- read.csv(system.file("testdata", "financial_features_testdata.csv", package = "trisk.model"))
ngfs_carbon_price_data <- read.csv(system.file("testdata", "ngfs_carbon_price_testdata.csv", package = "trisk.model"))

## -----------------------------------------------------------------------------
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

## -----------------------------------------------------------------------------
knitr::kable(head(outputs$npv_results)) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "100%", height = "400px")

## -----------------------------------------------------------------------------
knitr::kable(head(outputs$pd_results)) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "100%", height = "400px")

## -----------------------------------------------------------------------------
knitr::kable(head(outputs$company_trajectories)) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "100%", height = "400px")

