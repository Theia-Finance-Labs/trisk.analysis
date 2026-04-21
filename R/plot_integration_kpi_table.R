#' PD Integration KPI Table
#'
#' kableExtra-formatted one-row summary of the PD integration aggregate.
#' Ports the Shiny `valueBox` strip from `mod_integration.R:321-356`.
#'
#' @param pd_aggregate The `$aggregate` element from [integrate_pd()], or the
#'   output of [aggregate_pd_integration()].
#' @return A `knitr_kable` object.
#' @export
pipeline_crispy_pd_kpi_table <- function(pd_aggregate) {
  display <- tibble::tibble(
    `Total Exposure (USD)`            = format_big_number(pd_aggregate$total_exposure_usd),
    `Weighted Internal PD`            = format_pct(pd_aggregate$weighted_pd_internal),
    `Weighted Adjusted PD`            = format_pct(pd_aggregate$weighted_pd_adjusted),
    `Weighted PD Adjustment (pp)`     = format_pp(pd_aggregate$weighted_pd_adjustment),
    `Adjustment %`                    = format_pct(pd_aggregate$weighted_pd_adjustment_pct)
  )

  adjustment_color <- sign_color(pd_aggregate$weighted_pd_adjustment, positive_is = "red")
  display$`Weighted PD Adjustment (pp)` <- kableExtra::cell_spec(
    display$`Weighted PD Adjustment (pp)`, color = adjustment_color, bold = TRUE
  )

  display |>
    knitr::kable("html", escape = FALSE, align = "r") |>
    kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed"))
}

#' EL Integration KPI Table
#'
#' kableExtra-formatted one-row summary of the EL integration aggregate.
#' Ports `mod_integration.R:657-704` including the bps metric.
#'
#' @param el_aggregate The `$aggregate` element from [integrate_el()].
#' @return A `knitr_kable` object.
#' @export
pipeline_crispy_el_kpi_table <- function(el_aggregate) {
  display <- tibble::tibble(
    `Total Exposure (USD)` = format_big_number(el_aggregate$total_exposure_usd),
    `Total Internal EL`    = format_big_number(el_aggregate$total_el_internal),
    `Total Adjusted EL`    = format_big_number(el_aggregate$total_el_adjusted),
    `EL Adjustment`        = format_big_number(el_aggregate$total_el_adjustment),
    `Adjusted EL (bps)`    = format_bps(el_aggregate$el_adjusted_bps)
  )

  adjustment_color <- sign_color(el_aggregate$total_el_adjustment, positive_is = "green")
  display$`EL Adjustment` <- kableExtra::cell_spec(
    display$`EL Adjustment`, color = adjustment_color, bold = TRUE
  )

  display |>
    knitr::kable("html", escape = FALSE, align = "r") |>
    kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed"))
}

# Internal formatting helpers - declared here because they only serve the KPI tables.
format_big_number <- function(x) {
  if (is.null(x) || is.na(x)) return("-")
  if (abs(x) >= 1e9) return(sprintf("%.2fB", x / 1e9))
  if (abs(x) >= 1e6) return(sprintf("%.2fM", x / 1e6))
  if (abs(x) >= 1e3) return(sprintf("%.1fK", x / 1e3))
  sprintf("%.2f", x)
}

format_pct <- function(x) {
  if (is.null(x) || is.na(x)) return("-")
  sprintf("%.3f%%", x * 100)
}

format_pp <- function(x) {
  if (is.null(x) || is.na(x)) return("-")
  sprintf("%+.3f pp", x * 100)
}

format_bps <- function(x) {
  if (is.null(x) || is.na(x)) return("-")
  sprintf("%.1f bps", x)
}

# Return the color string to apply to a signed adjustment value.
# For PD: positive_is="red" means positive adjustments (PD got worse) render red.
# For EL: positive_is="green" means positive EL adjustments (less loss) render green.
sign_color <- function(x, positive_is = c("red", "green")) {
  positive_is <- match.arg(positive_is)
  if (is.null(x) || is.na(x) || abs(x) < 1e-12) return("#6c757d")  # grey neutral
  if (x > 0) {
    if (positive_is == "red") TRISK_HEX_RED else STATUS_GREEN
  } else {
    if (positive_is == "red") STATUS_GREEN else TRISK_HEX_RED
  }
}

#' EL Sector Breakdown Table
#'
#' Sector-level EL breakdown with direction arrows, exposure, internal vs
#' adjusted EL, delta, and EL/EAD in bps. Ports the Shiny collapsible breakdown
#' at `mod_integration.R:707-786` into a printable table.
#'
#' @param portfolio_df The `$portfolio` from [integrate_el()].
#' @param group_col Character column to group by. Default "sector".
#' @return A `knitr_kable` object.
#' @export
pipeline_crispy_el_sector_breakdown_table <- function(portfolio_df,
                                                      group_col = "sector") {
  if (!group_col %in% colnames(portfolio_df)) {
    stop("pipeline_crispy_el_sector_breakdown_table(): column '", group_col,
         "' not in portfolio_df")
  }

  summary <- portfolio_df |>
    dplyr::group_by(dplyr::across(dplyr::all_of(group_col))) |>
    dplyr::summarise(
      Count            = dplyr::n(),
      Exposure         = sum(.data$exposure_value_usd, na.rm = TRUE),
      `Internal EL`    = sum(.data$internal_el, na.rm = TRUE),
      `Adjusted EL`    = sum(.data$trisk_adjusted_el, na.rm = TRUE),
      `EL Adjustment`  = sum(.data$el_adjustment, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      `EL_EAD_bps` = ifelse(.data$Exposure > 0,
                            abs(.data$`Adjusted EL`) / .data$Exposure * 10000,
                            NA_real_),
      Direction = dplyr::case_when(
        .data$`EL Adjustment` < -0.01 ~ "\u2191",    # up arrow: loss worse
        .data$`EL Adjustment` >  0.01 ~ "\u2193",    # down arrow: loss better
        TRUE ~ "-"                                     # neutral
      )
    )

  display <- summary |>
    dplyr::transmute(
      !!rlang::sym(group_col) := .data[[group_col]],
      .data$Direction,
      Count = format(.data$Count),
      Exposure      = sapply(.data$Exposure,      format_big_number),
      `Internal EL` = sapply(.data$`Internal EL`, format_big_number),
      `Adjusted EL` = sapply(.data$`Adjusted EL`, format_big_number),
      `EL Adjustment` = sapply(.data$`EL Adjustment`, format_big_number),
      `EL/EAD (bps)`  = sapply(.data$EL_EAD_bps, format_bps)
    )

  display |>
    knitr::kable("html", escape = FALSE, align = "r") |>
    kableExtra::kable_styling(
      bootstrap_options = c("striped", "hover", "condensed")
    )
}
