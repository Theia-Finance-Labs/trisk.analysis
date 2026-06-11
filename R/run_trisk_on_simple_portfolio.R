#' Run TRISK Model on Simple Portfolio
#'
#' @description
#' Runs the TRISK model on a simple portfolio that has only
#' \code{company_id}, \code{company_name}, \code{exposure_value_usd}, \code{term},
#' and \code{loss_given_default}. No \code{country_iso2} is required; companies
#' are matched to assets by \code{company_id} across all countries.
#' Reuses the same TRISK run and join logic as \code{\link{run_trisk_on_portfolio}},
#' with join keys \code{company_id} and \code{term}.
#'
#' @param assets_data Data frame containing asset information.
#' @param scenarios_data Data frame containing scenario information.
#' @param financial_data Data frame containing financial information.
#' @param carbon_data Data frame containing carbon price information.
#' @param portfolio_data Data frame with columns \code{company_id}, \code{company_name},
#'   \code{exposure_value_usd}, \code{term}, \code{loss_given_default} (see
#'   \code{\link{check_portfolio_simple}}). Basel mapping:
#'   \code{exposure_value_usd} = EAD (exposure at default; equals the drawn amount
#'   as no undrawn/CCF is modelled), \code{loss_given_default} = LGD,
#'   \code{term} = effective maturity M (years), used as the PD-lookup horizon.
#' @param baseline_scenario String specifying the name of the baseline scenario.
#' @param target_scenario String specifying the name of the shock scenario.
#' @param ... Additional arguments forwarded to
#'   \code{\link[trisk.model]{run_trisk_model}}. The forwarded arguments and their
#'   defaults are:
#'   \itemize{
#'     \item \code{scenario_geography} (default \code{"Global"}): region(s) to compute results for.
#'     \item \code{carbon_price_model} (default \code{"no_carbon_tax"}): NGFS carbon-price pathway ("no_carbon_tax" to skip).
#'     \item \code{risk_free_rate} (default \code{0.045}): risk-free rate used in the Merton PD model.
#'     \item \code{discount_rate} (default \code{0.09}): DCF discount rate on dividends.
#'     \item \code{growth_rate} (default \code{0.03}): terminal growth rate of profits.
#'     \item \code{div_netprofit_prop_coef} (default \code{1}): dividend pass-through coefficient.
#'     \item \code{shock_year} (default \code{2030}): year the policy shock is applied.
#'     \item \code{market_passthrough} (default \code{0}): firm's ability to pass the carbon cost to consumers.
#'   }
#'
#' @return A named list with:
#' \itemize{
#'   \item \code{portfolio_results_tech_detail}: company/term/sector/technology-level
#'     details. Basel-aligned columns: \code{exposure_at_default} (EAD, the
#'     NPV-share allocated exposure), \code{lgd_weighted_exposure} (EAD*LGD), and
#'     \code{expected_loss_*} (EL = EAD*LGD*PD).
#'   \item \code{portfolio_results}: portfolio-level results re-aggregated to input-row shape.
#' }
#' @export
#'
run_trisk_on_simple_portfolio <- function(assets_data,
                                         scenarios_data,
                                         financial_data,
                                         carbon_data,
                                         portfolio_data,
                                         baseline_scenario,
                                         target_scenario,
                                         ...) {
  assets_data <- assets_data |>
    dplyr::mutate(
      asset_id = as.character(.data$asset_id),
      company_id = as.character(.data$company_id)
    )
  financial_data <- financial_data |>
    dplyr::mutate(company_id = as.character(.data$company_id))

  portfolio_data <- portfolio_data |>
    dplyr::mutate(
      company_id = as.character(.data$company_id),
      .portfolio_index = dplyr::row_number()
    )

  check_portfolio_simple(portfolio_data)
  warn_scenario_family_mismatch(baseline_scenario, target_scenario)  # NM1

  # Match portfolio companies to assets by company_id (obtain country_iso2 from assets)
  portfolio_matched_companies <- portfolio_data |>
    dplyr::filter(!is.na(.data$company_id)) |>
    dplyr::distinct(.data$company_id) |>
    dplyr::inner_join(
      assets_data |> dplyr::distinct(.data$company_id, .data$country_iso2),
      by = "company_id"
    )

  assets_data_filtered <- assets_data |>
    dplyr::inner_join(portfolio_matched_companies, by = c("company_id", "country_iso2"))

  cat("-- Start Trisk")
  st_results <- trisk.model::run_trisk_model(
    assets_data = assets_data_filtered,
    scenarios_data = scenarios_data,
    financial_data = financial_data,
    carbon_data = carbon_data,
    baseline_scenario = baseline_scenario,
    target_scenario = target_scenario,
    ...
  )

  npv_results <- st_results$npv_results |>
    dplyr::mutate(
      asset_id = as.character(.data$asset_id),
      company_id = as.character(.data$company_id)
    )
  pd_results <- st_results$pd_results |>
    dplyr::mutate(company_id = as.character(.data$company_id))

  # D1: warn (don't silently drop) when a portfolio term is outside the Merton grid.
  warn_terms_outside_grid(portfolio_data, pd_results)

  trisk_agg <- aggregate_trisk_outputs_simple(npv_results, pd_results)
  joined_data <- join_simple_portfolio_to_trisk(portfolio_data, trisk_agg)
  joined_data <- add_exposure_share_from_npv(joined_data)
  joined_data <- compute_simple_portfolio_metrics(joined_data)

  # Portfolio output: aggregate back to input-row shape.
  portfolio_results <- aggregate_simple_portfolio_results(joined_data)

  # Detail output: keep share-level columns and drop original exposure column.
  portfolio_results_tech_detail <- joined_data |>
    dplyr::select(-"exposure_value_usd")

  # Remove internal index from returned objects.
  portfolio_results_tech_detail <- portfolio_results_tech_detail |>
    dplyr::select(-".portfolio_index")
  portfolio_results <- portfolio_results |>
    dplyr::select(-".portfolio_index")

  out <- list(
    portfolio_results_tech_detail = portfolio_results_tech_detail,
    portfolio_results = portfolio_results
  )
  # A1: attach the audit-trail / reproducibility record (attribute keeps the
  # documented two-element return shape intact).
  attr(out, "trisk_run_meta") <- build_trisk_run_meta(
    baseline_scenario = baseline_scenario,
    target_scenario   = target_scenario,
    run_id            = unique(stats::na.omit(pd_results$run_id)),
    extra_args        = list(...)
  )
  return(out)
}



