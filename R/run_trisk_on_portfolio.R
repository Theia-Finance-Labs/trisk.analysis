#' Run TRISK Model on Portfolio
#'
#' @description
#' This function runs the TRISK model on a given portfolio, processing various input data
#' and returning analysis results. It's designed to be the primary data processing function
#' for generating plots.
#'
#' @param assets_data Data frame containing asset information.
#' @param scenarios_data Data frame containing scenario information.
#' @param financial_data Data frame containing financial information.
#' @param carbon_data Data frame containing carbon price information.
#' @param portfolio_data Data frame containing portfolio information.
#' @param baseline_scenario String specifying the name of the baseline scenario.
#' @param target_scenario String specifying the name of the shock scenario.
#' @param ... Additional arguments passed to \code{\link[trisk.model]{run_trisk_model}}.
#'
#' @return A data frame containing the processed and analyzed portfolio data.
#' @export
#'
run_trisk_on_portfolio <- function(assets_data,
                                   scenarios_data,
                                   financial_data,
                                   carbon_data,
                                   portfolio_data,
                                   baseline_scenario,
                                   target_scenario,
                                   ...) {
  # clean coltypes

  assets_data <- assets_data %>%
    dplyr::mutate(
      asset_id = as.character(.data$asset_id),
      company_id = as.character(.data$company_id)
    )
  financial_data <- financial_data %>%
    dplyr::mutate(
      company_id = as.character(.data$company_id)
    )

  if (!("company_id" %in% colnames(portfolio_data))){
    cat("-- Fuzzy matching assets to portfolio")
    portfolio_data <- portfolio_data %>%
      check_portfolio_and_match_company_id(assets_data = assets_data)

    portfolio_matched_companies <- portfolio_data %>%
      dplyr::filter(!is.na(.data$company_id)) %>%
      dplyr::distinct(.data$company_id, .data$country_iso2)
  } else{
    portfolio_matched_companies <- portfolio_data
  }

  assets_data_filtered <- assets_data %>%
    dplyr::inner_join(portfolio_matched_companies, by = c("company_id", "country_iso2"))

  cat("-- Start Trisk")
  st_results <- run_trisk_standard(
    assets_data = assets_data_filtered,
    scenarios_data = scenarios_data,
    financial_data = financial_data,
    carbon_data = carbon_data,
    baseline_scenario = baseline_scenario,
    target_scenario = target_scenario,
    ...
  )

  npv_results <- st_results$npv_results %>%
    dplyr::mutate(
      asset_id = as.character(.data$asset_id),
      company_id = as.character(.data$company_id)
    )
  pd_results <- st_results$pd_results %>%
    dplyr::mutate(
      company_id = as.character(.data$company_id)
    )

  analysis_data <- portfolio_data %>%
    join_trisk_outputs_to_portfolio(npv_results = npv_results, pd_results = pd_results)

  return(analysis_data)
}

#' Check Portfolio and Match Company IDs
#'
#' @description
#' This function checks if the portfolio data contains all required columns and
#' performs a fuzzy match to assign company IDs based on company names.
#'
#' @param portfolio_data Data frame containing portfolio information.
#' @param assets_data Data frame containing asset information with company IDs.
#'
#' @return A data frame of portfolio data with matched company IDs.
#' @export
check_portfolio_and_match_company_id <- function(portfolio_data, assets_data) {
  # List of required columns
  required_portfolio_columns <- c("company_name", "country_iso2", "exposure_value_usd", "term", "loss_given_default")

  # Check if all required columns are present
  if (!all(required_portfolio_columns %in% colnames(portfolio_data))) {
    missing_columns <- setdiff(required_portfolio_columns, colnames(portfolio_data))
    stop(paste("Error: Missing columns in portfolio_data:", paste(missing_columns, collapse = ", ")))
  }
  portfolio_data <- portfolio_data |>
    fuzzy_match_company_ids(assets_data = assets_data)

  return(portfolio_data)
}

#' Fuzzy Match Company IDs
#'
#' @description
#' This function performs a fuzzy match between portfolio company names and
#' asset company names to assign company IDs to the portfolio data.
#'
#' @param portfolio_data Data frame containing portfolio information.
#' @param assets_data Data frame containing asset information with company IDs.
#' @param threshold Numeric value for the matching threshold. Default is 0.2.
#'
#' @return A data frame of portfolio data with fuzzy-matched company IDs.
#' @export
#'
fuzzy_match_company_ids <- function(portfolio_data, assets_data, threshold = 0.2) {
  companies_with_ids <- assets_data |>
    dplyr::distinct(.data$company_id, .data$company_name)

  # Perform fuzzy matching
  matched_companies <- stringdist::stringdistmatrix(portfolio_data$company_name, companies_with_ids$company_name, method = "lv") |>
    as.data.frame() |>
    dplyr::mutate(portfolio_index = dplyr::row_number()) |>
    tidyr::pivot_longer(cols = -.data$portfolio_index, names_to = "npv_index", values_to = "distance") |>
    dplyr::group_by(.data$portfolio_index) |>
    dplyr::slice_min(order_by = .data$distance, n = 1) |>
    dplyr::ungroup() |>
    dplyr::filter(.data$distance <= threshold * nchar(portfolio_data$company_name[.data$portfolio_index]))

  # Join the matched company_ids to the portfolio data
  portfolio_data_with_ids <- portfolio_data |>
    dplyr::mutate(portfolio_index = dplyr::row_number()) |>
    dplyr::left_join(matched_companies, by = "portfolio_index") |>
    dplyr::left_join(companies_with_ids |> dplyr::mutate(npv_index = paste0("V", dplyr::row_number())), by = "npv_index") |>
    dplyr::select(-.data$portfolio_index, -.data$npv_index, -.data$distance, -.data$company_name.y) |>
    dplyr::rename(company_name = .data$company_name.x)

  return(portfolio_data_with_ids)
}

#' Join TRISK Outputs to Portfolio
#'
#' @description
#' This function joins the TRISK model outputs (NPV and PD results) to the portfolio data.
#'
#' @param portfolio_data Data frame containing portfolio information.
#' @param npv_results Data frame containing NPV (Net Present Value) results from TRISK model.
#' @param pd_results Data frame containing PD (Probability of Default) results from TRISK model.
#'
#' @return A data frame of portfolio data joined with TRISK model outputs.
#' @export
#'
join_trisk_outputs_to_portfolio <- function(portfolio_data, npv_results, pd_results) {
  # Merge with npv results
  portfolio_with_npv <- portfolio_data |>
    dplyr::left_join(npv_results |> dplyr::select(-.data$company_name), by = c("company_id", "sector", "technology"))

  # Merge portfolio to pd results
  full_joined_data <- portfolio_with_npv |>
    dplyr::left_join(pd_results |> dplyr::select(-.data$company_name), by = c("run_id", "company_id", "sector", "term"))

  return(full_joined_data)
}
