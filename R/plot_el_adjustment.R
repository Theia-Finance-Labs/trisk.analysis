#' EL Adjustment Bar Plot (horizontal, sign-filled)
#'
#' ggplot port of `mod_integration.R:789-834`. Horizontal bars of EL adjustment
#' (Adjusted minus Internal) by sector, with `TRISK_HEX_RED` for negative
#' (risk worsens) and `STATUS_GREEN` for positive (risk improves).
#'
#' @param integration_result Output of [integrate_el()].
#' @param facet_var Column for aggregation. Default "sector".
#' @return A ggplot2 object.
#' @export
pipeline_crispy_el_adjustment_bars <- function(integration_result,
                                               facet_var = "sector") {
  plot_data <- prepare_for_el_adjustment_plot(integration_result, facet_var)
  draw_el_adjustment_plot(plot_data, facet_var)
}

prepare_for_el_adjustment_plot <- function(integration_result, facet_var) {
  integration_result$portfolio |>
    dplyr::group_by_at(facet_var) |>
    dplyr::summarise(el_adjustment = sum(.data$el_adjustment, na.rm = TRUE),
                     .groups = "drop") |>
    dplyr::mutate(sign = ifelse(.data$el_adjustment < 0, "worse", "better"))
}

draw_el_adjustment_plot <- function(plot_data, facet_var) {
  facet_sym <- rlang::sym(facet_var)

  ggplot2::ggplot(plot_data,
                  ggplot2::aes(x = stats::reorder(!!facet_sym, .data$el_adjustment),
                               y = .data$el_adjustment,
                               fill = .data$sign)) +
    ggplot2::geom_bar(stat = "identity") +
    ggplot2::coord_flip() +
    ggplot2::scale_fill_manual(values = c(worse = TRISK_HEX_RED,
                                          better = STATUS_GREEN),
                               guide = "none") +
    TRISK_PLOT_THEME_FUNC() +
    ggplot2::labs(x = "", y = "EL Adjustment (USD)",
                  title = "EL Adjustment by Sector")
}
