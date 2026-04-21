test_that("aggregate_pd_integration returns EAD-weighted portfolio metrics", {
  df <- make_test_analysis_data()
  integrated <- integrate_pd(df, method = "absolute")
  agg <- aggregate_pd_integration(integrated$portfolio)

  expect_s3_class(agg, "data.frame")
  expect_equal(nrow(agg), 1)
  expect_true(all(c("total_exposure_usd",
                    "weighted_pd_internal",
                    "weighted_pd_baseline",
                    "weighted_pd_shock",
                    "weighted_pd_adjusted",
                    "weighted_pd_adjustment",
                    "weighted_pd_adjustment_pct") %in% colnames(agg)))

  # Total exposure = 100 + 200 + 300 = 600
  expect_equal(agg$total_exposure_usd, 600)

  # Weighted internal PD = (0*100 + 0.02*200 + 0.01*300) / 600 = 7/600
  expect_equal(agg$weighted_pd_internal, (0 * 100 + 0.02 * 200 + 0.01 * 300) / 600)

  # Weighted adjusted PD = (0.05*100 + 0.06*200 + 0.015*300) / 600 = 21.5/600
  expect_equal(agg$weighted_pd_adjusted, (0.05 * 100 + 0.06 * 200 + 0.015 * 300) / 600)
})

test_that("aggregate_pd_integration supports group_cols for sector rollup", {
  df <- make_test_analysis_data()
  integrated <- integrate_pd(df, method = "absolute")
  agg <- aggregate_pd_integration(integrated$portfolio, group_cols = "sector")

  expect_equal(nrow(agg), 2)  # Coal + Power
  expect_true("sector" %in% colnames(agg))
})

test_that("aggregate_pd_integration errors if required columns missing", {
  df <- make_test_analysis_data()
  expect_error(aggregate_pd_integration(df),  # raw df has no internal_pd
               "required columns")
})
