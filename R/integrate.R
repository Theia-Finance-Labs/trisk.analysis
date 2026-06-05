#' Integrate TRISK PD shift into an internal PD estimate
#'
#' Applies one of three methods to translate the TRISK baseline-to-shock PD
#' change into the bank's own internal PD scale. Mirrors the logic in the
#' trisk.r.docker Shiny integration module.
#'
#' @param analysis_data Data frame from [run_trisk_on_portfolio()]; must contain
#'   columns `pd_baseline`, `pd_shock`.
#' @param internal_pd Either (a) a numeric vector of length `nrow(analysis_data)`,
#'   (b) a data frame with `company_id` (+ optional `term`/keys) and a value
#'   column, or (c) NULL (default) in which case `pd_baseline` is used.
#'
#'   \strong{Horizon consistency:} TRISK's `pd_baseline`/`pd_shock` are cumulative
#'   over the loan `term`. This function does not know your `internal_pd`'s
#'   horizon and applies no conversion, so supply an `internal_pd` on a comparable
#'   horizon. If your internal PD is a 12-month (IFRS-9 Stage 1) figure, lift it
#'   to the term horizon first with [pd_annual_to_lifetime()]; see "Choosing a
#'   direction" in [pd_lifetime_to_annual()].
#' @param method One of "zscore", "absolute", "relative". Default "zscore"
#'   (Merton-style probit recombination of default thresholds, not the Basel
#'   IRB/Vasicek formula; zero-safe via clipping; recommended for sparse
#'   portfolios where baseline PDs can underflow from Merton inputs).
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
                         method = c("zscore", "absolute", "relative"),
                         zscore_floor = ZSCORE_FLOOR_DEFAULT,
                         zscore_cap = ZSCORE_CAP_DEFAULT) {
  method <- match.arg(method)

  if (nrow(analysis_data) == 0) {
    stop("integrate_pd(): analysis_data has zero rows; nothing to integrate.")
  }

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
  pd_change_pct <- ifelse(pd_baseline != 0, pd_change / pd_baseline, NA_real_)

  # R1: the relative method no-ops on zero-baseline rows (change_pct forced to 0),
  # silently dropping the shock signal. Surface it.
  if (method == "relative") {
    n_zero <- sum(pd_baseline == 0, na.rm = TRUE)
    if (n_zero > 0) {
      warning("integrate_pd(): method 'relative' leaves ", n_zero,
              " row(s) with pd_baseline == 0 unchanged (shock signal dropped); ",
              "use 'absolute' or 'zscore' for those.", call. = FALSE)
    }
  }

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

  portfolio_long <- portfolio |>
    tidyr::pivot_longer(
      cols = dplyr::all_of(c("internal_pd", "pd_baseline", "pd_shock", "trisk_adjusted_pd")),
      names_to = "pd_type_raw",
      values_to = "pd_value"
    ) |>
    dplyr::mutate(
      pd_type = ordered(
        dplyr::case_when(
          .data$pd_type_raw == "internal_pd"       ~ "internal",
          .data$pd_type_raw == "pd_baseline"       ~ "baseline",
          .data$pd_type_raw == "pd_shock"          ~ "shock",
          .data$pd_type_raw == "trisk_adjusted_pd" ~ "trisk_adjusted"
        ),
        levels = c("internal", "baseline", "shock", "trisk_adjusted")
      )
    ) |>
    dplyr::select(-"pd_type_raw")

  aggregate <- aggregate_pd_integration(portfolio)
  if (method == "zscore") {
    clipped <- zscore_clipped_share(list(internal_vec, pd_baseline, pd_shock),
                                    zscore_floor, zscore_cap)
    aggregate$zscore_clipped_share <- clipped
    warn_if_overclipped(clipped, "integrate_pd")
  }

  list(
    portfolio = portfolio,
    portfolio_long = portfolio_long,
    aggregate = aggregate
  )
}

