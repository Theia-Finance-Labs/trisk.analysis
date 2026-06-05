# Phase 2 (CX1, Codex finding) — the internal PD/EL lookup is matched by
# company_id only via match(), which returns the FIRST hit. A company with
# multiple loans (different terms) whose lookup is keyed per-(company, term) then
# silently reuses the first term's value for every row. The fix matches on all
# key columns shared with analysis_data and errors on ambiguous (duplicate-key)
# company-only lookups.

make_two_term_company <- function() {
  tibble::tibble(
    company_id         = c("X", "X"),
    company_name       = c("Xco", "Xco"),
    sector             = c("Power", "Power"),
    technology         = c("CoalCap", "CoalCap"),
    country_iso2       = c("DE", "DE"),
    term               = c(1L, 5L),
    exposure_value_usd = c(100, 100),
    loss_given_default = c(0.4, 0.4),
    pd_baseline        = c(0.01, 0.02),
    pd_shock           = c(0.03, 0.04)
  )
}

test_that("CX1: per-(company, term) internal_pd lookup matches on term", {
  ad <- make_two_term_company()
  lookup <- tibble::tibble(
    company_id  = c("X", "X"),
    term        = c(1L, 5L),
    internal_pd = c(0.05, 0.09)
  )
  res <- integrate_pd(ad, internal_pd = lookup, method = "absolute")
  # Each row must take its own term's internal PD. RED today: both get 0.05.
  expect_equal(res$portfolio$internal_pd, c(0.05, 0.09))
})

test_that("CX1: ambiguous company-only lookup with duplicate company_id errors", {
  ad <- make_two_term_company()
  lookup_ambig <- tibble::tibble(
    company_id  = c("X", "X"),     # duplicate company_id, no disambiguating key
    internal_pd = c(0.05, 0.09)
  )
  expect_error(
    integrate_pd(ad, internal_pd = lookup_ambig, method = "absolute"),
    "duplicate|ambiguous|unique"
  )
})

test_that("CX1: lookup works when analysis_data already carries an internal_pd column", {
  # bank_4 case: the portfolio's internal_pd column rides along into analysis_data
  # via the join. The lookup value must still win, not error on value detection.
  ad <- make_two_term_company()
  ad$internal_pd <- c(0.99, 0.99)   # ride-along from portfolio input
  lookup <- tibble::tibble(company_id = "X", internal_pd = 0.07)
  res <- integrate_pd(ad, internal_pd = lookup, method = "absolute")
  expect_equal(res$portfolio$internal_pd, c(0.07, 0.07))
})

test_that("CX1: plain company_id lookup (one row per company) still works", {
  ad <- make_two_term_company()
  lookup <- tibble::tibble(company_id = "X", internal_pd = 0.07)
  res <- integrate_pd(ad, internal_pd = lookup, method = "absolute")
  expect_equal(res$portfolio$internal_pd, c(0.07, 0.07))  # broadcast, intended
})
