# run_trisk_single_filtered.R

#' Run a single filtered TRISK model scenario
#'
#' This function runs the TRISK model for a single set of parameters, with the ability to filter assets 
#' based on country, sector, technology, and company name. The function returns a set of results including 
#' net present value (NPV), probability of default (PD), company trajectories, and model parameters.
#'
#' @param input_path The path to the input data directory containing the necessary files for the TRISK model.
#' @param run_params A list of parameters required for running the TRISK model, including `scenario_geography`, 
#'        `baseline_scenario`, `target_scenario`, and `shock_year`.
#' @param country_iso2 A character vector of ISO2 country codes to filter the assets. Defaults to NULL.
#' @param sector A character vector of sectors to filter the assets. Defaults to NULL.
#' @param technology A character vector of technologies to filter the assets. Defaults to NULL.
#' @param company_name A character vector of company names to filter the assets. Defaults to NULL.
#'
#' @return A list of tibbles containing the results of the TRISK model run. The list includes tibbles for NPV results (`npv`), 
#'         PD results (`pd`), company trajectories (`trajectories`), and model parameters (`params`).
#' @export
run_trisk_single_filtered <- function(input_path, 
                                      run_params,
                                      country_iso2 = NULL, 
                                      sector = NULL, 
                                      technology = NULL, 
                                      company_name = NULL) {
    
    # Get filtered assets data and other input data
    input_data_list <- get_filtered_assets_data(
        input_path = input_path,
        country_iso2 = country_iso2,
        sector = sector,
        technology = technology,
        company_name = company_name
    )
    
    # Merge the fixed input data with the current run parameters
    trisk_run_params <- c(
        list(
            assets_data = input_data_list$assets_data,
            scenarios_data = input_data_list$scenarios_data,
            financial_data = input_data_list$financial_data,
            carbon_data = input_data_list$carbon_data
        ),
        run_params
    )
    
    # Execute the TRISK model with the combined parameters
    output_list <- do.call(
        trisk.model::run_trisk_model,
        trisk_run_params
    )
    
    # Process the parameters used in the run
    trisk_params <- trisk.model:::process_params(fun = run_trisk_model, trisk_run_params)
    run_id <- uuid::UUIDgenerate() # TODO move into trisk.model:::process_params
    
    # Prepare and return the results as tibbles
    result_tibbles <- list(
        npv = tibble::as_tibble(trisk.model:::prepare_npv_results(output_list)),
        pd = tibble::as_tibble(trisk.model:::prepare_pd_results(output_list)),
        trajectories = tibble::as_tibble(trisk.model:::prepare_company_trajectories(output_list)),
        params = tibble::as_tibble(trisk.model:::prepare_params_df(trisk_params, run_id))
    )
    
    return(result_tibbles)
}

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
    input_data_list <- trisk.model:::st_read_agnostic(input_path)
    
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