#' Aggregate PD integration results to EAD-weighted portfolio level
#'
#' @param portfolio_df The `$portfolio` element from [integrate_pd()], containing
#'   `internal_pd`, `pd_baseline`, `pd_shock`, `trisk_adjusted_pd`,
#'   `exposure_value_usd`.
#' @param group_cols Character vector of columns to group by. NULL (default) produces
#'   a single-row portfolio total. Pass e.g. "sector" for a sector rollup.
#'
#' @return A one-row tibble (per group) with EAD-weighted PD metrics.
#' @export
aggregate_pd_integration <- function(portfolio_df, group_cols = NULL) {
  required <- c("internal_pd", "pd_baseline", "pd_shock",
                "trisk_adjusted_pd", "exposure_value_usd")
  missing_cols <- setdiff(required, colnames(portfolio_df))
  if (length(missing_cols) > 0) {
    stop("aggregate_pd_integration(): missing required columns: ",
         paste(missing_cols, collapse = ", "))
  }

  grouped <- if (is.null(group_cols)) {
    portfolio_df |> dplyr::mutate(.dummy = 1L) |> dplyr::group_by(.data$.dummy)
  } else {
    portfolio_df |> dplyr::group_by(dplyr::across(dplyr::all_of(group_cols)))
  }

  agg <- grouped |>
    dplyr::summarise(
      total_exposure_usd   = sum(.data$exposure_value_usd, na.rm = TRUE),
      weighted_pd_internal = sum(.data$internal_pd       * .data$exposure_value_usd, na.rm = TRUE),
      weighted_pd_baseline = sum(.data$pd_baseline       * .data$exposure_value_usd, na.rm = TRUE),
      weighted_pd_shock    = sum(.data$pd_shock          * .data$exposure_value_usd, na.rm = TRUE),
      weighted_pd_adjusted = sum(.data$trisk_adjusted_pd * .data$exposure_value_usd, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      weighted_pd_internal   = .data$weighted_pd_internal / .data$total_exposure_usd,
      weighted_pd_baseline   = .data$weighted_pd_baseline / .data$total_exposure_usd,
      weighted_pd_shock      = .data$weighted_pd_shock    / .data$total_exposure_usd,
      weighted_pd_adjusted   = .data$weighted_pd_adjusted / .data$total_exposure_usd,
      weighted_pd_adjustment     = .data$weighted_pd_adjusted - .data$weighted_pd_internal,
      weighted_pd_adjustment_pct = dplyr::if_else(
        !is.na(.data$weighted_pd_internal) & .data$weighted_pd_internal != 0,
        .data$weighted_pd_adjustment / .data$weighted_pd_internal,
        NA_real_
      )
    )

  if (is.null(group_cols)) {
    agg <- agg |> dplyr::select(-dplyr::any_of(".dummy"))
  }

  tibble::as_tibble(agg)
}

# Internal - resolve the internal PD/EL series from vector, df, or NULL input.
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
    if (!"company_id" %in% colnames(user_values)) {
      stop("resolve_internal_series(): dataframe must have 'company_id' and one value column.",
           call. = FALSE)
    }
    # Identify join keys by a known identifier set (NOT by "absent from
    # analysis_data" — the value column name, e.g. internal_pd, can ride along in
    # analysis_data from the portfolio input). The value column is whatever
    # remains. Matching on ALL shared keys (CX1) prevents a per-(company, term)
    # lookup from collapsing onto the first company_id match.
    id_candidates <- c("company_id", "term", "sector", "technology",
                       "country_iso2", "run_id")
    key_cols <- intersect(colnames(user_values), id_candidates)
    val_cols <- setdiff(colnames(user_values), key_cols)
    if (length(val_cols) != 1) {
      stop("resolve_internal_series(): user_values must have exactly one value ",
           "(non-key) column; found: ", paste(val_cols, collapse = ", "), ".",
           call. = FALSE)
    }
    val_col <- val_cols[1]
    # Join only on keys that actually exist in analysis_data.
    key_cols <- intersect(key_cols, colnames(analysis_data))
    # Ambiguity guard: duplicate keys would apply the first match to every
    # analysis row sharing that key. Force the caller to disambiguate.
    if (anyDuplicated(user_values[key_cols]) > 0L) {
      stop("resolve_internal_series(): user_values has duplicate rows for key(s) (",
           paste(key_cols, collapse = ", "),
           "); include a disambiguating column (e.g. 'term') so each row maps to a ",
           "unique value, or supply one row per company_id.", call. = FALSE)
    }
    # Composite key match across all key columns (character-coerced for type-safe
    # joins; \r separator avoids collisions between concatenated key parts).
    make_key <- function(df) {
      do.call(paste, c(lapply(key_cols, function(k) as.character(df[[k]])), sep = "\r"))
    }
    out <- default_vec
    idx <- match(make_key(analysis_data), make_key(user_values))
    unmatched_ids <- unique(as.character(analysis_data$company_id)[is.na(idx)])
    if (length(unmatched_ids) > 0) {
      warning(
        "resolve_internal_series(): ", length(unmatched_ids),
        " company_id(s) in analysis_data not matched in user_values; ",
        "falling back to '", default_col, "' for those rows. Unmatched: ",
        paste(unmatched_ids, collapse = ", "),
        call. = FALSE
      )
    }
    out[!is.na(idx)] <- user_values[[val_col]][idx[!is.na(idx)]]
    return(out)
  }

  stop("resolve_internal_series(): user_values must be NULL, numeric vector, or data frame.")
}

