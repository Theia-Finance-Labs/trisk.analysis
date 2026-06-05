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

  portfolio_data <- portfolio_data |>
    dplyr::mutate(company_id = as.character(.data$company_id))

  check_portfolio(portfolio_data)
  warn_scenario_family_mismatch(baseline_scenario, target_scenario)  # NM1

  if (any(is.na(portfolio_data$company_id))) {
    if (any(is.na(portfolio_data$company_name))) {
      countries_to_use <- portfolio_data |>
        dplyr::distinct(.data$country_iso2)
      portfolio_matched_companies <- assets_data |>
        dplyr::inner_join(countries_to_use, by = c("country_iso2")) |>
        dplyr::distinct(.data$company_id, .data$country_iso2)
    } else {
      cat("-- Fuzzy matching assets to portfolio")
      portfolio_data <- portfolio_data |>
        dplyr::select(-"company_id") |>
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

  # D1: warn (don't silently drop) when a portfolio term is outside the Merton grid.
  warn_terms_outside_grid(portfolio_data, pd_results)

  analysis_data <- portfolio_data |>
    join_trisk_outputs_to_portfolio(npv_results = npv_results, pd_results = pd_results)

  # A1: attach an audit-trail / reproducibility record for the caller to persist.
  attr(analysis_data, "trisk_run_meta") <- build_trisk_run_meta(
    baseline_scenario = baseline_scenario,
    target_scenario   = target_scenario,
    run_id            = unique(stats::na.omit(pd_results$run_id)),
    extra_args        = list(...)
  )

  return(analysis_data)
}

#' Check Portfolio and Match Company IDs
#'
#' @description
#' This function checks if the portfolio data contains all required columns and
#' performs a fuzzy match to assign company IDs based on company names.
#'
#' @param portfolio_data Data frame containing portfolio information.
#'
#' @return A data frame of portfolio data with matched company IDs.
#' @export
check_portfolio <- function(portfolio_data) {
  # Required columns for the FULL runner. sector + technology are mandatory here
  # (V1): the runner joins TRISK outputs to the portfolio on them, so omitting
  # them previously produced an opaque dplyr join error only after a full model
  # run. They are deliberately NOT required by the simple runner
  # (check_portfolio_simple), which allocates exposure across technologies by NPV
  # share and needs no technology column on the input.
  required_portfolio_columns <- c(
    "company_id", "company_name", "country_iso2", "exposure_value_usd",
    "term", "loss_given_default", "sector", "technology"
  )

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
#' @param threshold Numeric value for the matching threshold. Default is 0.5.
#' @param method String specifying the method to use for fuzzy matching. See help of stringdist::stringdistmatrix for possible values.
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

  # CX2: slice_min() keeps ties, so a portfolio name equidistant from several
  # company names would match all of them and duplicate that loan (full exposure
  # applied to each). Warn naming the affected portfolio names and keep one match
  # per portfolio row so exposure is not silently inflated.
  tie_counts <- matched_companies |>
    dplyr::count(.data$portfolio_index, name = "n_match") |>
    dplyr::filter(.data$n_match > 1)
  if (nrow(tie_counts) > 0) {
    tied_names <- unique(portfolio_data$company_name[tie_counts$portfolio_index])
    warning(
      "fuzzy_match_company_ids(): ", nrow(tie_counts),
      " portfolio name(s) tied across multiple companies at the same distance; ",
      "keeping the first match each. Disambiguate by supplying company_id. ",
      "Affected: ", paste(tied_names, collapse = ", "),
      call. = FALSE
    )
    matched_companies <- matched_companies |>
      dplyr::group_by(.data$portfolio_index) |>
      dplyr::slice(1) |>
      dplyr::ungroup()
  }

  # Join the matched company_ids to the portfolio data
  portfolio_data_with_ids <- portfolio_data |>
    dplyr::mutate(portfolio_index = dplyr::row_number()) |>
    dplyr::left_join(matched_companies, by = "portfolio_index") |>
    dplyr::left_join(companies_with_ids |> dplyr::mutate(npv_index = paste0("V", dplyr::row_number())), by = "npv_index") |>
    dplyr::select(-"portfolio_index", -"npv_index", -"distance", -"company_name.y") |>
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
  # X1 fix: TRISK NPV output is asset-level, but the portfolio is joined without
  # asset_id. Without this collapse, a company with multiple assets in one
  # (sector, technology) fans a single loan into N rows and the full
  # exposure_value_usd is then applied to each -> N x EAD/EL. Sum NPV across a
  # company's assets within each (run, company, sector, technology, country) so
  # every loan matches one row per technology and contributes its exposure once.
  # Mirrors aggregate_trisk_outputs_simple() in the simple runner.
  npv_results <- aggregate_npv_across_assets(npv_results)

  analysis_data <- dplyr::inner_join(
    npv_results,
    pd_results |> dplyr::select(-"company_name"),
    by = c("run_id", "company_id", "sector"),
    relationship = "many-to-many"
  )


  # Check if both company_name and country_name are NA
  if (any(is.na(portfolio_data$company_name)) & any(is.na(portfolio_data$company_id))) {
    # Aggregate facts for country only
    analysis_data <- analysis_data |>
      aggregate_facts_trisk(group_cols = c("country_iso2", "sector", "technology", "term"))

    # Define the join keys
    join_keys <- c("country_iso2", "sector", "technology", "term")

    # Merge the portfolio data
    full_joined_data <- merge_portfolio(portfolio_data, analysis_data, join_keys)
  } else {
    # Define the join keys including run_id and company_id
    join_keys <- c("company_id", "country_iso2", "sector", "technology", "term")

    # Merge the portfolio data
    full_joined_data <- merge_portfolio(portfolio_data, analysis_data, join_keys)
  }


  return(full_joined_data)
}


# Internal — collapse asset-level NPV to (run, company, sector, technology,
# country) grain so a single portfolio loan does not fan out across a company's
# assets (X1). NPV is summed across assets = the company-technology total. Other
# columns (asset_id, asset_name, model-derived difference/change) are dropped;
# net_present_value_difference and value-change metrics are recomputed downstream
# by compute_analysis_metrics().
aggregate_npv_across_assets <- function(npv_results) {
  npv_results |>
    dplyr::group_by(
      .data$run_id, .data$company_id, .data$sector,
      .data$technology, .data$country_iso2
    ) |>
    dplyr::summarise(
      # Preserve NA for an all-NA group instead of collapsing to 0 (which would
      # later divide into NaN/Inf in compute_analysis_metrics). Mirrors the
      # all-NA guards in the simple runner's aggregation.
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
}

# Helper function to merge portfolio data based on the presence of term
merge_portfolio <- function(portfolio, analysis, join_keys) {
  portfolio_with_term <- portfolio |> dplyr::filter(!is.na(.data$term))
  portfolio_without_term <- portfolio |> dplyr::filter(is.na(.data$term))

  # Merge portfolio_with_term including the term column
  merged_with_term <- portfolio_with_term |>
    dplyr::left_join(analysis, by = join_keys)

  # Filter analysis where term is 1 and drop the term column for the merge
  analysis_filtered <- analysis |>
    dplyr::filter(.data$term == 1) |>
    dplyr::select(-"term") |>
    dplyr::mutate(
      pd_baseline = NA_real_,
      pd_shock = NA_real_
    )

  # Merge portfolio_without_term without the term column
  merged_without_term <- portfolio_without_term |>
    dplyr::left_join(analysis_filtered, by = setdiff(join_keys, "term"))

  # Combine both merged datasets
  dplyr::bind_rows(merged_with_term, merged_without_term)
}
