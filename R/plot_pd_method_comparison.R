#' PD Integration Method Comparison Plot
#'
#' Runs all three PD integration methods on the same input and overlays
#' their EAD-weighted adjusted PDs per sector, so the user can see method
#' sensitivity at a glance. Inspired by the range-lollipop pattern in
#' `mod_results_scenarios.R:220-234`.
#'
#' Each sector shows:
#' - a segment from weighted_pd_internal to the maximum adjusted across methods
#' - three points (circle, triangle, square) for absolute / relative / zscore
#'
#' @param analysis_data Raw output of [run_trisk_on_portfolio()].
#' @param internal_pd Optional; forwarded to [integrate_pd()].
#' @param facet_var Column used for aggregation. Default "sector".
#' @return A ggplot2 object.
#' @export
pipeline_crispy_pd_method_comparison <- function(analysis_data,
                                                 internal_pd = NULL,
                                                 facet_var = "sector") {
  methods <- c("absolute", "relative", "zscore")

  per_method <- lapply(methods, function(m) {
    integrated <- integrate_pd(analysis_data,
                               internal_pd = internal_pd, method = m)
    agg <- aggregate_pd_integration(integrated$portfolio,
                                    group_cols = facet_var)
    agg |> dplyr::mutate(method = m)
  })
  plot_df <- dplyr::bind_rows(per_method)

  segment_df <- plot_df |>
    dplyr::group_by_at(facet_var) |>
    dplyr::summarise(
      internal = dplyr::first(.data$weighted_pd_internal),
      adjusted_max = max(.data$weighted_pd_adjusted, na.rm = TRUE),
      .groups = "drop"
    )

  facet_sym <- rlang::sym(facet_var)

  ggplot2::ggplot() +
    ggplot2::geom_segment(
      data = segment_df,
      ggplot2::aes(x = .data$internal, xend = .data$adjusted_max,
                   y = !!facet_sym, yend = !!facet_sym),
      color = TRISK_HEX_GREY, linewidth = 1
    ) +
    ggplot2::geom_point(
      data = plot_df,
      ggplot2::aes(x = .data$weighted_pd_adjusted,
                   y = !!facet_sym,
                   shape = .data$method,
                   color = .data$method),
      size = 3
    ) +
    ggplot2::geom_point(
      data = segment_df,
      ggplot2::aes(x = .data$internal, y = !!facet_sym),
      shape = 124, size = 5, color = "#1A1A1A"
    ) +
    ggplot2::scale_shape_manual(values = c(absolute = 16, relative = 17, zscore = 15)) +
    ggplot2::scale_color_manual(values = c(absolute = TRISK_HEX_ADJUSTED,
                                           relative = STATUS_GREEN,
                                           zscore   = TRISK_HEX_RED)) +
    ggplot2::scale_x_continuous(labels = scales::percent_format(scale = 100)) +
    TRISK_PLOT_THEME_FUNC() +
    ggplot2::labs(
      x = "EAD-weighted PD",
      y = "",
      color = "Method", shape = "Method",
      title = "PD Method Comparison (Internal → Adjusted)",
      subtitle = "Black tick = Internal PD; colored shapes = method-specific Adjusted PD"
    )
}