# Internal (Z1) - fraction of rows where any input PD lies outside [floor, cap]
# and is therefore clamped before qnorm(). A high share means the z-score overlay
# reflects the clip bound, not the model. Rows that are all-NA across the series
# are excluded from the denominator (they carry no model signal to clip).
zscore_clipped_share <- function(series_list, floor, cap) {
  if (length(series_list) == 0 || length(series_list[[1]]) == 0) return(NA_real_)
  all_na  <- Reduce(`&`, lapply(series_list, is.na))
  clipped <- Reduce(`|`, lapply(series_list, function(x) {
    !is.na(x) & (x < floor | x > cap)
  }))
  valid <- !all_na
  if (!any(valid)) return(NA_real_)
  mean(clipped[valid])
}

# Internal (Z1) - warn when the clipped share crosses the threshold.
warn_if_overclipped <- function(share, fn) {
  if (!is.na(share) && share > ZSCORE_CLIP_WARN_THRESHOLD) {
    warning(
      fn, "(): ", round(share * 100), "% of rows have a PD clipped to the ",
      "z-score floor/cap before qnorm(); the overlay is governed by the clip ",
      "bound, not the model. Baseline PDs below the floor erase the shock signal. ",
      "Consider method = \"absolute\" for underflow-prone (e.g. IG / short-horizon) ",
      "books, or review zscore_floor.",
      call. = FALSE
    )
  }
  invisible(share)
}

# Internal - pure vector math for the three PD methods. Shiny-parity.
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

