# TRISK bank-analyst review & implementation plan

**Date:** 2026-06-04
**Method:** Santa method (dual independent adversarial review, identical rubric, no shared context).
**Reviewers:** Reviewer C and Reviewer B2 — *both Claude* (the requested Codex reviewer could not run: Codex CLI not installed; `npm install -g @openai/codex` + `/codex:setup` to enable, then re-run for a cross-model pass).
**Verdict:** **FAIL — needs work before the workflow is defensible to bank model validation / risk committee / IFRS-9 & capital teams.** Both reviewers independently returned FAIL.

> Note on confidence: findings flagged by **both** reviewers are high-confidence. The two most severe issues (Z1, X1 below) were raised by **only one** reviewer but with empirical reproduction — per Santa, a single-reviewer finding is still real, but these change code/results, so the plan **verifies them first**.

---

## Critical (block sign-off)

### X1 — Full-runner EL path double-counts exposure for multi-technology companies *(reviewer-reproduced; one reviewer; the other disputed → VERIFY FIRST)*
> **UPDATE 2026-06-05 (empirical + Codex cross-model, see `2026-06-05-trisk-fixes-implementation-plan.md`): CONFIRMED Critical — but the mechanism is multi-ASSET, not multi-technology.** The technology join key *does* prevent cross-technology fan-out (so the original "multi-technology 3×" framing was the wrong mechanism, and a first empirical pass on bundled data wrongly read it as "dissolved" — bundled data has 1 asset/company/technology). The real bug: NPV is asset-level, the portfolio join has no `asset_id`, so a company with **>1 asset in one `(sector, technology)`** (e.g. a utility with several plants — normal in production) fans one loan into N rows at full exposure → N× EL/EAD, silently. Reproduced: 2× for a 2-asset company. Fix = aggregate NPV across assets before the portfolio join (mirror `aggregate_trisk_outputs_simple`).
- **Where:** `R/run_trisk_on_portfolio.R` (`join_trisk_outputs_to_portfolio`, many-to-many), `R/prepare_plot_data.R` (`compute_analysis_metrics` computes `exposure_at_default = exposure_value_usd * LGD` on every expanded row), `vignettes/bank_4` internal_el merge, `pipeline_trisk_expected_loss_plot`.
- **Issue:** The TRISK join expands one loan into N rows (per technology/asset); EL is then summed over those rows using the **full** exposure each time → ~N× EL/EAD for multi-tech companies. The **simple** runner avoids this via NPV-share allocation; the **full** runner does not. Hidden because `portfolio_ids_testdata` is artificially single-technology (company 105, the only multi-tech name, is excluded).
- **Disagreement to resolve:** Reviewer C concluded "not a double-counting bug" (portfolio reconciles, `gap≈0`) — but that reconciliation only holds for the single-tech test data. Reviewer B2 reproduced the 3× inflation for company 105.
- **Why it matters:** A real multi-technology loan book silently overstates portfolio EL/EAD → wrong reserves and capital.
- **Fix:** Apply NPV-share exposure allocation in the full runner before EL (mirror the simple runner), or de-dup exposure to one row per loan before aggregation. **Add a multi-technology company to the test fixtures so CI catches it.**

### K1 — EL "bps" headline KPI is mislabeled (two distinct defects, both reviewers)
- **Where:** `R/integrate.R` (`aggregate_el_integration`, `el_adjusted_bps`), `R/plot_integration_kpi_table.R`, `R/imports.R` (`el_to_bps`); `vignettes/bank_4` "P3b".
- **Issue A (denominator):** `el_to_bps()` divides by raw `exposure_value_usd`, but the table/vignette label it "EL / EAD". Since this package folds LGD into "EAD", EL/exposure ≠ EL/EAD.
- **Issue B (level vs delta):** the KPI reports the **adjusted EL level** (reviewer-reproduced 168 bps on bundled data), of which internal EL alone is ~151 bps and the actual climate overlay is only ~17 bps; the vignette text calls it "the bps **delta**". Headlining the level overstates the climate signal ~10×.
- **Why it matters:** The single number put in front of a risk committee is both mislabeled and ~10× the true overlay; validation rejects it.
- **Fix:** Emit and headline `el_adjustment_bps = el_to_bps(total_el_adjustment, denom)`; keep the level as a secondary row; make the denominator and its label agree (EL/exposure vs EL/EAD); align vignette text to the table.

