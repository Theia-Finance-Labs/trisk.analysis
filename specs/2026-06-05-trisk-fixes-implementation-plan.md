# TRISK bank-analyst fixes — executable implementation plan

**Date:** 2026-06-05
**Source review:** `specs/2026-06-04-bank-analyst-review-and-plan.md` (Santa dual review, FAIL verdict).
**Status of findings (updated 2026-06-05 after empirical reproduction):**
- **K1 and Z1 — confirmed Critical.** Both are code facts read directly from source (K1: `el_to_bps(total_el_adjusted, …)` headlines the level not the delta; Z1: the `[1e-4, 1-1e-4]` clip envelope). Real at any magnitude.
- **X1 — RE-ELEVATED to Critical after the Codex cross-model pass (2026-06-05).** My first empirical pass concluded X1 "dissolved" because the bundled test data has exactly **1 asset per company/technology**, so every measured inflation was 1.0. Codex reasoned *structurally* and was right: the NPV×PD join keeps **asset-level NPV rows**, and the portfolio join has **no `asset_id`** key — so a company with **>1 asset in the same `(sector, technology)`** (a utility with several plants of one type — normal in production) fans a single well-formed loan into N rows, and `compute_analysis_metrics` applies **full exposure to each** → N× EL/EAD, silently. **Confirmed empirically:** giving company 102 a second Coal/Coal asset, one loan row → 2 analysis rows → EAD 8,718,310 vs truth 4,359,155 = **2×**. Real loan books trigger this; toy data masks it.
  - **Nuance retained:** the *technology* join key does prevent cross-technology fan-out (the original "3× multi-technology" framing was the wrong mechanism); the real fan-out is **multi-asset-per-technology**. The duplicate-manual-entry case is a separate, lower issue.
  - **Fix:** aggregate NPV across `asset_id` to `(run_id, company_id, sector, technology, country_iso2)` **before** the portfolio join — mirror `aggregate_trisk_outputs_simple`. Each loan then matches one row per technology and contributes its exposure once; NPV is the company-technology total (correct).
**Method:** Strict TDD. Phase 0 writes failing tests that reproduce each bug on a multi-technology fixture *before* any fix. No fix lands until its test is RED, then GREEN, then revert-to-RED confirms the guard bites.

**Branching:** one branch `fix/bank-analyst-criticals` for Phase 0–1; subsequent phases each their own branch off main after the prior merges. Never commit fixes and their reproduction in the same commit (so revert-to-fail is trivial).

---

## Pre-flight (once, before Phase 0)

1. `R -q -e 'devtools::load_all(); devtools::test()'` → capture the current green baseline.
2. **X1 fan-out diagnosis — DONE 2026-06-05 (result below).** Reproduction run on `trisk.model` bundled testdata (assets/scenarios/financials/carbon) with scenarios `NGFS2023GCAM_CP` → `NGFS2023GCAM_NZ2050`:
   - `pd_results` columns = `run_id, company_id, company_name, sector, term, pd_baseline, pd_shock` → **no `technology`**. PD is company/sector/term-level.
   - `npv_results` carries `technology` + `asset_id`; the npv×pd inner-join fans company PD across technologies, but `merge_portfolio` then filters on the portfolio row's `technology`.
   - Measured inflation (summed `exposure_at_default` ÷ loan exposure×LGD): repo 4 loans → **1.0**; company 105 as one loan at one technology → **1.0**; company 105 entered 3× (per technology, full exposure) → **3.0**; simple runner, single 105 loan → **1.0**.
   - **No code/vignette path** turns a one-row-per-company portfolio into per-technology full-exposure rows (bank_3 joins exposure by `(company_id, term)`, not technology).
   - **Conclusion:** no silent inflation of a well-formed portfolio; the 3× is duplicate manual entry. No multi-asset/multi-tech fixture is needed to "reproduce X1" — there is no aggregation bug to reproduce.

---

## Phase 0 — Reproduce & guard (TDD, NO fixes)

