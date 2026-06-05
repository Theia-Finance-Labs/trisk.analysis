# IF1 — horizon conversion helpers for IFRS-9 staging.
# TRISK PDs are term-structured (cumulative over the loan `term`). IFRS-9 Stage 1
# needs a 12-month PD; Stage 2/3 a lifetime PD. Feeding a multi-year cumulative
# PD into a 12-month slot overstates provisions. These helpers convert between
# cumulative-lifetime and equivalent-annual PDs under a constant-hazard
# assumption.

#' Convert a cumulative lifetime PD to an equivalent annual PD
#'
#' Under a constant-hazard (flat marginal) assumption, a cumulative probability
#' of default `pd` over `term` years implies a per-year PD of
#' \eqn{1 - (1 - pd)^{1/term}}. Use this to place a TRISK term-structured PD into
#' a 12-month IFRS-9 Stage 1 slot.
#'
#' @param pd Numeric vector of cumulative lifetime PDs in `[0, 1]`.
#' @param term Numeric vector (recycled) of horizons in years, `> 0`.
#' @return Numeric vector of equivalent annual PDs in `[0, 1]`. `NA` inputs
#'   propagate; `term <= 0` yields `NA` with a warning.
#' @seealso [pd_annual_to_lifetime()]
#' @examples
#' pd_lifetime_to_annual(0.10, term = 5)   # ~0.0209
#' @export
pd_lifetime_to_annual <- function(pd, term) {
  if (any(stats::na.omit(pd) < 0 | stats::na.omit(pd) > 1)) {
    stop("pd_lifetime_to_annual(): pd must be in [0, 1].", call. = FALSE)
  }
  bad_term <- !is.na(term) & term <= 0
  if (any(bad_term)) {
    warning("pd_lifetime_to_annual(): term <= 0 returns NA for those elements.",
            call. = FALSE)
  }
  term <- ifelse(!is.na(term) & term > 0, term, NA_real_)
  1 - (1 - pd)^(1 / term)
}

#' Convert an annual PD to a cumulative lifetime PD over a horizon
#'
#' Inverse of [pd_lifetime_to_annual()] under the same constant-hazard
#' assumption: \eqn{1 - (1 - pd\_annual)^{term}}.
#'
#' @param pd_annual Numeric vector of annual PDs in `[0, 1]`.
#' @param term Numeric vector (recycled) of horizons in years, `>= 0`.
#' @return Numeric vector of cumulative lifetime PDs in `[0, 1]`.
#' @seealso [pd_lifetime_to_annual()]
#' @examples
#' pd_annual_to_lifetime(0.02, term = 5)   # ~0.0961
#' @export
pd_annual_to_lifetime <- function(pd_annual, term) {
  if (any(stats::na.omit(pd_annual) < 0 | stats::na.omit(pd_annual) > 1)) {
    stop("pd_annual_to_lifetime(): pd_annual must be in [0, 1].", call. = FALSE)
  }
  bad_term <- !is.na(term) & term < 0
  if (any(bad_term)) {
    warning("pd_annual_to_lifetime(): term < 0 returns NA for those elements.",
            call. = FALSE)
  }
  term <- ifelse(!is.na(term) & term >= 0, term, NA_real_)
  1 - (1 - pd_annual)^term
}
