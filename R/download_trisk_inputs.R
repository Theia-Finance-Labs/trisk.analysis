# download_trisk_inputs.R

#' Download TRISK input data files from a specified endpoint
#'
#' This function downloads TRISK input data files from a specified endpoint URL and saves them to a local folder.
#' It ensures that the local folder exists before downloading the files. If the folder does not exist, it is created.
#' Env variables containing endpoints are defined in imports.R
#'
#' @param endpoint_url The base URL of the endpoint from which the data files will be downloaded.
#'
#' @return No return value. The function downloads files and saves them to the specified local folder.
#' @export
download_trisk_inputs <- function(local_save_folder) {
  # Ensure the local save folder exists, create it if it doesn't
  if (!dir.exists(local_save_folder)) {
    dir.create(local_save_folder, recursive = TRUE)
  }

  # List of files to download
  files <- c(
    "assets.csv",
    "financial_features.csv",
    "scenarios.csv",
    "ngfs_carbon_price.csv"
  )

  # Loop through each file and download it
  for (file in files) {
    # Construct the full URL
    file_url <- paste0(TRISK_DATA_INPUT_ENDPOINT, "/", TRISK_DATA_S3_PREFIX, "/", file)

    # Construct the local file path
    save_path <- file.path(local_save_folder, file)

    # Download the file
    utils::download.file(file_url, save_path, mode = "wb")
  }

  message("Download completed.")
}
