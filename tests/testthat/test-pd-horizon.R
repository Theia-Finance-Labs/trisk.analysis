# Phase 3 (IF1) — lifetime <-> annual PD conversion under constant hazard.

test_that("IF1: lifetime->annual is the constant-hazard inverse of annual->lifetime", {
  expect_equal(pd_lifetime_to_annual(0.10, term = 5), 1 - (1 - 0.10)^(1 / 5))
  # round-trip
  expect_equal(pd_annual_to_lifetime(pd_lifetime_to_annual(0.10, 5), 5), 0.10)
  expect_equal(pd_lifetime_to_annual(pd_annual_to_lifetime(0.02, 5), 5), 0.02)
})

test_that("IF1: term = 1 is the identity", {
  expect_equal(pd_lifetime_to_annual(0.03, term = 1), 0.03)
  expect_equal(pd_annual_to_lifetime(0.03, term = 1), 0.03)
})

test_that("IF1: annual PD is below the cumulative lifetime PD for term > 1", {
  expect_lt(pd_lifetime_to_annual(0.20, term = 5), 0.20)
})

test_that("IF1: invalid inputs are handled", {
  expect_error(pd_lifetime_to_annual(1.5, term = 5), "must be in")
  expect_warning(res <- pd_lifetime_to_annual(0.1, term = 0), "term <= 0")
  expect_true(is.na(res))
  expect_true(is.na(pd_lifetime_to_annual(NA_real_, term = 5)))
})

test_that("IF1: vectorised over pd and term", {
  out <- pd_lifetime_to_annual(c(0.1, 0.2), term = c(2, 4))
  expect_length(out, 2)
  expect_equal(out, 1 - (1 - c(0.1, 0.2))^(1 / c(2, 4)))
})