### 0.1 X1 — multi-asset fan-out reproduction (RED) — `tests/testthat/test-exposure-fanout.R`
The bundled data masks X1 (1 asset/company/technology). Build a fixture where one company has **≥2 assets in the same `(sector, technology)`** — the production-realistic trigger Codex identified.
- Fixture: take `trisk.model` `assets_testdata`, duplicate company 102's Coal/Coal asset under a new `asset_id` (e.g. `+9000`). One portfolio loan row for company 102.
```r
assets_multi <- bind_rows(assets, a102 |> mutate(asset_id = asset_id + 9000))
full <- run_trisk_on_portfolio(assets_data = assets_multi, ...one 102 loan...) |>
  compute_analysis_metrics()
# PRIMARY analytic oracle: one loan contributes its exposure once
expect_equal(sum(full$exposure_at_default, na.rm = TRUE),
             6227364 * 0.7)        # FAILS today: measures 2x (8,718,310)
expect_equal(nrow(full), 1L)        # FAILS today: 2 asset rows fan out
```
Measured today: 2 rows, EAD = 8,718,310 = **2×** truth → RED. After the Phase-1 NPV-asset-aggregation fix → 1 row, 1× → GREEN; revert → RED.

### 0.2 X1 guard for the bundled (single-asset) case stays correct
Keep a companion assertion that the unmodified bundled data still reconciles at 1.0 (so the fix doesn't over-correct single-asset companies). This is the GREEN-now regression guard.

### 0.3 Z1 — `tests/testthat/test-zscore-floor.R` (RED)
```r
ad <- tibble(pd_baseline = c(5e-14, 3e-5, 2e-3),   # two below 1e-4 floor
             pd_shock    = c(8e-14, 9e-5, 4e-3), exposure_value_usd = 1e6, ...)
res <- integrate_pd(ad, method = "zscore")
# diagnostic must exist and report the clipped fraction (does not exist yet -> FAIL)
expect_true("zscore_clipped_share" %in% names(res$aggregate))
expect_gt(res$aggregate$zscore_clipped_share, 0)
# clip-governed artifact: two different sub-floor shocks -> identical adjusted PD
expect_equal(adj(5e-14, 8e-14), adj(5e-14, 9e-14))   # documents the floor artifact
```

### 0.4 K1 — `tests/testthat/test-el-bps-kpi.R` (RED)
```r
agg <- aggregate_el_integration(integrate_el(metrics)$portfolio)
# headline must be the DELTA on the RAW-EXPOSURE denominator (EL/exposure bps),
# not the adjusted LEVEL — and not EL/EAD, which would be PD-in-bps
expect_true("el_adjustment_bps" %in% names(agg))
expect_equal(agg$el_adjustment_bps,
             el_to_bps(agg$total_el_adjustment, agg$total_exposure_usd))  # FAILS: column absent
expect_false(isTRUE(all.equal(agg$el_adjustment_bps, agg$el_adjusted_bps)))  # delta != level
```

**Gate:** new tests RED, `devtools::test()` otherwise GREEN. Commit `test+fixture` only.

---

## Phase 1 — Critical fixes (only after Phase 0 is RED)

### X1 — aggregate NPV across assets before the portfolio join (Critical; Codex-confirmed)
- **Code evidence:** `join_trisk_outputs_to_portfolio` joins NPV→PD by `(run_id, company_id, sector)` keeping **asset-level NPV rows** (`R/run_trisk_on_portfolio.R:190-196`); `merge_portfolio` then joins the portfolio by `(company_id, country_iso2, sector, technology, term)` with **no `asset_id`** (`:211-215, :229-230`); `compute_analysis_metrics` applies full `exposure_value_usd * loss_given_default` to every resulting row (`R/prepare_plot_data.R:100-112`). A company with N assets in one `(sector, technology)` → N rows → N× EAD/EL. Reproduced: 2× for a 2-asset company.
- **Fix:** insert an asset-collapse step before the portfolio join — aggregate `npv_results` to `(run_id, company_id, sector, technology, country_iso2)`, summing `net_present_value_baseline`/`net_present_value_shock` across `asset_id` (mirror `aggregate_trisk_outputs_simple`). Then each loan matches one row per technology; exposure applied once; NPV = company-technology total.
- **Acceptance invariant:** summed `exposure_at_default` over a single loan == its own `exposure_value_usd * loss_given_default`, for any asset count.
- **Watch:** the full runner currently exposes `asset_id`/`asset_name` in detail output — confirm nothing downstream depends on asset-level rows (grep `prepare_plot_data`, plots) before collapsing; if needed, keep an asset-level detail object separate from the portfolio-joined frame.
- Drives 0.1 RED → GREEN; revert → RED; restore. (The separate duplicate-manual-entry case → a `warning()` in Phase 2, see V1/technology-isolation.)

### K1 — re-base + relabel the headline bps
- **Code evidence:** `aggregate_el_integration` (`R/integrate.R:405-409`) sets `el_adjusted_bps = el_to_bps(total_el_adjusted, total_exposure_usd)` — the *level* on *raw exposure*, while the table/vignette label it "EL/EAD delta".
- **Denominator algebra (decisive):** with EAD = exposure×LGD, `EL/EAD = (exp·LGD·PD)/(exp·LGD) = PD in bps` — a PD-like rate, **not** a loss rate. A headline "EL in bps" conventionally means EL / *notional exposure* = (LGD·PD) in bps. So the **correct denominator is raw `total_exposure_usd`**, relabelled **"EL / exposure (bps)"** — not `total_ead`, which would reintroduce the same confusion K1 exists to kill.
- **Fix:** emit `el_adjustment_bps = el_to_bps(total_el_adjustment, total_exposure_usd)` (the *delta* on *raw exposure*) as headline; keep `el_adjusted_bps` (level) clearly relabelled as a secondary diagnostic row. Update `R/plot_integration_kpi_table.R` and `vignettes/bank_4*` "P3b" so both the label ("EL/exposure delta, bps") and the wording ("delta") match the number. Ties cleanly into N1's exposure/EAD renaming.
- Pin the chosen denominator + label in test 0.4.

### Z1 — clip diagnostics + guidance
- **Code evidence:** `apply_pd_method`/`apply_el_method` clip to `[ZSCORE_FLOOR_DEFAULT=1e-4, ZSCORE_CAP_DEFAULT]` before `qnorm` (`R/integrate.R:206-212,360-369`; `R/imports.R:55-56`).
- **Fix:** compute `zscore_clipped_share` (fraction of rows where internal/baseline/shock hit a clip bound); attach to `$aggregate`; `warning()` when it exceeds a threshold (e.g. 0.5). Roxygen: document that sub-floor baselines erase signal; recommend `method="absolute"` for underflow-prone (IG / short-horizon) books. **Do not silently change the 1e-4 floor** (it would move every result) — surface and document it.

**Gate:** `devtools::test()` GREEN; `devtools::check()` clean (0 errors/warnings); revert-to-fail confirmed for X1/K1/Z1. PR → review → merge.

---

## Phase 2 — High (own branch)
- **A1** audit trail: attach `$meta` (or `attr`) to both runner outputs — scenario pair, all forwarded `...`, `packageVersion()` of trisk.analysis + trisk.model, `run_id`. Add a reproducibility-recipe section to a vignette.
- **V1 + technology isolation** (reframed per Jakub 2026-06-05): the technology requirement should be **isolated to the full runner**, not pushed onto all inputs.
  - **Positioning:** make `run_trisk_on_simple_portfolio()` the **recommended default** — it needs no `sector`/`technology`, allocates each company's exposure across technologies by NPV share, and avoids the X1 duplicate-entry footgun. The full runner is the **specialist path** for banks that genuinely hold technology-level exposure.
  - **V1 fail-fast:** in the *full* runner only, require `sector` + `technology` and error clearly if absent (today `check_portfolio` omits them → opaque join crash). The simple runner must never require them.
  - **Docs:** lead every bank vignette with the simple runner; present the full runner as opt-in for technology-targeted analysis. This is the input-side simplification — most portfolios never need a technology column.
- **D1** term-beyond-grid: promote the bank_3 inline drop-warning into the runners; name dropped `(company_id, term)`.
- **S1** de-hardcode DB creds in `R/run_trisk_from_db.R`: take a DBI connection or env-var secrets (`Sys.getenv`), error if absent, never embed a password.
- **CX1 (NEW, Codex) — internal PD/EL lookup keyed only by `company_id`.** `resolve_internal_series` (`R/integrate.R:171-190`) matches a `company_id`+value data frame by `company_id` alone, so a company with multiple loans (different terms/exposures) silently reuses the first internal value. → Match on `(company_id, term)` (or the full key), or error on multi-row companies when a per-company lookup is given. Add a test with a company holding two different-term loans. (High)

## Phase 3 — Medium (own branch; N1 is wide — isolate it)
- **N1** rename `exposure_at_default` → `lgd_weighted_exposure` everywhere (reserve `exposure_at_default` for pre-LGD); add EL-decomposition banner. **Grep all usages first** (`R/`, `vignettes/`, `tests/`); interacts with the K1 denominator and X1 allocation — do *after* Phase 1 so it renames already-correct columns. Single dedicated commit.
- **G1/AGG1** report assets-in vs assets-after geography filter; document or switch median PD → exposure-weighted in `aggregate_facts_trisk`.
- **NM1** disambiguate `NGFS2023GCAM_*` vs `NGFS2023_GCAM_*`; warn when baseline/target come from different families/year-ranges.
- **L1** document static-LGD limitation.
- **IF1** `pd_lifetime_to_annual(pd, term)` helper + worked staging example, or explicit "lifetime ECL input only" scope-out.
- **CX2 (NEW, Codex) — fuzzy match keeps ties.** `fuzzy_match_company_ids` uses `slice_min(order_by, n = 1)` which **keeps tied best matches** (`R/run_trisk_on_portfolio.R:148-173`); a portfolio name tying two asset companies duplicates that loan across both → exposure double-applied before the join. → `slice_min(..., with_ties = FALSE)` (or explicit tie-break) + warn on ties naming the loan. (Medium)

## Phase 4 — Low (own branch)
- I1 install chunk; EP1 empty-input guard (`get_available_parameters`); R1 relative no-op warning; SA1 `bind_rows`+`tryCatch` per run in `run_trisk_sa`; FZ1 docstring 0.2→0.5; DL1 input-provenance docs.

## Phase 5 — Re-review
- Re-run Santa dual review **with Codex as the cross-model second agent** (separate session, per user) on changed code + vignettes. Both must PASS before declaring bank-engagement-ready. Re-verify X1/Z1/K1 numbers independently.

---

## Dependency & ordering notes
- **Phase 1 = X1 + K1 + Z1** (X1 re-elevated after Codex cross-model confirmation).
- X1, K1, Z1 are independent code defects — fixable in any order.
- N1 (Phase 3) must follow K1 — it renames `exposure_at_default`→`lgd_weighted_exposure` and reinforces K1's "EL/exposure vs EL/EAD" labelling distinction.
- Each fix: test RED → fix → GREEN → revert-to-RED → restore. No exceptions.

## Verification commands (per phase)
```bash
R -q -e 'devtools::load_all(); devtools::test(filter="exposure-allocation|zscore-floor|el-bps")'   # Phase 0/1 targeted
R -q -e 'devtools::test()'                                                                          # full suite
R -q -e 'devtools::check()'                                                                         # CRAN-style gate before each PR
```

## Open decisions for Jakub
1. **X1 handling** (now High/Medium, not Critical): add a duplicate-`(company_id, term)` warning **and** document-and-steer to the simple runner (recommended) vs documentation only. Empirically there is no aggregation bug to fix.
2. **K1 denominator** = raw exposure, relabel "EL/exposure (bps)" (leading; EL/EAD = PD-in-bps, the wrong rate) vs keep EL/EAD only if the headline is explicitly redefined as a PD-equivalent. Default: raw exposure.
3. **IF1** = ship `pd_lifetime_to_annual()` + staging example vs scope the package explicitly as "lifetime ECL input only".
