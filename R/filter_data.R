# TODO: function that filters over a stack


# Function to filter data based on multiple criteria
filter_data <- function(df, params_df, filter_criteria) {
  # Start with the full params_df
  filtered_params_df <- params_df

  # Apply each filtering criterion
  for (key in names(filter_criteria)) {
    value <- filter_criteria[[key]]
    filtered_params_df <- filtered_params_df[filtered_params_df[[key]] == value, ]
  }

  # Merge the filtered params_df with the main dataframe
  filtered_df <- merge(df, filtered_params_df[c("run_id")], by = "run_id", all = FALSE)

  return(filtered_df)
}
