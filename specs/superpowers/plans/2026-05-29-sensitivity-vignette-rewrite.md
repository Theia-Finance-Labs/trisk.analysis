# Sensitivity-analysis vignette rewrite — implementation plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use `superpowers:subagent-driven-development` (recommended) or `superpowers:executing-plans` to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Replace the thin public `vignettes/sensitivity-analysis.Rmd` (121 lines, 3 sections) with a ~285-line vignette that demonstrates shock-year / IAM / ambition sensitivity using actual portfolio terms and EAD-weighted aggregation, closes with an integrated EL bps callout, and uses real NGFS data extended in `trisk.model`.

**Architecture:** Three phases. Phase 1 extends `trisk.model/inst/testdata/scenarios_testdata.csv` with eight new NGFS2023 scenarios (REMIND, MESSAGE, plus B2DS/DT under GCAM). Phase 2 tags a new `trisk.model` release that bundles PR #58 (ADO 1943) and Phase 1. Phase 3 rewrites the vignette in `trisk.analysis` against the new `trisk.model` baseline.

**Tech Stack:** R (devtools, testthat, rmarkdown), CSV data, NGFS public scenarios bucket (`https://storage.googleapis.com/crispy-public-data/trisk_inputs/scenarios.csv`).

**Spec:** [`specs/superpowers/2026-05-28-sensitivity-vignette-rewrite-design.md`](../2026-05-28-sensitivity-vignette-rewrite-design.md)

**External prerequisites (NOT in this plan):**
- `trisk.model` PR #58 (ADO 1943 term-grid fix) merged. PR URL: https://github.com/Theia-Finance-Labs/trisk.model/pull/58
- A reviewer for the Phase 1 PR and the trisk.analysis PR.

---

## Phase 1 — Extend `trisk.model` bundled scenarios

Working dir: `~/Documents/repos/trisk.model/`.

### Task 1.1: Branch from main with PR #58 merged

**Files:** none (git operation)

- [ ] **Step 1: Sync main and confirm PR #58 has merged**

```bash
git checkout main
git fetch origin
git pull origin main
gh pr view 58 --json state -q .state
```
Expected: `MERGED`. If not, STOP and resolve PR #58 first.

- [ ] **Step 2: Create feature branch**

```bash
git checkout -b feat/extend-scenarios-testdata-for-iam-ambition-sensitivity
```

### Task 1.2: Write the data-raw extension script

**Files:**
- Create: `data-raw/03_extend_scenarios_testdata.R`

- [ ] **Step 1: Write the script**

```r
# data-raw/03_extend_scenarios_testdata.R
#
# Extends inst/testdata/scenarios_testdata.csv with NGFS2023 IAM and ambition
# variants so the sensitivity-analysis vignette in trisk.analysis can demo
# IAM and ambition sensitivity on bundled data. Existing rows are preserved
# (the existing NGFS2023GCAM_* scenarios are referenced by the
# snapshot-continuity test and other vignettes; do not touch them).

library(magrittr)

TRISK_INPUTS_BUCKET_URL <- "https://storage.googleapis.com/crispy-public-data/trisk_inputs"
EXISTING_TESTDATA <- "inst/testdata/scenarios_testdata.csv"

NEW_SCENARIOS <- c(
  # IAM sensitivity demo (GCAM is already present via NGFS2023GCAM_*; add REMIND + MESSAGE
  # under the underscore namespace, with both CP and NZ2050 ambitions so vignette can
  # hold ambition fixed while varying IAM)
  "NGFS2023_GCAM_CP", "NGFS2023_GCAM_NZ2050",
  "NGFS2023_REMIND_CP", "NGFS2023_REMIND_NZ2050",
  "NGFS2023_MESSAGE_CP", "NGFS2023_MESSAGE_NZ2050",
  # Ambition sensitivity demo (GCAM only; CP and NZ2050 are above, add B2DS and DT)
  "NGFS2023_GCAM_B2DS", "NGFS2023_GCAM_DT"
)

# Step A: Download the canonical upstream scenarios file
upstream_path <- tempfile(fileext = ".csv")
utils::download.file(file.path(TRISK_INPUTS_BUCKET_URL, "scenarios.csv"),
                     upstream_path, mode = "wb")
upstream <- readr::read_csv(upstream_path, show_col_types = FALSE)

# Step B: Subset to the new scenarios, Global only
new_rows <- upstream %>%
  dplyr::filter(.data$scenario %in% NEW_SCENARIOS,
                .data$scenario_geography == "Global")
stopifnot("Expected at least one row per requested scenario." =
            length(setdiff(NEW_SCENARIOS, unique(new_rows$scenario))) == 0)

# Step C: Append to the existing testdata file
existing <- readr::read_csv(EXISTING_TESTDATA, show_col_types = FALSE)
stopifnot("Schema mismatch between upstream and existing testdata." =
            identical(sort(colnames(existing)), sort(colnames(new_rows))))

combined <- dplyr::bind_rows(existing, new_rows[, colnames(existing)]) %>%
  dplyr::distinct()
readr::write_csv(combined, EXISTING_TESTDATA)

cat("Wrote ", nrow(combined), " rows to ", EXISTING_TESTDATA,
    " (was ", nrow(existing), ").\n", sep = "")
```

