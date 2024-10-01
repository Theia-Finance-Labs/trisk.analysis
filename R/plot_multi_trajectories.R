#' Visualize Trajectory Risks Over Time by Business Unit and Sector
#'
#' This function generates a line plot visualizing the trajectory of risks over time for the "production_shock_scenario", segmented by business units and differentiated by sectors.
#' 
#' @param trajectories_data Dataframe containing yearly data on risk trajectories across different business units and sectors.
#' @param x_var The time variable, defaulting to "year".
#' @param facet_var The variable for faceting the plot by business units, defaulting to "ald_business_unit".
#' @param linecolor Variable determining line colors by sector, defaulting to "ald_sector".
#' @param y_in_percent plots in percent or absolute
#'
#' @return A ggplot object displaying the trend of the "production_shock_scenario" over time, providing insights into risk management and strategic planning.
#' @export
plot_multi_trajectories <- function(
    trajectories_data,
    x_var = "year",
    facet_var = "technology",
    linecolor = "run_id",
    y_in_percent=TRUE) {


  linecolor <- dplyr::intersect(colnames(trajectories_data), linecolor)

  data_trisk_line_plot <- prepare_for_trisk_line_plot(
    trajectories_data = trajectories_data,
    facet_var = facet_var,
    linecolor = linecolor
  )

  trisk_line_plot <- draw_trisk_line_plot(
    data_trisk_line_plot,
    x_var = x_var,
    facet_var = facet_var,
    linecolor = linecolor,
    y_in_percent=y_in_percent
  )

  return(trisk_line_plot)
}

#' Prepare Data for Risk Trajectory Line Plot
#'
#' Prepares trajectory data for line plot visualization, calculating production percentages of the maximum value for "production_shock_scenario" only, 
#' and removing the last year of each "run_id" group.
#'
#' @param trajectories_data Dataset containing trajectory information across different scenarios.
#' @param facet_var Variable for faceting plots by business units.
#' @param linecolor Variable for coloring lines by sector.
#'
#' @return A dataframe ready for plotting, with production percentages for "production_shock_scenario" for visualization, excluding the last year of each "run_id" group.
prepare_for_trisk_line_plot <- function(trajectories_data, facet_var, linecolor) {
  # Filtering for production_shock_scenario only and removing the last year for each run_id group
  data_trisk_line_plot <- trajectories_data |>
    dplyr::group_by_at(c(facet_var, linecolor, "year")) |>
    dplyr::summarise(
      production = sum(.data$production_shock_scenario, na.rm = TRUE)
    ) |>
    dplyr::ungroup() |>
    dplyr::group_by_at(c(facet_var, linecolor)) |>
    dplyr::mutate(
      base_year_production = dplyr::first(.data$production),
      production_pct = (.data$production / .data$base_year_production) * 100
    ) |>
    dplyr::ungroup() |>
    # Remove the last year of each run_id group
    dplyr::group_by_at(c(linecolor)) |>
    dplyr::filter(.data$year != max(.data$year)) |>
    dplyr::ungroup()

  return(data_trisk_line_plot)
}

#' Draw Line Plot for Risk Trajectories
#'
#' Creates a line plot to depict the "production_shock_scenario" risk trajectories as a percentage of the maximum value, offering a visual comparison within business units and sectors.
#' 
#' @param data_trisk_line_plot Prepared data for plotting, with production percentages.
#' @param x_var Time variable for the x-axis.
#' @param facet_var Variable for faceting plots by business units.
#' @param linecolor Variable for coloring lines by sector.
#' @param y_in_percent plots in percent or absolute
#'
#' @return A ggplot object illustrating risk trajectories over time, aiding in the analysis of production risk and scenario planning.
draw_trisk_line_plot <- function(
    data_trisk_line_plot,
    x_var,
    facet_var,
    linecolor,
    y_in_percent) {

  if (y_in_percent){
    trisk_line_plot <- ggplot2::ggplot(
      data_trisk_line_plot,
      ggplot2::aes(
        x = !!rlang::sym(x_var),
        y = !!rlang::sym("production_pct"),
        color = !!rlang::sym(linecolor)
      )
    ) +
    ggplot2::scale_y_continuous(labels = scales::percent_format(scale = 1)) +
      ggplot2::labs(
        y = "Percentage of today's production "
      )
  } else {
    trisk_line_plot <- ggplot2::ggplot(
      data_trisk_line_plot,
      ggplot2::aes(
        x = !!rlang::sym(x_var),
        y = !!rlang::sym("production"),
        color = !!rlang::sym(linecolor)
      )
    ) +
    ggplot2::scale_y_continuous(labels = function(x) scales::scientific(x)) +
    ggplot2::labs(
      y = "Production in raw unit"
      )
  }

  palette <- c(
    "#1b324f",  
    "#00c082",  
    "#ff9623",  
    "#574099",  
    "#f2e06e",  
    "#78c4d6",  
    "#a63d57",  
    "#FF1493",  
    "#00CED1",  
    "#9ACD32"   
  )
    
  facets_colors <- palette[seq_along(unique(data_trisk_line_plot[[linecolor]]))]
  trisk_line_plot <- trisk_line_plot +
    ggplot2::geom_line() +
    ggplot2::labs(
      x = "Year",
      linetype = "Scenario"
    ) +
    ggplot2::scale_color_manual(values = facets_colors) +
    TRISK_PLOT_THEME_FUNC()+
    ggplot2::theme(
      panel.background = ggplot2::element_blank(),
      panel.grid.major = ggplot2::element_blank(),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.y = ggplot2::element_blank(),
      strip.background = ggplot2::element_blank()
    ) +
    ggplot2::facet_wrap(
      stats::as.formula(paste("~", paste(facet_var, collapse = "+"))),
      scales = "free_y",
      ncol = 1
    )

  return(trisk_line_plot)
}
