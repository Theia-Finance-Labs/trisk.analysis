#' Scaffold a local TRISK input-data folder
#'
#' @description
#' Creates a project-level `trisk_inputs/` folder that a bank populates with its
#' own data, pre-seeded with **blank templates** (header-only CSVs to fill in)
#' and **filled samples** (the bundled example data, as a worked reference), plus
#' a `README.md` documenting the required files, their schemas, and the three
#' portfolio-matching modes.
#'
#' @details
#' The folder is created in your **working directory** (or wherever `path`
#' points), never inside the installed package: the package library is read-only
#' on many systems and is overwritten on every update, so input data must live in
#' your own project. The vignettes load bundled sample data as placeholders; once
#' you have filled the templates, save your files as `trisk_inputs/<input>.csv`
#' and point the analysis reads there.
#'
#' TRISK takes five inputs. Four describe the world; the fifth is your portfolio:
#' \describe{
#'   \item{assets}{Physical/production assets per company. You supply this.}
#'   \item{scenarios}{Climate-scenario price and production pathways. The full
#'     set is fetched with [download_trisk_inputs()]; a small sample is bundled.}
#'   \item{ngfs_carbon_price}{Carbon-price trajectories. A sample is bundled.}
#'   \item{financial_features}{Per-company financials (PD, margins, leverage,
#'     volatility). You supply this.}
#'   \item{portfolio_ids}{**Your loan book**, keyed by `company_id` — the main,
#'     recommended portfolio input. You can instead match by company name
#'     (`portfolio_names`) or by country only (`portfolio_countries`); both are
#'     options. Add an `internal_pd` column for the PD/EL-integration workflows.}
#' }
#'
#' @param path Directory to create. Defaults to `"trisk_inputs"` in the working
#'   directory.
#' @param overwrite If `FALSE` (default), existing files are left untouched so a
#'   re-run never clobbers data you have already filled in. If `TRUE`, templates,
#'   samples and the README are regenerated.
#'
#' @return The `path`, invisibly.
#' @export
setup_trisk_inputs <- function(path = "trisk_inputs", overwrite = FALSE) {
  sources <- list(
    assets             = list(package = "trisk.model",    file = "assets_testdata.csv"),
    scenarios          = list(package = "trisk.model",    file = "scenarios_testdata.csv"),
    ngfs_carbon_price  = list(package = "trisk.model",    file = "ngfs_carbon_price_testdata.csv"),
    financial_features = list(package = "trisk.model",    file = "financial_features_testdata.csv"),
    portfolio_ids      = list(package = "trisk.analysis", file = "portfolio_ids_testdata.csv")
  )

  templates_dir <- file.path(path, "templates")
  samples_dir   <- file.path(path, "samples")
  dir.create(templates_dir, recursive = TRUE, showWarnings = FALSE)
  dir.create(samples_dir, recursive = TRUE, showWarnings = FALSE)

  for (nm in names(sources)) {
    src <- system.file("testdata", sources[[nm]]$file, package = sources[[nm]]$package)
    if (!nzchar(src) || !file.exists(src)) {
      warning("Could not locate bundled source for '", nm, "' (",
              sources[[nm]]$file, "); skipping.", call. = FALSE)
      next
    }

    sample_path   <- file.path(samples_dir, paste0(nm, ".csv"))
    template_path <- file.path(templates_dir, paste0(nm, ".csv"))

    # Filled sample: copy the bundled example as-is.
    if (overwrite || !file.exists(sample_path)) {
      file.copy(src, sample_path, overwrite = TRUE)
    }

    # Blank template: the header line only, ready to fill in.
    if (overwrite || !file.exists(template_path)) {
      header_line <- readLines(src, n = 1L, warn = FALSE)
      writeLines(header_line, template_path)
    }
  }

  readme_path <- file.path(path, "README.md")
  if (overwrite || !file.exists(readme_path)) {
    writeLines(trisk_inputs_readme(), readme_path)
  }

  message("TRISK input folder ready at: ", normalizePath(path, mustWork = FALSE))
  message("  templates/  blank, header-only CSVs to fill in")
  message("  samples/    filled example data, as a reference")
  message("  README.md   required files, schemas and portfolio modes")
  invisible(path)
}


# Internal: the README written into a freshly scaffolded trisk_inputs/ folder.
# Provenance is per-input and deliberately accurate (download_trisk_inputs()
# currently fetches scenarios.csv only).
trisk_inputs_readme <- function() {
  c(
    "# TRISK input data",
    "",
    "This folder is **yours to populate**. TRISK needs five inputs; four describe",
    "the world, the fifth is your portfolio. Each input has a blank form in",
    "`templates/` and a filled worked example in `samples/`.",
    "",
    "## How to use this folder",
    "",
    "1. Open the blank form in `templates/<input>.csv` (or copy the matching",
    "   `samples/<input>.csv` and edit it).",
    "2. Fill it with your data, keeping the column names exactly as shown.",
    "3. Save the result as `trisk_inputs/<input>.csv`.",
    "4. In the vignettes, replace the placeholder `read.csv(system.file(...))`",
    "   lines with `read.csv(\"trisk_inputs/<input>.csv\")`.",
    "",
    "## The five inputs",
    "",
    "| File | What it is | Where it comes from |",
    "|------|------------|---------------------|",
    "| `assets.csv` | Physical/production assets per company | **You supply it.** |",
    "| `scenarios.csv` | Climate-scenario price & production pathways | Full set via `download_trisk_inputs()`; sample bundled. |",
    "| `ngfs_carbon_price.csv` | Carbon-price trajectories | Sample bundled; replace if you have your own. |",
    "| `financial_features.csv` | Per-company financials (PD, margins, leverage, volatility) | **You supply it.** |",
    "| `portfolio_ids.csv` | **Your loan book** (main portfolio input) | **You supply it.** |",
    "",
    "## The portfolio input (central)",
    "",
    "`portfolio_ids.csv` is the **main** portfolio input. It is keyed by",
    "`company_id` and carries, per loan:",
    "",
    "- `company_id`, `company_name`, `sector`, `technology`, `country_iso2`",
    "- `exposure_value_usd` — exposure of the loan",
    "- `term` — loan term in years",
    "- `loss_given_default` — LGD in [0, 1]",
    "",
    "Two alternative matching modes are available as **options**:",
    "",
    "- `portfolio_names.csv` — same columns, but companies are fuzzy-matched by",
    "  `company_name` when `company_id` is unknown.",
    "- `portfolio_countries.csv` — match by `country_iso2` only (country-level",
    "  aggregation) when neither id nor name is available.",
    "",
    "For the PD/EL-integration and sensitivity workflows, add an `internal_pd`",
    "column (your own PD per company, in [0, 1]) — this is the",
    "`portfolio_ids_internal_pd` variant used in those vignettes.",
    "",
    "## Getting the full scenario set",
    "",
    "The bundled `scenarios.csv` is a small sample. To pull the full production",
    "scenario library (many providers and vintages), run:",
    "",
    "```r",
    "download_trisk_inputs(local_save_folder = \"trisk_inputs\")",
    "```",
    "",
    "(`download_trisk_inputs()` currently fetches `scenarios.csv`; supply",
    "`assets.csv`, `financial_features.csv` and `ngfs_carbon_price.csv` yourself,",
    "starting from the bundled samples.)",
    ""
  )
}
