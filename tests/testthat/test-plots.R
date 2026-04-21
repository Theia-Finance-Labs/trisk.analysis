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
