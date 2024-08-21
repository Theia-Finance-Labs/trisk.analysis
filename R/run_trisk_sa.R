# run_trisk_sa.R

#' Run TRISK sensitivity analysis on multiple scenarios
#'
#' This function performs a sensitivity analysis by running the TRISK model on multiple scenarios. 
#' It takes a list of parameter sets and runs the TRISK model for each set, returning a comprehensive 
#' set of results that includes net present value (NPV), probability of default (PD), company trajectories, and model parameters.
#'
#' @param input_path The path to the input data directory containing the necessary files for the TRISK model.
#' @param run_params A list of parameter sets where each set contains the required parameters for a single TRISK model run. 
#'        Each parameter set must include `scenario_geography`, `baseline_scenario`, `target_scenario`, and `shock_year`.
#' @param ... Additional arguments passed to `get_filtered_assets_data`, such as `country_iso2`, `sector`, `technology`, and `company_name` for filtering assets.
#'
#' @return A list of tibbles containing the combined results for all runs. The list includes tibbles for NPV results (`npv`), 
#'         PD results (`pd`), company trajectories (`trajectories`), and model parameters (`params`).
#' @export 
run_trisk_sa <- function(input_path, run_params, ...) {
    
    # Get filtered assets data and other input data
    input_data_list <- get_filtered_assets_data(
        input_path = input_path,
        ...
    )
    
    print(paste("Starting the execution of", length(run_params), "total runs"))
    
    n_completed_runs <- 0
    
    # Initialize lists to store stacked results
    npv_results_list <- list()
    pd_results_list <- list()
    company_trajectories_list <- list()
    params_df_list <- list()
    
    # Loop over each set of parameters in run_params
    for (i in seq_along(run_params)) {
        run_param <- run_params[[i]]
        
        # Merge the fixed input data with the current run parameters
        trisk_run_params <- c(
            list(
                assets_data = input_data_list$assets_data,
                scenarios_data = input_data_list$scenarios_data,
                financial_data = input_data_list$financial_data,
                carbon_data = input_data_list$carbon_data
            ),
            run_param
        )
        
        # Execute the TRISK model with the combined parameters
        output_list <- do.call(
            trisk.model::run_trisk_model,
            trisk_run_params
        )
        
        # Process the parameters used in the run
        trisk_params <- trisk.model:::process_params(fun = run_trisk_model, trisk_run_params)
        run_id <- uuid::UUIDgenerate() # TODO move into trisk.model:::process_params
        
        # Prepare and stack the results
        npv_results_list[[length(npv_results_list) + 1]] <- trisk.model:::prepare_npv_results(output_list)
        pd_results_list[[length(pd_results_list) + 1]] <- trisk.model:::prepare_pd_results(output_list)
        company_trajectories_list[[length(company_trajectories_list) + 1]] <- trisk.model:::prepare_company_trajectories(output_list)
        params_df_list[[length(params_df_list) + 1]] <- trisk.model:::prepare_params_df(trisk_params, run_id)
        
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
