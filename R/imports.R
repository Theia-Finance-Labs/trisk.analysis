#' @importFrom rlang %||% abort warn .data .env :=
#' @importFrom magrittr %>%
NULL

#' Run TRISK Model
#'
#' @title run_trisk_model
#' @name run_trisk_model
#' @description Re-exported function from trisk.model package. Please see \code{trisk.model::run_trisk_model} for full documentation.
#' @return See \code{trisk.model::run_trisk_model}
#' @seealso \code{\link[trisk.model]{run_trisk_model}}
#' @importFrom trisk.model run_trisk_model
#' @export
NULL

TRISK_DATA_INPUT_ENDPOINT <- "https://storage.googleapis.com"
TRISK_DATA_S3_PREFIX <- "crispy-public-data/trisk_inputs"

#' TRISK plot palette constants
#'
#' Hex colour codes used by the built-in `pipeline_trisk_*` plot functions.
#' Exported so users can match the palette in custom plots and vignette chunks.
#'
#' \itemize{
#'   \item `TRISK_HEX_RED` — primary red, for shock / negative / worse-off fills.
#'   \item `TRISK_HEX_GREEN` — primary green, for baseline / better-off fills.
#'   \item `TRISK_HEX_GREY` — neutral grey, for reference / neutral series.
#'   \item `TRISK_HEX_ADJUSTED` — dark-red blend, for adjusted PD/EL series.
#'   \item `STATUS_GREEN` — muted green (from `trisk.r.docker`), for
#'     positive / better-off status fills.
#' }
#'
#' @format Character scalars (hex colour strings).
#' @name trisk_palette
NULL

#' @rdname trisk_palette
#' @export
TRISK_HEX_RED <- "#F53D3F"
#' @rdname trisk_palette
#' @export
TRISK_HEX_GREEN <- "#5D9324"
#' @rdname trisk_palette
#' @export
TRISK_HEX_GREY <- "#BAB6B5"
#' @rdname trisk_palette
#' @export
TRISK_HEX_ADJUSTED <- "#AA2A2B"
#' @rdname trisk_palette
#' @export
STATUS_GREEN <- "#3D8B5E"

# Numeric constants used across the integration + plotting layer.
# Default for `qnorm()` clip in the z-score effective-PD transform.
ZSCORE_FLOOR_DEFAULT <- 1e-4
ZSCORE_CAP_DEFAULT   <- 1 - 1e-4
# Z1: when more than this fraction of rows have a PD clipped to the floor/cap
# before qnorm(), the z-score overlay is governed by the clip bound rather than
# the model, so integrate_pd()/integrate_el() emit a warning.
ZSCORE_CLIP_WARN_THRESHOLD <- 0.5
# Default sigma for `scales::pseudo_log_trans()`; small enough that PDs in
# [0, 0.5] retain near-log spacing without exploding around zero.
PSEUDO_LOG_SIGMA_DEFAULT <- 1e-5
# Basis points scale factor (1 bp = 1e-4 of EAD).
BPS_PER_UNIT <- 1e4

# Convert a (signed or unsigned) EL value to basis points of EAD. Returns
# NA if ead is zero or NA; takes abs(el) so the sign of el doesn't flip the
# bps (callers attach direction separately).
el_to_bps <- function(el, ead) {
  ifelse(is.na(ead) | ead == 0, NA_real_, abs(el) / ead * BPS_PER_UNIT)
}

#' TRISK plot theme
#'
#' Standard ggplot2 theme used across trisk.analysis plots. Exported so
#' users can apply it to custom plots (e.g. vignette chunks) for visual
#' consistency with the built-in `pipeline_trisk_*` functions.
#'
#' @param base_size Base font size. Default 12.
#' @param base_family Base font family. Default "Helvetica".
#' @param base_line_size Line thickness. Default `base_size / 22`.
#' @param base_rect_size Rectangle border thickness. Default `base_size / 22`.
#' @return A ggplot2 theme object.
#' @export
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
