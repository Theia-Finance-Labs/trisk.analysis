# Phase 4 (Low) — EP1 empty-input guard; R1 zero-baseline no-op warning.

test_that("EP1: get_available_parameters returns an empty tibble on empty input", {
  empty <- tibble::tibble(
    scenario = character(), scenario_type = character(),
    scenario_geography = character(), scenario_provider = character()
  )
  expect_no_error(res <- get_available_parameters(empty))
  expect_s3_class(res, "tbl_df")
  expect_equal(nrow(res), 0L)
})

test_that("R1: integrate_pd 'relative' warns when a baseline PD is zero", {
  df <- make_test_analysis_data()  # company A has pd_baseline == 0
  expect_warning(integrate_pd(df, method = "relative"), "pd_baseline == 0")
})

test_that("R1: integrate_el 'relative' warns when a baseline EL is zero", {
  df <- make_test_analysis_data()  # company A has expected_loss_baseline == 0
  expect_warning(integrate_el(df, method = "relative"), "expected_loss_baseline == 0")
})