- [ ] **Step 2: Commit the script alone (no data change yet)**

```bash
git add data-raw/03_extend_scenarios_testdata.R
git commit -m "chore(data-raw): script to extend scenarios testdata with new IAM/ambition variants"
```

### Task 1.3: Run the extension script

**Files:**
- Modify: `inst/testdata/scenarios_testdata.csv`

- [ ] **Step 1: Execute and verify file growth**

```bash
Rscript data-raw/03_extend_scenarios_testdata.R
wc -l inst/testdata/scenarios_testdata.csv
```
Expected: file goes from 1423 lines to approximately 2767 lines (1422 data rows + 1344 new + 1 header = 2767). Allow ±50 for upstream variation.

- [ ] **Step 2: Verify the file is parseable and has the new scenarios**

```bash
Rscript -e '
s <- read.csv("inst/testdata/scenarios_testdata.csv")
expected_new <- c("NGFS2023_GCAM_B2DS", "NGFS2023_GCAM_CP", "NGFS2023_GCAM_DT",
                  "NGFS2023_GCAM_NZ2050", "NGFS2023_MESSAGE_CP",
                  "NGFS2023_MESSAGE_NZ2050", "NGFS2023_REMIND_CP",
                  "NGFS2023_REMIND_NZ2050")
expected_old <- c("NGFS2023GCAM_CP", "NGFS2023GCAM_NZ2050")
stopifnot(all(expected_new %in% s$scenario))
stopifnot(all(expected_old %in% s$scenario))
cat("OK. Unique scenarios:", length(unique(s$scenario)), "\n")
'
```
Expected: `OK. Unique scenarios: 10`

### Task 1.4: Run the trisk.model snapshot continuity test

**Files:** none yet (read-only check)

- [ ] **Step 1: Run the gated continuity test**

```bash
R_USE_TESTS=TRUE Rscript -e 'devtools::test(filter = "output_continuity")'
```

- [ ] **Step 2: Interpret the result**

If PASS: existing snapshots are robust to file extension. Skip to Task 1.5.

If FAIL with snapshot mismatch on rows other than the new scenarios: investigate before regenerating — the new rows should be additive only, so existing scenario outputs must be byte-identical. If the test fails on rows that use `NGFS2023GCAM_CP` or `NGFS2023GCAM_NZ2050`, STOP — the append broke something upstream (likely an unintended row dedupe or column reordering by `dplyr::distinct()` reordering). Fix the data-raw script and re-run Task 1.3.

If FAIL because the snapshot files now contain rows for the new scenarios: regenerate snapshots.

```bash
R_USE_TESTS=TRUE Rscript -e 'testthat::snapshot_accept()'
```
Then re-run the test to confirm pass.

### Task 1.5: Commit the data change

- [ ] **Step 1: Stage and commit**

```bash
git add inst/testdata/scenarios_testdata.csv
# If snapshots were regenerated, also:
# git add tests/testthat/snapshots/
git commit -m "data(testdata): extend scenarios with NGFS2023 REMIND/MESSAGE/B2DS/DT for sensitivity demo

Adds 8 NGFS2023 scenarios (REMIND CP+NZ2050, MESSAGE CP+NZ2050, GCAM B2DS+DT,
plus underscore-namespace GCAM CP+NZ2050) so the public sensitivity-analysis
vignette in trisk.analysis can demonstrate IAM and ambition sensitivity on
bundled data. Existing NGFS2023GCAM_* rows untouched. Pulled from the
canonical public bucket via data-raw/03_extend_scenarios_testdata.R."
```

### Task 1.6: Push branch and open PR

- [ ] **Step 1: Push and create PR**

