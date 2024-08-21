run_trisk_single_filtered <- function(input_path, 
                                      run_param,
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
    
    # Prepare and return the results as tibbles
    result_tibbles <- list(
        npv = tibble::as_tibble(trisk.model:::prepare_npv_results(output_list)),
        pd = tibble::as_tibble(trisk.model:::prepare_pd_results(output_list)),
        trajectories = tibble::as_tibble(trisk.model:::prepare_company_trajectories(output_list)),
        params = tibble::as_tibble(trisk.model:::prepare_params_df(trisk_params, run_id))
    )
    
    return(result_tibbles)
}
