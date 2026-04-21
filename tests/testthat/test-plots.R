test_that("pipeline_crispy_pd_integration_bars returns a ggplot", {
  df <- make_test_analysis_data()
  integrated <- integrate_pd(df, method = "absolute")
  p <- pipeline_crispy_pd_integration_bars(integrated)
  expect_s3_class(p, "ggplot")
})