```bash
git push -u origin feat/extend-scenarios-testdata-for-iam-ambition-sensitivity
gh pr create --title "data: extend bundled scenarios with NGFS2023 IAM/ambition variants" \
  --body "$(cat <<'EOF'
## Summary

- Adds 8 NGFS2023 scenarios to `inst/testdata/scenarios_testdata.csv`: REMIND CP+NZ2050, MESSAGE CP+NZ2050, GCAM B2DS+DT, and underscore-namespace GCAM CP+NZ2050.
- Existing `NGFS2023GCAM_*` rows are untouched (referenced by the snapshot test and existing vignettes).
- Enables the public `sensitivity-analysis.Rmd` rewrite in trisk.analysis to demonstrate IAM and ambition sensitivity on bundled data.

## Test plan

- [x] Snapshot continuity test passes (or snapshots regenerated cleanly if affected by additive change).
- [x] `devtools::test()` overall PASS.
- [x] `devtools::check()` no new errors / warnings.

## File size impact

`inst/testdata/scenarios_testdata.csv` grows from ~185KB (1423 lines) to ~365KB (~2767 lines). Within `inst/testdata/` norms.

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

- [ ] **Step 2: Note PR URL for the release task**

Capture the PR URL output. PHASE 1 STOPS HERE pending PR review and merge.

---

## Phase 2 — Tag a new `trisk.model` release

External / human-in-the-loop. NOT executed by the agent.

### Task 2.1: After both PRs merge, tag a release

**Trigger:** PR #58 merged AND Phase 1 PR merged on `main`.

- [ ] **Step 1: Confirm both PRs are merged**

```bash
gh pr view 58 --json state -q .state
gh pr list --search "extend-scenarios-testdata" --state merged
```
Both must show merged.

- [ ] **Step 2: Bump DESCRIPTION version**

Decide the version bump: ADO 1943 is a bug fix, the scenario extension is data-only, neither is breaking. Default is a patch bump (e.g. `2.6.1` → `2.6.2`).

Edit `DESCRIPTION` `Version:` field. Commit.

```bash
git commit -am "chore: bump version to 2.6.2"
```

- [ ] **Step 3: Tag the release**

```bash
git tag v2.6.2
git push origin main --tags
```

---

## Phase 3 — Rewrite the vignette in `trisk.analysis`

Working dir: `~/Documents/repos/trisk.analysis/`.

### Task 3.1: Branch and bump trisk.model dependency

**Files:**
- Modify: `DESCRIPTION` (Remotes line)

- [ ] **Step 1: Branch**

```bash
git checkout main
git pull origin main
git checkout -b feat/sensitivity-vignette-rewrite
```

- [ ] **Step 2: Pin trisk.model to the new tag**

Inspect `DESCRIPTION` `Remotes:` field. If it pins to a commit or tag of `trisk.model`, update to the new tag (`v2.6.2` or whatever Phase 2 produced). If it pins to `main`, no change required but install the new version manually:

```bash
Rscript -e 'pak::pkg_install("Theia-Finance-Labs/trisk.model@v2.6.2")'
```

- [ ] **Step 3: Verify the new scenarios are visible**

```bash
Rscript -e '
s <- read.csv(system.file("testdata", "scenarios_testdata.csv", package = "trisk.model"))
print(sort(unique(s$scenario)))
'
```
Expected output includes `NGFS2023_REMIND_CP`, `NGFS2023_MESSAGE_NZ2050`, `NGFS2023_GCAM_B2DS`, etc.

- [ ] **Step 4: Commit dep bump (if any)**

```bash
# Only if DESCRIPTION changed:
git add DESCRIPTION
git commit -m "chore: bump trisk.model dependency to v2.6.2"
```

### Task 3.2: Write the vignette setup section (sections 1–4)

**Files:**
- Modify: `vignettes/sensitivity-analysis.Rmd` (full rewrite)

- [ ] **Step 1: Replace the existing vignette content with sections 1–4**

Open `vignettes/sensitivity-analysis.Rmd` and replace its entire content with:

````markdown
---
title: "Sensitivity analysis (bank-impact view)"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{Sensitivity analysis (bank-impact view)}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---

```{r, include = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE,
  comment  = "#>"
)
```

```{r setup}
library(trisk.analysis)
library(magrittr)
```

# Setup

This vignette uses the bundled testdata to demonstrate sensitivity analysis
in three dimensions (shock year, IAM, ambition policy), each read through a
bank-impact lens: actual portfolio terms, EAD-weighted sector aggregation,
and an integrated expected-loss bps callout at the end.

```{r}
assets_testdata             <- read.csv(system.file("testdata", "assets_testdata.csv",             package = "trisk.model"))
scenarios_testdata          <- read.csv(system.file("testdata", "scenarios_testdata.csv",          package = "trisk.model"))
financial_features_testdata <- read.csv(system.file("testdata", "financial_features_testdata.csv", package = "trisk.model"))
ngfs_carbon_price_testdata  <- read.csv(system.file("testdata", "ngfs_carbon_price_testdata.csv",  package = "trisk.model"))
portfolio_ids_internal_pd   <- read.csv(system.file("testdata", "portfolio_ids_internal_pd_testdata.csv",
                                                    package = "trisk.analysis"))

stopifnot(
  "Portfolio file must include an `internal_pd` column per exposure." =
    "internal_pd" %in% colnames(portfolio_ids_internal_pd),
  "`internal_pd` values must be numeric in [0, 1]." =
    is.numeric(portfolio_ids_internal_pd$internal_pd) &&
      all(portfolio_ids_internal_pd$internal_pd >= 0 &
            portfolio_ids_internal_pd$internal_pd <= 1, na.rm = TRUE)
)

