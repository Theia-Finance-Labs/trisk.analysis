#' PD Integration Method Comparison Plot
#'
#' Runs all three PD integration methods on the same input and overlays
#' their adjusted PDs so the user can see method sensitivity at a glance.
#' Inspired by the range-lollipop pattern in `mod_results_scenarios.R:220-234`.
#'
#' At `granularity = "sector"` (default), each group shows the EAD-weighted
#' internal PD as a tick and the weighted adjusted PD as a colored shape per
#' method. At `granularity = "firm"`, each firm row shows its internal PD
#' tick and three method-specific adjusted PDs. Firm-level is more
#' informative when sectors aggregate away method divergence (e.g. sparse
#' portfolios where most firms have baseline PDs near zero).
#'
#' The `scale` argument controls x-axis transformation. `"pseudo_log"`
#' (via [scales::pseudo_log_trans()]) handles values spanning many orders
#' of magnitude including zero, which is common when Merton inputs drive
#' some firms' baseline PDs to double-precision underflow.
#'
#' @param analysis_data Raw output of [run_trisk_on_portfolio()].
#' @param internal_pd Optional; forwarded to [integrate_pd()].
#' @param facet_var Column used for sector-level aggregation (ignored when
#'   `granularity = "firm"`). Default `"sector"`.
#' @param granularity One of `"sector"` (aggregate to facet_var groups,
#'   EAD-weighted) or `"firm"` (one row per portfolio firm/technology/term).
#'   Default `"sector"`.
#' @param scale One of `"linear"` or `"pseudo_log"`. Default `"linear"`.
#' @return A ggplot2 object.
#' @export
pipeline_crispy_pd_method_comparison <- function(analysis_data,
                                                 internal_pd = NULL,
                                                 facet_var = "sector",
                                                 granularity = c("sector", "firm"),
                                                 scale = c("linear", "pseudo_log")) {
  granularity <- match.arg(granularity)
  scale <- match.arg(scale)
  methods <- c("absolute", "relative", "zscore")

  if (granularity == "sector") {
    per_method <- lapply(methods, function(m) {
      integrated <- integrate_pd(analysis_data,
                                 internal_pd = internal_pd, method = m)
      agg <- aggregate_pd_integration(integrated$portfolio,
                                      group_cols = facet_var)
      agg |>
        dplyr::mutate(method = m) |>
        dplyr::rename(internal_pd = "weighted_pd_internal",
                      trisk_adjusted_pd = "weighted_pd_adjusted")
    })
    plot_df <- dplyr::bind_rows(per_method)
    y_sym <- rlang::sym(facet_var)
    facet_layer <- NULL
    subtitle <- "Black tick = Internal PD; colored shapes = method-specific Adjusted PD"
  } else {
    per_method <- lapply(methods, function(m) {
      integrate_pd(analysis_data, internal_pd = internal_pd, method = m)$portfolio |>
        dplyr::mutate(
          method = m,
          firm_label = paste(.data$company_id, .data$technology, sep = "/")
        ) |>
        dplyr::select(dplyr::any_of(c(facet_var)),
                      "firm_label", "method",
                      "internal_pd", "trisk_adjusted_pd")
    })
    plot_df <- dplyr::bind_rows(per_method)
    y_sym <- rlang::sym("firm_label")
    facet_layer <- ggplot2::facet_grid(
      stats::as.formula(paste(facet_var, "~ .")),
      scales = "free_y", space = "free_y"
    )
    subtitle <- "Black tick = Internal PD; colored shapes = method-specific Adjusted PD (per firm)"
  }

  segment_df <- plot_df |>
    dplyr::group_by(!!y_sym) |>
    dplyr::summarise(
      internal = dplyr::first(.data$internal_pd),
      adjusted_max = max(.data$trisk_adjusted_pd, na.rm = TRUE),
      .groups = "drop"
    )
  if (granularity == "firm") {
    segment_df <- segment_df |>
      dplyr::left_join(
        plot_df |>
          dplyr::select(dplyr::any_of(c(facet_var, "firm_label"))) |>
          dplyr::distinct(),
        by = "firm_label"
      )
  }

  x_scale <- if (scale == "pseudo_log") {
    ggplot2::scale_x_continuous(
      trans  = scales::pseudo_log_trans(sigma = 1e-5),
      breaks = c(0, 1e-4, 1e-3, 0.01, 0.05, 0.15),
      labels = scales::percent_format(accuracy = 0.01)
    )
  } else {
    ggplot2::scale_x_continuous(labels = scales::percent_format(scale = 100))
  }

  ggplot2::ggplot() +
    ggplot2::geom_segment(
      data = segment_df,
      ggplot2::aes(x = .data$internal, xend = .data$adjusted_max,
                   y = !!y_sym, yend = !!y_sym),
      color = TRISK_HEX_GREY, linewidth = 1
    ) +
    ggplot2::geom_point(
      data = plot_df,
      ggplot2::aes(x = .data$trisk_adjusted_pd,
                   y = !!y_sym,
                   shape = .data$method,
                   color = .data$method),
      size = 3
    ) +
    ggplot2::geom_point(
      data = segment_df,
      ggplot2::aes(x = .data$internal, y = !!y_sym),
      shape = 124, size = 5, color = "#1A1A1A"
    ) +
    facet_layer +
    ggplot2::scale_shape_manual(values = c(absolute = 16, relative = 17, zscore = 15)) +
    ggplot2::scale_color_manual(values = c(absolute = TRISK_HEX_ADJUSTED,
                                           relative = STATUS_GREEN,
                                           zscore   = TRISK_HEX_RED)) +
    x_scale +
    TRISK_PLOT_THEME_FUNC() +
    ggplot2::labs(
      x = if (granularity == "sector") "EAD-weighted PD" else "PD",
      y = "",
      color = "Method", shape = "Method",
      title = "PD Method Comparison (Internal \u2192 Adjusted)",
      subtitle = subtitle
    )
}
