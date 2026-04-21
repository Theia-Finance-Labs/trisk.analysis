#' PD Integration Bar Plot (4-bar grouped)
#'
#' For each sector facet, draws four bars: Internal PD (grey), TRISK Baseline
#' (green), TRISK Shock (red), TRISK-Adjusted PD (dark-red). Extends the
#' `mod_results_summary.R` PD-by-sector pattern from 2 bars to 4.
#'
#' @param integration_result Output of [integrate_pd()] (a list with
#'   `$portfolio_long`).
#' @param facet_var Column used for facets. Default "sector".
#' @return A ggplot2 object.
#' @export
pipeline_crispy_pd_integration_bars <- function(integration_result,
                                                facet_var = "sector") {
  plot_data <- prepare_for_pd_integration_plot(integration_result, facet_var)
  draw_pd_integration_plot(plot_data, facet_var)
}

prepare_for_pd_integration_plot <- function(integration_result, facet_var) {
  integration_result$portfolio_long |>
    dplyr::group_by_at(c(facet_var, "term", "pd_type")) |>
    dplyr::summarise(pd_value = stats::median(.data$pd_value, na.rm = TRUE),
                     .groups = "drop")
}

draw_pd_integration_plot <- function(plot_data, facet_var) {
  fill_palette <- c(
    internal       = TRISK_HEX_GREY,
    baseline       = TRISK_HEX_GREEN,
    shock          = TRISK_HEX_RED,
    trisk_adjusted = TRISK_HEX_ADJUSTED
  )

  ggplot2::ggplot(plot_data,
                  ggplot2::aes(x = as.factor(.data$term),
                               y = .data$pd_value,
                               fill = .data$pd_type)) +
    ggplot2::geom_bar(stat = "identity",
                      position = ggplot2::position_dodge()) +
    ggplot2::facet_grid(stats::as.formula(paste(facet_var, "~ ."))) +
    ggplot2::scale_fill_manual(values = fill_palette,
                               name = "PD Type") +
    ggplot2::scale_y_continuous(labels = scales::percent_format(scale = 100)) +
    TRISK_PLOT_THEME_FUNC() +
    ggplot2::labs(x = "Term", y = "PD",
                  title = "PD Integration: Baseline, Shock, Internal, Adjusted")
}
