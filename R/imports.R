#' @importFrom rlang %||% abort warn .data .env :=
#' @importFrom magrittr %>%


TRISK_DATA_INPUT_ENDPOINT <- "https://crispy-datamodels-bucket.fra1.cdn.digitaloceanspaces.com"
TRISK_DATA_S3_PREFIX <- "crispy-datamodels-bucket/trisk_V2_legacy/csv"

TRISK_HEX_RED <- "#F53D3F"
TRISK_HEX_GREEN <- "#5D9324"
TRISK_HEX_GREY <- "#BAB6B5"
TRISK_PLOT_THEME_FUNC <- function(
    base_size = 12, base_family = "Helvetica", base_line_size = base_size / 22,
    base_rect_size = base_size / 22) {
  supporting_elts_color <- "#C0C0C0"
  margin <- ggplot2::margin(5, 5, 5, 5)

  ggplot2::theme_classic(
    base_size = base_size,
    base_family = base_family,
    base_line_size = base_line_size,
    base_rect_size = base_rect_size
  ) +
    ggplot2::theme(
      axis.line = ggplot2::element_line(colour = supporting_elts_color),
      axis.ticks = ggplot2::element_line(colour = supporting_elts_color),
      axis.text = ggplot2::element_text(size = base_size * 10 / 12, margin = margin),
      axis.title = ggplot2::element_text(margin = margin),
      legend.text = ggplot2::element_text(size = base_size * 9 / 12, margin = margin),
      legend.title = ggplot2::element_blank(),
      plot.margin = ggplot2::unit(c(0.5, 1, 0.5, 0.5), "cm"),
      plot.title = ggplot2::element_text(
        hjust = 0.5,
        vjust = 0.5,
        face = "bold",
        size = base_size * 14 / 12,
        margin = ggplot2::margin(8, 2, 8, 6)
      ),
      plot.subtitle = ggplot2::element_text(
        hjust = 0.5,
        vjust = 0.5,
        size = base_size * 10 / 12,
        margin = ggplot2::margin(0, 2, 8, 6)
      ),
      strip.background = ggplot2::element_blank(),
      strip.switch.pad.grid = ggplot2::unit(0.2, "cm"),
      strip.text = ggplot2::element_text(size = base_size * 10 / 12, margin = margin)
    )
}
