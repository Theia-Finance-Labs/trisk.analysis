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
#'   \code{\link{check_portfolio_simple}}).
#' @param baseline_scenario String specifying the name of the baseline scenario.
#' @param target_scenario String specifying the name of the shock scenario.
#' @param ... Additional arguments passed to \code{\link[trisk.model]{run_trisk_model}}.
#'
#' @return A named list with:
#' \itemize{
#'   \item \code{portfolio_results_tech_detail}: company/term/sector/technology-level details.
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

  trisk_agg <- aggregate_trisk_outputs_simple(npv_results, pd_results)
  joined_data <- join_simple_portfolio_to_trisk(portfolio_data, trisk_agg)
  joined_data <- add_exposure_share_from_npv(joined_data)
  joined_data <- compute_simple_portfolio_metrics(joined_data)

  # Detail output: keep share-level columns and drop original exposure column.
  portfolio_results_tech_detail <- joined_data |>
    dplyr::select(-"exposure_value_usd")

  # Portfolio output: aggregate back to input-row shape.
  portfolio_results <- aggregate_simple_portfolio_results(portfolio_results_tech_detail)

  # Remove internal index from returned objects.
  portfolio_results_tech_detail <- portfolio_results_tech_detail |>
    dplyr::select(-".portfolio_index")
  portfolio_results <- portfolio_results |>
    dplyr::select(-".portfolio_index")

  return(list(
    portfolio_results_tech_detail = portfolio_results_tech_detail,
    portfolio_results = portfolio_results
  ))
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
#' exposure.
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

  df <- portfolio_results |>
    dplyr::group_by(.data$.portfolio_index, .data$run_id) |>
    dplyr::mutate(
      has_trisk_npv = any(!is.na(.data$net_present_value_baseline)),
      total_company_npv = dplyr::if_else(
        .data$has_trisk_npv,
        sum(.data$net_present_value_baseline, na.rm = TRUE),
        NA_real_
      )
    ) |>
    dplyr::ungroup() |>
    dplyr::mutate(
      npv_share = dplyr::if_else(
        is.na(.data$total_company_npv),
        NA_real_,
        dplyr::if_else(
          .data$total_company_npv == 0,
          0,
          .data$net_present_value_baseline / .data$total_company_npv
        )
      ),
      exposure_value_usd_share_run = .data$exposure_value_usd * .data$npv_share
    )

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
      net_present_value_baseline = sum(.data$net_present_value_baseline, na.rm = TRUE),
      net_present_value_shock = sum(.data$net_present_value_shock, na.rm = TRUE),
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
      exposure_at_default = .data$exposure_value_usd_share * .data$loss_given_default,
      pd_difference = .data$pd_shock - .data$pd_baseline,
      expected_loss_baseline = -.data$exposure_at_default * .data$pd_baseline,
      expected_loss_shock = -.data$exposure_at_default * .data$pd_shock,
      expected_loss_difference = -.data$exposure_at_default * .data$pd_difference
    )
}


#' Aggregate simple portfolio tech details back to input-row shape
#'
#' @param portfolio_results_tech_detail Detailed output from \code{run_trisk_on_simple_portfolio()}.
#'
#' @return Portfolio output with one row per input portfolio row.
#' @export
aggregate_simple_portfolio_results <- function(portfolio_results_tech_detail) {
  portfolio_results_tech_detail |>
    dplyr::group_by(
      .data$.portfolio_index,
      .data$company_id,
      .data$company_name,
      .data$term,
      .data$loss_given_default
    ) |>
    dplyr::summarise(
      exposure_value_usd = if (all(is.na(.data$exposure_value_usd_share))) NA_real_ else sum(.data$exposure_value_usd_share, na.rm = TRUE),
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
