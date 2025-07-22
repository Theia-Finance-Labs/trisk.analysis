#' Download TRISK input data files from a specified endpoint
#'
#' This function downloads TRISK input data files from a specified endpoint URL and saves them to a local folder.
#' It ensures that the local folder exists before downloading the files. If the folder does not exist, it is created.
#' Package-level variables for `endpoint` and `s3_prefix` are used if not provided as parameters.
#'
#' @param local_save_folder Where to download outputs locally.
#' @param endpoint URL of the endpoint (optional; defaults to `TRISK_DATA_INPUT_ENDPOINT` from the package).
#' @param s3_prefix Prefix for the files in the S3 bucket (optional; defaults to `TRISK_DATA_S3_PREFIX` from the package).
#' @param skip_confirmation Set to true to allow CI/CD building of vignettes
#'
#' @return TRUE if all files are downloaded successfully, FALSE otherwise.
#' @export
download_trisk_inputs <- function(local_save_folder, endpoint = NULL, s3_prefix = NULL, skip_confirmation = FALSE) {
  # Use package-level variables if parameters are NULL
  endpoint <- endpoint %||% tryCatch(TRISK_DATA_INPUT_ENDPOINT, error = function(e) NULL)
  s3_prefix <- s3_prefix %||% tryCatch(TRISK_DATA_S3_PREFIX, error = function(e) NULL)

  # Validate that the defaults exist and are non-NULL
  if (is.null(endpoint)) {
    stop("Endpoint is not provided and the package-level `TRISK_DATA_INPUT_ENDPOINT` is not defined.")
  }
  if (is.null(s3_prefix)) {
    stop("S3 prefix is not provided and the package-level `TRISK_DATA_S3_PREFIX` is not defined.")
  }
  if (!skip_confirmation) {
    # Ask user for confirmation
    proceed <- readline(prompt = "This will download TRISK input data files. Do you want to proceed? (yes/no): ")
    if (tolower(proceed) != "yes") {
      message("Download cancelled by user.")
      return(FALSE)
    }
  }
  # Ensure the local save folder exists, create it if it doesn't
  if (!dir.exists(local_save_folder)) {
    dir.create(local_save_folder, recursive = TRUE)
  }

  # List of files to download
  files <- c(
    #"assets.csv",
    #"financial_features.csv",
    "scenarios.csv"
    #"ngfs_carbon_price.csv"
  )

  # Try-catch block to handle errors
  tryCatch(
    {
      # Loop through each file and download it
      for (file in files) {
        # Construct the full URL
        file_url <- paste0(endpoint, "/", s3_prefix, "/", file)

        # Construct the local file path
        save_path <- file.path(local_save_folder, file)

        # Attempt to download the file
        utils::download.file(file_url, save_path, mode = "wb")
      }
      message("Download completed.")
      return(TRUE)
    },
    error = function(e) {
      message("Error occurred during download: ", conditionMessage(e))
      return(FALSE)
    }
  )
}
