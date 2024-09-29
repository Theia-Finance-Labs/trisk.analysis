#' Visualize Sector-wise NPV Percentage Changes
#'
#' Generates a plot to visualize net present value (NPV) percentage changes across sectors, facilitating quick insights into sectors' performance under varying conditions. This function streamlines the data preparation and plotting process, focusing on key financial metrics for strategic analysis.
#'
#' @param analysis_data Dataframe containing sector-wise NPV changes and other financial metrics.
#' @param x_var Sector variable for categorization, defaulting to "ald_sector".
#' @param y_var NPV change variable, defaulting to "crispy_perc_value_change".
#' @param granularity Character vector specifying the grouping columns for aggregation.
#'
#' @return A ggplot object illustrating the percentage change in NPV across sectors, essential for financial and strategic planning.
#' @export
pipeline_crispy_npv_change_plot <- function(
    analysis_data,
    x_var = "technology",
    y_var = "crispy_perc_value_change",
    granularity = c("sector", "technology")) {
  analysis_data <- analysis_data |>
    dplyr::filter(!is.na(.data$company_id)) |>
    aggregate_facts(group_cols = granularity) |>
    compute_analysis_metrics()

  x_var <- dplyr::intersect(colnames(analysis_data), x_var)

  data_crispy_npv_change_plot <- prepare_for_crispy_npv_change_plot(analysis_data, x_var, y_var)

  crispy_npv_change_plot <- draw_crispy_npv_change_plot(
    data_crispy_npv_change_plot,
    "x_var", y_var
  )

  return(crispy_npv_change_plot)
}

#' Prepare Data for NPV Change Visualization
#'
#' Transforms the analysis dataset for visualization, focusing on NPV percentage changes. It ensures that the data is in the correct format for the plotting function, enhancing clarity and focus in the visual representation of NPV changes.
#'
#' @param analysis_data Dataset including sector-wise financial metrics and NPV changes.
#' @param x_var Sector categorization variable.
#' @param y_var NPV change percentage variable.
#'
#' @return A dataframe with unified sector categorization, ready for NPV change visualization.
prepare_for_crispy_npv_change_plot <- function(analysis_data, x_var, y_var) {
  data_exposure_change <- analysis_data |>
    dplyr::select_at(
      c(x_var, y_var)
    ) |>
    tidyr::unite("x_var", !!!x_var, sep = " ")
  return(data_exposure_change)
}


#' Construct NPV Change Visualization Plot
#'
#' Creates the final visualization for NPV percentage changes across sectors using a color gradient to represent increase, decrease, or no change. This function applies a gradient scale to highlight variations in NPV change, facilitating an intuitive understanding of financial performance across sectors.
#'
#' @param data_crispy_npv_change_plot Prepared dataframe for plotting.
#' @param x_var Unified sector categorization variable.
#' @param y_var NPV change percentage variable.
#'
#' @return A ggplot object depicting NPV changes across sectors, crucial for assessing financial impact and strategic direction.
draw_crispy_npv_change_plot <- function(
    data_crispy_npv_change_plot,
    x_var,
    y_var) {
  # HARDCODED PARAMETERS
  plot_color_gradient <- c(
    TRISK_HEX_RED,
    TRISK_HEX_GREY,
    TRISK_HEX_GREEN
  )
  bar_width <- 0.9 # Adjust as needed TODO variabiliser conf


  # PLOTTING

  crispy_npv_change_plot <- ggplot2::ggplot(
    data_crispy_npv_change_plot,
    ggplot2::aes(x = !!rlang::sym(x_var), y = !!rlang::sym(y_var), fill = !!rlang::sym(y_var))
  ) +
    ggplot2::geom_col(width = bar_width) +
    ggplot2::scale_fill_gradient2(
      low = plot_color_gradient[1],
      mid = plot_color_gradient[2],
      high = plot_color_gradient[3],
      midpoint = 0,
      labels = scales::percent
    ) +
    ggplot2::scale_y_continuous(labels = scales::percent) +
    ggplot2::labs(y = "Crispy npv change", x = "") +
    TRISK_PLOT_THEME_FUNC() +
    ggplot2::theme(
      legend.position = "none",
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)
    )


  return(crispy_npv_change_plot)
}
