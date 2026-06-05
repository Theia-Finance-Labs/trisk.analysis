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
- **Acceptance invariant:** (post-EAD1) summed `exposure_at_default` over a single loan == its own `exposure_value_usd` (true EAD), and summed `lgd_weighted_exposure` == `exposure_value_usd * loss_given_default`, for any asset count.
- **Watch:** the full runner currently exposes `asset_id`/`asset_name` in detail output — confirm nothing downstream depends on asset-level rows (grep `prepare_plot_data`, plots) before collapsing; if needed, keep an asset-level detail object separate from the portfolio-joined frame.
- Drives 0.1 RED → GREEN; revert → RED; restore. (The separate duplicate-manual-entry case → a `warning()` in Phase 2, see V1/technology-isolation.)

### K1 — re-base + relabel the headline bps
- **Code evidence:** `aggregate_el_integration` (`R/integrate.R:405-409`) sets `el_adjusted_bps = el_to_bps(total_el_adjusted, total_exposure_usd)` — the *level* on *raw exposure*, while the table/vignette label it "EL/EAD delta".
- **Denominator algebra (decisive):** with EAD = exposure×LGD, `EL/EAD = (exp·LGD·PD)/(exp·LGD) = PD in bps` — a PD-like rate, **not** a loss rate. A headline "EL in bps" conventionally means EL / *notional exposure* = (LGD·PD) in bps. So the **correct denominator is raw `total_exposure_usd`**, relabelled **"EL / exposure (bps)"** — not `total_ead`, which would reintroduce the same confusion K1 exists to kill.
- **Fix (DONE):** emit **both** bps measures on raw exposure — `el_adjusted_bps` (level) and `el_adjustment_bps` (delta) — and fix the labels. The defect was the *mislabel* (level called "delta"/"EL/EAD"), not showing the level.
- **Headline decision (Jakub 2026-06-05): LEVEL first.** KPI table (`R/plot_integration_kpi_table.R`) headlines `Adjusted EL (bps)` (level = total expected-loss rate of the shocked book), with `EL/exposure delta (bps)` (climate overlay) as the secondary column; P4 sector breakdown shows the adjusted-level rate. `vignettes/bank_4*` "P3b"/"P4" wording leads with the level and points to the delta for climate attribution. Denominator is raw exposure throughout (EL/EAD would be PD-in-bps).
- Pinned in `test-el-bps-kpi.R` (delta exists, equals delta/exposure, ≠ level).

### Z1 — clip diagnostics + guidance
- **Code evidence:** `apply_pd_method`/`apply_el_method` clip to `[ZSCORE_FLOOR_DEFAULT=1e-4, ZSCORE_CAP_DEFAULT]` before `qnorm` (`R/integrate.R:206-212,360-369`; `R/imports.R:55-56`).
- **Fix:** compute `zscore_clipped_share` (fraction of rows where internal/baseline/shock hit a clip bound); attach to `$aggregate`; `warning()` when it exceeds a threshold (e.g. 0.5). Roxygen: document that sub-floor baselines erase signal; recommend `method="absolute"` for underflow-prone (IG / short-horizon) books. **Do not silently change the 1e-4 floor** (it would move every result) — surface and document it.

**Gate:** `devtools::test()` GREEN; `devtools::check()` clean (0 errors/warnings); revert-to-fail confirmed for X1/K1/Z1. PR → review → merge.

---

## Phase 2 — High (own branch)
- **✅ A1** (DONE): both runners attach a `trisk_run_meta` attribute (scenario pair, `run_id`, forwarded `...`, package versions, timestamp) via `build_trisk_run_meta`. Reproducibility recipe added to bank_4. `test-runner-metadata.R`.
- **✅ V1 + technology isolation** (DONE): `check_portfolio` (full runner only) now requires `sector` + `technology` and fails fast; `check_portfolio_simple` stays technology-free. Tests in `test-check-portfolio.R`. (Vignette positioning — lead with simple runner — folded into A1/docs pass, still TODO.)
- **✅ D1** (DONE): `warn_terms_outside_grid()` in both runners warns and names dropped `(company_id, term)` when a portfolio term is outside the Merton grid. `test-runner-metadata.R`.
- **✅ S1** (DONE): `run_trisk_from_db()` takes an optional `conn` or reads `TRISK_DB_*` env vars, fails fast if absent, no hardcoded password. `test-run-trisk-from-db.R`.
- **✅ CX1** (DONE): `resolve_internal_series` now matches on all shared key columns (company_id [+ term/…]) and errors on ambiguous duplicate-key lookups. `test-internal-lookup.R`.

