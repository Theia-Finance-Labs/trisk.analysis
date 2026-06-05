# Shared internal helpers for the portfolio runners: audit-trail metadata (A1)
# and the term-outside-grid warning (D1).

#' Build a TRISK run audit-trail / reproducibility record
#'
#' Captures everything needed to reproduce a runner call: the scenario pair, the
#' `run_id`, the forwarded TRISK arguments, and the versions of both packages.
#' Attached to runner output as the `trisk_run_meta` attribute (A1).
#'
#' @param baseline_scenario,target_scenario Scenario names used for the run.
#' @param run_id The TRISK `run_id`(s) of the model run.
#' @param extra_args A list of the additional arguments forwarded to
#'   [trisk.model::run_trisk_model()] (typically `list(...)` from the runner).
#' @return A named list: `baseline_scenario`, `target_scenario`, `run_id`,
#'   `trisk_args`, `package_versions`, `created_at`.
#' @keywords internal
build_trisk_run_meta <- function(baseline_scenario, target_scenario,
                                 run_id, extra_args = list()) {
  safe_version <- function(pkg) {
    tryCatch(as.character(utils::packageVersion(pkg)), error = function(e) NA_character_)
  }
  list(
    baseline_scenario = baseline_scenario,
    target_scenario   = target_scenario,
    run_id            = run_id,
    trisk_args        = extra_args,
    package_versions  = c(
      trisk.analysis = safe_version("trisk.analysis"),
      trisk.model    = safe_version("trisk.model")
    ),
    created_at        = Sys.time()
  )
}

#' Warn when portfolio terms fall outside the TRISK Merton grid (D1)
#'
#' The term join silently drops portfolio rows whose contractual `term` is not in
#' the model's PD term grid (sized to the analysis horizon), yielding NA PD/EL.
#' This surfaces those rows by name instead.
#'
#' @param portfolio_data Portfolio data frame with `company_id` and `term`.
#' @param pd_results PD results from the TRISK model (provides the term grid).
#' @return Invisibly, the dropped rows (`company_id`, `term`).
#' @keywords internal
warn_terms_outside_grid <- function(portfolio_data, pd_results) {
  if (!all(c("term") %in% colnames(portfolio_data)) ||
      !"term" %in% colnames(pd_results)) {
    return(invisible(NULL))
  }
  grid <- sort(unique(stats::na.omit(pd_results$term)))
  pf <- portfolio_data[!is.na(portfolio_data$term), , drop = FALSE]
  dropped <- pf[!pf$term %in% grid, , drop = FALSE]
  if (nrow(dropped) > 0) {
    cid <- if ("company_id" %in% colnames(dropped)) dropped$company_id else NA
    pairs <- paste(cid, dropped$term, sep = "/term=", collapse = ", ")
    warning(
      "run_trisk: ", nrow(dropped), " portfolio row(s) have a term outside the ",
      "Merton grid (", paste(grid, collapse = ", "), "); their PD/EL will be NA. ",
      "Affected (company_id/term): ", pairs,
      call. = FALSE
    )
  }
  invisible(dropped)
}
