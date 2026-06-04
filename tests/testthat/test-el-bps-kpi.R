# Phase 0 (K1) — failing tests pinning the EL bps headline KPI.
# Decision (2026-06-05): the headline must be the EL *delta* (adjusted - internal),
# divided by *raw exposure* (a true loss rate, LGD*PD in bps), relabelled
# "EL/exposure (bps)". The current code emits only `el_adjusted_bps`, which is the
# adjusted *level* (internal credit risk + climate overlay) -> overstates the
# climate signal ~10x. These tests are RED until the Phase 1 K1 fix adds
# `el_adjustment_bps`.

test_that("K1: aggregate exposes the EL *delta* in bps on raw exposure", {
  df  <- make_test_analysis_data()
  agg <- integrate_el(df, method = "absolute")$aggregate

  # Headline KPI must exist and equal the DELTA over RAW exposure.
  expect_true("el_adjustment_bps" %in% names(agg))
  expect_equal(agg$el_adjustment_bps,
               el_to_bps(agg$total_el_adjustment, agg$total_exposure_usd))
})

test_that("K1: headline delta is materially smaller than the adjusted level", {
  df  <- make_test_analysis_data()
  agg <- integrate_el(df, method = "absolute")$aggregate

  # The delta (climate overlay) and the level (all credit risk) must not be the
  # same number — headlining the level is the ~10x overstatement K1 flags.
  expect_false(isTRUE(all.equal(agg$el_adjustment_bps, agg$el_adjusted_bps)))
})
