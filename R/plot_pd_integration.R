#' PD integration bar plot (4-bar grouped)
#'
#' Draws four bars per facet group: Internal PD (navy), TRISK Baseline (mint),
#' TRISK Shock (orange), TRISK-Adjusted PD (purple). The four-colour palette
#' matches `plot_multi_trajectories()` for visual consistency across vignettes.
#'
#' At `granularity = "sector"` (default), the term dimension is collapsed and
#' bars are EAD-weighted means of PD per sector x pd_type. Each sector gets a
#' row of four bars (one per pd_type). At `granularity = "firm"`, one group of
#' four bars per firm/technology/term row; sectors are the facet. Firm view
#' reveals within-sector heterogeneity that sector aggregation hides.
#'
#' The `scale` argument controls y-axis transformation. `"pseudo_log"` (the
#' default, via [scales::pseudo_log_trans()]) is zero-safe and spreads values
#' that span many orders of magnitude, useful when baseline PDs underflow.
#' Pass `scale = "linear"` for a plain percent axis if all values sit in a
#' comparable range.
#'
#' @param integration_result Output of [integrate_pd()] (a list with
#'   `$portfolio_long`, which must include `exposure_value_usd`).
#' @param facet_var Column used for facets. Default `"sector"`.
#' @param granularity One of `"sector"` (EAD-weighted mean per pd_type) or
#'   `"firm"` (one bar group per firm/technology/term). Default `"sector"`.
#' @param scale One of `"pseudo_log"` (default) or `"linear"`.
#' @return A ggplot2 object.
#' @export
pipeline_crispy_pd_integration_bars <- function(integration_result,
                                                facet_var = "sector",
                                                granularity = c("sector", "firm"),
                                                scale = c("pseudo_log", "linear")) {
  granularity <- match.arg(granularity)
  scale <- match.arg(scale)
  plot_data <- prepare_for_pd_integration_plot(integration_result, facet_var, granularity)
  draw_pd_integration_plot(plot_data, facet_var, granularity, scale)
}

prepare_for_pd_integration_plot <- function(integration_result, facet_var,
                                            granularity = "sector") {
  long <- integration_result$portfolio_long
  if (granularity == "sector") {
    # EAD-weighted mean per (sector, pd_type), aggregating across all loans
    # and across all term values for that sector. The term dimension is
    # collapsed at this granularity.
    long |>
      dplyr::group_by(dplyr::across(dplyr::all_of(c(facet_var, "pd_type")))) |>
      dplyr::summarise(
        pd_value = stats::weighted.mean(.data$pd_value,
                                        .data$exposure_value_usd, na.rm = TRUE),
        .groups = "drop"
      )
  } else {
    long |>
      dplyr::mutate(firm_label = paste(.data$company_id, .data$technology,
                                       paste0("t=", .data$term), sep = "/")) |>
      dplyr::select(dplyr::any_of(c(facet_var)), "firm_label", "term",
                    "pd_type", "pd_value")
  }
}

draw_pd_integration_plot <- function(plot_data, facet_var,
                                     granularity = "sector",
                                     scale = "pseudo_log") {
  # Trajectory-aligned palette: navy, mint, orange, purple. Each colour has
  # a distinct semantic role so the four bar types remain visually separable
  # without relying on order-of-presentation cues.
  fill_palette <- c(
    internal       = "#1b324f",
    baseline       = "#00c082",
    shock          = "#ff9623",
    trisk_adjusted = "#574099"
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
                         ggplot2::aes(x = .data$pd_type,
                                      y = .data$pd_value,
                                      fill = .data$pd_type)) +
      ggplot2::geom_bar(stat = "identity", show.legend = FALSE) +
      ggplot2::facet_grid(stats::as.formula(paste(facet_var, "~ ."))) +
      ggplot2::labs(x = "PD type", y = "EAD-weighted PD")
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
      ggplot2::labs(x = "firm / technology / term", y = "PD")
  }

  p +
    ggplot2::scale_fill_manual(values = fill_palette, name = "PD type") +
    y_scale +
    TRISK_PLOT_THEME_FUNC() +
    ggplot2::labs(title = "PD integration: baseline, shock, internal, adjusted")
}
