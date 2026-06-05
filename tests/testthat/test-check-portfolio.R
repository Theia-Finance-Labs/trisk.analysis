# Phase 2 (V1 + technology isolation) — the technology requirement belongs to the
# full runner only. check_portfolio() (full) must fail fast when sector/technology
# are missing; check_portfolio_simple() must never require them.

test_that("V1: check_portfolio fails fast when sector/technology are missing", {
  p <- tibble::tibble(
    company_id = "1", company_name = NA, country_iso2 = "DE",
    exposure_value_usd = 100, term = 1, loss_given_default = 0.5
  )
  expect_error(check_portfolio(p), "technology")
  expect_error(check_portfolio(p), "sector")
})

test_that("V1: check_portfolio accepts a fully-specified full-runner portfolio", {
  p <- tibble::tibble(
    company_id = "1", company_name = NA, country_iso2 = "DE",
    exposure_value_usd = 100, term = 1, loss_given_default = 0.5,
    sector = "Power", technology = "CoalCap"
  )
  expect_identical(check_portfolio(p), p)
})

test_that("V1: simple runner does NOT require sector/technology", {
  p <- tibble::tibble(
    company_id = "1", company_name = "x",
    exposure_value_usd = 100, term = 1, loss_given_default = 0.5
  )
  expect_invisible(check_portfolio_simple(p))
})
