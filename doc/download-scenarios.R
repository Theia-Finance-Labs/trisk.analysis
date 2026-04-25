## ----include = FALSE----------------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
is_CRAN <- !identical(Sys.getenv("NOT_CRAN"), "true")

## ----setup--------------------------------------------------------------------
library(trisk.analysis)
library(dplyr)
library(fs)

## -----------------------------------------------------------------------------
print(
  paste0(trisk.analysis:::TRISK_DATA_INPUT_ENDPOINT, "/", trisk.analysis:::TRISK_DATA_S3_PREFIX)
)

## -----------------------------------------------------------------------------
trisk_inputs_folder <- file.path(".", "trisk_inputs")

## -----------------------------------------------------------------------------
if (!is_CRAN) {
  download_success <- download_trisk_inputs(local_save_folder = trisk_inputs_folder, skip_confirmation = TRUE)
}

## ----echo=FALSE---------------------------------------------------------------
if (!is_CRAN) {
  dir_tree(trisk_inputs_folder)
}

## -----------------------------------------------------------------------------
if (!is_CRAN) {
  scenarios <- read.csv(file.path(trisk_inputs_folder, "scenarios.csv"))
}

## -----------------------------------------------------------------------------
if (!is_CRAN) {
  scenarios <- read.csv(file.path(trisk_inputs_folder, "scenarios.csv"))
  number_of_scenario_per_sector <- scenarios %>%
    distinct(scenario, sector, technology) %>%
    group_by(sector, technology) %>%
    summarise(n_scenarios = n())
}

## ----echo=FALSE---------------------------------------------------------------
if (!is_CRAN) {
  knitr::kable(number_of_scenario_per_sector) %>%
    kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
    kableExtra::scroll_box(width = "100%", height = "400px")
}

## -----------------------------------------------------------------------------
if (!is_CRAN) {
  sectors_covered_by_scenarios <- scenarios %>%
    distinct(sector, scenario) %>%
    arrange(sector, scenario)
}

## ----echo=FALSE---------------------------------------------------------------
if (!is_CRAN) {
  knitr::kable(sectors_covered_by_scenarios) %>%
    kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
    kableExtra::scroll_box(width = "100%", height = "400px")
}

## -----------------------------------------------------------------------------
if (!is_CRAN) {
  available_parameters <- get_available_parameters(scenarios)
}

## ----echo=FALSE---------------------------------------------------------------
if (!is_CRAN) {
  knitr::kable(available_parameters) %>%
    kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
    kableExtra::scroll_box(width = "100%", height = "400px")
}

## -----------------------------------------------------------------------------
if (!is_CRAN) {
  assets_data <- read.csv(system.file("testdata", "assets_testdata.csv", package = "trisk.model"))
  scenarios_data <- read.csv(file.path(trisk_inputs_folder, "scenarios.csv"))
  financial_features_data <- read.csv(system.file("testdata", "financial_features_testdata.csv", package = "trisk.model"))
  ngfs_carbon_price_data <- read.csv(system.file("testdata", "ngfs_carbon_price_testdata.csv", package = "trisk.model"))
  
  assets_data <- assets_data %>% dplyr::filter(.data$production_year >= min(scenarios_data$scenario_year))
  }

## -----------------------------------------------------------------------------
baseline_scenario <- "NGFS2024GCAM_CP"
target_scenario <- "NGFS2024GCAM_NZ2050"
scenario_geography <- "Global" # CHANGE GEOGRAPHY

## -----------------------------------------------------------------------------
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

## ----echo=FALSE---------------------------------------------------------------
if (!is_CRAN) {
  knitr::kable(st_results$npv_results) %>%
    kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
    kableExtra::scroll_box(width = "100%", height = "400px")
}

## -----------------------------------------------------------------------------
if (!is_CRAN) {
  available_carbon_taxes <- ngfs_carbon_price_data %>%
    distinct(model)
  print(available_carbon_taxes)
}

## -----------------------------------------------------------------------------
carbon_price_model <- "GCAM 5.3+ NGFS"
market_passthrough <- 0.3

## -----------------------------------------------------------------------------
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

