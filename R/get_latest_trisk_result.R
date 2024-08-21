get_latest_trisk_result <- function(trisk_output_path, result_type){
  sub_dir <- get_latest_timestamped_folder(path=trisk_output_path)
  result <- get_single_trisk_result(sub_dir=sub_dir, result_type=result_type)
  return(result)
}


get_latest_timestamped_folder <- function(path) {
  # Check if the path is a directory
  if (!dir.exists(path)) {
    stop("The specified path does not exist or is not a directory.")
  }

  # List all the directories in the specified path
  directories <- list.dirs(path, full.names = FALSE, recursive = FALSE)

  # Filter out only those directories that start with a date in the specified format
  valid_directories <- directories[grepl("^\\d{8}_\\d{6}", directories)]

  # If no valid directories are found, return a message
  if (length(valid_directories) == 0) {
    return("No directories with the specified date format found.")
  }

  # Extract the dates from the directory names
  dates <- as.POSIXct(substring(valid_directories, 1, 15), format = "%Y%m%d_%H%M%S")

  # Find the directory with the newest date
  newest_index <- which.max(dates)
  newest_directory <- valid_directories[newest_index]
  # Return the full relative path
  newest_directory <- file.path(path, newest_directory)


  return(newest_directory)
}

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
    data <- readr::read_csv(file_path)
    return(tibble::as_tibble(data))  # Convert to tibble and return
  } else {
    warning(paste("File", file_path, "does not exist and was skipped."))
    return(NULL)  # Return NULL if the file doesn't exist
  }
}
