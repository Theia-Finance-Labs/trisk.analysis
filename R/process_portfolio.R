#' Data load function to generate plots
#'
#' @description
#'  The dataframe in output of this function should always be
#'  the one used as input for the plots preprocessing functions
#'
#' @param granularity granularity
#' @param trisk_start_year (default) sets to the earliest year of multi_cripy_data
#' @param multi_crispy_data multi_crispy_data
#' @param portfolio_data portfolio_data
#'
#' @export
#'
load_input_plots_data_from_tibble <-
  function(npv_results
          pd_results,
           portfolio_data,
           granularity = c("company_id", "company_name", "ald_sector", "ald_business_unit")) {

    # List of required columns
    required_portfolio_columns <- c("company_name", "country_iso2", "exposure_value_usd", "term", "loss_given_default")

    # Check if all required columns are present
    if (!all(required_portfolio_columns %in% colnames(portfolio_data))) {
      missing_columns <- setdiff(required_portfolio_columns, colnames(portfolio_data))
      stop(paste("Error: Missing columns in portfolio_data:", paste(missing_columns, collapse = ", ")))
    }
    portfolio_data <- portfolio_data |>
        aggregate_portfolio_facts(group_cols = granularity)


    trisk_data <-
      create_analysis_data(portfolio_data, npv_results, pd_results, portfolio_crispy_merge_cols) |>
        aggregate_crispy_facts(group_cols = granularity) |>
        aggregate_equities() |>
        compute_analysis_metrics() 

    return(trisk_data)
  }


#' Title
#'
#' @param portfolio_data_path
#'
read_portfolio_data <- function(portfolio_data_path=NULL) {
  if (!is.null(portfolio_data_path)) {
    portfolio_data <- readr::read_csv(
      portfolio_data_path,
      col_types = readr::cols_only(
        company_name = "c",
        country_iso2 = "c",
        exposure_value_usd = "d",
        term = "c",
        loss_given_default = "d"
      )
    ) %>%
      convert_date_column(colname="expiration_date")

  } else {
    portfolio_data <- tibble::tibble(
      portfolio_id = character(),
      asset_type = character(),
      company_id = character(),
      company_name = character(),
      ald_sector = character(),
      ald_business_unit = character(),
      exposure_value_usd = double(),
      expiration_date = date(),
      loss_given_default = double(),
      pd_portfolio = double()
    )
  }

  return(portfolio_data)
}



#' Title
#'
#' @param portfolio_data portfolio_data
#' @param group_cols group_cols
#'
#'
aggregate_portfolio_facts <- function(portfolio_data, group_cols) {
  portfolio_data <- portfolio_data |>
    dplyr::group_by_at(group_cols) |>
    dplyr::summarize(
      exposure_value_usd = sum(.data$exposure_value_usd),
      loss_given_default = stats::median(loss_given_default, na.rm = T),
      pd_portfolio = stats::median(.data$pd_portfolio, na.rm = T),
      .groups = "drop"
    )

  return(portfolio_data)
}
