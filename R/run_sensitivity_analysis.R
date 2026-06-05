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
  # Ensure the input data is a tibble
  assets_data <- tibble::as_tibble(assets_data)

  print(paste("Starting the execution of", length(run_params), "total runs"))

  n_completed_runs <- 0

  # Initialize lists to store stacked results
  npv_results_list <- list()
  pd_results_list <- list()
  company_trajectories_list <- list()
  params_df_list <- list()
  failures <- list()  # SA1: collect per-run failures instead of aborting the sweep

  assets_data_filtered <- get_filtered_assets_data(assets_data, ...)

  # Loop over each set of parameters in run_params
  for (i in seq_along(run_params)) {
    a_run_params <- c(run_params[[i]], list(run_id = uuid::UUIDgenerate()))

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

    # SA1: isolate each run so one bad parameter set does not abort the sweep.
    one <- tryCatch(
      {
        result_tibbles <- do.call(trisk.model::run_trisk_model, trisk_run_params)
        trisk_params <- do.call(
          trisk.model::process_params,
          c(list(fun = trisk.model::run_trisk_model), a_run_params)
        )
        list(
          npv = result_tibbles$npv,
          pd = result_tibbles$pd,
          trajectories = result_tibbles$company_trajectories,
          params = tibble::as_tibble(trisk_params)
        )
      },
      error = function(e) {
        failures[[length(failures) + 1L]] <<- list(
          run = i, run_id = a_run_params$run_id, message = conditionMessage(e)
        )
        NULL
      }
    )

    if (!is.null(one)) {
      npv_results_list[[length(npv_results_list) + 1]] <- one$npv
      pd_results_list[[length(pd_results_list) + 1]] <- one$pd
      company_trajectories_list[[length(company_trajectories_list) + 1]] <- one$trajectories
      params_df_list[[length(params_df_list) + 1]] <- one$params
      n_completed_runs <- n_completed_runs + 1
      print(paste("Done", n_completed_runs, "/", length(run_params), "total runs"))
    }
  }

  if (length(failures) > 0) {
    warning(
      "run_trisk_sa(): ", length(failures), " of ", length(run_params),
      " run(s) failed and were skipped: ",
      paste(vapply(failures, function(f) sprintf("run %d (%s)", f$run, f$message),
                   character(1)), collapse = "; "),
      call. = FALSE
    )
  }
  print(paste("All runs completed:", n_completed_runs, "succeeded,",
              length(failures), "failed."))

  # Combine the stacked results (bind_rows tolerates differing columns / empties).
  result_tibbles <- list(
    npv = dplyr::bind_rows(npv_results_list),
    pd = dplyr::bind_rows(pd_results_list),
    trajectories = dplyr::bind_rows(company_trajectories_list),
    params = dplyr::bind_rows(params_df_list)
  )

  # Return the list of tibbles
  return(result_tibbles)
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
#' @keywords internal
get_filtered_assets_data <- function(assets_data,
                                     country_iso2 = NULL,
                                     sector = NULL,
                                     technology = NULL,
                                     company_name = NULL) {
  # Apply filters if they are provided
  if (!is.null(country_iso2)) {
    assets_data <- assets_data |>
      dplyr::filter(country_iso2 %in% !!country_iso2)
  }

  if (!is.null(sector)) {
    assets_data <- assets_data |>
      dplyr::filter(sector %in% !!sector)
  }

  if (!is.null(technology)) {
    assets_data <- assets_data |>
      dplyr::filter(technology %in% !!technology)
  }

  if (!is.null(company_name)) {
    assets_data <- assets_data |>
      dplyr::filter(company_name %in% !!company_name)
  }

  # Return the filtered tibble
  return(assets_data)
}
