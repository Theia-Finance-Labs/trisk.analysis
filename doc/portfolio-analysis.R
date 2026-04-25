## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(trisk.analysis)
library(magrittr)

## -----------------------------------------------------------------------------
assets_testdata <- read.csv(system.file("testdata", "assets_testdata.csv", package = "trisk.model", mustWork = TRUE))
scenarios_testdata <- read.csv(system.file("testdata", "scenarios_testdata.csv", package = "trisk.model", mustWork = TRUE))
financial_features_testdata <- read.csv(system.file("testdata", "financial_features_testdata.csv", package = "trisk.model", mustWork = TRUE))
ngfs_carbon_price_testdata <- read.csv(system.file("testdata", "ngfs_carbon_price_testdata.csv", package = "trisk.model", mustWork = TRUE))

## -----------------------------------------------------------------------------
portfolio_countries_testdata <- read.csv(system.file("testdata", "portfolio_countries_testdata.csv", package = "trisk.analysis"))
portfolio_ids_testdata <- read.csv(system.file("testdata", "portfolio_ids_testdata.csv", package = "trisk.analysis"))
portfolio_names_testdata <- read.csv(system.file("testdata", "portfolio_names_testdata.csv", package = "trisk.analysis"))

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(portfolio_countries_testdata) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "200%", height = "400px")

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(portfolio_names_testdata) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "200%", height = "400px")

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(portfolio_ids_testdata) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "200%", height = "400px")

## -----------------------------------------------------------------------------
portfolio_testdata <- portfolio_ids_testdata

## -----------------------------------------------------------------------------
baseline_scenario <- "NGFS2023GCAM_CP"
target_scenario <- "NGFS2023GCAM_NZ2050"
scenario_geography <- "Global"

## -----------------------------------------------------------------------------
analysis_data <- run_trisk_on_portfolio(
  assets_data = assets_testdata,
  scenarios_data = scenarios_testdata,
  financial_data = financial_features_testdata,
  carbon_data = ngfs_carbon_price_testdata,
  portfolio_data = portfolio_testdata,
  baseline_scenario = baseline_scenario,
  target_scenario = target_scenario,
  scenario_geography = scenario_geography
)

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(analysis_data) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "200%", height = "400px")

## -----------------------------------------------------------------------------
pipeline_crispy_npv_change_plot(analysis_data)

## -----------------------------------------------------------------------------
pipeline_crispy_exposure_change_plot(analysis_data)

## -----------------------------------------------------------------------------
pipeline_crispy_pd_term_plot(analysis_data)

## -----------------------------------------------------------------------------
pipeline_crispy_expected_loss_plot(analysis_data)