portfolio_terms <- portfolio_ids_internal_pd[, c("company_id", "term", "exposure_value_usd")]
```

# Why sensitivity

Climate stress-testing carries three layers of uncertainty a bank reader cares
about: **when** the shock arrives (`shock_year`), **whose model** of the
transition you trust (the IAM), and **how ambitious** the target scenario is.
This vignette sweeps each one and reads the result as a change in the bank's
portfolio risk picture, not as an abstract model output.

# Base run

```{r}
run_params_base <- list(
  list(
    scenario_geography = "Global",
    baseline_scenario  = "NGFS2023GCAM_CP",
    target_scenario    = "NGFS2023GCAM_NZ2050",
    shock_year         = 2030
  )
)

sa_base <- run_trisk_sa(
  assets_data    = assets_testdata,
  scenarios_data = scenarios_testdata,
  financial_data = financial_features_testdata,
  carbon_data    = ngfs_carbon_price_testdata,
  run_params     = run_params_base
)

knitr::kable(head(sa_base$pd[, c("run_id", "company_id", "sector", "term",
                                  "pd_baseline", "pd_shock")]))
```

# Convention: actual portfolio terms, EAD-weighted

Every plot below evaluates PD at each firm's contractual loan term (from
`portfolio_terms`) and aggregates sector-level numbers as EAD-weighted means.
This matches the convention used by the integration pipeline
(`pipeline_crispy_pd_integration_bars` and siblings) and means the PDs and EL
deltas read here are directly comparable to those in
[`pd-el-integration.Rmd`](pd-el-integration.html) — no per-section translation
needed.

> **Caveat.** If a portfolio row has a contractual term beyond TRISK's Merton
> grid (sized to the analysis horizon since `trisk.model` v2.6.2 / PR #58), the
> term join silently drops it. The helper below emits a warning naming the
> dropped `(company_id, term)` pairs so the omission is visible.
````

- [ ] **Step 2: Render just the front matter to confirm parse**

```bash
Rscript -e 'Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64"); rmarkdown::render("vignettes/sensitivity-analysis.Rmd", quiet = TRUE)'
```
Expected: clean render of sections 1–4. (Sections 5–10 will be added in later tasks; this is checkpoint render only — if the render succeeds, the YAML and setup parse correctly.)

- [ ] **Step 3: Commit checkpoint**

```bash
git add vignettes/sensitivity-analysis.Rmd
git commit -m "feat(vignette): scaffold sections 1-4 of sensitivity-analysis rewrite"
```

### Task 3.3: Add plot helpers section

**Files:**
- Modify: `vignettes/sensitivity-analysis.Rmd` (append section 5)

- [ ] **Step 1: Append the plot helpers section**

Add to the bottom of `vignettes/sensitivity-analysis.Rmd`:

````markdown
# Plot helpers

These three functions are defined inline in the vignette (not exported from
the package). Each one takes the long-format PD output of `run_trisk_sa()`,
attaches the bank's contractual portfolio terms, and produces a comparison
plot of PD difference (`pd_shock - pd_baseline`) per variant.

```{r}
attach_portfolio_term <- function(sa_pd, portfolio_terms) {
  joined <- sa_pd %>%
    dplyr::inner_join(portfolio_terms, by = c("company_id", "term"))
  n_dropped <- nrow(portfolio_terms) - dplyr::n_distinct(joined[, c("company_id", "term")])
  if (n_dropped > 0) {
    dropped <- dplyr::anti_join(portfolio_terms, joined, by = c("company_id", "term"))
    warning("Dropped ", n_dropped, " portfolio row(s) whose term is outside the Merton grid: ",
            paste(dropped$company_id, dropped$term, sep = "/term=", collapse = ", "),
            call. = FALSE)
  }
  joined
}

label_by_variant <- function(sa_result, label_fn) {
  sa_result$pd %>%
    dplyr::left_join(sa_result$params, by = "run_id") %>%
    dplyr::mutate(variant = label_fn(.data))
}

