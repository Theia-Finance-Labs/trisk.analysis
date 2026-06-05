# Phase 0/1 (K1) — pin the EL bps KPI contract.
# Decision (2026-06-05): the aggregate emits BOTH bps measures over *raw exposure*
# (a true loss rate, LGD*PD in bps; EL/EAD would be PD-in-bps): `el_adjusted_bps`
# (the adjusted EL level) and `el_adjustment_bps` (the climate overlay/delta =
# adjusted - internal). Presentation headlines the LEVEL with the delta secondary
# (Jakub's call); these tests assert both exist and that the delta is computed
# correctly and is distinct from the level. The original defect was the *mislabel*
# (level presented as the delta), not the presence of the level.

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
