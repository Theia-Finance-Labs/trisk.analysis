test_that("pipeline_crispy_pd_integration_bars returns a ggplot", {
  df <- make_test_analysis_data()
  integrated <- integrate_pd(df, method = "absolute")
  p <- pipeline_crispy_pd_integration_bars(integrated)
  expect_s3_class(p, "ggplot")
})

test_that("pipeline_crispy_el_adjustment_bars returns a ggplot", {
  df <- make_test_analysis_data()
  integrated <- integrate_el(df, method = "absolute")
  p <- pipeline_crispy_el_adjustment_bars(integrated)
  expect_s3_class(p, "ggplot")
})

test_that("pipeline_crispy_pd_kpi_table returns a knitr_kable", {
  df <- make_test_analysis_data()
  integrated <- integrate_pd(df, method = "absolute")
  tbl <- pipeline_crispy_pd_kpi_table(integrated$aggregate)
  expect_s3_class(tbl, "knitr_kable")
})

test_that("pipeline_crispy_el_kpi_table returns a knitr_kable", {
  df <- make_test_analysis_data()
  integrated <- integrate_el(df, method = "absolute")
  tbl <- pipeline_crispy_el_kpi_table(integrated$aggregate)
  expect_s3_class(tbl, "knitr_kable")
})

test_that("pipeline_crispy_el_sector_breakdown_table returns a knitr_kable", {
  df <- make_test_analysis_data()
  integrated <- integrate_el(df, method = "absolute")
  tbl <- pipeline_crispy_el_sector_breakdown_table(integrated$portfolio)
  expect_s3_class(tbl, "knitr_kable")
})

test_that("pipeline_crispy_pd_method_comparison returns a ggplot", {
  df <- make_test_analysis_data()
  p <- pipeline_crispy_pd_method_comparison(df)
  expect_s3_class(p, "ggplot")
})

test_that("pipeline_crispy_pd_method_comparison firm granularity returns a ggplot", {
  df <- make_test_analysis_data()
  p <- pipeline_crispy_pd_method_comparison(df, granularity = "firm")
  expect_s3_class(p, "ggplot")
})

test_that("pipeline_crispy_pd_method_comparison pseudo_log scale returns a ggplot", {
  df <- make_test_analysis_data()
  p <- pipeline_crispy_pd_method_comparison(df, scale = "pseudo_log")
  expect_s3_class(p, "ggplot")
})

test_that("pipeline_crispy_pd_method_comparison firm + pseudo_log returns a ggplot", {
  df <- make_test_analysis_data()
  p <- pipeline_crispy_pd_method_comparison(df, granularity = "firm", scale = "pseudo_log")
  expect_s3_class(p, "ggplot")
})

test_that("pipeline_crispy_pd_method_comparison errors on invalid granularity", {
  df <- make_test_analysis_data()
  expect_error(pipeline_crispy_pd_method_comparison(df, granularity = "bogus"))
})

test_that("pipeline_crispy_pd_method_comparison errors on invalid scale", {
  df <- make_test_analysis_data()
  expect_error(pipeline_crispy_pd_method_comparison(df, scale = "bogus"))
})

test_that("pipeline_crispy_pd_integration_bars firm granularity returns a ggplot", {
  df <- make_test_analysis_data()
  integrated <- integrate_pd(df, method = "absolute")
  p <- pipeline_crispy_pd_integration_bars(integrated, granularity = "firm")
  expect_s3_class(p, "ggplot")
})

test_that("pipeline_crispy_pd_integration_bars pseudo_log scale returns a ggplot", {
  df <- make_test_analysis_data()
  integrated <- integrate_pd(df, method = "absolute")
  p <- pipeline_crispy_pd_integration_bars(integrated, scale = "pseudo_log")
  expect_s3_class(p, "ggplot")
})

test_that("pipeline_crispy_pd_integration_bars firm + pseudo_log returns a ggplot", {
  df <- make_test_analysis_data()
  integrated <- integrate_pd(df, method = "absolute")
  p <- pipeline_crispy_pd_integration_bars(integrated, granularity = "firm", scale = "pseudo_log")
  expect_s3_class(p, "ggplot")
})

test_that("pipeline_crispy_pd_integration_bars errors on invalid granularity", {
  df <- make_test_analysis_data()
  integrated <- integrate_pd(df, method = "absolute")
  expect_error(pipeline_crispy_pd_integration_bars(integrated, granularity = "bogus"))
})

test_that("pipeline_crispy_pd_integration_bars errors on invalid scale", {
  df <- make_test_analysis_data()
  integrated <- integrate_pd(df, method = "absolute")
  expect_error(pipeline_crispy_pd_integration_bars(integrated, scale = "bogus"))
})
