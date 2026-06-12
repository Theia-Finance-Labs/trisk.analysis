test_that("pipeline_trisk_tech_mix returns a ggplot", {
  df <- data.frame(
    sector = c("Power", "Power", "Power", "Coal"),
    technology = c("CoalCap", "OilCap", "RenewablesCap", "Coal"),
    net_present_value_baseline = c(100, 10, 200, 50),
    exposure_at_default = c(60, 5, 40, 30)
  )
  p <- pipeline_trisk_tech_mix(df)
  expect_s3_class(p, "ggplot")
})

test_that("prepare_for_trisk_tech_mix shares are non-negative and sum to 1 per sector", {
  df <- data.frame(
    sector = c("Power", "Power"),
    technology = c("CoalCap", "RenewablesCap"),
    net_present_value_baseline = c(-10, 200), # negative component must be clamped
    exposure_at_default = c(60, 40)
  )
  mix <- prepare_for_trisk_tech_mix(df)
  expect_true(all(mix$`% of NPV value` >= 0))
  expect_equal(sum(mix$`% of NPV value`), 1)
  expect_equal(sum(mix$`% of exposure (EAD)`), 1)
})

test_that("prepare_for_trisk_tech_mix falls back to exposure_value_usd", {
  df <- data.frame(
    sector = "Coal", technology = "Coal",
    net_present_value_baseline = 50, exposure_value_usd = 30
  )
  expect_s3_class(prepare_for_trisk_tech_mix(df), "data.frame")
})

test_that("trisk_sector_shades returns one hex colour per technology", {
  cols <- trisk_sector_shades("Power", c("CoalCap", "OilCap", "RenewablesCap"))
  expect_length(cols, 3)
  expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", cols)))
})

test_that("add_exposure_share_from_npv warns and stays non-negative on negative NPV", {
  pr <- data.frame(
    .portfolio_index = c(1, 1),
    run_id = c("r1", "r1"),
    company_id = c("105", "105"),
    company_name = c("X", "X"),
    term = c(5, 5),
    loss_given_default = c(0.45, 0.45),
    sector = c("Power", "Power"),
    technology = c("CoalCap", "RenewablesCap"),
    net_present_value_baseline = c(-10, 100),
    exposure_value_usd = c(50, 50)
  )
  expect_warning(out <- add_exposure_share_from_npv(pr), "non-positive baseline NPV")
  expect_true(all(out$exposure_value_usd_share >= 0, na.rm = TRUE))
})

test_that("add_exposure_share_from_npv equal-splits an all-non-positive company", {
  pr <- data.frame(
    .portfolio_index = c(1, 1, 1),
    run_id = c("r1", "r1", "r1"),
    company_id = c("9", "9", "9"),
    company_name = c("Z", "Z", "Z"),
    term = c(5, 5, 5),
    loss_given_default = c(0.4, 0.4, 0.4),
    sector = c("Power", "Power", "Power"),
    technology = c("CoalCap", "OilCap", "RenewablesCap"),
    net_present_value_baseline = c(-5, -2, 0), # every technology non-positive
    exposure_value_usd = c(30, 30, 30)
  )
  expect_warning(out <- add_exposure_share_from_npv(pr), "non-positive baseline NPV")
  shares <- out$exposure_value_usd_share
  expect_true(all(shares >= 0) && all(is.finite(shares)))
  expect_equal(length(unique(round(shares, 8))), 1L) # equal split across technologies
})

test_that("trisk_sector_shades darkens with carbon intensity (regression for C4)", {
  lum <- function(h) {
    0.299 * strtoi(substr(h, 2, 3), 16L) +
      0.587 * strtoi(substr(h, 4, 5), 16L) +
      0.114 * strtoi(substr(h, 6, 7), 16L)
  }
  cases <- list(
    Power = c("CoalCap", "OilCap", "GasCap", "NuclearCap", "HydroCap", "RenewablesCap"),
    Automotive = c("ICE", "Hybrid", "FuelCell", "Electric"),
    Steel = c("BF-OHF", "BF-BOF", "BOF", "DRI-BOF", "BF-EAF", "DRI-EAF", "EAF")
  )
  for (s in names(cases)) {
    techs <- cases[[s]]
    cols <- trisk_sector_shades(s, rev(techs)) # shuffled input -> must re-sort by intensity
    l <- vapply(cols[techs], lum, numeric(1))   # reorder dirtiest -> cleanest
    expect_true(all(diff(l) > 0), info = s)      # strictly darker for dirtier tech
  }
})
