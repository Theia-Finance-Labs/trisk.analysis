#' Technology mix by sector, on two bases (NPV value and exposure)
#'
#' 100%-stacked horizontal bars of each sector's technology composition,
#' computed two ways: as a share of baseline NPV value, and as a share of
#' exposure (EAD). Technologies render as shades of the sector's base colour
#' (darkest = most carbon-intensive, via [trisk_sector_shades()]). Showing both
#' bases makes the allocation choice explicit: the NPV-weighted and
#' exposure-weighted mixes can differ materially, so a single basis can mislead.
#'
#' @param analysis_data Tech-detail frame from a TRISK runner (e.g.
#'   `run_trisk_on_simple_portfolio()$portfolio_results_tech_detail`). Must
#'   contain `sector`, `technology`, `net_present_value_baseline`, and an
#'   exposure column (`exposure_at_default` preferred, else `exposure_value_usd`).
#' @param bases Character vector selecting which bases to draw; default both.
#'
#' @return A ggplot object.
#' @export
pipeline_trisk_tech_mix <- function(analysis_data,
                                    bases = c("% of NPV value", "% of exposure (EAD)")) {
  bases <- match.arg(bases, several.ok = TRUE)
  mix <- prepare_for_trisk_tech_mix(analysis_data)
  draw_trisk_tech_mix(mix, bases)
}

#' Prepare dual-basis technology mix
#'
#' Aggregates a tech-detail frame to sector x technology and computes each
#' technology's share of baseline NPV value and of exposure (EAD), within
#' sector. Negative NPVs are clamped to zero, and a sector with no positive NPV
#' (or no exposure) falls back to an equal split, so shares stay in `[0, 1]` and
#' sum to 1 (mirrors the `add_exposure_share_from_npv()` guard).
#'
#' @param analysis_data Tech-detail frame (see [pipeline_trisk_tech_mix()]).
#' @return A tibble: one row per sector/technology with both share columns.
#' @keywords internal
prepare_for_trisk_tech_mix <- function(analysis_data) {
  ead_col <- if ("exposure_at_default" %in% colnames(analysis_data)) {
    "exposure_at_default"
  } else if ("exposure_value_usd" %in% colnames(analysis_data)) {
    "exposure_value_usd"
  } else {
    stop("pipeline_trisk_tech_mix(): need an `exposure_at_default` or ",
         "`exposure_value_usd` column.", call. = FALSE)
  }
  miss <- setdiff(c("sector", "technology", "net_present_value_baseline"),
                  colnames(analysis_data))
  if (length(miss) > 0) {
    stop("pipeline_trisk_tech_mix(): missing columns: ",
         paste(miss, collapse = ", "), call. = FALSE)
  }
  analysis_data |>
    dplyr::group_by(.data$sector, .data$technology) |>
    dplyr::summarise(
      npv = sum(.data$net_present_value_baseline, na.rm = TRUE),
      ead = sum(.data[[ead_col]], na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::group_by(.data$sector) |>
    dplyr::mutate(
      # Non-negative weights (mirrors the add_exposure_share_from_npv guard); a
      # sector with no positive NPV (or no exposure) falls back to an equal split
      # so shares stay in [0, 1] and sum to 1 rather than going 0 / 0 = NaN.
      `% of NPV value` = if (sum(pmax(.data$npv, 0)) > 0) {
        pmax(.data$npv, 0) / sum(pmax(.data$npv, 0))
      } else {
        1 / dplyr::n()
      },
      `% of exposure (EAD)` = if (sum(pmax(.data$ead, 0)) > 0) {
        pmax(.data$ead, 0) / sum(pmax(.data$ead, 0))
      } else {
        1 / dplyr::n()
      }
    ) |>
    dplyr::ungroup()
}

#' Draw the technology-mix plot
#'
#' @param mix Output of [prepare_for_trisk_tech_mix()].
#' @param bases Bases to draw (column names present in `mix`).
#' @return A ggplot object.
#' @keywords internal
draw_trisk_tech_mix <- function(mix,
                                bases = c("% of NPV value", "% of exposure (EAD)")) {
  nice <- function(t) ifelse(grepl("Cap$", t), sub("Cap$", " capacity", t), t)

  fill_values <- character(0)
  fill_labels <- character(0)
  for (s in unique(mix$sector)) {
    techs <- unique(mix$technology[mix$sector == s])
    cols  <- trisk_sector_shades(s, techs)
    keys  <- paste(s, names(cols), sep = "||")
    fill_values[keys] <- unname(cols)
    fill_labels[keys] <- nice(names(cols))
  }

  plotdf <- mix |>
    tidyr::pivot_longer(dplyr::all_of(bases),
                        names_to = "basis", values_to = "share") |>
    dplyr::mutate(
      fillkey = paste(.data$sector, .data$technology, sep = "||"),
      basis = factor(.data$basis, levels = rev(bases))
    )

  ggplot2::ggplot(plotdf,
                  ggplot2::aes(x = .data$share, y = .data$basis, fill = .data$fillkey)) +
    ggplot2::geom_col(width = 0.68, colour = "white", linewidth = 0.3) +
    ggplot2::facet_grid(rows = ggplot2::vars(.data$sector), switch = "y",
                        scales = "free_y", space = "free_y") +
    ggplot2::scale_x_continuous(labels = scales::percent_format(accuracy = 1),
                                expand = ggplot2::expansion(mult = c(0, 0.02))) +
    ggplot2::scale_fill_manual(values = fill_values, labels = fill_labels, name = NULL) +
    TRISK_PLOT_THEME_FUNC() +
    ggplot2::theme(
      panel.spacing = ggplot2::unit(0.9, "lines"),
      strip.placement = "outside",
      strip.text.y.left = ggplot2::element_text(angle = 0, hjust = 1),
      legend.position = "bottom",
      axis.title.y = ggplot2::element_blank()
    ) +
    ggplot2::guides(fill = ggplot2::guide_legend(ncol = 6, byrow = TRUE)) +
    ggplot2::labs(x = NULL, title = "Technology mix by sector",
                  subtitle = "Share of baseline NPV value vs share of exposure (EAD)")
}