draw_pd_by_sector <- function(labelled_pd, portfolio_terms, variant_name,
                              palette_values = NULL) {
  agg <- labelled_pd %>%
    attach_portfolio_term(portfolio_terms) %>%
    dplyr::mutate(pd_difference = .data$pd_shock - .data$pd_baseline) %>%
    dplyr::group_by(.data$sector, .data$variant) %>%
    dplyr::summarise(
      pd_difference = stats::weighted.mean(.data$pd_difference,
                                           w = .data$exposure_value_usd,
                                           na.rm = TRUE),
      .groups = "drop"
    )
  p <- ggplot2::ggplot(agg, ggplot2::aes(x = .data$variant,
                                          y = .data$pd_difference,
                                          fill = .data$variant)) +
    ggplot2::geom_col(width = 0.7) +
    ggplot2::facet_grid(. ~ sector, scales = "free_y") +
    ggplot2::scale_y_continuous(
      trans  = scales::pseudo_log_trans(sigma = 1e-7),
      labels = scales::percent_format(accuracy = 0.0001)
    ) +
    TRISK_PLOT_THEME_FUNC() +
    ggplot2::labs(x = variant_name, y = "EAD-weighted PD difference (shock - baseline)",
                  fill = variant_name,
                  title = paste("PD sensitivity to", variant_name, "by sector"),
                  subtitle = "Actual portfolio terms; EAD-weighted; pseudo-log y per sector")
  if (!is.null(palette_values)) p <- p + ggplot2::scale_fill_manual(values = palette_values)
  p
}

draw_pd_by_exposure <- function(labelled_pd, portfolio_terms, variant_name,
                                palette_values = NULL) {
  agg <- labelled_pd %>%
    attach_portfolio_term(portfolio_terms) %>%
    dplyr::mutate(firm = paste(.data$company_id, .data$sector, sep = "/"),
                  pd_difference = .data$pd_shock - .data$pd_baseline)
  p <- ggplot2::ggplot(agg, ggplot2::aes(x = .data$firm,
                                          y = .data$pd_difference,
                                          fill = .data$variant)) +
    ggplot2::geom_col(position = ggplot2::position_dodge(width = 0.8), width = 0.7) +
    ggplot2::facet_grid(. ~ sector, scales = "free", space = "free_x") +
    ggplot2::scale_y_continuous(
      trans  = scales::pseudo_log_trans(sigma = 1e-7),
      labels = scales::percent_format(accuracy = 0.0001)
    ) +
    TRISK_PLOT_THEME_FUNC() +
    ggplot2::theme(axis.text.x = ggplot2::element_text(angle = 45, hjust = 1)) +
    ggplot2::labs(x = "Firm / sector", y = "PD difference (shock - baseline)",
                  fill = variant_name,
                  title = paste("Per-exposure PD sensitivity to", variant_name),
                  subtitle = "Actual portfolio terms; pseudo-log y per sector")
  if (!is.null(palette_values)) p <- p + ggplot2::scale_fill_manual(values = palette_values)
  p
}
```

A small palette shared across the three dimension sections so the same
variant index gets the same colour everywhere:

```{r}
TRAJ_PALETTE <- c("#1b324f", "#00c082", "#ff9623")  # matches plot_multi_trajectories()
```
````

- [ ] **Step 2: Render and confirm helpers parse**

```bash
Rscript -e 'Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64"); rmarkdown::render("vignettes/sensitivity-analysis.Rmd", quiet = TRUE)'
```
Expected: clean render. The chunks define helpers; they don't draw anything yet.

- [ ] **Step 3: Commit**

```bash
git add vignettes/sensitivity-analysis.Rmd
git commit -m "feat(vignette): add plot helpers (attach_portfolio_term, draw_pd_by_*)"
```

### Task 3.4: Section 6 — Shock year sensitivity

**Files:**
- Modify: `vignettes/sensitivity-analysis.Rmd` (append section 6)

- [ ] **Step 1: Append section 6**

````markdown
# Shock year

What happens to portfolio PD when the policy shock hits earlier or later?
This section sweeps `shock_year` across 2026 / 2030 / 2035, holding the
scenario pair fixed at NGFS2023GCAM CP vs NZ2050.

```{r}
run_params_shockyear <- list(
  list(scenario_geography = "Global",
       baseline_scenario  = "NGFS2023GCAM_CP",
       target_scenario    = "NGFS2023GCAM_NZ2050",
       shock_year         = 2026),
  list(scenario_geography = "Global",
       baseline_scenario  = "NGFS2023GCAM_CP",
       target_scenario    = "NGFS2023GCAM_NZ2050",
       shock_year         = 2030),
  list(scenario_geography = "Global",
       baseline_scenario  = "NGFS2023GCAM_CP",
       target_scenario    = "NGFS2023GCAM_NZ2050",
       shock_year         = 2035)
)

sa_shockyear <- run_trisk_sa(
  assets_data    = assets_testdata,
  scenarios_data = scenarios_testdata,
  financial_data = financial_features_testdata,
  carbon_data    = ngfs_carbon_price_testdata,
  run_params     = run_params_shockyear
)

pd_shockyear <- label_by_variant(sa_shockyear,
  function(d) factor(d$shock_year, levels = c(2026, 2030, 2035)))
```

```{r fig.width=8, fig.height=4}
draw_pd_by_sector(pd_shockyear, portfolio_terms, "shock year",
                  palette_values = stats::setNames(TRAJ_PALETTE,
                                                   c("2026", "2030", "2035")))
