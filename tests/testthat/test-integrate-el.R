test_that("integrate_el absolute method computes additive EL shift", {
  df <- make_test_analysis_data()
  result <- integrate_el(df, method = "absolute")

  expect_type(result, "list")
  expect_named(result, c("portfolio", "portfolio_long", "aggregate"))
  # Absolute: adjusted = internal + (shock - baseline)
  # internal defaults to expected_loss_baseline
  # Row A: internal=0, shock-baseline=2, adjusted=2
  # Row B: internal=1.6, shock-baseline=3.2, adjusted=4.8
  # Row C: internal=1.2, shock-baseline=0.6, adjusted=1.8
  expect_equal(result$portfolio$trisk_adjusted_el, c(2.0, 4.8, 1.8))
})

test_that("integrate_el relative method scales by percent change", {
  df <- make_test_analysis_data()
  internal <- c(0.5, 2.0, 1.0)
  result <- integrate_el(df, internal_el = internal, method = "relative")

  # Row A: el_base=0, pct=0, adjusted=internal=0.5
  # Row B: el_base=1.6, pct=(4.8-1.6)/1.6=2.0, adjusted=2.0*3=6.0
  # Row C: el_base=1.2, pct=(1.8-1.2)/1.2=0.5, adjusted=1.0*1.5=1.5
  expect_equal(result$portfolio$trisk_adjusted_el, c(0.5, 6.0, 1.5))
})

test_that("integrate_el errors on unknown method", {
  df <- make_test_analysis_data()
  expect_error(integrate_el(df, method = "zscore"))
})
