#' @export 
download_trisk_inputs <- function(endpoint_url, s3_path, local_save_folder) {

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
    download.file(file_url, save_path, mode = "wb")
  }

  message("Download completed.")
}
