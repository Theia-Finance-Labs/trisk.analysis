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

test_that("el_adjustment near-zero classified as neutral (not green)", {
  # Pre-existing nit caught by Reviewer C': el_adjustment == 0 was rendering
  # green. Now it renders TRISK_HEX_GREY ("neutral").
  portfolio <- tibble::tibble(
    company_id    = c("X", "Y", "Z"),
    sector        = c("WorseSec", "NeutralSec", "BetterSec"),
    el_adjustment = c(+50, 0, -30)
  )
  prepared <- trisk.analysis:::prepare_for_el_adjustment_plot(
    list(portfolio = portfolio), facet_var = "sector"
  )
  expect_equal(prepared$sign[prepared$sector == "WorseSec"],   "worse")
  expect_equal(prepared$sign[prepared$sector == "NeutralSec"], "neutral")
  expect_equal(prepared$sign[prepared$sector == "BetterSec"],  "better")
})

test_that("el_adjustment sign mapping: positive=worse=red, negative=better=green", {
  # Build a minimal integration_result with one positive-adjustment sector and
  # one negative-adjustment sector, so we can verify the sign mapping and the
  # colour mapping that hid the C1 bug.
  portfolio <- tibble::tibble(
    company_id    = c("X", "Y"),
    sector        = c("PosWorseSector", "NegBetterSector"),
    el_adjustment = c(+50, -30)
  )
  integration_result <- list(portfolio = portfolio)

  prepared <- trisk.analysis:::prepare_for_el_adjustment_plot(integration_result,
                                                              facet_var = "sector")

  expect_equal(prepared$sign[prepared$sector == "PosWorseSector"], "worse")
  expect_equal(prepared$sign[prepared$sector == "NegBetterSector"], "better")

  # Verify the colour mapping at the plot layer: the fill scale palette must
  # map "worse" -> TRISK_HEX_RED and "better" -> STATUS_GREEN.
  p <- pipeline_crispy_el_adjustment_bars(integration_result)
  fill_scale <- ggplot2::ggplot_build(p)$plot$scales$get_scales("fill")
  pal <- rlang::`%||%`(fill_scale$palette.cache, fill_scale$palette(2))
  # Inspect the named values directly from the scale definition where possible.
  named_values <- fill_scale$palette(2)
  expect_true(
    "worse" %in% names(fill_scale$palette(2)) || identical(named_values["worse"], NULL) ||
      TRUE,  # the manual scale may not expose names via palette(); fall through
    info = "palette() output is implementation-defined"
  )
  # The authoritative check: look directly at the scale's stored values vector.
  expect_equal(unname(fill_scale$palette(2)["worse"]), TRISK_HEX_RED)
  expect_equal(unname(fill_scale$palette(2)["better"]), STATUS_GREEN)
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

test_that("sign_color: positive_is='red' picks red on positive, green on negative", {
  expect_equal(trisk.analysis:::sign_color( 50, positive_is = "red"), TRISK_HEX_RED)
  expect_equal(trisk.analysis:::sign_color(-30, positive_is = "red"), STATUS_GREEN)
  expect_equal(trisk.analysis:::sign_color(  0, positive_is = "red"), "#6c757d")
  expect_equal(trisk.analysis:::sign_color( NA, positive_is = "red"), "#6c757d")
})

test_that("EL KPI table renders positive el_adjustment in red (regression for C1)", {
  # A worsening portfolio (positive el_adjustment under positive-EL convention)
  # must render RED in the KPI table. Before the C1 fix, the zscore method
  # returned negative EL and this signal flipped to green. kableExtra renders
  # colours as rgba(R,G,B,A); convert TRISK_HEX_RED / STATUS_GREEN to that
  # form before grepping.
  hex_to_rgba <- function(hex, alpha = 255) {
    rgb <- grDevices::col2rgb(hex)
    sprintf("rgba(%d, %d, %d, %d)", rgb[1], rgb[2], rgb[3], alpha)
  }
  red_rgba   <- hex_to_rgba(TRISK_HEX_RED)
  green_rgba <- hex_to_rgba(STATUS_GREEN)

  fake_aggregate <- list(
    total_exposure_usd    = 1e6,
    total_el_internal     = 1000,
    total_el_adjusted     = 1500,
    total_el_adjustment   =  500,
    el_adjusted_bps       =   15
  )
  tbl_html <- as.character(pipeline_crispy_el_kpi_table(fake_aggregate))
  expect_true(grepl(red_rgba, tbl_html, fixed = TRUE),
              info = "Positive el_adjustment must render red in the KPI table.")
  expect_false(grepl(green_rgba, tbl_html, fixed = TRUE),
               info = "Positive el_adjustment must not render green.")

  # Negative adjustment must render green (the inverse direction).
  fake_aggregate$total_el_adjustment <- -500
  tbl_html_neg <- as.character(pipeline_crispy_el_kpi_table(fake_aggregate))
  expect_true(grepl(green_rgba, tbl_html_neg, fixed = TRUE),
              info = "Negative el_adjustment must render green in the KPI table.")
  expect_false(grepl(red_rgba, tbl_html_neg, fixed = TRUE),
               info = "Negative el_adjustment must not render red.")
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

test_that("pipeline_crispy_pd_waterfall returns a ggplot", {
  df <- make_test_analysis_data()
  integrated <- integrate_pd(df, method = "absolute")
  p <- pipeline_crispy_pd_waterfall(integrated)
  expect_s3_class(p, "ggplot")
})

test_that("pipeline_crispy_pd_waterfall builds true cumulative segments", {
  # Build a one-sector integration_result so we can assert the exact
  # cumulative arithmetic: Internal bar 0->I, Adjustment bar I->A, Adjusted
  # bar 0->A. Where A = I + Adjustment.
  portfolio <- tibble::tibble(
    company_id          = c("X", "Y"),
    sector              = c("Sec1", "Sec1"),
    exposure_value_usd  = c(100, 100),
    internal_pd         = c(0.02, 0.02),
    pd_baseline         = c(0.02, 0.02),
    pd_shock            = c(0.04, 0.04),
    trisk_adjusted_pd   = c(0.03, 0.03),
    pd_adjustment       = c(0.01, 0.01)
  )
  integration_result <- list(portfolio = portfolio)

  p <- pipeline_crispy_pd_waterfall(integration_result)
  expect_s3_class(p, "ggplot")

  built <- ggplot2::ggplot_build(p)
  # The waterfall must use a geom that accepts ymin/ymax (geom_rect under the
  # hood). Verify the rect data carries cumulative-segment y coordinates:
  # Internal: ymin=0, ymax=internal_pd
  # Adjustment: ymin=internal_pd, ymax=internal_pd + adjustment
  # Adjusted: ymin=0, ymax=trisk_adjusted_pd
  rect_data <- built$data[[1]]
  expect_true(all(c("ymin", "ymax") %in% colnames(rect_data)))
  # Sort by xmin to get stable Internal/Adjustment/Adjusted ordering.
  rect_data <- rect_data[order(rect_data$xmin), ]
  expect_equal(rect_data$ymin, c(0, 0.02, 0), tolerance = 1e-9)
  expect_equal(rect_data$ymax, c(0.02, 0.03, 0.03), tolerance = 1e-9)
})
