# Final-review follow-up — lock the run_trisk_model output contract
# (npv_results / pd_results) used by run_trisk_agg() and run_trisk_sa(), so the
# code does not silently rely on R's $ partial matching.

testthat::skip_if_not_installed("trisk.model")

trisk_inputs <- function() {
  d <- system.file("testdata", package = "trisk.model")
  list(
    A = read.csv(file.path(d, "assets_testdata.csv")),
    S = read.csv(file.path(d, "scenarios_testdata.csv")),
    F = read.csv(file.path(d, "financial_features_testdata.csv")),
    C = read.csv(file.path(d, "ngfs_carbon_price_testdata.csv"))
  )
}

test_that("run_trisk_agg returns populated npv_results / pd_results", {
  i <- trisk_inputs()
  agg <- run_trisk_agg(
    i$A, i$S, i$F, i$C,
    baseline_scenario = "NGFS2023GCAM_CP", target_scenario = "NGFS2023GCAM_NZ2050",
    scenario_geography = "Global"
  )
  expect_gt(nrow(agg$npv_results), 0)
  expect_gt(nrow(agg$pd_results), 0)
})

test_that("run_trisk_sa returns populated npv / pd across runs", {
  i <- trisk_inputs()
  sa <- run_trisk_sa(
    i$A, i$S, i$F, i$C,
    run_params = list(list(
      baseline_scenario = "NGFS2023GCAM_CP",
      target_scenario = "NGFS2023GCAM_NZ2050",
      scenario_geography = "Global"
    ))
  )
  expect_gt(nrow(sa$npv), 0)
  expect_gt(nrow(sa$pd), 0)
  expect_equal(nrow(sa$params), 1L)
})
