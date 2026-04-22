# Khan Bank Analysis Outputs

**Date:** 2026-04-22
**Branch:** output-development
**Source data:** `/Users/jakub/Downloads/04.17 debug khanbank/` (out of repo)

Diagnostic outputs from three trisk.analysis workflows applied to Khan Bank's
12-firm portfolio:

1. **PD/EL integration** (the new S1+S2 methodology from this branch)
2. **Portfolio analysis** (mirrors `vignettes/portfolio-analysis.Rmd`)
3. **Sensitivity analysis** (mirrors `vignettes/sensitivity-analysis.Rmd`)

All files here are gitignored. Khan Bank data must never enter the package
tarball (see `.Rbuildignore` and `.gitignore` at repo root).

## Reproducers

Three Rmd notebooks regenerate every artifact in this folder. Knit to HTML
with pandoc installed (`brew install pandoc` then `Rscript -e 'rmarkdown::render("DEBUG/khanbank-analysis/<file>.Rmd")'`). Alternative: tangle to a
script and source it:

```bash
for f in run_diagnostic.Rmd run_portfolio_analysis.Rmd run_sensitivity_analysis.Rmd; do
  Rscript -e "knitr::purl('DEBUG/khanbank-analysis/$f', output='/tmp/x.R'); source('/tmp/x.R')"
done
```

- `run_diagnostic.Rmd` — PD/EL integration (Tasks 1-20 methodology)
- `run_portfolio_analysis.Rmd` — mirrors `vignettes/portfolio-analysis.Rmd`
- `run_sensitivity_analysis.Rmd` — mirrors `vignettes/sensitivity-analysis.Rmd`

The portfolio and integration notebooks load the cached `analysis_data.rds`.
The sensitivity notebook re-runs TRISK from assets + financials (using bundled
NGFS scenarios and carbon prices, which are non-client).

---

## 1. PD/EL integration outputs

### Plots
- `N1_pd_method_comparison.png` — sector-level lollipop comparing absolute /
  relative / zscore integration methods. Methods cluster tightly at Coal/Power
  sector level because both sectors have dominant tech categories.
- `P1_pd_integration_bars.png` — per-term 4-bar grouped plot
  (Internal / Baseline / Shock / Adjusted). Coal dominates; Power nearly flat.
- `P2_el_adjustment_bars.png` — horizontal sign-colored bars of EL adjustment
  by sector. Coal: large negative (loss worse) in red.

### Tables (kableExtra HTML fragments)
- `P3a_pd_kpi_table.html` — portfolio PD KPIs (weighted internal, adjusted, delta, pct).
- `P3b_el_kpi_table.html` — portfolio EL KPIs (totals + bps). 76.8 bps.
- `P4_el_sector_breakdown.html` — sector rollup with direction arrows.
  Coal ↑ loss worse, Power ↓ loss better.

### Diagnostics (CSV)
- `khanbank_pd_diagnostic_perfirm.csv` — one row per firm at term=1 with
  Merton state, pattern classification, and plain-English `why` sentence.
- `khanbank_pd_diagnostic.csv` — one row per portfolio row (firm x term)
  with all three integration methods' adjusted PDs and the pattern column.

### Why low/zero baseline PDs in this portfolio

Three compounding drivers in the bank's financial_features inputs:

1. **Hard double-precision underflow (firm 101 only):** d2=38.97 at term=1.
   `pnorm(-d2)` returns exactly 0 in IEEE 754 doubles.
2. **Near-zero PDs from input shape (firms 102, 103, 104, 106, 107, 108, 109):**
   d2 in 8-27 range so pnorm(-d2) in 10^-8 to 10^-163. Non-zero but below any
   practical precision threshold. Drivers: low volatility (2.7-5.5% for firms
   101, 104, 106) and/or low leverage (V0/L > 8 for firms 101, 102, 108).
3. **Shock benefit (firm 104):** renewables equity rises +13% under the
   carbon-pricing shock, so both baseline and shock PDs are similarly tiny.

Firms 105, 110-112 are the "clean signal" firms with d2 ~ 3, PD ~ 0.16%,
where all three integration methods produce visible adjusted PDs.

---

## 2. Portfolio analysis outputs

Mirrors the 4 plots from `vignettes/portfolio-analysis.Rmd`:

- `portfolio_npv_change.png` — equities: average NPV change percentage by tech.
- `portfolio_exposure_change.png` — equities: portfolio exposure change.
- `portfolio_pd_term.png` — bonds/loans: average PDs at baseline and shock by term.
- `portfolio_expected_loss.png` — bonds/loans: expected loss by sector.
- `portfolio_summary.csv` — 11-row tabular form (firm x term) with NPV, PD,
  EL columns used by the plots.

---

## 3. Sensitivity analysis outputs

Mirrors `vignettes/sensitivity-analysis.Rmd`: two TRISK runs with shock_year
varied between 2030 and 2025, all other parameters held fixed.

- `sensitivity_trajectories.png` — multi-run trajectory plot from
  `plot_multi_trajectories()`. Shows how the production-under-shock path
  differs between a 2025 and 2030 shock year.
- `sensitivity_npv.csv` / `sensitivity_pd.csv` / `sensitivity_trajectories.csv` —
  consolidated per-run outputs with `run_id` index.
- `sensitivity_params.csv` — 2-row table documenting the parameter variation.
- `sensitivity_pd_by_run.csv` — sector x term x shock_year rollup of
  mean baseline/shock PDs.

---

## Upstream fixes applied during this analysis

- `trisk.model` commit `5ef6d1b` on main: extended `calculate_pd_change_overall()`
  from `term = 1:5` to `term = 1:10`. Resolves firm 101's term=7 silent-NA case.
  The cached `analysis_data.rds` and the sensitivity outputs pre-date this fix
  (they were produced against the installed trisk.model). Reinstall trisk.model
  from the updated source and re-run the scripts to pick up terms 6-10.
