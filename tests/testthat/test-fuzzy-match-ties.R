# Phase 3 (CX2) — fuzzy matching must not duplicate a loan when a portfolio name
# ties across several company names at the same distance.

test_that("CX2: tied best matches warn and keep one match per portfolio row", {
  assets <- tibble::tibble(
    company_id   = c("1", "2"),
    company_name = c("ABCE", "ABCF")  # both lcs-equidistant from "ABCD"
  )
  pf <- tibble::tibble(
    company_name = "ABCD", exposure_value_usd = 100, term = 1, loss_given_default = 0.5
  )
  expect_warning(
    res <- fuzzy_match_company_ids(pf, assets, threshold = 0.6),
    "tied"
  )
  # One portfolio row stays one row (no exposure-duplicating fan-out).
  expect_equal(nrow(res), 1L)
})

test_that("CX2: a clear unique best match does not warn", {
  assets <- tibble::tibble(
    company_id   = c("1", "2"),
    company_name = c("Apple Inc", "Zenith Corp")
  )
  pf <- tibble::tibble(
    company_name = "Apple Inc", exposure_value_usd = 100, term = 1, loss_given_default = 0.5
  )
  expect_no_warning(res <- fuzzy_match_company_ids(pf, assets, threshold = 0.5))
  expect_equal(nrow(res), 1L)
  expect_equal(res$company_id, "1")
})
