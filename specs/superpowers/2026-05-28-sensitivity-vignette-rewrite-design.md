# Sensitivity-analysis vignette rewrite — design

**Date:** 2026-05-28
**Target:** `vignettes/sensitivity-analysis.Rmd` (public, currently a 121-line thin scaffold)
**Author:** Jakub via brainstorming with Claude
**Status:** Approved design; pending implementation plan via `writing-plans`

## 1. Why

The public `sensitivity-analysis.Rmd` is a thin scaffold (3 sections, 121 lines)
that demonstrates `run_trisk_sa()` for shock-year and country-filter variants
but offers no methodology, no plot interpretation, and no bridge to the bank
impact. The richer 435-line `sensitivity-analysis_khan_bank.Rmd` (gitignored,
client-specific) does cover three sensitivity dimensions properly — shock year,
IAM, ambition policy — but uses client data and a TERM_FIXED=5 plot convention
that reads as a modeler's convenience rather than a bank's view.

Goal: replace the thin public scaffold with a vignette that

1. teaches sensitivity analysis using bundled testdata only,
2. covers the three dimensions from khan_bank generalized to the public testdata,
3. is framed in **bank-impact terms throughout**, not as a separate translation
   at the end, and
4. ends with a single closing section that connects the sensitivity story to
   integrated EL bps.

A separate exploratory vignette will test other bank-impact framings (capital /
RWA, IFRS 9 stage shifts, internal limits) before any of them are promoted into
the public vignette — out of scope for this spec.

## 2. Methodology decision: actual portfolio terms + EAD-weighted aggregation

The khan_bank vignette uses `TERM_FIXED <- 5L` and filters every plot to
`term == 5`. The rationale is that Merton PD is monotonically increasing in
term, so a cross-firm comparison at heterogeneous terms would conflate scenario
design with loan maturity.

This vignette rejects that convention. The reasoning:

- The within-variant comparison the reader cares about is **within-firm across
  variants** (firm A at shock=2026 vs firm A at shock=2030). Same firm, same
  contractual term, only the scenario changes — the maturity confound does
  not bite.
- Cross-firm comparisons (firm A vs firm B in the same sector) **are** affected
  by their different terms — but that's honest signal a bank reader wants:
  "this 20-year exposure is more loss-sensitive than this 3-year one." Hiding
  it behind TERM_FIXED produces PD numbers that don't match the bank's actual
  book.
- Sector aggregation under heterogeneous terms must be **EAD-weighted**, not a
  flat mean. This matches what the integration pipeline already does
  (`pipeline_trisk_pd_integration_bars` and friends) and makes sector-level
  numbers comparable to those in `pd-el-integration.Rmd`.

The vignette therefore attaches each firm's contractual term once up front via
an inner join on `(company_id, term)` and uses EAD-weighted means throughout.
The resulting numbers are directly comparable to the integration vignette's
portfolio-level results, removing the "translate at the end" awkwardness the
khan_bank structure forced.

