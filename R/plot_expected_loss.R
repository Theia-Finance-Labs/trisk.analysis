#' Financial Risk Visualization via Expected Loss and Exposure Plot
#'
#' Generates a plot that visualizes financial risk by showcasing expected losses and exposure across different segments. It preprocesses data for visual representation and uses faceting to provide insights into risk distribution across specified categories, aiding in targeted risk mitigation strategies.
#'
#' @param analysis_data Dataframe with financial exposure and expected loss data, segmented by various categories.
#' @param facet_var Categorical variable for segmenting the data, enabling detailed risk analysis across segments.
#' @param granularity Character vector specifying the grouping columns for aggregation.
#'
#' @return A ggplot object displaying financial risks segmented by `facet_var`, crucial for risk management decisions.
#' @export
pipeline_crispy_expected_loss_plot <- function(
    analysis_data,
    facet_var = "sector",
    granularity = c("sector")) {
  analysis_data <- analysis_data |>
    dplyr::filter(!is.na(.data$company_id)) |>
    aggregate_facts(group_cols = granularity) |>
    compute_analysis_metrics()

  data_expected_loss_plot <- prepare_for_expected_loss_plot(
    analysis_data = analysis_data,
    facet_var = facet_var
  )

  expected_loss_plot <- draw_exposure_change_plot(
    data_expected_loss_plot,
    x_var = "el_type",
    y_exposure_var = "exposure_value_usd",
    y_value_loss_var = "el_value",
    facet_var = facet_var
  )
  return(expected_loss_plot)
}

#' Data Preparation for Financial Risk Visualization
#'
#' Prepares dataset for plotting by transforming financial risk data, including expected losses and exposure values, into a format that allows for aggregated analysis across specified segments. Essential for highlighting financial vulnerabilities and focusing risk management efforts.
#'
#' @param analysis_data Dataset including detailed financial risk metrics, to be transformed for visualization.
#' @param facet_var Segmentation variable used to categorize and analyze financial risk across different divisions.
#'
#' @return Dataframe optimized for visualizing financial risk, with aggregated metrics for each segment.
prepare_for_expected_loss_plot <- function(analysis_data, facet_var) {
  data_expected_loss_plot <- analysis_data |>
    tidyr::pivot_longer(
      cols = tidyr::starts_with("expected_loss_"),
      names_to = "el_type",
      values_to = "el_value",
      names_prefix = "expected_loss_"
    ) |>
    dplyr::filter(!.data$el_type %in% c("difference", "portfolio")) |>
    dplyr::group_by_at(c(facet_var, "el_type")) |>
    dplyr::summarise(
      el_value = sum(.data$el_value, na.rm = T),
      exposure_value_usd = sum(.data$exposure_value_usd, na.rm = T)
    ) |>
    dplyr::select_at(c(facet_var, "exposure_value_usd", "el_type", "el_value"))
  return(data_expected_loss_plot)
}
