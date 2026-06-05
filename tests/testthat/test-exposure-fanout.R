# Phase 0 (X1) — reproduce the multi-asset exposure fan-out in the full runner.
# Confirmed by the Codex cross-model review: NPV is asset-level, but the portfolio
# join has no asset_id, so a company with >1 asset in one (sector, technology)
# fans a single well-formed loan into N rows and compute_analysis_metrics() then
# applies FULL exposure to each row -> N x EAD/EL, silently.
#
# Bundled trisk.model testdata has exactly 1 asset per company/technology, which
# masks the bug; we synthesise a realistic multi-asset company (a utility with two
# plants of the same technology) to expose it.
#
# These assertions are RED today (measured 2x) and turn GREEN after the Phase 1
# fix (aggregate NPV across asset_id before the portfolio join).

testthat::skip_if_not_installed("trisk.model")

trisk_model_testdata <- function(f) {
  read.csv(system.file("testdata", f, package = "trisk.model"))
}

test_that("X1: a single loan to a multi-asset company does not inflate EAD", {
  assets <- trisk_model_testdata("assets_testdata.csv")
  scen   <- trisk_model_testdata("scenarios_testdata.csv")
  fin    <- trisk_model_testdata("financial_features_testdata.csv")
  carbon <- trisk_model_testdata("ngfs_carbon_price_testdata.csv")

  # Give company 102 a SECOND asset in the same (sector = Coal, technology = Coal).
  a102_second <- assets[assets$company_id == 102, ]
  a102_second$asset_id   <- a102_second$asset_id + 9000L
  a102_second$asset_name <- paste0(a102_second$asset_name, "_B")
  assets_multi <- rbind(assets, a102_second)

  exposure <- 6227364
  lgd      <- 0.7
  port <- data.frame(
    company_id = 102, company_name = NA, sector = "Coal", technology = "Coal",
    country_iso2 = "DE", exposure_value_usd = exposure, term = 1,
    loss_given_default = lgd
  )

  expect_warning(
    full <- run_trisk_on_portfolio(
      assets_data = assets_multi, scenarios_data = scen, financial_data = fin,
      carbon_data = carbon, portfolio_data = port,
      baseline_scenario = "NGFS2023GCAM_CP", target_scenario = "NGFS2023GCAM_NZ2050",
      scenario_geography = "Global"
    ),
    "deprecated"  # full runner is runtime-deprecated; this also asserts the warning fires
  )
  metrics <- compute_analysis_metrics(full)

  # One loan must contribute its exposure exactly once, regardless of asset count.
  # RED today: the loan fans out to 2 rows and EAD doubles to 8,718,310.
  expect_equal(nrow(full), 1L)
  # Basel: exposure_at_default = EAD (the notional), lgd_weighted_exposure = EAD*LGD.
  expect_equal(sum(metrics$exposure_at_default, na.rm = TRUE), exposure)
  expect_equal(sum(metrics$lgd_weighted_exposure, na.rm = TRUE), exposure * lgd)
})

test_that("X1: aggregate_npv_across_assets preserves NA for an all-NA company", {
  # Codex re-review edge: an all-NA NPV group must stay NA, not collapse to 0
  # (which would later divide into NaN/Inf in compute_analysis_metrics).
  npv <- tibble::tibble(
    run_id = "r1",
    company_id = c("A", "A", "B"),
    sector = "Power", technology = "CoalCap", country_iso2 = "DE",
    net_present_value_baseline = c(NA_real_, NA_real_, 100),
    net_present_value_shock    = c(NA_real_, NA_real_, 80)
  )
  agg <- trisk.analysis:::aggregate_npv_across_assets(npv)
  a <- agg[agg$company_id == "A", ]
  b <- agg[agg$company_id == "B", ]
  expect_true(is.na(a$net_present_value_baseline))   # preserved, not 0
  expect_true(is.na(a$net_present_value_shock))
  expect_equal(b$net_present_value_baseline, 100)    # normal sum still works
})

test_that("X1: single-asset (bundled) company already reconciles (guard against over-correction)", {
  assets <- trisk_model_testdata("assets_testdata.csv")
  scen   <- trisk_model_testdata("scenarios_testdata.csv")
  fin    <- trisk_model_testdata("financial_features_testdata.csv")
  carbon <- trisk_model_testdata("ngfs_carbon_price_testdata.csv")

  exposure <- 6227364
  lgd      <- 0.7
  port <- data.frame(
    company_id = 102, company_name = NA, sector = "Coal", technology = "Coal",
    country_iso2 = "DE", exposure_value_usd = exposure, term = 1,
    loss_given_default = lgd
  )

  full <- suppressWarnings(run_trisk_on_portfolio(  # deprecated runner; warning not under test here
    assets_data = assets, scenarios_data = scen, financial_data = fin,
    carbon_data = carbon, portfolio_data = port,
    baseline_scenario = "NGFS2023GCAM_CP", target_scenario = "NGFS2023GCAM_NZ2050",
    scenario_geography = "Global"
  ))
  metrics <- compute_analysis_metrics(full)

  # GREEN now and must stay GREEN after the fix.
  expect_equal(sum(metrics$exposure_at_default, na.rm = TRUE), exposure)
  expect_equal(sum(metrics$lgd_weighted_exposure, na.rm = TRUE), exposure * lgd)

  # Basel identity must hold: EL = EAD * LGD * PD (numerics unchanged by rename).
  expect_equal(
    metrics$expected_loss_baseline,
    metrics$exposure_at_default * metrics$loss_given_default * metrics$pd_baseline
  )
  expect_equal(
    metrics$expected_loss_shock,
    metrics$exposure_at_default * metrics$loss_given_default * metrics$pd_shock
  )
})
