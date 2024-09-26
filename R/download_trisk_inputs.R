# download_trisk_inputs.R

#' Download TRISK input data files from a specified endpoint
#'
#' This function downloads TRISK input data files from a specified endpoint URL and saves them to a local folder.
#' It ensures that the local folder exists before downloading the files. If the folder does not exist, it is created.
#'
#' @param endpoint_url The base URL of the endpoint from which the data files will be downloaded.
#' @param s3_path The specific path within the endpoint where the data files are located.
#' @param local_save_folder The local folder path where the downloaded files will be saved.
#'
#' @return No return value. The function downloads files and saves them to the specified local folder.
#' @export
download_trisk_inputs <- function(
    local_save_folder, endpoint_url = "https://crispy-datamodels-bucket.fra1.cdn.digitaloceanspaces.com",
    s3_path = "crispy-datamodels-bucket/trisk_V2/csv") {
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
    file_url <- paste0(endpoint_url, "/", s3_path, "/", file)

    # Construct the local file path
    save_path <- file.path(local_save_folder, file)

    # Download the file
    utils::download.file(file_url, save_path, mode = "wb")
  }

  message("Download completed.")
}
