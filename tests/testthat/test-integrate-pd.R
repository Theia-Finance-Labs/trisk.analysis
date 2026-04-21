test_that("integrate_pd absolute method computes additive shift", {
  df <- make_test_analysis_data()
  result <- integrate_pd(df, method = "absolute")

  expect_type(result, "list")
  expect_named(result, c("portfolio", "portfolio_long", "aggregate"))
  expect_s3_class(result$portfolio, "data.frame")
  expect_equal(nrow(result$portfolio), nrow(df))

  # Absolute: adjusted = internal + (shock - baseline)
  # internal defaults to pd_baseline when NULL
  # Row A: internal=0.00, shock-baseline=0.05 => adjusted=0.05
  # Row B: internal=0.02, shock-baseline=0.04 => adjusted=0.06
  # Row C: internal=0.01, shock-baseline=0.005 => adjusted=0.015
  expect_equal(result$portfolio$trisk_adjusted_pd, c(0.05, 0.06, 0.015))
  expect_equal(result$portfolio$pd_change, c(0.05, 0.04, 0.005))
  expect_equal(result$portfolio$pd_adjustment,
               result$portfolio$trisk_adjusted_pd - result$portfolio$internal_pd)
})

test_that("integrate_pd relative method scales internal PD by percent change", {
  df <- make_test_analysis_data()
  result <- integrate_pd(df, method = "relative")

  # Relative: adjusted = internal * (1 + pd_change_pct)
  # Row A: baseline=0, pd_change_pct=0, adjusted=internal=0
  # Row B: internal=0.02, change_pct=(0.06-0.02)/0.02=2.0, adjusted=0.02*3=0.06
  # Row C: internal=0.01, change_pct=0.5, adjusted=0.015
  expect_equal(result$portfolio$trisk_adjusted_pd, c(0.00, 0.06, 0.015))
})

test_that("integrate_pd relative method preserves internal when pd_baseline is 0", {
  # Documented Shiny-parity quirk: shock signal lost on zero-baseline rows
  df <- make_test_analysis_data()
  internal <- c(0.03, 0.03, 0.03)
  result <- integrate_pd(df, internal_pd = internal, method = "relative")

  # Row A baseline=0 => change_pct=0 => adjusted = internal = 0.03
  expect_equal(result$portfolio$trisk_adjusted_pd[1], 0.03)
  # Rows B, C still get the scaling
  expect_equal(result$portfolio$trisk_adjusted_pd[2], 0.03 * (1 + 2.0))
  expect_equal(result$portfolio$trisk_adjusted_pd[3], 0.03 * (1 + 0.5))
})

test_that("integrate_pd zscore method uses Vasicek combination", {
  df <- make_test_analysis_data()
  internal <- c(0.01, 0.02, 0.01)
  result <- integrate_pd(df, internal_pd = internal, method = "zscore")

  # Manual computation for row B: baseline=0.02, shock=0.06, internal=0.02
  # z_int=qnorm(0.02), z_base=qnorm(0.02), z_shock=qnorm(0.06)
  # adjusted = pnorm(z_int + z_shock - z_base) = pnorm(z_shock) = 0.06
  expect_equal(result$portfolio$trisk_adjusted_pd[2], 0.06, tolerance = 1e-9)

  # All rows must be in [0, 1]
  expect_true(all(result$portfolio$trisk_adjusted_pd >= 0))
  expect_true(all(result$portfolio$trisk_adjusted_pd <= 1))
})

test_that("integrate_pd zscore clips pd_baseline = 0 to zscore_floor", {
  df <- make_test_analysis_data()
  result <- integrate_pd(df, method = "zscore", zscore_floor = 1e-4)

  # pd_baseline = 0 clips to 1e-4 -> qnorm stays finite
  expect_true(is.finite(result$portfolio$trisk_adjusted_pd[1]))
})
