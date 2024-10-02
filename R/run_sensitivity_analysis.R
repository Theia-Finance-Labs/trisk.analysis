# run_trisk_sa.R

#' Run TRISK sensitivity analysis on multiple scenarios
#'
#' This function performs a sensitivity analysis by running the TRISK model on multiple scenarios.
#' It takes a list of parameter sets and runs the TRISK model for each set, returning a comprehensive
#' set of results that includes net present value (NPV), probability of default (PD), company trajectories, and model parameters.
#'
#' @param assets_data Data frame containing asset information.
#' @param scenarios_data Data frame containing scenario information.
#' @param financial_data Data frame containing financial information.
#' @param carbon_data Data frame containing carbon price information.
#' @param run_params A list of parameter sets where each set contains the required parameters for a single TRISK model run.
#'        Each parameter set must include `scenario_geography`, `baseline_scenario`, `target_scenario`, and `shock_year`. Find their definition and other Trisk parameters at \code{\link[trisk.model]{run_trisk_model}}
#' @param ... Additional arguments passed to \code{\link{get_filtered_assets_data}} (`country_iso2`, `sector`, `technology`, and `company_name`).
#'
#' @return A list of tibbles containing the combined results for all runs. The list includes tibbles for NPV results (`npv`),
#'         PD results (`pd`), company trajectories (`trajectories`), and model parameters (`params`).
#' @export
run_trisk_sa <- function(assets_data, scenarios_data, financial_data, carbon_data, run_params, ...) {
  print(paste("Starting the execution of", length(run_params), "total runs"))

  n_completed_runs <- 0

  # Initialize lists to store stacked results
  npv_results_list <- list()
  pd_results_list <- list()
  company_trajectories_list <- list()
  params_df_list <- list()
  
  assets_data_filtered <- get_filtered_assets_data(asset_data, ...)
  
  # Loop over each set of parameters in run_params
  for (i in seq_along(run_params)) {
    a_run_params <- run_params[[i]]
    run_id <- uuid::UUIDgenerate()
    a_run_params <- c(a_run_params, list(run_id = run_id))
    
    # Merge the fixed input data with the current run parameters
    trisk_run_params <- c(
      list(
        assets_data = assets_data_filtered,
        scenarios_data = scenarios_data,
        financial_data = financial_data,
        carbon_data = carbon_data
      ),
      a_run_params
    )

    # Execute the TRISK model with the combined parameters
    result_tibbles <- do.call(
      trisk.model::run_trisk_model,
      trisk_run_params
    )

    # Process the parameters used in the run
    trisk_params <- do.call(trisk.model::process_params, c(list(fun = trisk.model::run_trisk_model), a_run_params))
    params_df <- tibble::as_tibble(trisk_params)

    npv_result <- result_tibbles$npv
    pd_result <- result_tibbles$pd
    trajectories_result <- result_tibbles$company_trajectories

    # Prepare and stack the results
    npv_results_list[[length(npv_results_list) + 1]] <- npv_result
    pd_results_list[[length(pd_results_list) + 1]] <- pd_result
    company_trajectories_list[[length(company_trajectories_list) + 1]] <- trajectories_result
    params_df_list[[length(params_df_list) + 1]] <- params_df

    n_completed_runs <- n_completed_runs + 1
    print(paste("Done", n_completed_runs, "/", length(run_params), "total runs"))
  }

  print("All runs completed.")

  # Combine the stacked results into tibbles
  result_tibbles <- list(
    npv = tibble::as_tibble(do.call(rbind, npv_results_list)),
    pd = tibble::as_tibble(do.call(rbind, pd_results_list)),
    trajectories = tibble::as_tibble(do.call(rbind, company_trajectories_list)),
    params = tibble::as_tibble(do.call(rbind, params_df_list))
  )

  # Return the list of tibbles
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
