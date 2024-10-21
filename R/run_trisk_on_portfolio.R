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
#' @param threshold max distance for validating a fuzzy match
#' @param method String specifying method to use for fuzzy matching. See help of stringdist::stringdistmatrix for possible values.
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
                                   threshold = 0.5,
                                   method = "lcs",
                                   ...) {
  # clean coltypes

  assets_data <- assets_data |>
    dplyr::mutate(
      asset_id = as.character(.data$asset_id),
      company_id = as.character(.data$company_id)
    )
  financial_data <- financial_data |>
    dplyr::mutate(
      company_id = as.character(.data$company_id)
    )


  check_portfolio(portfolio_data )
          
  if (any(is.na(portfolio_data$company_id))) {
    if (any(is.na(portfolio_data$company_name))) {

      countries_to_use <- portfolio_data |>
        dplyr::distinct(.data$country_iso2)
      portfolio_matched_companies <- assets_data |>
        dplyr::inner_join(countries_to_use, by = c("country_iso2")) |>
        dplyr::distinct(.data$company_id, .data$country_iso2)

    } else {
      cat("-- Fuzzy matching assets to portfolio")
      portfolio_data <- portfolio_data  |>
        fuzzy_match_company_ids(
          assets_data = assets_data,
          threshold = threshold,
          method = method
        )

      portfolio_matched_companies <- portfolio_data |>
        dplyr::filter(!is.na(.data$company_id)) |>
        dplyr::distinct(.data$company_id, .data$country_iso2)
        
    }
  } else {
    portfolio_matched_companies <- portfolio_data |>
      dplyr::filter(!is.na(.data$company_id)) |>
      dplyr::distinct(.data$company_id, .data$country_iso2)
  }



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
    dplyr::mutate(
      company_id = as.character(.data$company_id)
    )

  analysis_data <- portfolio_data |>
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
check_portfolio <- function(portfolio_data) {
  # List of required columns
  required_portfolio_columns <- c("company_id", "company_name","country_iso2", "exposure_value_usd", "term", "loss_given_default")

  # Check if all required columns are present
  if (!all(required_portfolio_columns %in% colnames(portfolio_data))) {
    missing_columns <- setdiff(required_portfolio_columns, colnames(portfolio_data))
    stop(paste("Error: Missing columns in portfolio_data:", paste(missing_columns, collapse = ", ")))
  }

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
#' @param method tring specifying method to use for fuzzy matching. See help of stringdist::stringdistmatrix for possible values.
#'
#' @return A data frame of portfolio data with fuzzy-matched company IDs.
#' @export
#'
fuzzy_match_company_ids <- function(portfolio_data, assets_data, threshold = 0.5, method = "lcs") {
  companies_with_ids <- assets_data |>
    dplyr::distinct(.data$company_id, .data$company_name)

  # Perform normalized Levenshtein distance fuzzy matching
  matched_companies <- stringdist::stringdistmatrix(portfolio_data$company_name, companies_with_ids$company_name, method = method) |>
    as.data.frame() |>
    dplyr::mutate(portfolio_index = dplyr::row_number()) |>
    tidyr::pivot_longer(cols = -.data$portfolio_index, names_to = "npv_index", values_to = "distance") |>
    # Normalize the distance by dividing by the max string length between the portfolio and company name
    dplyr::mutate(
      normalized_distance = .data$distance /
        pmax(
          nchar(portfolio_data$company_name[.data$portfolio_index]),
          nchar(companies_with_ids$company_name[as.integer(gsub("V", "", .data$npv_index))])
        )
    ) |>
    # Group by the portfolio index and find the minimum normalized distance
    dplyr::group_by(.data$portfolio_index) |>
    dplyr::slice_min(order_by = .data$normalized_distance, n = 1) |>
    dplyr::ungroup() |>
    # Filter by the normalized threshold
    dplyr::filter(.data$normalized_distance <= threshold)

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

  analysis_data <- dplyr::inner_join(
    npv_results |> dplyr::select(-.data$company_name),
    pd_results |> dplyr::select(-.data$company_name),
    by = c("run_id", "company_id", "sector")
  )


# Check if any company_name is NA
if (any(is.na(portfolio_data$company_name))) {
  
  # Aggregate facts for country only
  analysis_data <- analysis_data |> 
    aggregate_facts_trisk(group_cols = c("country_iso2", "sector", "technology", "term"))
  
  # Define the join keys
  join_keys <- c("country_iso2", "sector", "technology", "term")
  
  # Merge the portfolio data
  full_joined_data <- merge_portfolio(portfolio_data, analysis_data, join_keys)
} else {
  # Define the join keys including run_id and company_id
  join_keys <- c("run_id", "company_id", "country_iso2", "sector", "technology", "term")
  
  # Merge the portfolio data
  full_joined_data <- merge_portfolio(portfolio_data, analysis_data, join_keys)
}


  return(full_joined_data)
}


# Helper function to merge portfolio data based on the presence of term
merge_portfolio <- function(portfolio, analysis, join_keys) {
  portfolio_with_term <- portfolio |> dplyr::filter(!is.na(term))
  portfolio_without_term <- portfolio |> dplyr::filter(is.na(term))
  
  # Merge portfolio_with_term including the term column
  merged_with_term <- portfolio_with_term |>
    dplyr::left_join(analysis, by = join_keys)
  
  # Filter analysis where term is 1 and drop the term column for the merge
  analysis_filtered <- analysis |>
    dplyr::filter(term == 1) |>
    dplyr::select(-term) |>
    dplyr::mutate(
      pd_baseline=NA_real_,
      pd_shock=NA_real_
    )
  
  # Merge portfolio_without_term without the term column
  merged_without_term <- portfolio_without_term |>
    dplyr::left_join(analysis_filtered, by = setdiff(join_keys, "term"))
  
  # Combine both merged datasets
  dplyr::bind_rows(merged_with_term, merged_without_term)
}