#get_latest_trisk_result.R

#' Get the latest TRISK result of a specified type
#'
#' This function retrieves the latest TRISK result based on the specified result type.
#' It identifies the most recent output directory using a timestamped folder structure, and then loads
#' the corresponding result file.
#'
#' @param trisk_output_path The path to the TRISK output directory containing timestamped folders.
#' @param result_type The type of result to retrieve. Valid options are "npv", "pd", "trajectories", and "params".
#'
#' @return A tibble containing the requested TRISK result data. If the specified file does not exist, a warning is issued, and NULL is returned.
#' @export
get_latest_trisk_result <- function(trisk_output_path, result_type){
  sub_dir <- get_latest_timestamped_folder(path=trisk_output_path)
  result <- get_single_trisk_result(sub_dir=sub_dir, result_type=result_type)
  return(result)
}

#' Get the latest timestamped folder in a directory
#'
#' This function finds the most recent folder in a given directory where the folder names follow a specific
#' timestamp format (YYYYMMDD_HHMMSS).
#'
#' @param path The directory path containing timestamped folders.
#'
#' @return The relative path of the most recent timestamped folder. If no valid directories are found, a message is returned.
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

#' Get a specific TRISK result from a given sub-directory
#'
#' This function retrieves a specific TRISK result file from a given sub-directory based on the provided result type.
#'
#' @param sub_dir The sub-directory path containing the TRISK result files.
#' @param result_type The type of result to retrieve. Valid options are "trajectories", "pd", "npv", and "params".
#'
#' @return A tibble containing the requested TRISK result data. If the file does not exist, a warning is issued, and NULL is returned.
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
