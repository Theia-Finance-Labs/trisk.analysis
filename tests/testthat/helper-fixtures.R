# Synthetic 3-row analysis_data fixture for integration tests.
# Values chosen so that:
#   - company A has pd_baseline = 0 (triggers zero-baseline quirks)
#   - company B has a standard shock (baseline 2%, shock 6%)
#   - company C has a small shock (baseline 1%, shock 1.5%)
make_test_analysis_data <- function() {
  tibble::tibble(
    company_id               = c("A", "B", "C"),
    company_name             = c("Alpha", "Beta", "Gamma"),
    sector                   = c("Coal", "Power", "Power"),
    technology               = c("Coal", "CoalCap", "RenewablesCap"),
    country_iso2             = c("MN", "MN", "MN"),
    term                     = c(1L, 1L, 1L),
    exposure_value_usd       = c(100, 200, 300),
    loss_given_default       = c(0.4, 0.4, 0.4),
    pd_baseline              = c(0.00, 0.02, 0.01),
    pd_shock                 = c(0.05, 0.06, 0.015),
    expected_loss_baseline   = c(0,   1.6, 1.2),
    expected_loss_shock      = c(2.0, 4.8, 1.8)
  )
}
