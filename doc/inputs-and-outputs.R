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
str(assets_testdata)

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(head(assets_testdata)) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "100%", height = "400px") %>%
  kableExtra::column_spec(1:ncol(assets_testdata), width = "150px")

## -----------------------------------------------------------------------------
str(financial_features_testdata)

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(head(financial_features_testdata)) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "100%", height = "400px")

## -----------------------------------------------------------------------------
str(ngfs_carbon_price_testdata)

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(head(ngfs_carbon_price_testdata)) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "100%", height = "400px")

## -----------------------------------------------------------------------------
str(scenarios_testdata)

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(head(scenarios_testdata, 50)) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "200%", height = "400px")

## -----------------------------------------------------------------------------
baseline_scenario <- "NGFS2023GCAM_CP"
target_scenario <- "NGFS2023GCAM_NZ2050"
scenario_geography <- "Global"
shock_year <- 2030

## -----------------------------------------------------------------------------
carbon_price_model <- "no_carbon_tax"
risk_free_rate <- 0.02
discount_rate <- 0.07
growth_rate <- 0.03
div_netprofit_prop_coef <- 1
shock_year <- 2030
market_passthrough <- 0

## -----------------------------------------------------------------------------
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

## -----------------------------------------------------------------------------
npv_results_agg <- st_results_agg$npv_results
pd_results_agg <- st_results_agg$pd_results
company_trajectories_agg <- st_results_agg$company_trajectories

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(head(as.data.frame(npv_results_agg))) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "100%", height = "400px")

## -----------------------------------------------------------------------------
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

## -----------------------------------------------------------------------------
npv_results <- st_results$npv_results
pd_results <- st_results$pd_results
company_trajectories <- st_results$company_trajectories

## -----------------------------------------------------------------------------
str(npv_results)

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(head(as.data.frame(npv_results))) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "100%", height = "400px")

## -----------------------------------------------------------------------------
str(pd_results)

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(head(as.data.frame(pd_results))) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "100%", height = "400px")

## -----------------------------------------------------------------------------
str(company_trajectories)

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(head(as.data.frame(company_trajectories))) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "100%", height = "400px")