#' Integrate TRISK EL shift into an internal EL estimate
#'
#' Applies one of three methods to translate the TRISK baseline-to-shock EL
#' change into the bank's own internal EL scale. "absolute" and "relative"
#' mirror the Shiny EL integration logic; "zscore" adds a Basel IRB-aligned
#' Vasicek recombination by transforming EL to an effective PD
#' (|EL| / (EAD * LGD)), applying the z-score combination in normal-quantile
#' space, and converting back. All three methods return EL as a positive
#' magnitude (post 59571f3 package-wide convention). The zscore method requires
#' `exposure_value_usd` and `loss_given_default` columns in `analysis_data`.
#'
#' @param analysis_data Data frame from [run_trisk_on_portfolio()]; must contain
#'   columns `expected_loss_baseline`, `expected_loss_shock`. The zscore method
#'   additionally needs an EAD denominator: it uses an `exposure_at_default`
#'   column when present (the canonical contract, written by
#'   [compute_analysis_metrics()] and [run_trisk_on_simple_portfolio()]) and
#'   otherwise reconstructs it as `exposure_value_usd * loss_given_default`.
#' @param internal_el Numeric vector of length `nrow(analysis_data)`, or a data
#'   frame with `company_id` (+ optional keys) and a value column, or NULL
#'   (default) which uses `expected_loss_baseline`. The PD embedded in an internal
#'   EL should be on a horizon comparable to the TRISK `term` (no conversion is
#'   applied here); see the horizon note in [integrate_pd()].
#' @param method One of "zscore", "absolute", "relative". Default "zscore".
#' @param zscore_floor Lower clip bound for effective PDs before `qnorm()`.
#'   Default 1e-4.
#' @param zscore_cap Upper clip bound. Default 1 - 1e-4.
#'
#' @return List with `$portfolio`, `$portfolio_long`, `$aggregate`.
#' @export
integrate_el <- function(analysis_data,
                         internal_el = NULL,
                         method = c("zscore", "absolute", "relative"),
                         zscore_floor = ZSCORE_FLOOR_DEFAULT,
                         zscore_cap = ZSCORE_CAP_DEFAULT) {
  method <- match.arg(method)

  if (nrow(analysis_data) == 0) {
    stop("integrate_el(): analysis_data has zero rows; nothing to integrate.")
  }

  if (zscore_floor >= zscore_cap) {
    stop("integrate_el(): zscore_floor must be strictly less than zscore_cap (got ",
         zscore_floor, " vs ", zscore_cap, ")")
  }

  required_cols <- c("expected_loss_baseline", "expected_loss_shock")
  missing_cols <- setdiff(required_cols, colnames(analysis_data))
  if (length(missing_cols) > 0) {
    stop("integrate_el(): missing required columns: ",
         paste(missing_cols, collapse = ", "))
  }
  if (method == "zscore") {
    # Need EAD: either an explicit exposure_at_default column, or the
    # ingredients (exposure_value_usd + loss_given_default) to reconstruct it.
    has_ead     <- "exposure_at_default" %in% colnames(analysis_data)
    has_product <- all(c("exposure_value_usd", "loss_given_default")
                       %in% colnames(analysis_data))
    if (!has_ead && !has_product) {
      stop("integrate_el(): zscore method needs either `exposure_at_default` ",
           "or both `exposure_value_usd` + `loss_given_default` in analysis_data.")
    }
  }

  internal_vec <- resolve_internal_series(analysis_data, internal_el,
                                          "expected_loss_baseline")
  if (all(is.na(internal_vec))) {
    stop("integrate_el(): all resolved internal EL values are NA.")
  }

  el_baseline <- analysis_data$expected_loss_baseline
  el_shock <- analysis_data$expected_loss_shock
  el_change <- el_shock - el_baseline
  el_change_pct <- ifelse(el_baseline != 0, el_change / el_baseline, NA_real_)

  # R1: the relative method no-ops on zero-baseline rows. Surface it.
  if (method == "relative") {
    n_zero <- sum(el_baseline == 0, na.rm = TRUE)
    if (n_zero > 0) {
      warning("integrate_el(): method 'relative' leaves ", n_zero,
              " row(s) with expected_loss_baseline == 0 unchanged (shock signal ",
              "dropped); use 'absolute' or 'zscore' for those.", call. = FALSE)
    }
  }

  # zscore needs an EAD denominator. Prefer an explicit exposure_at_default
  # column when the caller has supplied one (e.g. via compute_analysis_metrics
  # or run_trisk_on_simple_portfolio, which scale EAD by NPV share). Falling
  # back to exposure_value_usd * loss_given_default is correct only when the
  # EL columns are on that same unscaled basis; otherwise the effective-PD
  # round-trip recovers a scaled PD and the z-score result is wrong.
  ead <- if (method == "zscore") {
    if ("exposure_at_default" %in% colnames(analysis_data)) {
      analysis_data$exposure_at_default
    } else {
      analysis_data$exposure_value_usd * analysis_data$loss_given_default
    }
  } else NULL

  adjusted <- apply_el_method(internal_vec, el_baseline, el_shock, method,
                              ead          = ead,
                              zscore_floor = zscore_floor,
                              zscore_cap   = zscore_cap)

  portfolio <- analysis_data |>
    dplyr::mutate(
      internal_el        = internal_vec,
      el_change          = el_change,
      el_change_pct      = el_change_pct,
      trisk_adjusted_el  = adjusted,
      el_adjustment      = adjusted - internal_vec
    )

  portfolio_long <- portfolio |>
    tidyr::pivot_longer(
      cols = dplyr::all_of(c("internal_el", "expected_loss_baseline",
                             "expected_loss_shock", "trisk_adjusted_el")),
      names_to = "el_type_raw",
      values_to = "el_value"
    ) |>
    dplyr::mutate(
      el_type = factor(
        dplyr::case_when(
          .data$el_type_raw == "internal_el"            ~ "internal",
          .data$el_type_raw == "expected_loss_baseline" ~ "baseline",
          .data$el_type_raw == "expected_loss_shock"    ~ "shock",
          .data$el_type_raw == "trisk_adjusted_el"      ~ "trisk_adjusted"
        ),
        levels = c("internal", "baseline", "shock", "trisk_adjusted")
      )
    ) |>
    dplyr::select(-"el_type_raw")

  aggregate <- aggregate_el_integration(portfolio)
  if (method == "zscore") {
    # Effective PD = |EL| / EAD, matching apply_el_method(). Rows with EAD <= 0
    # carry no loss and contribute 0 EL; map them to NA so they are excluded from
    # the clip-share denominator rather than counting as clipped (warning misfire).
    eff_pd <- function(x) ifelse(!is.na(ead) & ead > 0, abs(x) / ead, NA_real_)
    clipped <- zscore_clipped_share(
      list(eff_pd(internal_vec), eff_pd(el_baseline), eff_pd(el_shock)),
      zscore_floor, zscore_cap
    )
    aggregate$zscore_clipped_share <- clipped
    warn_if_overclipped(clipped, "integrate_el")
  }

  list(
    portfolio = portfolio,
    portfolio_long = portfolio_long,
    aggregate = aggregate
  )
}