```

### Advanced: per-firm view

```{r fig.width=10, fig.height=5}
draw_pd_by_exposure(pd_shockyear, portfolio_terms, "shock year",
                    palette_values = stats::setNames(TRAJ_PALETTE,
                                                     c("2026", "2030", "2035")))
```
````

- [ ] **Step 2: Render and visually inspect**

```bash
Rscript -e 'Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64"); rmarkdown::render("vignettes/sensitivity-analysis.Rmd", quiet = TRUE)'
open vignettes/sensitivity-analysis.html
```
Expected: section 6 has two figures, three variant bars (2026 / 2030 / 2035) per sector. No warnings about dropped portfolio rows (testdata has 4 rows, terms in [1, 5]).

- [ ] **Step 3: Commit**

```bash
git add vignettes/sensitivity-analysis.Rmd
git commit -m "feat(vignette): shock-year sensitivity section"
```

### Task 3.5: Section 7 — IAM sensitivity

**Files:**
- Modify: `vignettes/sensitivity-analysis.Rmd` (append section 7)

- [ ] **Step 1: Append section 7**

````markdown
# IAM (integrated assessment model)

Same transition story, different model: NGFS2023 publishes its CP and NZ2050
scenarios under three IAMs — GCAM, REMIND, and MESSAGE. Bank readers who pick
one IAM should know how their numbers move under the other two.

```{r}
run_params_iam <- list(
  list(scenario_geography = "Global",
       baseline_scenario  = "NGFS2023_GCAM_CP",
       target_scenario    = "NGFS2023_GCAM_NZ2050",
       shock_year         = 2030),
  list(scenario_geography = "Global",
       baseline_scenario  = "NGFS2023_REMIND_CP",
       target_scenario    = "NGFS2023_REMIND_NZ2050",
       shock_year         = 2030),
  list(scenario_geography = "Global",
       baseline_scenario  = "NGFS2023_MESSAGE_CP",
       target_scenario    = "NGFS2023_MESSAGE_NZ2050",
       shock_year         = 2030)
)

sa_iam <- run_trisk_sa(
  assets_data    = assets_testdata,
  scenarios_data = scenarios_testdata,
  financial_data = financial_features_testdata,
  carbon_data    = ngfs_carbon_price_testdata,
  run_params     = run_params_iam
)

pd_iam <- label_by_variant(sa_iam, function(d) {
  iam <- sub("^NGFS2023_([A-Z]+)_.*", "\\1", d$baseline_scenario)
  factor(iam, levels = c("GCAM", "REMIND", "MESSAGE"))
})
```

```{r fig.width=8, fig.height=4}
draw_pd_by_sector(pd_iam, portfolio_terms, "IAM",
                  palette_values = stats::setNames(TRAJ_PALETTE,
                                                   c("GCAM", "REMIND", "MESSAGE")))
```

### Advanced: per-firm view

```{r fig.width=10, fig.height=5}
draw_pd_by_exposure(pd_iam, portfolio_terms, "IAM",
                    palette_values = stats::setNames(TRAJ_PALETTE,
                                                     c("GCAM", "REMIND", "MESSAGE")))
```
````

- [ ] **Step 2: Render and inspect**

```bash
Rscript -e 'Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64"); rmarkdown::render("vignettes/sensitivity-analysis.Rmd", quiet = TRUE)'
open vignettes/sensitivity-analysis.html
```
Expected: section 7 has two figures, three IAM bars per sector. If `run_trisk_sa` errors on REMIND or MESSAGE scenarios, Phase 1's PR did not land all the expected rows — STOP and inspect `inst/testdata/scenarios_testdata.csv` in the installed `trisk.model`.

- [ ] **Step 3: Commit**

```bash
git add vignettes/sensitivity-analysis.Rmd
git commit -m "feat(vignette): IAM sensitivity section"
```

### Task 3.6: Section 8 — Ambition policy sensitivity

**Files:**
- Modify: `vignettes/sensitivity-analysis.Rmd` (append section 8)

- [ ] **Step 1: Append section 8**

````markdown
# Ambition policy

Same IAM (GCAM), different policy stringency: how does the PD signal change
across Current Policies, Below 2°C, Delayed Transition, and Net Zero 2050?

```{r}
run_params_ambition <- list(
  list(scenario_geography = "Global",
       baseline_scenario  = "NGFS2023_GCAM_CP",
       target_scenario    = "NGFS2023_GCAM_NZ2050",
       shock_year         = 2030),
  list(scenario_geography = "Global",
       baseline_scenario  = "NGFS2023_GCAM_CP",
       target_scenario    = "NGFS2023_GCAM_B2DS",
       shock_year         = 2030),
  list(scenario_geography = "Global",
       baseline_scenario  = "NGFS2023_GCAM_CP",
       target_scenario    = "NGFS2023_GCAM_DT",
       shock_year         = 2030)
)