#' Check Simple Portfolio
#'
#' @description
#' Validates that the portfolio data has the columns required for a simple portfolio:
#' \code{company_id}, \code{company_name}, \code{exposure_value_usd}, \code{term},
#' \code{loss_given_default}. No \code{country_iso2} is required.
#'
#' @param portfolio_data Data frame containing portfolio information.
#' @return The input \code{portfolio_data} (invisibly).
#' @export
check_portfolio_simple <- function(portfolio_data) {
  required <- c("company_id", "company_name", "exposure_value_usd", "term", "loss_given_default")
  if (!all(required %in% colnames(portfolio_data))) {
    missing <- setdiff(required, colnames(portfolio_data))
    stop("Missing columns in portfolio_data: ", paste(missing, collapse = ", "))
  }
  invisible(portfolio_data)
}


#' Compute exposure shares from baseline NPV
#'
#' @description
#' Allocates \code{exposure_value_usd} to assets using each asset baseline NPV share.
#' It mirrors the Python logic: compute run-level shares, average exposure share after
#' dropping \code{run_id}, then re-scale so each original portfolio row keeps its total
#' exposure. Non-negative guard: negative technology NPVs are clamped to 0 and a
#' company whose total baseline NPV is non-positive is split equally across its
#' technologies (with a warning), so allocated exposure stays non-negative and
#' still reconciles to the original loan totals.
#'
#' @param portfolio_results Output of \code{run_trisk_on_simple_portfolio} before share allocation.
#'
#' @return Input dataframe with an additional \code{exposure_value_usd_share} column.
#' @export
add_exposure_share_from_npv <- function(portfolio_results) {
  grouping_keys <- c(
    ".portfolio_index", "company_id", "company_name", "term", "loss_given_default",
    "sector", "technology"
  )
  grouping_keys <- grouping_keys[grouping_keys %in% colnames(portfolio_results)]

  # G(NPV): NPV-share allocation needs non-negative weights. A negative
  # technology NPV would allocate negative exposure, and an all-non-positive
  # company NPV would silently drop the loan from every EAD-weighted aggregate.
  # Guard: clamp component NPVs to >= 0 for the share; if a company's clamped
  # total is 0 (every technology non-positive), fall back to an equal split.
  df <- portfolio_results |>
    dplyr::group_by(.data$.portfolio_index, .data$run_id) |>
    dplyr::mutate(
      has_trisk_npv = any(!is.na(.data$net_present_value_baseline)),
      npv_pos       = pmax(.data$net_present_value_baseline, 0),
      total_pos     = sum(.data$npv_pos, na.rm = TRUE),
      n_tech        = dplyr::n(),
      npv_share = dplyr::case_when(
        !.data$has_trisk_npv ~ NA_real_,
        .data$total_pos > 0  ~ .data$npv_pos / .data$total_pos,
        TRUE                 ~ 1 / .data$n_tech
      ),
      exposure_value_usd_share_run = .data$exposure_value_usd * .data$npv_share
    ) |>
    dplyr::ungroup()

  # Surface the company/run groups where the guard bit, so the fallback is visible.
  flagged <- portfolio_results |>
    dplyr::group_by(.data$.portfolio_index, .data$run_id, .data$company_id) |>
    dplyr::summarise(
      bit = any(.data$net_present_value_baseline < 0, na.rm = TRUE) ||
        (any(!is.na(.data$net_present_value_baseline)) &&
          sum(pmax(.data$net_present_value_baseline, 0), na.rm = TRUE) == 0),
      .groups = "drop"
    ) |>
    dplyr::filter(.data$bit)
  if (nrow(flagged) > 0) {
    warning("add_exposure_share_from_npv(): non-positive baseline NPV in ",
            length(unique(flagged$company_id)), " company(ies); negative ",
            "technology NPVs were clamped to 0 and all-non-positive companies were ",
            "split equally across technologies. Affected company_id(s): ",
            paste(unique(flagged$company_id), collapse = ", "), call. = FALSE)
  }

  grouped <- df |>
    dplyr::group_by(dplyr::across(dplyr::all_of(grouping_keys))) |>
    dplyr::summarise(
      avg_exposure_value_usd_share = dplyr::if_else(
        all(is.na(.data$exposure_value_usd_share_run)),
        NA_real_,
        mean(.data$exposure_value_usd_share_run, na.rm = TRUE)
      ),
      .groups = "drop"
    )

  original_exposure <- portfolio_results |>
    dplyr::group_by(.data$.portfolio_index, .data$company_id, .data$company_name, .data$term, .data$loss_given_default) |>
    dplyr::summarise(exposure_value_usd = mean(.data$exposure_value_usd, na.rm = TRUE), .groups = "drop")

  grouped <- grouped |>
    dplyr::left_join(
      original_exposure,
      by = c(".portfolio_index", "company_id", "company_name", "term", "loss_given_default")
    ) |>
    dplyr::group_by(.data$.portfolio_index, .data$company_id, .data$company_name, .data$term, .data$loss_given_default) |>
    dplyr::mutate(
      grouped_total = dplyr::if_else(
        all(is.na(.data$avg_exposure_value_usd_share)),
        NA_real_,
        sum(.data$avg_exposure_value_usd_share, na.rm = TRUE)
      )
    ) |>
    dplyr::ungroup() |>
    dplyr::mutate(
      scaling_factor = dplyr::if_else(
        is.na(.data$grouped_total),
        NA_real_,
        dplyr::if_else(.data$grouped_total == 0, 0, .data$exposure_value_usd / .data$grouped_total)
      ),
      exposure_value_usd_share = .data$avg_exposure_value_usd_share * .data$scaling_factor
    ) |>
    dplyr::select(dplyr::all_of(grouping_keys), "exposure_value_usd_share")

  portfolio_results |>
    dplyr::left_join(grouped, by = grouping_keys)
}


