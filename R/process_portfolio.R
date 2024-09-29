#' Data load function to generate plots
#'
#' @description
#'  The dataframe in output of this function should always be
#'  the one used as input for the plots preprocessing functions


#' @param assets_data Data frame containing asset information.
#' @param scenarios_data Data frame containing scenario information.
#' @param financial_data Data frame containing financial information.
#' @param carbon_data Data frame containing carbon price information.
#' @param portfolio_data portfolio_data
#' @param baseline_scenario String specifying the name of the baseline scenario.
#' @param target_scenario String specifying the name of the shock scenario.
#' @param granularity granularity
#' @param ... Additional arguments passed to \code{\link[trisk.model]{run_trisk_model}}
#'
#' @export
#'
run_trisk_on_portfolio <-
  function(assets_data,
           scenarios_data,
           financial_data,
           carbon_data,
           portfolio_data,
           baseline_scenario,
           target_scenario,
           granularity = c("company_id", "sector", "technology", "term"),
           ...) {


    # clean coltypes

    assets_data <- assets_data %>%
      dplyr::mutate(
        asset_id = as.character(asset_id),
        company_id = as.character(asset_id)
      )
      financial_data <- financial_data %>%
        dplyr::mutate(
        company_id = as.character(company_id)
      )

    cat("-- Matching assets to portfolio")
    portfolio_data <- portfolio_data %>%
      check_portfolio_and_match_company_id(assets_data=assets_data)

    matched_companies <- portfolio_data %>%
      dplyr::filter(!is.na(company_id)) %>%
      dplyr::distinct(company_id) %>%
      dplyr::pull()

    assets_data_filtered <- assets_data %>%
      dplyr::filter(.data$company_id %in% matched_companies)

    cat("-- Start Trisk")
    st_results <- run_trisk_model(
      assets_data = assets_data_filtered,
      scenarios_data = scenarios_data,
      financial_data = financial_data,
      carbon_data = carbon_data,
      baseline_scenario = baseline_scenario,
      target_scenario = target_scenario
    )

    npv_results <- st_results$npv_results%>%
      dplyr::mutate(
        asset_id = as.character(asset_id),
        company_id = as.character(asset_id)
      )
    pd_results <- st_results$pd_results%>%
        dplyr::mutate(
        company_id = as.character(company_id)
      )

    analysis_data <- portfolio_data |>
        join_trisk_outputs_to_portfolio(npv_results=npv_results, pd_results=pd_results) |>
        aggregate_facts(group_cols = granularity) |>
        compute_analysis_metrics()

    return(analysis_data)
  }



check_portfolio_and_match_company_id <- function(portfolio_data, assets_data){
    # List of required columns
    required_portfolio_columns <- c("company_name", "country_iso2", "exposure_value_usd", "term", "loss_given_default")

    # Check if all required columns are present
    if (!all(required_portfolio_columns %in% colnames(portfolio_data))) {
      missing_columns <- setdiff(required_portfolio_columns, colnames(portfolio_data))
      stop(paste("Error: Missing columns in portfolio_data:", paste(missing_columns, collapse = ", ")))
    }
    portfolio_data <- portfolio_data |>
        fuzzy_match_company_ids(assets_data=assets_data)

  return(portfolio_data)
}

fuzzy_match_company_ids <- function(portfolio_data, assets_data, threshold = 0.2) {
  companies_with_ids <- assets_data |>
    dplyr::distinct(.data$company_id, .data$company_name)

  # Perform fuzzy matching
  matched_companies <- stringdist::stringdistmatrix(portfolio_data$company_name, companies_with_ids$company_name, method = "lv") |>
    as.data.frame() |>
    dplyr::mutate(portfolio_index = dplyr::row_number()) |>
    tidyr::pivot_longer(cols = -portfolio_index, names_to = "npv_index", values_to = "distance") |>
    dplyr::group_by(.data$portfolio_index) |>
    dplyr::slice_min(order_by = .data$distance, n = 1) |>
    dplyr::ungroup() |>
    dplyr::filter(.data$distance <= threshold * nchar(portfolio_data$company_name[.data$portfolio_index]))

  # Join the matched company_ids to the portfolio data
  portfolio_data_with_ids <- portfolio_data |>
    dplyr::mutate(portfolio_index = dplyr::row_number()) |>
    dplyr::left_join(matched_companies, by = "portfolio_index") |>
    dplyr::left_join(companies_with_ids |> dplyr::mutate(npv_index = paste0("V", dplyr::row_number())), by = "npv_index") |>
    dplyr::select(-portfolio_index, -npv_index, -distance, -company_name.y) |>
    dplyr::rename(company_name = .data$company_name.x)

  return(portfolio_data_with_ids)
}

join_trisk_outputs_to_portfolio <- function(portfolio_data, npv_results, pd_results) {
  # Merge portfolio to pd results using company_id
  portfolio_with_pd <- portfolio_data |>
    dplyr::left_join(pd_results |> dplyr::select(-company_name), by = c("company_id", "sector", "term"))

  # Merge with npv results using company_id
  full_joined_data <- portfolio_with_pd |>
    dplyr::left_join(npv_results |> dplyr::select(-company_name), by = c("run_id", "company_id", "sector", "technology"))

  return(full_joined_data)
}