### Z1 — Z-score integration is governed by floor-clipping when baseline PDs underflow *(reviewer-reproduced; one reviewer → VERIFY FIRST)*
- **Where:** `R/integrate.R` (`apply_pd_method`/`apply_el_method` zscore), `ZSCORE_FLOOR_DEFAULT <- 1e-4` (`R/imports.R`).
- **Issue:** Merton `pd_baseline` on bundled data is ~5e-14–3e-5, below the 1e-4 floor. Clipping pins baseline (and often shock) to the floor, so `qnorm(shock) − qnorm(baseline)` reflects the clip bound, not the model — and clipping baseline upward shrinks the shift toward zero. Structural for any sub-1e-4 baseline PD (common for IG names / short horizons), not an edge case. In the worked run nearly the entire overlay rode on one unclipped row.
- **Why it matters:** The integrated number is a floor artifact for most of the book; its sensitivity to scenario choice can't be defended.
- **Fix:** Return/log the share of rows hitting the clip bound; document that sub-floor baselines erase signal; reconsider the 1e-4 floor; recommend `absolute` as the safer default for underflow-prone books.

---

## High

- **A1 — No audit trail / reproducibility from the primary runners (both).** `run_trisk_on_portfolio`/`_simple` return only result frames; no scenario pair, rate assumptions, package versions, seed, or persisted `params` (only `run_trisk_sa` keeps `params`); `run_id` is a fresh UUID. → Attach a `params`/metadata element (scenario pair, all forwarded args, `packageVersion()` of both packages, `run_id`) to runner output; document a reproducibility recipe.
- **V1 — `check_portfolio` accepts portfolios missing `sector`/`technology`, then the join crashes (B2, reproduced).** Validation passes the 6 "required" cols but the id-match join needs `sector`,`technology` → opaque `dplyr` error after a full run. → Add them to required columns; fail fast.
- **D1 — Term beyond the Merton grid → silent NA EL from the runners (both).** Only the bank_3 *inline* helper warns; the package functions don't. → Promote the drop-warning into the runners (name dropped `(company_id, term)`), or cap/flag.
- **S1 — Hardcoded DB credentials (both).** `R/run_trisk_from_db.R` embeds `user`/`password`. → Take a DBI connection / env-var secrets; never commit a password; error if absent.

---

## Medium

- **N1 — `exposure_at_default = exposure × LGD` non-standard (both).** Conventionally EAD precedes LGD; folding LGD in inverts the EAD×PD×LGD decomposition and confuses validation. → Rename to `lgd_weighted_exposure` (reserve `exposure_at_default` for pre-LGD), present EL as the standard decomposition; add a definition banner where it first appears.
- **G1 — Geography filtering silently drops assets (both).** `scenario_geography != "Global"` drops out-of-region assets with no count. → Report assets-in vs assets-after-filter (message/attribute).
- **NM1 — Two near-identical scenario name families (both).** `NGFS2023GCAM_*` vs `NGFS2023_GCAM_*` are *different* scenarios (different year ranges) used in different bank_3 sections. → Document the distinction; warn when baseline/target come from different families/year ranges.
- **AGG1 — Country/aggregate mode uses median PD + silent geography drop (B2).** `aggregate_facts_trisk` uses `median()` PD across heterogeneous counterparties. → Document/justify or switch to exposure-weighted; report drops.
- **L1 — Static LGD only; no downturn/stress LGD (both).** Transition shock moves PD/NPV but not LGD. → Document the static-LGD limitation; optionally allow scenario-conditional LGD.
- **IF1 — IFRS-9 staging / lifetime-vs-12m PD left to the user (both).** bank_4 warns not to feed term-PD into a 12m slot but ships no annualisation helper or staging. → Provide `pd_lifetime_to_annual(pd, term)` + a worked staging example, or scope explicitly as "lifetime ECL input only".
- **EL-PLOT1 — `pipeline_trisk_expected_loss_plot` inherits the X1 double-count (B2).** Fixed at the source by X1; add the multi-tech fixture.

