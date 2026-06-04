# Phase 0 (Z1) — failing tests that document the z-score floor-clipping artifact.
# These are RED until the Phase 1 Z1 fix adds a `zscore_clipped_share` diagnostic
# to the integrate_pd()/integrate_el() aggregate. The clip-artifact identity test
# is expected to PASS now (it demonstrates the defect: sub-floor shocks collapse
# to the same answer) and must KEEP passing after the fix — the fix surfaces the
# artifact, it does not change the math at/below the floor.

# analysis_data whose Merton baseline PDs underflow below ZSCORE_FLOOR_DEFAULT (1e-4).
make_subfloor_analysis_data <- function(pd_shock = c(8e-14, 9e-5, 4e-3)) {
  tibble::tibble(
    company_id             = c("A", "B", "C"),
    company_name           = c("Alpha", "Beta", "Gamma"),
    sector                 = c("Coal", "Power", "Power"),
    technology             = c("Coal", "CoalCap", "RenewablesCap"),
    country_iso2           = c("MN", "MN", "MN"),
    term                   = c(1L, 1L, 1L),
    exposure_value_usd     = c(1e6, 1e6, 1e6),
    loss_given_default     = c(0.4, 0.4, 0.4),
    pd_baseline            = c(5e-14, 3e-5, 2e-3),  # rows A,B below the 1e-4 floor
    pd_shock               = pd_shock
  )
}

test_that("Z1: integrate_pd zscore reports the share of rows hitting the clip bound", {
  ad <- make_subfloor_analysis_data()
  res <- integrate_pd(ad, method = "zscore")

  # The aggregate must expose how much of the book is governed by the clip bound
  # rather than the model. RED until the Phase 1 diagnostic is added.
  expect_true("zscore_clipped_share" %in% names(res$aggregate))
  expect_gt(res$aggregate$zscore_clipped_share, 0)
})

test_that("Z1: sub-floor shocks collapse to the same adjusted PD (the artifact)", {
  # Two scenarios identical except row A's shock (both below the 1e-4 floor).
  # Because qnorm() sees the clipped floor in both cases, the adjusted PD is
  # identical -> the model signal on that row is erased. This documents the
  # defect; it should remain true after the fix (the fix warns, it does not
  # change the clipped math).
  res_lo <- integrate_pd(make_subfloor_analysis_data(pd_shock = c(8e-14, 9e-5, 4e-3)),
                         method = "zscore")
  res_hi <- integrate_pd(make_subfloor_analysis_data(pd_shock = c(9e-14, 9e-5, 4e-3)),
                         method = "zscore")

  expect_equal(res_lo$portfolio$trisk_adjusted_pd[1],
               res_hi$portfolio$trisk_adjusted_pd[1])
})
