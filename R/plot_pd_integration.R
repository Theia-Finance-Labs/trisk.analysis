#' PD Integration Bar Plot (4-bar grouped)
#'
#' Draws four bars per facet group: Internal PD (grey), TRISK Baseline
#' (green), TRISK Shock (red), TRISK-Adjusted PD (dark-red). Extends the
#' `mod_results_summary.R` PD-by-sector pattern from 2 bars to 4.
#'
#' At `granularity = "sector"` (default), bars are the median PD per
#' sector x term x pd_type. At `granularity = "firm"`, one group of four
#' bars per firm/technology row; sectors are the facet. Firm view reveals
#' within-sector heterogeneity that sector medians hide.
#'
#' The `scale` argument controls y-axis transformation. `"pseudo_log"`
#' (via [scales::pseudo_log_trans()]) is zero-safe and spreads values
#' that span many orders of magnitude, useful when baseline PDs underflow.
#'
#' @param integration_result Output of [integrate_pd()] (a list with
#'   `$portfolio_long`).
#' @param facet_var Column used for facets. Default `"sector"`.
#' @param granularity One of `"sector"` (median per term group) or `"firm"`
#'   (one bar group per firm/technology). Default `"sector"`.
#' @param scale One of `"linear"` or `"pseudo_log"`. Default `"linear"`.
#' @return A ggplot2 object.
#' @export
pipeline_crispy_pd_integration_bars <- function(integration_result,
                                                facet_var = "sector",
                                                granularity = c("sector", "firm"),
                                                scale = c("linear", "pseudo_log")) {
  granularity <- match.arg(granularity)
  scale <- match.arg(scale)
  plot_data <- prepare_for_pd_integration_plot(integration_result, facet_var, granularity)
  draw_pd_integration_plot(plot_data, facet_var, granularity, scale)
}

prepare_for_pd_integration_plot <- function(integration_result, facet_var,
                                            granularity = "sector") {
  long <- integration_result$portfolio_long
  if (granularity == "sector") {
    long |>
      dplyr::group_by(dplyr::across(dplyr::all_of(c(facet_var, "term", "pd_type")))) |>
      dplyr::summarise(pd_value = stats::median(.data$pd_value, na.rm = TRUE),
                       .groups = "drop")
  } else {
    long |>
      dplyr::mutate(firm_label = paste(.data$company_id, .data$technology, sep = "/")) |>
      dplyr::select(dplyr::any_of(c(facet_var)), "firm_label", "term",
                    "pd_type", "pd_value")
  }
}

draw_pd_integration_plot <- function(plot_data, facet_var,
                                     granularity = "sector",
                                     scale = "linear") {
  fill_palette <- c(
    internal       = TRISK_HEX_GREY,
    baseline       = TRISK_HEX_GREEN,
    shock          = TRISK_HEX_RED,
    trisk_adjusted = TRISK_HEX_ADJUSTED
  )

  y_scale <- if (scale == "pseudo_log") {
    ggplot2::scale_y_continuous(
      trans  = scales::pseudo_log_trans(sigma = 1e-5),
      breaks = c(0, 1e-4, 1e-3, 0.01, 0.05, 0.15),
      labels = scales::percent_format(accuracy = 0.01)
    )
  } else {
    ggplot2::scale_y_continuous(labels = scales::percent_format(scale = 100))
  }

  if (granularity == "sector") {
    p <- ggplot2::ggplot(plot_data,
                         ggplot2::aes(x = as.factor(.data$term),
                                      y = .data$pd_value,
                                      fill = .data$pd_type)) +
      ggplot2::geom_bar(stat = "identity",
                        position = ggplot2::position_dodge()) +
      ggplot2::facet_grid(stats::as.formula(paste(facet_var, "~ ."))) +
      ggplot2::labs(x = "Term", y = "PD")
  } else {
    p <- ggplot2::ggplot(plot_data,
                         ggplot2::aes(x = .data$firm_label,
                                      y = .data$pd_value,
                                      fill = .data$pd_type)) +
      ggplot2::geom_bar(stat = "identity",
                        position = ggplot2::position_dodge()) +
      ggplot2::coord_flip() +
      ggplot2::facet_grid(stats::as.formula(paste(facet_var, "~ .")),
                          scales = "free_y", space = "free_y") +
      ggplot2::labs(x = "firm / technology", y = "PD")
  }

  p +
    ggplot2::scale_fill_manual(values = fill_palette, name = "PD Type") +
    y_scale +
    TRISK_PLOT_THEME_FUNC() +
    ggplot2::labs(title = "PD Integration: Baseline, Shock, Internal, Adjusted")
}
