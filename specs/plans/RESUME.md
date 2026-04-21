# Resume Context — PD & EL Integration Implementation

**Paused:** 2026-04-21
**Status:** Design + plan committed. Implementation not started.
**Execution method:** Subagent-driven with Santa Method adversarial verification.

---

## How to restart in a new session

Paste this prompt into the new Claude session (adjust paths if not on Jakub's machine):

> Resume implementation of the PD/EL integration in `trisk.analysis`. Context is in
> `/Users/jakub/Documents/repos/trisk.analysis/specs/plans/RESUME.md`. Read that
> first, then load the design spec and the 20-task plan. Use
> `superpowers:subagent-driven-development` to execute tasks one at a time, and
> wrap each task's verification in `everything-claude-code:santa-method`
> (two-agent adversarial review — both must approve before moving on). Start
> with Task 1.

---

## Key documents (read in this order)

1. **Design spec:** `specs/2026-04-21-pd-el-integration-design.md` — the "what and why"
2. **Implementation plan:** `specs/plans/2026-04-21-pd-el-integration-plan.md` — 20 TDD tasks with exact code
3. **This file** — state + decisions not captured elsewhere

---

## Decisions locked during brainstorming (do not re-litigate)

| Axis | Decision |
|---|---|
| Scope for this implementation | S1 (integration functions + aggregates) + S2 (workflow vignette). S3 (viz walkthrough) and S4 (sensitivity rewrite) deferred. |
| API shape | Single function per metric (`integrate_pd`, `integrate_el`) with `method` argument |
| File structure | One file `R/integrate.R` for all integration logic + one `R/plot_*.R` per visualization |
| Edge-case behavior | **Shiny parity** — port `mod_integration.R` logic line-for-line including known quirks (e.g., relative method silently returns `internal_pd` when `pd_baseline = 0`). Quirks are documented in roxygen, not fixed. |
| Vignette data | **Bundled package testdata only.** Never use Khan Bank CSVs at `/Users/jakub/Downloads/04.17 debug khanbank/` in the vignette or in `inst/`. |
| Palette additions | `TRISK_HEX_ADJUSTED = "#AA2A2B"` (new), `STATUS_GREEN = "#3D8B5E"` (ported from trisk.r.docker). Primary three `TRISK_HEX_*` constants unchanged. |
| EL scope | Include EL integration alongside PD in this pass |
| N1 vs N2 | Build N1 (method comparison plot) first. Task 17 is a gate: render N1 against testdata, ask Jakub, then decide whether to implement N2 (waterfall). |

---

## Santa Method application

Wrap **each task's verification step** (the step that runs `devtools::test(...)` and checks for green) in the Santa loop:

1. Task subagent completes the task (RED → GREEN → COMMIT).
2. Santa review agent 1 (fresh context): reads the diff + the plan's task spec + the design spec. Approves or rejects with specific reasons.
3. Santa review agent 2 (fresh context, independent of agent 1): same task. Approves or rejects.
4. **Both must approve** before moving to the next task. If either rejects, the task subagent addresses the feedback and the Santa loop re-runs.
5. At minimum, each reviewer should verify:
   - Code matches the spec's API and coding-style checklist (§9 of spec)
   - Tests actually cover what they claim (no hollow assertions)
   - No unrelated changes / scope creep
   - Commit message is accurate

On heavy review friction at any single task, escalate to Jakub before burning loops — don't let two reviewers bikeshed.

---

## Repo state at pause

- **Branch:** `output-development`
- **Recent commits:**
  ```
  b1e9dda docs: add PD and EL integration implementation plan
  41df9f8 docs: add PD and EL integration design spec
  ca0e45d new_vignette: NPV country analysis   ← pre-existing tip before my work
  ```
- **Caveat:** commit `41df9f8` (spec commit) also captured a pre-existing staged `SKIP_FIX.txt` that was in the index before this session started. Jakub may want to amend/split it. Not blocking.
- **Working tree:** clean (after the two commits above).
- **No R code has been written in the package yet.** Tasks 1-20 are untouched.

---

## Why this work exists (domain context — one paragraph)

TRISK recomputes PD from a Merton structural model. Two problems: (a) it doesn't consume the bank's internal PD, so the TRISK level is incomparable — only the shift matters; (b) when volatility is low or the equity buffer is large, `pnorm(-d2)` underflows to zero in double precision, producing baseline PDs that look like 0 even for real credit risk. The trisk.r.docker Shiny desktop app solved this with three integration methods (absolute, relative, Basel IRB z-score) that map the TRISK shift onto the bank's own PD scale. This work ports that methodology into `trisk.analysis` as reusable library functions so it can be called from any R script or vignette.

---

## Zero-PD investigation findings (reference for the vignette's motivation paragraph)

These came from the 2026-04-21 debug run on Khan Bank data — **do not include the data, only the finding pattern**. Diagnostic scripts and CSVs are at `/Users/jakub/Downloads/04.17 debug khanbank/` (out of repo).

Three distinct mechanisms produced 0 PDs in that portfolio:

1. **Numerical underflow** (firms 103, 104, 106, 107, 109): low σ + high V0/L + short term pushes Merton `d2` above ~8.3; `pnorm(-d2)` underflows to exact zero.
2. **Portfolio term > model term** (firm 101): `calc_pd_change_overall()` in `trisk.model` hardcodes `term = 1:5`; portfolio rows with `term = 7` silently become NA in the join. This is an upstream `trisk.model` bug — logged but **not fixed in this work**.
3. **Shock benefit** (firm 104 RenewablesCap, emission_factor = 0): carbon tax doesn't hit → shock equity > baseline equity → `d2_ls > d2_base` → both underflow to zero.

The vignette's §3 ("Why integration matters") should capture the conceptual insight without naming firms or citing the Khan Bank data.

---

## Trisk.r.docker cross-repo references (for reviewer context)

When tasks port Shiny logic, the reviewers should open the source for line-for-line parity checks:

- `~/Documents/repos/trisk.r.docker/app/modules/mod_integration.R:170-234` — PD method math (absolute, relative, zscore)
- `~/Documents/repos/trisk.r.docker/app/modules/mod_integration.R:509-557` — EL method math
- `~/Documents/repos/trisk.r.docker/app/modules/mod_integration.R:321-356` — PD KPI valueBox strip (P3a source)
- `~/Documents/repos/trisk.r.docker/app/modules/mod_integration.R:657-704` — EL KPI valueBox strip (P3b source)
- `~/Documents/repos/trisk.r.docker/app/modules/mod_integration.R:707-786` — Sector breakdown (P4 source)
- `~/Documents/repos/trisk.r.docker/app/modules/mod_integration.R:789-891` — EL adjustment bar chart (P2 source)
- `~/Documents/repos/trisk.r.docker/app/modules/mod_results_summary.R:438-463` — PD by sector grouped bars (P1 inspiration)
- `~/Documents/repos/trisk.r.docker/app/modules/mod_results_scenarios.R:220-234` — Metric range lollipop (N1 inspiration)

---

## Deferred work (out of scope for this pass)

- **S3:** PD/EL visualization walkthrough vignette (narrate end-to-end). Separate spec + plan when this lands.
- **S4:** Simplify / rewrite `sensitivity-analysis.Rmd` with bank-impact commentary. Separate spec + plan.
- **trisk.model upstream:** `calculate_pd_change_overall()` term > 5 silent-NA bug. Separate PR to trisk.model.

---

## First-task bootstrap checklist for the resuming agent

Before starting Task 1:

- [ ] Confirm working directory is `~/Documents/repos/trisk.analysis/`
- [ ] Confirm branch is `output-development` and working tree is clean (`git status`)
- [ ] Confirm `devtools` is installed: `Rscript -e 'packageVersion("devtools")'`
- [ ] Confirm roxygen2 and testthat are installed
- [ ] Read `specs/2026-04-21-pd-el-integration-design.md` in full
- [ ] Read `specs/plans/2026-04-21-pd-el-integration-plan.md` in full
- [ ] Open the Santa Method skill: `Skill: everything-claude-code:santa-method`
- [ ] Open the subagent-driven-development skill: `Skill: superpowers:subagent-driven-development`
- [ ] Begin Task 1: "Add color constants to imports.R"
