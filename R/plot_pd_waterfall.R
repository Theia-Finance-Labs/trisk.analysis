#' PD waterfall plot
#'
#' Per-facet decomposition: Internal PD bar -> signed Adjustment bar -> Adjusted
#' PD bar. The Adjustment bar fill flips on sign: `TRISK_HEX_RED` when the
#' adjustment worsens risk (positive delta), `STATUS_GREEN` when it improves
#' risk. Internal and Adjusted bars use the neutral grey and dark-red roles
#' from the standard palette.
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

  plot_df <- agg |>
    tidyr::pivot_longer(
      cols = c("weighted_pd_internal", "weighted_pd_adjustment", "weighted_pd_adjusted"),
      names_to = "stage_raw",
      values_to = "value"
    ) |>
    dplyr::mutate(
      stage = factor(
        dplyr::case_when(
          .data$stage_raw == "weighted_pd_internal"   ~ "Internal",
          .data$stage_raw == "weighted_pd_adjustment" ~ "Adjustment",
          .data$stage_raw == "weighted_pd_adjusted"  ~ "Adjusted"
        ),
        levels = c("Internal", "Adjustment", "Adjusted")
      ),
      sign_group = dplyr::case_when(
        .data$stage == "Adjustment" & .data$value > 0 ~ "worse",
        .data$stage == "Adjustment" & .data$value < 0 ~ "better",
        .data$stage == "Internal"                     ~ "internal",
        .data$stage == "Adjusted"                     ~ "adjusted",
        TRUE                                          ~ "neutral"
      )
    )

  ggplot2::ggplot(plot_df,
                  ggplot2::aes(x = .data$stage, y = .data$value,
                               fill = .data$sign_group)) +
    ggplot2::geom_bar(stat = "identity") +
    ggplot2::facet_wrap(stats::as.formula(paste("~", facet_var))) +
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
