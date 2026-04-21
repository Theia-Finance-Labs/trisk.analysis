#' Integrate TRISK PD shift into an internal PD estimate
#'
#' Applies one of three methods to translate the TRISK baseline-to-shock PD
#' change into the bank's own internal PD scale. Mirrors the logic in the
#' trisk.r.docker Shiny integration module.
#'
#' @param analysis_data Data frame from [run_trisk_on_portfolio()]; must contain
#'   columns `pd_baseline`, `pd_shock`.
#' @param internal_pd Either (a) a numeric vector of length `nrow(analysis_data)`,
#'   (b) a data frame with `company_id` and `internal_pd` columns, or (c) NULL
#'   (default) in which case `pd_baseline` is used.
#' @param method One of "absolute", "relative", "zscore". Default "absolute".
#' @param zscore_floor Lower clip bound for PDs before `qnorm()` in the zscore
#'   method. Default 1e-4.
#' @param zscore_cap Upper clip bound. Default 1 - 1e-4.
#'
#' @return A list with three elements:
#' \describe{
#'   \item{portfolio}{`analysis_data` with columns added: `internal_pd`,
#'     `pd_change`, `pd_change_pct`, `trisk_adjusted_pd`, `pd_adjustment`.}
#'   \item{portfolio_long}{Pivot-longer helper for plotting.}
#'   \item{aggregate}{One-row tibble of EAD-weighted portfolio metrics.}
#' }
#' @export
integrate_pd <- function(analysis_data,
                         internal_pd = NULL,
                         method = c("absolute", "relative", "zscore"),
                         zscore_floor = 1e-4,
                         zscore_cap = 1 - 1e-4) {
  method <- match.arg(method)

  if (zscore_floor >= zscore_cap) {
    stop("integrate_pd(): zscore_floor must be strictly less than zscore_cap (got ",
         zscore_floor, " vs ", zscore_cap, ")")
  }

  required_cols <- c("pd_baseline", "pd_shock")
  missing_cols <- setdiff(required_cols, colnames(analysis_data))
  if (length(missing_cols) > 0) {
    stop("integrate_pd(): missing required columns in analysis_data: ",
         paste(missing_cols, collapse = ", "))
  }

  internal_vec <- resolve_internal_series(analysis_data, internal_pd, "pd_baseline")
  if (all(is.na(internal_vec))) {
    stop("integrate_pd(): all resolved internal PD values are NA.")
  }

  pd_baseline <- analysis_data$pd_baseline
  pd_shock <- analysis_data$pd_shock
  pd_change <- pd_shock - pd_baseline
  pd_change_pct <- ifelse(pd_baseline != 0, pd_change / pd_baseline, 0)

  adjusted <- apply_pd_method(internal_vec, pd_baseline, pd_shock,
                              method, zscore_floor, zscore_cap)
  adjusted <- pmin(pmax(adjusted, 0), 1)

  portfolio <- analysis_data |>
    dplyr::mutate(
      internal_pd        = internal_vec,
      pd_change          = pd_change,
      pd_change_pct      = pd_change_pct,
      trisk_adjusted_pd  = adjusted,
      pd_adjustment      = adjusted - internal_vec
    )

  list(
    portfolio = portfolio,
    portfolio_long = NULL,    # wired up in later task
    aggregate = NULL          # wired up in later task
  )
}

# Internal — resolve the internal PD/EL series from vector, df, or NULL input.
resolve_internal_series <- function(analysis_data, user_values, default_col) {
  n <- nrow(analysis_data)
  default_vec <- analysis_data[[default_col]]

  if (is.null(user_values)) {
    return(default_vec)
  }

  if (is.numeric(user_values)) {
    if (length(user_values) != n) {
      stop("resolve_internal_series(): vector length ", length(user_values),
           " does not match nrow(analysis_data) = ", n)
    }
    return(user_values)
  }

  if (is.data.frame(user_values)) {
    val_col <- setdiff(colnames(user_values), "company_id")
    if (!"company_id" %in% colnames(user_values) || length(val_col) == 0) {
      stop("resolve_internal_series(): dataframe must have 'company_id' and one value column.")
    }
    val_col <- val_col[1]
    out <- default_vec
    idx <- match(as.character(analysis_data$company_id),
                 as.character(user_values$company_id))
    out[!is.na(idx)] <- user_values[[val_col]][idx[!is.na(idx)]]
    return(out)
  }

  stop("resolve_internal_series(): user_values must be NULL, numeric vector, or data frame.")
}

# Internal — pure vector math for the three PD methods. Shiny-parity.
apply_pd_method <- function(internal, baseline, shock, method,
                            zscore_floor, zscore_cap) {
  switch(method,
    absolute = internal + (shock - baseline),
    relative = {
      change_pct <- ifelse(baseline != 0, (shock - baseline) / baseline, 0)
      internal * (1 + change_pct)
    },
    zscore = {
      clip <- function(x) pmin(pmax(x, zscore_floor), zscore_cap)
      z_internal <- stats::qnorm(clip(internal))
      z_baseline <- stats::qnorm(clip(baseline))
      z_shock    <- stats::qnorm(clip(shock))
      stats::pnorm(z_internal + z_shock - z_baseline)
    }
  )
}
