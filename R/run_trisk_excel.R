#' Run TRISK model and save results to Excel
#'
#' This function runs the TRISK model, processes the resulting CSV files, and converts them to Excel format if they contain fewer rows than Excel's row limit. If a file exceeds Excel's row limit, it is saved as a CSV with a new name.
#'
#' @param input_path Character. Path to the input file used by the TRISK model.
#' @param output_path Character. Path to the output folder where results will be saved.
#' @param ... Additional arguments passed to `trisk.model::run_trisk`.
#'
#' @return None. The function saves the processed results as Excel or CSV files in the output directory and prints a completion message.
#' @export
run_trisk_excel <- function(input_path, output_path, ...) {
  results_folder <- trisk.model::run_trisk(input_path, output_path, show_params_cols = TRUE, ...)

  # Define the folder path and suffix
  suffix <- strsplit(basename(results_folder), "__")[[1]][2]

  # Get list of all CSV files in the folder
  csv_files <- list.files(results_folder, pattern = "\\.csv$", full.names = TRUE)

  # Loop through each CSV, read it, and process accordingly
  for (csv_file in csv_files) {
    # Read the CSV file
    data <- readr::read_csv(csv_file, show_col_types = FALSE)

    # Create the new file name with suffix
    file_name <- tools::file_path_sans_ext(basename(csv_file))
    new_file_name <- paste0(file_name, "_", suffix)

    # Check if the number of rows exceeds Excel's limit
    if (nrow(data) > 1048576) {
      # Rewrite as CSV with new name
      new_csv_file <- paste0(new_file_name, ".csv")
      readr::write_csv(data, file.path(results_folder, new_csv_file))
    } else {
      # Write to Excel
      new_excel_file <- paste0(new_file_name, ".xlsx")
      openxlsx::write.xlsx(data, file.path(results_folder, new_excel_file))
    }
  }

  # Delete all original CSV files from the folder
  file.remove(csv_files)
  print("Trisk run complete and results saved to excel.")
}
