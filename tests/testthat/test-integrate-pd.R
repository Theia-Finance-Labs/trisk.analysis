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