#' Aggregate simple portfolio input rows
#'
#' @param portfolio_data A simple portfolio dataframe.
#'
#' @return Portfolio aggregated at company/term/lgd level.
#' @export
aggregate_simple_portfolio <- function(portfolio_data) {
  portfolio_data |>
    dplyr::group_by(.data$company_id, .data$company_name, .data$term, .data$loss_given_default) |>
    dplyr::summarise(
      exposure_value_usd = sum(.data$exposure_value_usd, na.rm = TRUE),
      .groups = "drop"
    )
}


#' Aggregate TRISK outputs for simple portfolio analysis
#'
#' @param npv_results NPV results from \code{trisk.model::run_trisk_model()}.
#' @param pd_results PD results from \code{trisk.model::run_trisk_model()}.
#'
#' @return TRISK outputs aggregated without asset/country dimensions.
#' @export
aggregate_trisk_outputs_simple <- function(npv_results, pd_results) {
  npv_agg <- npv_results |>
    dplyr::group_by(.data$run_id, .data$company_id, .data$sector, .data$technology) |>
    dplyr::summarise(
      # Preserve NA for all-NA groups (symmetry with the full runner's X1 helper);
      # collapsing to 0 would turn missing model output into a real zero NPV.
      net_present_value_baseline = if (all(is.na(.data$net_present_value_baseline))) {
        NA_real_
      } else {
        sum(.data$net_present_value_baseline, na.rm = TRUE)
      },
      net_present_value_shock = if (all(is.na(.data$net_present_value_shock))) {
        NA_real_
      } else {
        sum(.data$net_present_value_shock, na.rm = TRUE)
      },
      .groups = "drop"
    )

  pd_agg <- pd_results |>
    dplyr::group_by(.data$run_id, .data$company_id, .data$sector, .data$term) |>
    dplyr::summarise(
      pd_baseline = stats::median(.data$pd_baseline, na.rm = TRUE),
      pd_shock = stats::median(.data$pd_shock, na.rm = TRUE),
      .groups = "drop"
    )

  dplyr::inner_join(
    npv_agg,
    pd_agg,
    by = c("run_id", "company_id", "sector"),
    relationship = "many-to-many"
  )
}