sa_ambition <- run_trisk_sa(
  assets_data    = assets_testdata,
  scenarios_data = scenarios_testdata,
  financial_data = financial_features_testdata,
  carbon_data    = ngfs_carbon_price_testdata,
  run_params     = run_params_ambition
)

pd_ambition <- label_by_variant(sa_ambition, function(d) {
  ambition <- sub("^NGFS2023_GCAM_(.*)$", "\\1", d$target_scenario)
  factor(ambition, levels = c("NZ2050", "B2DS", "DT"))
})
```

```{r fig.width=8, fig.height=4}
draw_pd_by_sector(pd_ambition, portfolio_terms, "ambition policy",
                  palette_values = stats::setNames(TRAJ_PALETTE,
                                                   c("NZ2050", "B2DS", "DT")))
```

### Advanced: per-firm view

```{r fig.width=10, fig.height=5}
draw_pd_by_exposure(pd_ambition, portfolio_terms, "ambition policy",
                    palette_values = stats::setNames(TRAJ_PALETTE,
                                                     c("NZ2050", "B2DS", "DT")))
```
````

- [ ] **Step 2: Render and inspect**

```bash
Rscript -e 'Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64"); rmarkdown::render("vignettes/sensitivity-analysis.Rmd", quiet = TRUE)'
open vignettes/sensitivity-analysis.html
```
Expected: section 8 has two figures, three ambition bars per sector. Section 8 should use the new underscore namespace (`NGFS2023_GCAM_*`) consistently — do not mix with `NGFS2023GCAM_*`.

- [ ] **Step 3: Commit**

```bash
git add vignettes/sensitivity-analysis.Rmd
git commit -m "feat(vignette): ambition-policy sensitivity section"
```

### Task 3.7: Section 9 — What this means for the bank (EL bps)

**Files:**
- Modify: `vignettes/sensitivity-analysis.Rmd` (append section 9)

- [ ] **Step 1: Append section 9**

````markdown
# What this means for the bank

The previous sections show how raw PD shifts under different design choices.
The bank-impact question is: how does that translate into expected-loss
basis points on the actual portfolio? We pick one variant (`shock_year =
2030`, NGFS2023GCAM CP vs NZ2050, Global — the base run) and walk it through
the integration pipeline, ending with the EL bps KPI used elsewhere in the
package.

```{r}
analysis_data <- run_trisk_on_portfolio(
  assets_data       = assets_testdata,
  scenarios_data    = scenarios_testdata,
  financial_data    = financial_features_testdata,
  carbon_data       = ngfs_carbon_price_testdata,
  portfolio_data    = portfolio_ids_internal_pd,
  baseline_scenario = "NGFS2023GCAM_CP",
  target_scenario   = "NGFS2023GCAM_NZ2050"
)
analysis_data_el <- compute_analysis_metrics(analysis_data)

internal_pd_lookup <- portfolio_ids_internal_pd[, c("company_id", "internal_pd")]
internal_el_lookup <- merge(
  analysis_data_el[, c("company_id", "exposure_value_usd", "loss_given_default")],
  internal_pd_lookup,
  by = "company_id"
)
internal_el_lookup$internal_el <-
  internal_el_lookup$exposure_value_usd *
  internal_el_lookup$loss_given_default *
  internal_el_lookup$internal_pd

result_el <- integrate_el(analysis_data_el,
                          internal_el = internal_el_lookup[, c("company_id", "internal_el")])
```

```{r}
pipeline_crispy_el_kpi_table(result_el$aggregate)
```

Read the `delta_bps` field as the bank-impact summary of this one variant.
The sensitivity sections above tell you how that number would move if you
chose a different shock year, IAM, or ambition tier. For deeper plot
references and the full methodology, see
[`pd-el-integration.Rmd`](pd-el-integration.html) and
[`pd-el-viz-walkthrough.Rmd`](pd-el-viz-walkthrough.html).
````

- [ ] **Step 2: Render the full vignette**

```bash
Rscript -e 'Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64"); rmarkdown::render("vignettes/sensitivity-analysis.Rmd", quiet = TRUE)'
open vignettes/sensitivity-analysis.html
wc -l vignettes/sensitivity-analysis.Rmd
ls -la vignettes/sensitivity-analysis.html
```
Expected: clean render, no errors, no warnings except possibly the documented "Dropped N portfolio row(s)" if testdata terms ever leave [1, 5]. Vignette Rmd line count ~280-310, HTML output ≥ 200KB.

- [ ] **Step 3: Commit**

```bash
git add vignettes/sensitivity-analysis.Rmd
git commit -m "feat(vignette): bank-impact closing section with EL bps KPI"
```

### Task 3.8: Final integration check

**Files:** none (verification only)

- [ ] **Step 1: Run tests**

```bash
Rscript -e 'devtools::test()'
```
Expected: 70/70 PASS. No R/ code changed in this phase.

- [ ] **Step 2: Run R CMD check**

```bash
Rscript -e 'Sys.setenv(RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64"); devtools::check(error_on = "never", quiet = TRUE)'
```
Expected: 0 errors / 0 warnings / 1 NOTE (transient NTP timestamp only). If a new NOTE appears about "package directory size" because the vignette HTML is large, that's acceptable and not actionable here.

- [ ] **Step 3: Commit any roxygen / man-page side effects**

If `devtools::check()` triggered `document()` updates, commit them:

```bash
git status
# If man/*.Rd changed:
git add man/
git commit -m "docs: regenerate roxygen man pages"
```

### Task 3.9: Push and open PR

- [ ] **Step 1: Push and create PR**

```bash
git push -u origin feat/sensitivity-vignette-rewrite
gh pr create --title "feat(vignette): rewrite sensitivity-analysis with bank-impact framing" \
  --body "$(cat <<'EOF'
