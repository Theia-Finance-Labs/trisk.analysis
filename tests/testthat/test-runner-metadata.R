# Phase 2 (A1 audit trail, D1 term-outside-grid warning).

test_that("A1: build_trisk_run_meta captures scenarios, run_id, args, versions", {
  m <- build_trisk_run_meta(
    "NGFS_base", "NGFS_targ", run_id = "r1",
    extra_args = list(scenario_geography = "Global", risk_free_rate = 0.045)
  )
  expect_equal(m$baseline_scenario, "NGFS_base")
  expect_equal(m$target_scenario, "NGFS_targ")
  expect_equal(m$run_id, "r1")
  expect_equal(m$trisk_args$scenario_geography, "Global")
  expect_true(all(c("trisk.analysis", "trisk.model") %in% names(m$package_versions)))
  expect_s3_class(m$created_at, "POSIXct")
})

test_that("D1: warn_terms_outside_grid warns and names the dropped (company_id, term)", {
  pf <- tibble::tibble(company_id = c("A", "B"), term = c(1L, 99L))
  pd <- tibble::tibble(company_id = "A", term = c(1L, 2L, 3L), run_id = "r1")
  expect_warning(warn_terms_outside_grid(pf, pd), "term outside the Merton grid")
  expect_warning(warn_terms_outside_grid(pf, pd), "B/term=99")
})

test_that("D1: no warning when all terms are within the grid", {
  pf <- tibble::tibble(company_id = c("A", "B"), term = c(1L, 2L))
  pd <- tibble::tibble(company_id = "A", term = c(1L, 2L, 3L), run_id = "r1")
  expect_no_warning(warn_terms_outside_grid(pf, pd))
})

test_that("X1 guard: duplicate per-technology entry of one company loan warns", {
  pf <- tibble::tibble(
    company_id = c("X", "X"), term = c(3L, 3L),
    technology = c("CoalCap", "OilCap"), exposure_value_usd = c(10, 10)
  )
  expect_warning(warn_duplicate_company_term_exposure(pf), "company-level")
})

test_that("X1 guard: distinct exposures (genuine sub-loans) do not warn", {
  pf <- tibble::tibble(
    company_id = c("X", "X"), term = c(3L, 5L),
    technology = c("CoalCap", "OilCap"), exposure_value_usd = c(10, 20)
  )
  expect_no_warning(warn_duplicate_company_term_exposure(pf))
})

test_that("NM1: warns when baseline and target scenario families differ", {
  expect_warning(
    warn_scenario_family_mismatch("NGFS2023GCAM_CP", "NGFS2024REMIND_NZ2050"),
    "different scenario families"
  )
})

test_that("NM1: no warning when scenario families match (same vintage)", {
  expect_no_warning(
    warn_scenario_family_mismatch("NGFS2023GCAM_CP", "NGFS2023GCAM_NZ2050")
  )
})

test_that("A1: run_trisk_on_portfolio attaches trisk_run_meta to its output", {
  testthat::skip_if_not_installed("trisk.model")
  td <- function(f) read.csv(system.file("testdata", f, package = "trisk.model"))
  ad <- suppressWarnings(run_trisk_on_portfolio(  # deprecated runner; testing the meta attribute, not the warning
    assets_data = td("assets_testdata.csv"),
    scenarios_data = td("scenarios_testdata.csv"),
    financial_data = td("financial_features_testdata.csv"),
    carbon_data = td("ngfs_carbon_price_testdata.csv"),
    portfolio_data = data.frame(
      company_id = 102, company_name = NA, sector = "Coal", technology = "Coal",
      country_iso2 = "DE", exposure_value_usd = 6227364, term = 1,
      loss_given_default = 0.7
    ),
    baseline_scenario = "NGFS2023GCAM_CP",
    target_scenario = "NGFS2023GCAM_NZ2050",
    scenario_geography = "Global"
  ))
  meta <- attr(ad, "trisk_run_meta")
  expect_false(is.null(meta))
  expect_equal(meta$baseline_scenario, "NGFS2023GCAM_CP")
  expect_equal(meta$trisk_args$scenario_geography, "Global")
  expect_true(length(meta$run_id) >= 1)
})
