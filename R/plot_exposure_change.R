#' Visualize Exposure and Value Loss Changes
#'
#' Creates a visualization of exposure value changes alongside crispy value losses for different sectors or categories. It allows for an adjustable focus through faceting and customization of the exposure and loss variables. This plot is vital for stakeholders to assess the impact of various factors on sectoral financial stability and risk exposure.
#'
#' @param analysis_data Dataframe with sector/category-wise financial data.
#' @param x_var Variable on the x-axis, typically sector or category.
#' @param y_exposure_var Variable for exposure values to be visualized.
#' @param y_value_loss_var Variable for crispy value loss to be overlayed.
#' @param facet_var Optional; faceting variable to segment data further.
#' @param granularity Character vector specifying the grouping columns for aggregation.
#'
#' @return A ggplot object that shows changes in exposure values and value losses, aiding in risk evaluation and management.
#' @export
pipeline_crispy_exposure_change_plot <- function(
    analysis_data,
    x_var = "technology",
    y_exposure_var = "exposure_value_usd",
    y_value_loss_var = "crispy_value_loss",
    facet_var = NULL,
    granularity = c("sector", "technology")) {
  analysis_data <- analysis_data |>
    dplyr::filter(!is.na(.data$company_id)) |>
    aggregate_facts(group_cols = granularity) |>
    compute_analysis_metrics()

  data_exposure_change <- prepare_for_exposure_change_plot(
    analysis_data = analysis_data,
    x_var = x_var,
    y_exposure_var = y_exposure_var,
    y_value_loss_var = y_value_loss_var
  )

  exposure_change_plot <- draw_exposure_change_plot(
    data_exposure_change = data_exposure_change,
    x_var = x_var,
    y_exposure_var = y_exposure_var,
    y_value_loss_var = y_value_loss_var,
    facet_var = facet_var
  )

  return(exposure_change_plot)
}

#' Preprocess Data for Exposure and Value Loss Visualization
#'
#' Transforms given dataset for visualizing changes in exposure and crispy value losses, selecting only the relevant variables. This step ensures that the visualization is focused and clear, aiding in the analysis of financial risk and impact across sectors or categories.
#'
#' @param analysis_data Dataset including financial metrics for exposure and value loss.
#' @param x_var Category or sector variable.
#' @param y_exposure_var Exposure value metric.
#' @param y_value_loss_var Crispy value loss metric.
#'
#' @return A simplified dataframe focusing on selected variables for visualization.
prepare_for_exposure_change_plot <- function(analysis_data, x_var, y_exposure_var, y_value_loss_var) {
  data_exposure_change <- analysis_data |>
    dplyr::select_at(
      c(x_var, y_exposure_var, y_value_loss_var)
    )
  return(data_exposure_change)
}


#' Generate Exposure Change and Value Loss Plot
#'
#' Constructs the final plot visualizing sector/category-wise changes in financial exposure and value losses, using a combination of bar and tile geoms to represent data points and their positive/negative changes. Faceting can be applied for more detailed analysis. This function integrates aesthetic elements and scales to effectively communicate the financial impact.
#'
#' @param data_exposure_change Prepared dataframe for plotting.
#' @param x_var Category or sector variable for the x-axis.
#' @param y_exposure_var Metric for exposure value.
#' @param y_value_loss_var Metric for crispy value loss.
#' @param facet_var Optional; variable to facet the plot by.
#'
#' @return A ggplot object depicting exposure changes and value losses, crucial for detailed financial impact analysis.
draw_exposure_change_plot <- function(
    data_exposure_change,
    x_var,
    y_exposure_var,
    y_value_loss_var,
    facet_var = NULL) {
  plot_bar_color <-
    r2dii.colours::palette_1in1000_plot |>
    dplyr::filter(.data$label == "grey") |>
    dplyr::pull(.data$hex)

  # HARDCODED PARAMETERS
  plot_color_gradient <- c(
    r2dii.colours::palette_1in1000_plot |> dplyr::filter(.data$label == "red") |> dplyr::pull(.data$hex),
    r2dii.colours::palette_1in1000_plot |> dplyr::filter(.data$label == "green") |> dplyr::pull(.data$hex)
  )
  bar_width <- 0.9 # Adjust as needed TODO variabiliser conf

  # PLOTTING

  exposure_change_plot <- ggplot2::ggplot(data_exposure_change, ggplot2::aes(x = !!rlang::sym(x_var))) +
    ggplot2::geom_col(
      ggplot2::aes(y = !!rlang::sym(y_exposure_var)),
      width = bar_width, fill = plot_bar_color
    ) +
    ggplot2::geom_tile(
      ggplot2::aes(
        y = !!rlang::sym(y_exposure_var) + (!!rlang::sym(y_value_loss_var) / 2),
        height = abs(!!rlang::sym(y_value_loss_var)),
        fill = dplyr::if_else(!!rlang::sym(y_value_loss_var) < 0, "Loss", "Gain")
      ),
      width = bar_width
    ) +
    ggplot2::scale_fill_manual(
      name = "Crispy value change",
      values = c(plot_color_gradient[1], plot_color_gradient[2]),
      breaks = c("Loss", "Gain")
    ) +
    ggplot2::labs(y = "Value USD", x = "") +
    r2dii.plot::theme_2dii() +
    ggplot2::scale_y_continuous(labels = scales::unit_format(unit = "M", scale = 1e-6)) +
    ggplot2::theme(
      # legend.position = "none",
      axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)
    ) +
    ggplot2::labs(title = "Estimated impact of the Shock on Exposure")

  if (!is.null(facet_var)) {
    exposure_change_plot <- exposure_change_plot +
      ggplot2::facet_wrap(stats::as.formula(paste("~", facet_var)), scales = "free_y", ncol = 1)
  }

  return(exposure_change_plot)
}
