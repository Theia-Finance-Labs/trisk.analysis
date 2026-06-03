# Build NGFS2024 scenarios in PACTA production format (smsp / tmsr)
# -----------------------------------------------------------------------------
# Source : trisk.r.docker/data/input/scenarios.csv (14-col TRISK format, holds
#          NGFS2024 GCAM/MESSAGE/REMIND with ABSOLUTE scenario_pathway).
# Target : the PACTA "production" template
#          (scenario_source, region, scenario, sector, technology, year, smsp, tmsr),
#          short horizon 2023-2030.
#
# Transform (verified against r2dii.analysis::target_market_share and against the
# internal consistency of the supplied geco/weo/isf template files):
#   tmsr = pathway_t / pathway_t0                         (technology market-share ratio, = 1 at base)
#   smsp = (pathway_t - pathway_t0) / sector_total_t0     (sector market-share percentage, = 0 at base)
# where t0 = base year (2023) and sector_total_t0 = sum of base-year pathways
# across the technologies of a sector, within a scenario_source/region/scenario.
#
# NOT produced here (no source in scenarios.csv -> see report):
#   * Automotive production  -> NGFS does not model vehicle fleets.
#   * Steel/Cement/Aviation emission intensities -> scenarios.csv has no emission column.
# -----------------------------------------------------------------------------

library(dplyr)
library(tidyr)
library(readr)
library(stringr)

scenarios_path <- "/Users/jakub/Documents/repos/trisk.r.docker/data/input/scenarios.csv"
out_path       <- "/Users/jakub/Documents/repos/trisk.analysis/ngfs2024_production_smsp_tmsr.csv"

start_year <- 2023L
end_year   <- 2030L

# NGFS2024 full models (not the Global-only "NGFS2024_*" underscore variants).
ngfs_providers <- c("NGFS2024GCAM", "NGFS2024MESSAGE", "NGFS2024REMIND")

# TRISK sector/technology -> PACTA template vocabulary (lowercase). Only the
# production sectors that exist in the template are kept; Cement (a production
# pathway in NGFS) is dropped because the template treats cement as an emission
# intensity, not a production share.
sector_map <- c("Power" = "power", "Coal" = "coal", "Oil&Gas" = "oil and gas")

raw <- read_csv(scenarios_path, show_col_types = FALSE)

# Regions are taken as-is from NGFS's own model geographies (Global + ~10 IAM
# regions), lowercased. This set is intentionally different from the supplied
# geco/weo/isf template's IEA regions: region coverage is per scenario provider,
# not governed by the template format, so do NOT "correct" it to match the template.
ngfs <- raw |>
  filter(
    .data$scenario_provider %in% ngfs_providers,
    .data$sector %in% names(sector_map),
    .data$scenario_year >= start_year,
    .data$scenario_year <= end_year
  ) |>
  transmute(
    scenario_source = str_to_lower(.data$scenario_provider),
    region          = str_to_lower(.data$scenario_geography),
    # strip the provider prefix from the scenario name: NGFS2024GCAM_NZ2050 -> nz2050
    scenario        = str_to_lower(str_remove(.data$scenario, paste0(.data$scenario_provider, "_"))),
    sector          = unname(sector_map[.data$sector]),
    technology      = str_to_lower(.data$technology),
    year            = as.integer(.data$scenario_year),
    scenario_pathway = .data$scenario_pathway
  )

# Base-year (2023) pathway per technology and sector-total per sector.
base_tech <- ngfs |>
  filter(.data$year == start_year) |>
  select(scenario_source, region, scenario, sector, technology,
         first_pathway = scenario_pathway)

base_sector <- base_tech |>
  group_by(.data$scenario_source, .data$region, .data$scenario, .data$sector) |>
  summarise(sector_total_first = sum(.data$first_pathway), .groups = "drop")

production_full <- ngfs |>
  left_join(base_tech, by = c("scenario_source", "region", "scenario", "sector", "technology")) |>
  left_join(base_sector, by = c("scenario_source", "region", "scenario", "sector")) |>
  mutate(
    # Match the supplied geco/weo/isf template convention for a zero base-year pathway:
    #   pathway > 0 over a 0 base  -> Inf  (R's x/0)
    #   pathway = 0 over a 0 base  -> 1    (0/0 treated as "no change", as the template does
    #                                       for zero-nuclear regions: smsp=0, tmsr=1)
    tmsr = .data$scenario_pathway / .data$first_pathway,
    tmsr = if_else(is.nan(.data$tmsr), 1, .data$tmsr),
    smsp = if_else(.data$sector_total_first == 0, NA_real_,
                   (.data$scenario_pathway - .data$first_pathway) / .data$sector_total_first)
  ) |>
  arrange(.data$scenario_source, .data$region, .data$scenario, .data$sector,
          .data$technology, .data$year)

production <- production_full |>
  select(scenario_source, region, scenario, sector, technology, year, smsp, tmsr)

# --- in-script assertions (fail loudly if the transform is wrong) ------------
# Finite-tmsr base rows must equal 1; non-finite (Inf/NaN) only for zero base-year
# pathway. smsp is defined for every row and must equal 0 at base year.
base_rows <- production |> filter(.data$year == start_year)
stopifnot(
  "tmsr must equal 1 at base year (finite rows)" =
    all(abs(base_rows$tmsr[is.finite(base_rows$tmsr)] - 1) < 1e-9),
  "smsp must equal 0 at base year" = all(abs(base_rows$smsp) < 1e-9, na.rm = TRUE),
  "non-finite tmsr only where base pathway is 0" =
    all(production_full$first_pathway[!is.finite(production_full$tmsr)] == 0)
)

# Each technology's base share (first_pathway / sector_total_first) must sum to 1
# across the sector. This guards against join duplication: if a left_join fanned
# out rows, sector_total_first would be inflated and the shares would not sum to 1.
# NOTE: compute the share directly from pathways, NOT as smsp/(tmsr-1): that ratio
# is 0/0 (undefined) for technologies that are flat from the base year (tmsr == 1),
# so it silently drops them and the surviving shares appear to sum to < 1. The
# direct first_pathway/sector_total form is stable and includes flat technologies.
share_check <- production_full |>
  filter(.data$year == start_year, .data$sector_total_first != 0) |>
  mutate(base_share = .data$first_pathway / .data$sector_total_first) |>
  group_by(.data$scenario_source, .data$region, .data$scenario, .data$sector) |>
  summarise(share_sum = sum(.data$base_share), .groups = "drop")
stopifnot("per-sector base shares must sum to 1" =
            all(abs(share_check$share_sum - 1) < 1e-6))

write_csv(production, out_path)

cat("Wrote", out_path, "\n")
cat("rows:", nrow(production), "\n")
cat("scenario_source:", paste(sort(unique(production$scenario_source)), collapse = ", "), "\n")
cat("scenarios:", paste(sort(unique(production$scenario)), collapse = ", "), "\n")
cat("sectors:", paste(sort(unique(production$sector)), collapse = ", "), "\n")
cat("regions:", length(unique(production$region)),
    "->", paste(sort(unique(production$region)), collapse = ", "), "\n")
cat("years:", min(production$year), "-", max(production$year), "\n")
cat("share-sum check groups:", nrow(share_check), "all == 1 within 1e-6\n")
