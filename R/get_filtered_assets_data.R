#' Get filtered assets data based on provided criteria
#'
#' This function loads and filters the assets data based on criteria such as country, sector, technology, and company name.
#'
#' @param input_path The path to the input data directory containing the necessary files for the TRISK model.
#' @param country_iso2 A character vector of ISO2 country codes to filter the assets. Defaults to NULL.
#' @param sector A character vector of sectors to filter the assets. Defaults to NULL.
#' @param technology A character vector of technologies to filter the assets. Defaults to NULL.
#' @param company_name A character vector of company names to filter the assets. Defaults to NULL.
#'
#' @return A list containing the filtered assets data and other input data required for the TRISK model.
get_filtered_assets_data <- function(input_path,
                                     country_iso2 = NULL,
                                     sector = NULL,
                                     technology = NULL,
                                     company_name = NULL) {
  # Load the input data once
  input_data_list <- trisk.model::st_read_agnostic(input_path)

  # Filter assets data based on the provided criteria
  filtered_assets_data <- filter_assets(
    assets_data = input_data_list$assets_data,
    country_iso2 = country_iso2,
    sector = sector,
    technology = technology,
    company_name = company_name
  )

  # Update the input data list with the filtered assets data
  input_data_list$assets_data <- filtered_assets_data

  return(input_data_list)
}

#' Filter assets based on provided criteria
#'
#' This function filters the assets data based on criteria such as country, sector, technology, and company name.
#'
#' @param assets_data The assets data to be filtered.
#' @param country_iso2 A character vector of ISO2 country codes to filter the assets. Defaults to NULL.
#' @param sector A character vector of sectors to filter the assets. Defaults to NULL.
#' @param technology A character vector of technologies to filter the assets. Defaults to NULL.
#' @param company_name A character vector of company names to filter the assets. Defaults to NULL.
#'
#' @return A tibble containing the filtered assets data.
filter_assets <- function(assets_data,
                          country_iso2 = NULL,
                          sector = NULL,
                          technology = NULL,
                          company_name = NULL) {
  # Ensure the input data is a tibble
  assets_data <- tibble::as_tibble(assets_data)

  # Apply filters if they are provided
  if (!is.null(country_iso2)) {
    assets_data <- assets_data %>%
      dplyr::filter(country_iso2 %in% !!country_iso2)
  }

  if (!is.null(sector)) {
    assets_data <- assets_data %>%
      dplyr::filter(sector %in% !!sector)
  }

  if (!is.null(technology)) {
    assets_data <- assets_data %>%
      dplyr::filter(technology %in% !!technology)
  }

  if (!is.null(company_name)) {
    assets_data <- assets_data %>%
      dplyr::filter(company_name %in% !!company_name)
  }

  # Return the filtered tibble
  return(assets_data)
}
