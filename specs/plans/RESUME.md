# Resume Context — PD & EL Integration Implementation

**Status:** SHIPPED. All 20 plan tasks complete on `main`. N2 waterfall (originally conditional) built on 2026-05-28.

---

## Where things stand

| Branch | State |
|---|---|
| `main` | Canonical. Holds squashed feature merge (`8a6e824`), PR #42 follow-up (`9e2ae2f`), N2 waterfall (`f542ea5`), and vignette §10 update (`d015356`). |
| `output-development` | Stale 91-commit workspace that produced the squashed merge. Do not commit further work here. Only unique content is the gitignored `DEBUG/khanbank-analysis/` artifacts. |
| `patch/pd-integration-bars-defaults` | Source of PR #42. Already merged. |

---

## What ships on main

**Library functions** (`R/integrate.R`):
- `integrate_pd(analysis_data, internal_pd, method)` — methods: `"absolute"`, `"relative"`, `"zscore"`
- `integrate_el(analysis_data, internal_el, method)` — methods: `"absolute"`, `"relative"`
- `aggregate_pd_integration(portfolio_df, group_cols)`
- `aggregate_el_integration(portfolio_df, group_cols)`
- `compute_analysis_metrics()` — exported helper (was internal)

**Visualizations:**
- P1 `pipeline_crispy_pd_integration_bars` — 4-bar grouped, with `granularity` and `scale` args (`R/plot_pd_integration.R`)
- P2 `pipeline_crispy_el_adjustment_bars` — horizontal sign-bars (`R/plot_el_adjustment.R`)
- P3a `pipeline_crispy_pd_kpi_table` / P3b `pipeline_crispy_el_kpi_table` — kableExtra summaries (`R/plot_integration_kpi_table.R`)
- P4 `pipeline_crispy_el_sector_breakdown_table` — kableExtra sector rollup
- N1 `pipeline_crispy_pd_method_comparison` — lollipop with `granularity` and `scale` args (`R/plot_pd_method_comparison.R`)
- N2 `pipeline_crispy_pd_waterfall` — Internal → Adjustment → Adjusted (`R/plot_pd_waterfall.R`)

**Vignette:** `vignettes/pd-el-integration.Rmd` (14 sections, bundled testdata only)

**Extra features on main beyond the original plan:** `run_trisk_on_simple_portfolio` workflow + bundled `inst/testdata/simple_portfolio.csv` + `vignettes/simple-portfolio-analysis.Rmd`.

---

## Verification baseline (2026-05-28)

- `devtools::test()` — **70/70 PASS**, 0 fail, 0 warn, 0 skip
- `devtools::check()` — **0 errors, 0 warnings, 3 NOTEs**
  - 3 NOTEs are pre-existing local-workspace cruft (`.claude`, `.ruff_cache`, `dist/` at top level, NTP timestamp). Not fixable from inside the package.

---

## Open follow-ups (out of scope for this work)

- **S3 vignette:** PD/EL visualization walkthrough — separate spec + plan when this lands.
- **S4 vignette:** Simplify / rewrite `sensitivity-analysis.Rmd` with bank-impact commentary — separate spec + plan.
- **Upstream `trisk.model` bug:** `calc_pd_change_overall()` hardcodes `term = 1:5`; rows with `term = 6+` silently become NA. Separate `trisk.model` PR.
- **dplyr 2.x migration:** `dplyr::group_by_at` is superseded; revisit if/when targeting dplyr 2.x.
- **EL sign convention check:** `compute_analysis_metrics()` stores EL as negative; `integrate_el` treats it positively. Symmetric but worth confirming for client-facing output.

---

## Local environment notes

- **Pandoc** is required for `devtools::check()` to rebuild vignettes. It is NOT on PATH but is bundled with RStudio:
  ```
  export RSTUDIO_PANDOC="/Applications/RStudio.app/Contents/Resources/app/quarto/bin/tools/aarch64"
  ```
  Set this before running `check()`, or `brew install pandoc` for a system-wide fix.
- **roxygen2** on disk is 7.2.3 but DESCRIPTION pins 7.3.3. `check()` skips re-document with a soft warning. `install.packages("roxygen2")` to upgrade if desired.

---

## Cross-repo references

When porting more Shiny logic, the source modules to read line-for-line:

- `~/Documents/repos/trisk.r.docker/app/modules/mod_integration.R:170-234` — PD method math
- `~/Documents/repos/trisk.r.docker/app/modules/mod_integration.R:509-557` — EL method math
- `~/Documents/repos/trisk.r.docker/app/modules/mod_integration.R:321-356` — PD KPI valueBox strip (P3a)
- `~/Documents/repos/trisk.r.docker/app/modules/mod_integration.R:657-704` — EL KPI valueBox strip (P3b)
- `~/Documents/repos/trisk.r.docker/app/modules/mod_integration.R:707-786` — Sector breakdown (P4)
- `~/Documents/repos/trisk.r.docker/app/modules/mod_integration.R:789-891` — EL adjustment bar (P2)
- `~/Documents/repos/trisk.r.docker/app/modules/mod_results_scenarios.R:220-234` — Metric range lollipop (N1 inspiration)

---

## Render artifacts

Standalone PNGs of N1 and N2 against bundled testdata sit at:

- `specs/plans/artifacts/n1_method_comparison.png`
- `specs/plans/artifacts/n2_pd_waterfall.png`

Both gitignored (`specs/` excluded via `.Rbuildignore` and treated as workspace).