---

## Low

- **I1 — getting-started has no install chunk (C).** Body jumps to `library(trisk.analysis)`; install only in README. → Add `pak::pak("Theia-Finance-Labs/trisk.analysis")` (`eval=FALSE`) at the top.
- **EP1 — `get_available_parameters` errors on empty input (C).** `possible_combinations` only assigned inside `if (nrow>0)` → "object not found" on empty; dead `combinations <- list()`. → Initialize to `tibble()`; remove dead code.
- **R1 — `relative` method silently no-ops on zero-baseline rows (C).** → Warn naming the count.
- **SA1 — `run_trisk_sa` uses base `rbind`, no per-run error isolation (C).** One bad parameter set aborts the sweep. → `dplyr::bind_rows` + `tryCatch` per run; report failures.
- **FZ1 — `fuzzy_match_company_ids` doc default (0.2) ≠ code default (0.5) (B2).** → Fix docstring.
- **DL1 — `download_trisk_inputs` fetches only `scenarios.csv` (B2).** assets/financials/carbon are hand-built. → Document expected provenance/format, or provide a reference-universe fetch.

---

## Implementation plan (phased)

**Phase 0 — Verify the unproven Criticals (TDD, no fixes yet).**
Write failing tests that reproduce, on a **multi-technology** fixture:
- X1: full-runner portfolio EL/EAD vs the true per-loan exposure (expect inflation).
- Z1: share of rows clipped to `zscore_floor`; overlay sensitivity with/without floor.
- K1: assert `el_adjusted_bps` numerically equals EL/exposure and differs from the climate *delta*.
Add a multi-tech company to `inst/testdata/portfolio_ids_testdata.csv` (and the `_internal_pd` sibling). This both proves the bugs and becomes the regression guard. Resolve the C-vs-B2 disagreement here.

**Phase 1 — Critical fixes (only after Phase 0 reproduces them).**
X1 exposure allocation in the full runner; K1 KPI re-base + relabel + vignette text; Z1 clip diagnostics + guidance/default. Re-run Phase 0 tests to green; revert-to-fail to confirm the regression tests bite.

**Phase 2 — High (correctness/defensibility).**
A1 audit-trail metadata on runners; V1 fail-fast validation (sector/technology); D1 term-drop warnings in runners; S1 de-hardcode DB creds.

**Phase 3 — Medium (naming, transparency, gaps).**
N1 EAD renaming + EL decomposition banner; G1/AGG1 geography & median diagnostics; NM1 scenario-name disambiguation + validator warning; L1 static-LGD limitation; IF1 annualisation helper + staging example (or explicit scope-out).

**Phase 4 — Low (polish).**
I1 install chunk; EP1 empty-input guard; R1 relative no-op warning; SA1 bind_rows+tryCatch; FZ1 docstring; DL1 input-provenance docs.

**Phase 5 — Re-review.**
Re-run the Santa dual review (install Codex for the cross-model pass) on the changed code + vignettes; require both PASS before declaring bank-engagement-ready.

---

## Caveats
- One reviewer was substituted (Claude, not Codex) because the Codex CLI isn't installed — same-model second opinion has correlated blind spots. Install Codex and re-run for true cross-model verification, especially on X1/Z1/K1.
- Reviewer-reported numbers (168/151/17 bps, 3× inflation, clip shares) are reproductions by the review agent; Phase 0 independently re-verifies before any fix lands.
