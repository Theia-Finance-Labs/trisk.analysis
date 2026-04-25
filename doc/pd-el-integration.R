## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## ----setup--------------------------------------------------------------------
library(trisk.analysis)
library(magrittr)

## -----------------------------------------------------------------------------
assets_testdata    <- read.csv(system.file("testdata", "assets_testdata.csv",    package = "trisk.model"))
scenarios_testdata <- read.csv(system.file("testdata", "scenarios_testdata.csv", package = "trisk.model"))
fin_testdata       <- read.csv(system.file("testdata", "financial_features_testdata.csv", package = "trisk.model"))
carbon_testdata    <- read.csv(system.file("testdata", "ngfs_carbon_price_testdata.csv", package = "trisk.model"))
portfolio_testdata <- read.csv(system.file("testdata", "portfolio_ids_testdata.csv", package = "trisk.analysis"))

## -----------------------------------------------------------------------------
analysis_data <- run_trisk_on_portfolio(
  assets_data       = assets_testdata,
  scenarios_data    = scenarios_testdata,
  financial_data    = fin_testdata,
  carbon_data       = carbon_testdata,
  portfolio_data    = portfolio_testdata,
  baseline_scenario = "NGFS2023GCAM_CP",
  target_scenario   = "NGFS2023GCAM_NZ2050"
)

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(head(analysis_data[, c("company_id", "sector", "technology", "term",
                                    "pd_baseline", "pd_shock",
                                    "net_present_value_baseline", "net_present_value_shock")])) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "100%", height = "300px")

## -----------------------------------------------------------------------------
result_abs <- integrate_pd(analysis_data, method = "absolute")

## ----echo=FALSE---------------------------------------------------------------
knitr::kable(head(result_abs$portfolio[, c("company_id", "sector", "internal_pd",
                                           "pd_baseline", "pd_shock",
                                           "trisk_adjusted_pd", "pd_adjustment")])) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "100%", height = "300px")

## -----------------------------------------------------------------------------
result_rel <- integrate_pd(analysis_data, method = "relative")

## -----------------------------------------------------------------------------
result_zs <- integrate_pd(analysis_data, method = "zscore")

## -----------------------------------------------------------------------------
flat_internal <- rep(0.03, nrow(analysis_data))
result_custom <- integrate_pd(analysis_data,
                              internal_pd = flat_internal,
                              method      = "zscore")

## ----fig.width=7, fig.height=4------------------------------------------------
pipeline_crispy_pd_method_comparison(analysis_data)

## ----fig.width=7, fig.height=4------------------------------------------------
pipeline_crispy_pd_integration_bars(result_zs)

## -----------------------------------------------------------------------------
analysis_data_el <- trisk.analysis:::compute_analysis_metrics(analysis_data)
result_el <- integrate_el(analysis_data_el, method = "relative")

## ----fig.width=7, fig.height=4------------------------------------------------
pipeline_crispy_el_adjustment_bars(result_el)

## -----------------------------------------------------------------------------
pipeline_crispy_pd_kpi_table(result_zs$aggregate)

## -----------------------------------------------------------------------------
pipeline_crispy_el_kpi_table(result_el$aggregate)

## -----------------------------------------------------------------------------
pipeline_crispy_el_sector_breakdown_table(result_el$portfolio)