apply_el_method <- function(internal, baseline, shock, method,
                            ead = NULL,
                            zscore_floor = ZSCORE_FLOOR_DEFAULT,
                            zscore_cap = ZSCORE_CAP_DEFAULT) {
  switch(method,
    absolute = internal + (shock - baseline),
    relative = {
      change_pct <- ifelse(baseline != 0, (shock - baseline) / baseline, 0)
      internal * (1 + change_pct)
    },
    zscore = {
      # Basel IRB style recombination, applied to EL via the
      # effective-PD transform: EL = EAD * PD  -->  PD_eff = |EL| / EAD,
      # where `ead` is exposure_value_usd * loss_given_default. After z-score
      # recombination in normal-quantile space, convert back via EAD * PD_adj.
      # Returns a positive magnitude, matching the package's positive-EL
      # convention (see 59571f3).
      clip <- function(x) pmin(pmax(x, zscore_floor), zscore_cap)
      safe_div <- function(x) ifelse(ead > 0, abs(x) / ead, 0)
      pd_internal <- clip(safe_div(internal))
      pd_baseline <- clip(safe_div(baseline))
      pd_shock    <- clip(safe_div(shock))
      adjusted_pd <- stats::pnorm(
        stats::qnorm(pd_internal) +
        stats::qnorm(pd_shock) -
        stats::qnorm(pd_baseline)
      )
      ead * adjusted_pd
    }
  )
}

#' Aggregate EL integration results to portfolio level
#'
#' @param portfolio_df The `$portfolio` element from [integrate_el()].
#' @param group_cols Character vector or NULL. NULL = portfolio total.
#' @return A one-row tibble (per group) with total ELs and two bps measures, both
#'   as a loss rate over *notional exposure* (EL/EAD would be PD-in-bps, not a
#'   loss rate): `el_adjusted_bps` — the adjusted EL *level* (total expected-loss
#'   rate of the shocked book), and `el_adjustment_bps` — the climate overlay
#'   (delta = adjusted - internal), the marginal transition effect.
#' @export
aggregate_el_integration <- function(portfolio_df, group_cols = NULL) {
  required <- c("internal_el", "expected_loss_baseline", "expected_loss_shock",
                "trisk_adjusted_el", "exposure_value_usd")
  missing_cols <- setdiff(required, colnames(portfolio_df))
  if (length(missing_cols) > 0) {
    stop("aggregate_el_integration(): missing required columns: ",
         paste(missing_cols, collapse = ", "))
  }

  grouped <- if (is.null(group_cols)) {
    portfolio_df |> dplyr::mutate(.dummy = 1L) |> dplyr::group_by(.data$.dummy)
  } else {
    portfolio_df |> dplyr::group_by(dplyr::across(dplyr::all_of(group_cols)))
  }

  agg <- grouped |>
    dplyr::summarise(
      total_exposure_usd = sum(.data$exposure_value_usd, na.rm = TRUE),
      total_el_internal  = sum(.data$internal_el, na.rm = TRUE),
      total_el_baseline  = sum(.data$expected_loss_baseline, na.rm = TRUE),
      total_el_shock     = sum(.data$expected_loss_shock, na.rm = TRUE),
      total_el_adjusted  = sum(.data$trisk_adjusted_el, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      total_el_adjustment = .data$total_el_adjusted - .data$total_el_internal,
      # Both bps measures use *notional exposure* as the denominator: EL / exposure
      # = LGD*PD in bps, a true loss rate. Dividing by EAD (= exposure * LGD) would
      # instead yield PD-in-bps, not a loss rate (K1).
      # el_adjusted_bps: the adjusted EL *level* as a loss rate (total expected loss
      # of the shocked book = baseline credit risk + climate overlay).
      el_adjusted_bps     = el_to_bps(.data$total_el_adjusted,
                                      .data$total_exposure_usd),
      # el_adjustment_bps: the climate overlay (delta = adjusted - internal) as a
      # loss rate — the marginal effect attributable to the transition scenario.
      # Signed (el_to_bps returns a magnitude): positive = more loss, negative =
      # less loss, so the direction of the delta is preserved.
      el_adjustment_bps   = sign(.data$total_el_adjustment) *
                            el_to_bps(.data$total_el_adjustment,
                                      .data$total_exposure_usd)
    )

  if (is.null(group_cols)) {
    agg <- agg |> dplyr::select(-dplyr::any_of(".dummy"))
  }

  tibble::as_tibble(agg)
}
