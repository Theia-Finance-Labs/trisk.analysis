#' PD waterfall plot
#'
#' Per-facet cumulative decomposition: an Internal anchor bar (0 to internal
#' PD), a signed Adjustment segment that bridges the Internal top to the
#' Adjusted top, and an Adjusted anchor bar (0 to adjusted PD). The
#' Adjustment segment fill flips on sign: `TRISK_HEX_RED` when the
#' adjustment worsens risk (positive delta), `STATUS_GREEN` when it improves
#' risk. Internal and Adjusted anchors use the neutral grey and dark-red
#' roles from the standard palette. The cumulative segment construction is
#' what makes this a true waterfall: reading left to right traces internal +
#' adjustment = adjusted geometrically.
#'
#' @param integration_result Output of [integrate_pd()] (a list with a
#'   `$portfolio` data frame).
#' @param facet_var Column used for facet wrapping. Default `"sector"`.
#' @return A ggplot2 object.
#' @export
pipeline_crispy_pd_waterfall <- function(integration_result,
                                         facet_var = "sector") {
  agg <- aggregate_pd_integration(integration_result$portfolio,
                                  group_cols = facet_var)

  # Build explicit (xmin, xmax, ymin, ymax) per stage so the three bars form a
  # cumulative chain: Internal (0 -> I), Adjustment (I -> I + adj == Adjusted),
  # Adjusted (0 -> A). Bar width 0.6 leaves padding around each x position.
  bar_half <- 0.3
  rect_df <- agg |>
    dplyr::mutate(
      internal = .data$weighted_pd_internal,
      adjustment = .data$weighted_pd_adjustment,
      adjusted = .data$weighted_pd_adjusted
    ) |>
    dplyr::select(dplyr::all_of(c(facet_var, "internal", "adjustment", "adjusted")))

  rect_df <- dplyr::bind_rows(
    rect_df |> dplyr::mutate(stage = "Internal",
                             xmin = 1 - bar_half, xmax = 1 + bar_half,
                             ymin = 0, ymax = .data$internal,
                             sign_group = "internal"),
    rect_df |> dplyr::mutate(stage = "Adjustment",
                             xmin = 2 - bar_half, xmax = 2 + bar_half,
                             ymin = pmin(.data$internal, .data$adjusted),
                             ymax = pmax(.data$internal, .data$adjusted),
                             sign_group = dplyr::case_when(
                               .data$adjustment > 0 ~ "worse",
                               .data$adjustment < 0 ~ "better",
                               TRUE                 ~ "neutral"
                             )),
    rect_df |> dplyr::mutate(stage = "Adjusted",
                             xmin = 3 - bar_half, xmax = 3 + bar_half,
                             ymin = 0, ymax = .data$adjusted,
                             sign_group = "adjusted")
  ) |>
    dplyr::mutate(stage = factor(.data$stage,
                                 levels = c("Internal", "Adjustment", "Adjusted")))

  ggplot2::ggplot(rect_df) +
    ggplot2::geom_rect(ggplot2::aes(xmin = .data$xmin, xmax = .data$xmax,
                                    ymin = .data$ymin, ymax = .data$ymax,
                                    fill = .data$sign_group)) +
    ggplot2::facet_wrap(stats::as.formula(paste("~", facet_var))) +
    ggplot2::scale_x_continuous(breaks = c(1, 2, 3),
                                labels = c("Internal", "Adjustment", "Adjusted")) +
    ggplot2::scale_fill_manual(
      values = c(
        internal = TRISK_HEX_GREY,
        adjusted = TRISK_HEX_ADJUSTED,
        worse    = TRISK_HEX_RED,
        better   = STATUS_GREEN,
        neutral  = TRISK_HEX_GREY
      ),
      guide = "none"
    ) +
    ggplot2::scale_y_continuous(labels = scales::percent_format()) +
    TRISK_PLOT_THEME_FUNC() +
    ggplot2::labs(x = "", y = "EAD-weighted PD",
                  title = "PD Waterfall: Internal -> Adjustment -> Adjusted")
}
