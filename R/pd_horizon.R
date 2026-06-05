# IF1 — horizon conversion helpers for IFRS-9 staging.
# TRISK PDs are term-structured (cumulative over the loan `term`). IFRS-9 Stage 1
# needs a 12-month PD; Stage 2/3 a lifetime PD. Feeding a multi-year cumulative
# PD into a 12-month slot overstates provisions. These helpers convert between
# cumulative-lifetime and equivalent-annual PDs under a constant-hazard
# assumption. The package does NOT know the horizon of a user-supplied
# internal PD — the caller must decide which (if any) conversion applies; see
# "Choosing a direction" below.

#' Convert a cumulative lifetime PD to an equivalent annual PD
#'
#' Under a constant-hazard (flat marginal) assumption, a cumulative probability
#' of default `pd` over `term` years implies a per-year PD of
#' \eqn{1 - (1 - pd)^{1/term}}. Use this to place a TRISK term-structured PD into
#' a 12-month IFRS-9 Stage 1 slot.
#'
#' @section Choosing a direction (what to do based on your internal PD):
#' TRISK's `pd_baseline` / `pd_shock` are **cumulative over the loan `term`**.
#' The package cannot know the horizon of a user-supplied `internal_pd`, so you
#' must reconcile horizons yourself before [integrate_pd()] / [integrate_el()]:
#' \itemize{
#'   \item **Internal PD is a 12-month (IFRS-9 Stage 1) PD** and you want to
#'     integrate it with TRISK's term PD: lift it to the term horizon first with
#'     `pd_annual_to_lifetime(internal_pd, term)`.
#'   \item **Internal PD is already a lifetime/term PD** on the same horizon as
#'     the TRISK `term`: no conversion needed.
#'   \item **You need a 12-month figure out of TRISK's term PD** (Stage 1
#'     reporting): use `pd_lifetime_to_annual(pd, term)`.
#' }
#' Both directions assume a constant hazard, so the converted figure is an
#' approximation (TRISK's curve is not flat).
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
#' assumption: \eqn{1 - (1 - pd\_annual)^{term}}. The caller is responsible for
#' asserting that the input is genuinely an annual PD — the package does not (and
#' cannot) infer the horizon of an internal PD. Typical use: lift a 12-month
#' internal PD onto TRISK's `term` horizon so the two are comparable before
#' integration (see "Choosing a direction" in [pd_lifetime_to_annual()]).
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