#' Join simple portfolio to aggregated TRISK outputs
#'
#' @param portfolio_data Aggregated simple portfolio.
#' @param trisk_agg Aggregated TRISK outputs.
#'
#' @return Joined dataframe at company/term/lgd/sector/technology level.
#' @export
join_simple_portfolio_to_trisk <- function(portfolio_data, trisk_agg) {
  portfolio_data |>
    dplyr::left_join(
      trisk_agg,
      by = c("company_id", "term"),
      relationship = "many-to-many"
    )
}


#' Compute value-change and expected-loss metrics on exposure shares
#'
#' @param analysis_data Analysis dataset with exposure shares.
#'
#' @return Analysis dataset with additional metrics columns.
#' @export
compute_simple_portfolio_metrics <- function(analysis_data) {
  analysis_data |>
    dplyr::mutate(
      net_present_value_difference = .data$net_present_value_shock - .data$net_present_value_baseline,
      net_present_value_change = dplyr::if_else(
        is.na(.data$net_present_value_baseline) | .data$net_present_value_baseline == 0,
        0,
        .data$net_present_value_difference / .data$net_present_value_baseline
      ),
      exposure_share_loss_usd = .data$net_present_value_change * .data$exposure_value_usd_share,
      # Basel decomposition: EAD (exposure at default) is the gross allocated
      # exposure BEFORE the LGD haircut; LGD is a fraction OF EAD. So the
      # loss-given-default amount is EAD * LGD (lgd_weighted_exposure), and
      # EL = EAD * LGD * PD. (Previously this column held EAD*LGD, mislabelled.)
      exposure_at_default = .data$exposure_value_usd_share,
      lgd_weighted_exposure = .data$exposure_at_default * .data$loss_given_default,
      pd_difference = .data$pd_shock - .data$pd_baseline,
      expected_loss_baseline = .data$exposure_at_default * .data$loss_given_default * .data$pd_baseline,
      expected_loss_shock = .data$exposure_at_default * .data$loss_given_default * .data$pd_shock,
      expected_loss_difference = .data$exposure_at_default * .data$loss_given_default * .data$pd_difference
    )
}


#' Aggregate simple portfolio tech details back to input-row shape
#'
#' @param portfolio_results_detailed Detailed output from \code{run_trisk_on_simple_portfolio()}
#'   before dropping \code{exposure_value_usd}.
#'
#' @return Portfolio output with one row per input portfolio row.
#' @export
aggregate_simple_portfolio_results <- function(portfolio_results_detailed) {
  portfolio_results_detailed |>
    dplyr::group_by(
      .data$.portfolio_index,
      .data$company_id,
      .data$company_name,
      .data$term,
      .data$loss_given_default
    ) |>
    dplyr::summarise(
      exposure_value_usd = dplyr::first(.data$exposure_value_usd),
      exposure_loss_shock_usd = if (all(is.na(.data$exposure_share_loss_usd))) NA_real_ else sum(.data$exposure_share_loss_usd, na.rm = TRUE),
      expected_loss_baseline = if (all(is.na(.data$expected_loss_baseline))) NA_real_ else sum(.data$expected_loss_baseline, na.rm = TRUE),
      expected_loss_shock = if (all(is.na(.data$expected_loss_shock))) NA_real_ else sum(.data$expected_loss_shock, na.rm = TRUE),
      expected_loss_difference = if (all(is.na(.data$expected_loss_difference))) NA_real_ else sum(.data$expected_loss_difference, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      exposure_change_percent = dplyr::if_else(
        is.na(.data$exposure_value_usd) | .data$exposure_value_usd == 0,
        NA_real_,
        .data$exposure_loss_shock_usd / .data$exposure_value_usd
      )
    ) |>
    dplyr::relocate(
      "exposure_change_percent",
      .after = "exposure_loss_shock_usd"
    )
}