**Caveat to document inline:** the trisk.model Merton grid spans the analysis
horizon (after the ADO 1943 fix in PR #58). A portfolio row with a term beyond
the horizon will be silently dropped by the join, so the vignette emits a
one-line warning naming the dropped rows for transparency.

## 3. Section structure

| § | Title | Purpose | Approx. lines |
|---|-------|---------|---------------|
| 1 | Setup | Bundle testdata loading, portfolio_terms attachment table | 30 |
| 2 | Why sensitivity | One short framing paragraph | 5 |
| 3 | Base run | One CP vs NZ2050 reference using `run_trisk_sa()` | 25 |
| 4 | Convention | Actual-term + EAD-weighted; one paragraph + caveat block | 15 |
| 5 | Plot helpers | `attach_portfolio_term`, `draw_pd_by_sector`, `draw_pd_by_exposure` | 40 |
| 6 | Shock year | 2026 / 2030 / 2035; sector plot + Advanced: per-firm subsection | 35 |
| 7 | IAM | GCAM / REMIND / MESSAGE with scenario-availability fallback note; sector + Advanced | 40 |
| 8 | Ambition policy | CP vs {NZ2050, B2DS, DT} with fallback note; sector + Advanced | 40 |
| 9 | What this means for the bank | Pick one variant, run integration on bundled `internal_pd`, report EL bps delta | 50 |
| 10 | Cross-references | Pointers to `pd-el-integration.Rmd` and `pd-el-viz-walkthrough.Rmd` | 5 |

**Total: ~285 lines** (vs current public 121; vs khan_bank 435).

## 4. Components

### Setup section
- Load bundled `assets`, `scenarios`, `financial_features`, `ngfs_carbon_price`,
  `portfolio_ids_internal_pd` (the last from `trisk.analysis`, others from
  `trisk.model`).
- `stopifnot` that `portfolio_ids_internal_pd` has an `internal_pd` column in
  `[0, 1]` (same guard as `pd-el-integration.Rmd`).
- Build `portfolio_terms <- portfolio_ids_internal_pd[, c("company_id", "term",
  "exposure_value_usd")]` as the attachment table reused by every plot section.

### Plot helpers
- `attach_portfolio_term(sa_pd, portfolio_terms)` — `inner_join` on
  `(company_id, term)`; emit a `warning()` if any portfolio rows are dropped
  (term beyond Merton grid).
- `draw_pd_by_sector(labelled_pd, variant_name, palette_values = NULL)` —
  EAD-weighted `pd_difference = pd_shock - pd_baseline` per `(sector, variant)`,
  faceted by sector. Lifted from khan_bank §6b but with `stats::weighted.mean`
  replacing flat `mean` and the TERM_FIXED filter removed.
- `draw_pd_by_exposure(labelled_pd, variant_name, palette_values = NULL)` —
  per `(company_id, sector, variant)` bars, faceted by sector. Same change.

### Sensitivity sections (6, 7, 8)
Each has identical structure:
1. One paragraph framing the dimension and what variants we'll sweep.
2. `run_params` list with the variants.
3. `run_trisk_sa()` call.
4. `label_by_variant()` + `attach_portfolio_term()` pipeline.
5. Sector plot via `draw_pd_by_sector`.
6. Subsection `### Advanced: per-firm view` with `draw_pd_by_exposure`.
7. Optional one-liner pointing the reader at section 9 for the bank-impact
   continuation.

### Section 9 — bank-impact continuation
- Pick one canonical variant (e.g. shock_year = 2030, NGFS CP vs NZ2050,
  Global) and run the full integration pipeline:
  - `compute_analysis_metrics()` to derive EL columns.
  - Build the `internal_el_lookup` from `internal_pd_lookup` × `LGD` × `EAD`.
  - `integrate_el()` (default `"zscore"` method).
- Show `pipeline_trisk_el_kpi_table(result_el$aggregate)` to surface the EL
  bps delta — same KPI table used in `pd-el-integration.Rmd` §12, so the
  reader sees the metric they already know.
- One-paragraph commentary connecting the section-6/7/8 PD signal to the EL
  bps consequence: "Section 6 shows shock_year shifts of X pp in PD on the
  power sector; integrated across the portfolio at the bank's actual terms
  and exposures, that translates to a delta of Y bps in EL/EAD."

## 5. Error handling and edge cases

- `stopifnot` for `internal_pd` column presence and numeric range.
- `warning()` (not error) when `attach_portfolio_term()` drops rows; lists the
  offending `(company_id, term)` pairs.
- Scenario availability: if `scenarios_testdata.csv` does not include
  REMIND / MESSAGE entries, section 7's run_params is reduced to GCAM-only and
  a `cat()` note explains the dimension would normally compare across IAMs.
  Same fallback for section 8's {NZ2050, B2DS, DT} ambition policies.

## 6. Testing

- `rmarkdown::render("vignettes/sensitivity-analysis.Rmd")` succeeds with the
  dev version of `trisk.analysis` installed; HTML output ≥ 100KB with all
  plot chunks rendered (visual check via `xdg-open` / `open`).
- `devtools::check()` stays at the baseline (0 errors / 0 warnings / 1 NOTE
  for the NTP timestamp).
- `devtools::test()` stays at 70/70 PASS — no R/ source change is required by
  this work.
- The vignette's plot helpers are defined inline (not as exported package
  functions), so no roxygen update or NAMESPACE change.

## 7. What this spec does NOT cover

- Capital / RWA, IFRS 9 stage shift, and internal-limit framings. These go
  into a separate exploratory vignette
  (`vignettes/sensitivity-bank-impact-experiments.Rmd`) that is built but not
  yet promoted to the public set. Out of scope for this spec.
- The `sensitivity-analysis_khan_bank.Rmd` client-specific vignette stays as
  is. It is gitignored and serves a different purpose.
- Any changes to the underlying `run_trisk_sa()` API or to the integration
  pipeline functions.

## 8. Cross-references

- `vignettes/pd-el-integration.Rmd` — canonical methodology vignette; the
  bank-impact section in this vignette is a one-step pointer into that one.
- `vignettes/pd-el-viz-walkthrough.Rmd` — visual reference for the seven
  pipeline plots and tables; useful sibling for readers who arrive at the
  EL bps KPI and want to see what other artefacts the pipeline produces.
- `vignettes/sensitivity-analysis_khan_bank.Rmd` — client-specific reference
  for the pattern this vignette generalizes.
- `~/Documents/repos/trisk.model` PR #58 — the ADO 1943 fix that makes the
  Merton term grid match the analysis horizon, which underpins the
  inner-join-on-actual-term approach used here.