### Phase 2 Codex re-review (2026-06-05): V1/A1/D1 = FIXED; CX1 regression + S1 nits → fixed
- **CX1 regression (Codex):** value detection by "absent from analysis_data" broke the bank_4 path (the portfolio's `internal_pd` rides along into analysis_data). Fixed: keys identified by a known ID set (`company_id, term, sector, technology, country_iso2, run_id`), value = remainder. Regression test added (analysis_data carrying `internal_pd`).
- **S1 (Codex):** added `TRISK_DB_PORT` positive-integer validation before connecting; removed the password literal from the test (constructed dynamically). Caller-supplied `conn` correctly left open.

### Phase 1 hardening (from Codex re-review 2026-06-05)
- **✅ X1 edge:** `aggregate_npv_across_assets` preserves NA for all-NA-NPV groups (no collapse-to-0 → no NaN/Inf downstream).
- **✅ Z1 edges:** `zscore_clipped_share` excludes all-NA rows from the denominator; `integrate_el` maps zero/NA-EAD rows to NA (no warning misfire). Edge tests added.
- **✅ K1 test comment** corrected to the level-first decision.
- Codex re-review verdict: K1 = FIXED; X1/Z1 cores correct, edges now closed.

## Phase 3 — Medium (own branch; N1 is wide — isolate it)
- **N1 — RESOLVED by EAD1 (2026-06-05).** Jakub confirmed the Basel-strict convention. Implemented additively + corrective: `exposure_at_default` now means true EAD (`= exposure_value_usd`, pre-LGD), and the EAD×LGD product moved to a new `lgd_weighted_exposure` column (the EL-zscore denominator). `expected_loss_* = EAD×LGD×PD` — numerics unchanged. Input CSV kept (`exposure_value_usd`), Basel mapping documented. See the EAD1 section above for the full change set and touched files.
- **✅ G1/AGG1** (DONE, doc): G1 geography-drop caveat added to bank_4; AGG1 median-PD choice documented in `aggregate_facts_trisk` (robust central tendency; not exposure-weighted because exposure joins later).
- **✅ NM1** (DONE): `warn_scenario_family_mismatch()` in both runners warns when baseline/target scenario families differ. `test-runner-metadata.R`.
- **✅ L1** (DONE, doc): static-LGD limitation documented in bank_4 caveats.
- **✅ IF1** (DONE): `pd_lifetime_to_annual()` + `pd_annual_to_lifetime()` (constant-hazard) in `R/pd_horizon.R`; bank_4 horizon caveat references them. `test-pd-horizon.R`.
- **✅ CX2** (DONE): `fuzzy_match_company_ids` warns on tied best matches and keeps one per portfolio row (no exposure-duplicating fan-out); FZ1 docstring default corrected (0.2→0.5). `test-fuzzy-match-ties.R`.

## Phase 4 — Low (DONE)
- **✅ I1** install chunk (`pak::pak(...)`, eval=FALSE) added to `0_getting-started.Rmd`.
- **✅ EP1** `get_available_parameters` initialises `possible_combinations <- tibble()` (empty input → empty tibble, no error); dead `combinations <- list()` removed.
- **✅ R1** `integrate_pd`/`integrate_el` warn (naming the count) when `method="relative"` no-ops on zero-baseline rows.
- **✅ SA1** `run_trisk_sa` isolates each run in `tryCatch` (one bad set no longer aborts the sweep), reports failures, and combines with `dplyr::bind_rows`.
- **✅ FZ1** `fuzzy_match_company_ids` docstring default corrected (0.2→0.5) (done in Phase 3 commit).
- **✅ DL1** `download_trisk_inputs` roxygen documents provenance (fetches scenarios only; assets/financials/carbon are user-supplied → `setup_trisk_inputs()`).
- **✅ non-ASCII** em-dashes in `setup_trisk_inputs.R` replaced with ASCII hyphens → R CMD check WARNING cleared.
- Tests: `test-low-fixes.R` (EP1, R1).

## Phase 5 — Re-review (DONE — 4 Codex cross-model passes)
- Codex cross-model review run 4× over the branch: (1) Criticals, (2) Phase-1 fixes, (3) Phase-2 High, (4) final holistic. Every flagged item closed with a regression test:
  - Round 1: confirmed X1 (re-elevated — multi-asset fan-out), K1, Z1.
  - Round 2: X1/Z1 edge hardening (NA preservation, clip-share denominator, zero-EAD).
  - Round 3: CX1 regression + S1 nits (port validation, test literal).
  - Round 4 (final): 11/12 areas CONFIRMED. Two "blocking" findings (run_trisk_sa / run_trisk_agg reading `$npv`/`$pd`) were **false alarms** — empirically both return populated results via R's `$` partial matching (run_trisk_agg → 7 npv / 145 pd rows; run_trisk_sa likewise). Fixed anyway for robustness: exact names `$npv_results`/`$pd_results` + contract test (`test-runner-contracts.R`). Two genuine minors fixed: `el_adjustment_bps` now signed; simple-runner NPV aggregation preserves all-NA groups (symmetry with X1).
- Status: R CMD check 0 errors / 0 warnings; 213 tests pass. N1 remains the only acknowledged deferral (breaking rename, awaiting decision).

---

## Post-review refinements (2026-06-05, Jakub domain clarification)
Confirmed from model output: `asset_id` is effectively the **company** (1 row per company-technology; company 105 shares asset_id across its 3 technologies), and PD is company-level cumulative-over-term. So the real grain is **company > company-technology**; true asset-level only arrives with 1in1000 Spatial data (post-summer). Implications acted on:
- **X1 reframed as defensive.** `aggregate_npv_across_assets` is a no-op on current (Asset-Impact) data; it only bites on future asset-resolved inputs. Kept as a safety net.
- **X1 duplicate-entry guard added** (`warn_duplicate_company_term_exposure`): warns when one company loan is split per technology with repeated full exposure (the real 3× footgun) and steers to the simple runner.
- **Full runner deprecated.** `run_trisk_on_portfolio` roxygen states a loan is company-level and prefers `run_trisk_on_simple_portfolio` (no technology column); the technology-keyed join is for technology/asset-resolved use only. Machinery retained for post-summer asset-level data. **Now runtime-deprecated (2026-06-05):** the function calls base `.Deprecated()` pointing to the simple runner — no internal callers exist (simple/agg/SA don't call it), so the recommended paths don't warn. Tests: one asserts the warning (`expect_warning(..., "deprecated")`), others wrap in `suppressWarnings()`; vignettes (bank_2, bank_4) mark it deprecated and set `warning=FALSE` on the demo chunks.
- **IF1 re-documented honestly.** The package cannot know an internal PD's horizon; `pd_lifetime_to_annual` is grounded on TRISK's cumulative term-PD; `pd_annual_to_lifetime` is a generic inverse (caller asserts the input is annual). Added a "Choosing a direction" guidance section and a horizon-consistency note to `integrate_pd`/`integrate_el` (`internal_pd` must be on a horizon comparable to the TRISK `term`; convert first if it's a 12-month figure).

## EAD1 — Basel EAD/EL naming fix (2026-06-05)
**Finding:** the computed column `exposure_at_default` held `exposure_value_usd × loss_given_default` = **EAD × LGD**, not EAD. Per Basel (BIS *Explanatory Note on the IRB Risk Weight Functions* §4.3–4.4: *"EL of a loan (expressed as percentage figure of EAD)"*, EL = average PD × downturn LGD), **EAD is the gross exposure before the LGD haircut; LGD is a fraction of EAD; EL = EAD × LGD × PD**. The EL number was always correct (`(EAD×LGD)×PD`); only the column was mislabelled.

**Input CSV (decision: keep + document):** `exposure_value_usd` = EAD (drawn amount; no undrawn/CCF modelled), `loss_given_default` = LGD, `term` = effective maturity M, `internal_pd` = PD. No renames — Basel mapping documented in roxygen.

**Output fix (decision: now, this PR):**
- `exposure_at_default` now = `exposure_value_usd` (true EAD); simple runner uses the NPV-share-allocated `exposure_value_usd_share`.
- New column `lgd_weighted_exposure` = EAD × LGD (the old `exposure_at_default` value).
- `expected_loss_* = exposure_at_default × loss_given_default × pd_*` (reads as Basel EAD×LGD×PD; numerically identical).
- `integrate_el()` zscore normalizer now reads `lgd_weighted_exposure` (fallback: `exposure_value_usd × loss_given_default`); local var + `apply_el_method` param renamed `ead → lgd_weighted_exp`. `aggregate_el_integration` unaffected (divides EL by **notional** exposure for the bps loss-rate).
- Touched: `run_trisk_on_simple_portfolio.R`, `prepare_plot_data.R`, `integrate.R`, tests `test-exposure-fanout.R` / `test-integrate-el.R`. Added Basel-identity regression (`EL == EAD×LGD×PD`). 219 pass / 0 fail.

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