## Summary

- Replace the thin public `vignettes/sensitivity-analysis.Rmd` (121 lines, 3 sections) with a richer ~285-line vignette covering shock-year / IAM / ambition sensitivity.
- Methodology change vs. the gitignored khan_bank reference: use actual portfolio terms throughout (inner join on `(company_id, term)`) and EAD-weighted sector aggregation. Drops the TERM_FIXED=5 convention. Output numbers are directly comparable to the integration vignette's portfolio results.
- Bank-impact closing section runs the full integration pipeline on the bundled internal-PD lookup and surfaces the EL bps KPI for one canonical variant.

## Prerequisites

- trisk.model v2.6.2 (or whatever version bundles ADO 1943 fix + extended scenarios).
- DESCRIPTION bumped to the new tag.

## Test plan

- [x] `rmarkdown::render` succeeds; HTML output ≥ 200KB with all chunks rendered.
- [x] `devtools::test()` 70/70 PASS.
- [x] `devtools::check()` 0 errors / 0 warnings.
- [x] No portfolio rows are dropped during the term join (bundled testdata terms in [1, 5]; warning suppression is defensive).

## Design

See [`specs/superpowers/2026-05-28-sensitivity-vignette-rewrite-design.md`](specs/superpowers/2026-05-28-sensitivity-vignette-rewrite-design.md).

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

---

## Self-review log

**Spec coverage:**
- §1 Setup → Task 3.2 step 1 (yaml + setup chunk + stopifnot).
- §2 Methodology decision (actual term + EAD-weighted) → Task 3.3 (helpers do the join + `weighted.mean`).
- §3 Section table 1-10 → Tasks 3.2 (1-4), 3.3 (5), 3.4 (6), 3.5 (7), 3.6 (8), 3.7 (9). Section 10 (cross-references) is included inside Task 3.7 step 1's closing paragraph; no separate task.
- §4 Components → covered by Task 3.3 (helpers), Tasks 3.4-3.7 (per-section).
- §5 Error handling — `stopifnot` (3.2), `warning()` on drop (3.3 attach_portfolio_term), scenario fallbacks — see note below.
- §6 Testing → Task 3.8.
- §7 Out of scope (companion vignette, khan_bank vignette, API changes) → not in plan, as intended.
- §8 Cross-references → in 3.7 step 1 closing paragraph.

**Scope gap caught after spec was written:**
- Spec §5 mentioned "scenario availability fallback" assuming bundled data might lack the IAMs. With Phase 1 of this plan, all required scenarios are present, so the fallback code is unnecessary in Phase 3. The plan therefore omits fallback notes in sections 7 / 8.

**Placeholder scan:** No "TBD", no "implement later". All code blocks contain the full content the engineer will paste in.

**Type / signature consistency:**
- `attach_portfolio_term(sa_pd, portfolio_terms)`: used in `draw_pd_by_sector` and `draw_pd_by_exposure` with consistent arg order.
- `label_by_variant(sa_result, label_fn)`: takes the full `sa_*` list (with `$pd` and `$params`), used identically in sections 6 / 7 / 8.
- `draw_pd_by_sector(labelled_pd, portfolio_terms, variant_name, palette_values = NULL)`: signature matches all three calling sites in sections 6 / 7 / 8.
- `draw_pd_by_exposure` same.
- `TRAJ_PALETTE` defined once in Task 3.3 step 1, used by all three dimension sections.

**No untested risk paths:**
- The plan's only `warning()` is inside `attach_portfolio_term` and won't fire on bundled testdata (terms [1, 5]) — that's documented.
- The render checkpoints after each section catch issues at the granularity of one figure.
