get_single_trisk_result <- function(sub_dir, result_type) {
  # Define the mapping of result_type to file names
  file_map <- list(
    "trajectories" = "company_trajectories.csv",
    "pd" = "pd_results.csv",
    "npv" = "npv_results.csv",
    "params" = "params.csv"
  )
  
  # Validate result_type
  if (!result_type %in% names(file_map)) {
    stop("Invalid result_type provided. Choose from 'trajectories', 'pd', 'npv', or 'params'.")
  }
  
  # Construct the full file path based on result_type
  file_path <- file.path(sub_dir, file_map[[result_type]])
  
  # Check if the file exists before attempting to load it
  if (file.exists(file_path)) {
    # Read the file into a data frame
    data <- read.csv(file_path)
    return(tibble::as_tibble(data))  # Convert to tibble and return
  } else {
    warning(paste("File", file_path, "does not exist and was skipped."))
    return(NULL)  # Return NULL if the file doesn't exist
  }
}
