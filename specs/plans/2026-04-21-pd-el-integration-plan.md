# PD and EL Integration Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Port the three PD and two EL integration methods from `trisk.r.docker/app/modules/mod_integration.R` into reusable `trisk.analysis` library functions, add EAD-weighted portfolio aggregates, build static ggplot visualizations following the `pipeline_crispy_*` convention, and ship a workflow vignette using only bundled package testdata.

**Architecture:** Two new public functions (`integrate_pd`, `integrate_el`) each returning a list (`$portfolio` wide, `$portfolio_long` pivot-longer for plots, `$aggregate` one-row tibble). Two aggregate helpers (`aggregate_pd_integration`, `aggregate_el_integration`). Five visualization functions: four direct ports of Shiny visuals (P1 4-bar PD, P2 horizontal EL sign-bars, P3a/P3b kableExtra KPI tables, P4 kableExtra sector breakdown) plus one novel method-comparison plot (N1). Waterfall (N2) is conditional on N1 shipping cleanly.

**Tech Stack:** R 4.1+, tidyverse (`dplyr`, `tidyr`, `rlang`), ggplot2, scales, kableExtra, testthat (new dep). No new runtime dependencies beyond those already in DESCRIPTION except kableExtra (already used in vignettes, needs to be declared).

**Spec reference:** `specs/2026-04-21-pd-el-integration-design.md`

**Working directory:** `~/Documents/repos/trisk.analysis/`

---

## File map

| File | Status | Responsibility |
|---|---|---|
| `R/imports.R` | MODIFY | Add `TRISK_HEX_ADJUSTED`, `STATUS_GREEN` color constants |
| `DESCRIPTION` | MODIFY | Add `kableExtra` to Imports, add `testthat` to Suggests |
| `R/integrate.R` | CREATE | `integrate_pd`, `integrate_el`, `resolve_internal_series`, `apply_pd_method`, `apply_el_method`, `aggregate_pd_integration`, `aggregate_el_integration` |
| `R/plot_pd_integration.R` | CREATE | P1: `pipeline_crispy_pd_integration_bars` + `prepare_for_pd_integration_plot` + `draw_pd_integration_plot` |
| `R/plot_el_adjustment.R` | CREATE | P2: `pipeline_crispy_el_adjustment_bars` + `prepare_for_el_adjustment_plot` + `draw_el_adjustment_plot` |
| `R/plot_integration_kpi_table.R` | CREATE | P3a `pipeline_crispy_pd_kpi_table`, P3b `pipeline_crispy_el_kpi_table`, P4 `pipeline_crispy_el_sector_breakdown_table` |
| `R/plot_pd_method_comparison.R` | CREATE | N1: `pipeline_crispy_pd_method_comparison` + helpers |
| `R/plot_pd_waterfall.R` | CONDITIONAL | N2: only if N1 ships cleanly |
| `tests/testthat.R` | CREATE | testthat entry point |
| `tests/testthat/helper-fixtures.R` | CREATE | Synthetic 3-row `analysis_data` fixture used across tests |
| `tests/testthat/test-integrate-pd.R` | CREATE | Tests for `integrate_pd` (9 method-mode combos + edge cases) |
| `tests/testthat/test-integrate-el.R` | CREATE | Tests for `integrate_el` |
| `tests/testthat/test-aggregate.R` | CREATE | Tests for both aggregate functions |
| `tests/testthat/test-plots.R` | CREATE | Smoke tests: each plot returns expected class |
| `vignettes/pd-el-integration.Rmd` | CREATE | 12-section workflow vignette |
| `NAMESPACE` | REGENERATED | Via `devtools::document()` |

---

## Task 1: Add color constants to imports.R

**Files:**
- Modify: `R/imports.R` — append two constants after existing `TRISK_HEX_GREY` line

- [ ] **Step 1: Read current imports.R to find insertion point**

Run:
```bash
grep -n "TRISK_HEX_GREY" R/imports.R
```
Expected: `23:TRISK_HEX_GREY <- "#BAB6B5"`

- [ ] **Step 2: Append the two constants after line 23**

Edit `R/imports.R`, replace:
```r
TRISK_HEX_GREY <- "#BAB6B5"
TRISK_PLOT_THEME_FUNC <- function(
```
with:
```r
TRISK_HEX_GREY <- "#BAB6B5"
TRISK_HEX_ADJUSTED <- "#AA2A2B"  # Dark-red blend of TRISK_HEX_RED; for "adjusted PD/EL" role
STATUS_GREEN <- "#3D8B5E"        # Muted green from trisk.r.docker/global.R; for positive/better-off fills

TRISK_PLOT_THEME_FUNC <- function(
```

- [ ] **Step 3: Commit**

```bash
git add R/imports.R
git commit -m "feat: add TRISK_HEX_ADJUSTED and STATUS_GREEN color constants"
```

---

## Task 2: Declare new package dependencies in DESCRIPTION

**Files:**
- Modify: `DESCRIPTION`

- [ ] **Step 1: Add kableExtra to Imports and testthat to Suggests**

Edit `DESCRIPTION`. Find the `Imports:` block (currently contains dplyr, magrittr, rlang, tibble, uuid, trisk.model, ggplot2, scales, stringdist, tidyr, DBI, RPostgres) and add `kableExtra` alphabetically:

```
Imports: 
    dplyr,
    DBI,
    ggplot2,
    kableExtra,
    magrittr,
    rlang,
    RPostgres,
    scales,
    stringdist,
    tibble,
    tidyr,
    trisk.model,
    uuid
```

After the Imports block and before `Remotes:`, add:
```
Suggests:
    testthat (>= 3.0.0),
    knitr,
    rmarkdown
Config/testthat/edition: 3
```

- [ ] **Step 2: Commit**

```bash
git add DESCRIPTION
git commit -m "build: declare kableExtra import and testthat suggests"
```

---

## Task 3: Set up testthat scaffolding

**Files:**
- Create: `tests/testthat.R`
- Create: `tests/testthat/helper-fixtures.R`

- [ ] **Step 1: Create tests/testthat.R entry point**

Create `tests/testthat.R` with:
```r
library(testthat)
library(trisk.analysis)

test_check("trisk.analysis")
```

- [ ] **Step 2: Create helper-fixtures.R with the shared synthetic fixture**

Create `tests/testthat/helper-fixtures.R` with:
```r
# Synthetic 3-row analysis_data fixture for integration tests.
# Values chosen so that:
#   - company A has pd_baseline = 0 (triggers zero-baseline quirks)
#   - company B has a standard shock (baseline 2%, shock 6%)
#   - company C has a small shock (baseline 1%, shock 1.5%)
make_test_analysis_data <- function() {
  tibble::tibble(
    company_id               = c("A", "B", "C"),
    company_name             = c("Alpha", "Beta", "Gamma"),
    sector                   = c("Coal", "Power", "Power"),
    technology               = c("Coal", "CoalCap", "RenewablesCap"),
    country_iso2             = c("MN", "MN", "MN"),
    term                     = c(1L, 1L, 1L),
    exposure_value_usd       = c(100, 200, 300),
    loss_given_default       = c(0.4, 0.4, 0.4),
    pd_baseline              = c(0.00, 0.02, 0.01),
    pd_shock                 = c(0.05, 0.06, 0.015),
    expected_loss_baseline   = c(0,   1.6, 1.2),
    expected_loss_shock      = c(2.0, 4.8, 1.8)
  )
}
```

- [ ] **Step 3: Run testthat once to confirm zero tests pass**

Run:
```bash
Rscript -e 'devtools::test(filter = NULL)'
```
Expected: `[ FAIL 0 | WARN 0 | SKIP 0 | PASS 0 ]`. Any error means testthat scaffold is broken — fix before proceeding.

- [ ] **Step 4: Commit**

```bash
git add tests/
git commit -m "test: scaffold testthat with shared 3-row fixture"
```

---

## Task 4: Write failing test for integrate_pd() absolute method

**Files:**
- Create: `tests/testthat/test-integrate-pd.R`

- [ ] **Step 1: Write the failing test**

Create `tests/testthat/test-integrate-pd.R` with:
```r
test_that("integrate_pd absolute method computes additive shift", {
  df <- make_test_analysis_data()
  result <- integrate_pd(df, method = "absolute")

  expect_type(result, "list")
  expect_named(result, c("portfolio", "portfolio_long", "aggregate"))
  expect_s3_class(result$portfolio, "data.frame")
  expect_equal(nrow(result$portfolio), nrow(df))

  # Absolute: adjusted = internal + (shock - baseline)
  # internal defaults to pd_baseline when NULL
  # Row A: internal=0.00, shock-baseline=0.05 => adjusted=0.05
  # Row B: internal=0.02, shock-baseline=0.04 => adjusted=0.06
  # Row C: internal=0.01, shock-baseline=0.005 => adjusted=0.015
  expect_equal(result$portfolio$trisk_adjusted_pd, c(0.05, 0.06, 0.015))
  expect_equal(result$portfolio$pd_change, c(0.05, 0.04, 0.005))
  expect_equal(result$portfolio$pd_adjustment,
               result$portfolio$trisk_adjusted_pd - result$portfolio$internal_pd)
})
```

- [ ] **Step 2: Run to confirm failure**

Run:
```bash
Rscript -e 'devtools::test(filter = "integrate-pd")'
```
Expected: FAIL with "could not find function 'integrate_pd'".

---

## Task 5: Implement integrate_pd() with absolute method

**Files:**
- Create: `R/integrate.R`

- [ ] **Step 1: Create the minimal file to make the first test pass**

Create `R/integrate.R` with:
```r
#' Integrate TRISK PD shift into an internal PD estimate
#'
#' Applies one of three methods to translate the TRISK baseline-to-shock PD
#' change into the bank's own internal PD scale. Mirrors the logic in the
#' trisk.r.docker Shiny integration module.
#'
#' @param analysis_data Data frame from [run_trisk_on_portfolio()]; must contain
#'   columns `pd_baseline`, `pd_shock`.
#' @param internal_pd Either (a) a numeric vector of length `nrow(analysis_data)`,
#'   (b) a data frame with `company_id` and `internal_pd` columns, or (c) NULL
#'   (default) in which case `pd_baseline` is used.
#' @param method One of "absolute", "relative", "zscore". Default "absolute".
#' @param zscore_floor Lower clip bound for PDs before `qnorm()` in the zscore
#'   method. Default 1e-4.
#' @param zscore_cap Upper clip bound. Default 1 - 1e-4.
#'
#' @return A list with three elements:
#' \describe{
#'   \item{portfolio}{`analysis_data` with columns added: `internal_pd`,
#'     `pd_change`, `pd_change_pct`, `trisk_adjusted_pd`, `pd_adjustment`.}
#'   \item{portfolio_long}{Pivot-longer helper for plotting.}
#'   \item{aggregate}{One-row tibble of EAD-weighted portfolio metrics.}
#' }
#' @export
integrate_pd <- function(analysis_data,
                         internal_pd = NULL,
                         method = c("absolute", "relative", "zscore"),
                         zscore_floor = 1e-4,
                         zscore_cap = 1 - 1e-4) {
  method <- match.arg(method)

  if (zscore_floor >= zscore_cap) {
    stop("integrate_pd(): zscore_floor must be strictly less than zscore_cap (got ",
         zscore_floor, " vs ", zscore_cap, ")")
  }

  required_cols <- c("pd_baseline", "pd_shock")
  missing_cols <- setdiff(required_cols, colnames(analysis_data))
  if (length(missing_cols) > 0) {
    stop("integrate_pd(): missing required columns in analysis_data: ",
         paste(missing_cols, collapse = ", "))
  }

  internal_vec <- resolve_internal_series(analysis_data, internal_pd, "pd_baseline")
  if (all(is.na(internal_vec))) {
    stop("integrate_pd(): all resolved internal PD values are NA.")
  }

  pd_baseline <- analysis_data$pd_baseline
  pd_shock <- analysis_data$pd_shock
  pd_change <- pd_shock - pd_baseline
  pd_change_pct <- ifelse(pd_baseline != 0, pd_change / pd_baseline, 0)

  adjusted <- apply_pd_method(internal_vec, pd_baseline, pd_shock,
                              method, zscore_floor, zscore_cap)
  adjusted <- pmin(pmax(adjusted, 0), 1)

  portfolio <- analysis_data |>
    dplyr::mutate(
      internal_pd        = internal_vec,
      pd_change          = pd_change,
      pd_change_pct      = pd_change_pct,
      trisk_adjusted_pd  = adjusted,
      pd_adjustment      = adjusted - internal_vec
    )

  list(
    portfolio = portfolio,
    portfolio_long = NULL,    # wired up in later task
    aggregate = NULL          # wired up in later task
  )
}

# Internal — resolve the internal PD/EL series from vector, df, or NULL input.
resolve_internal_series <- function(analysis_data, user_values, default_col) {
  n <- nrow(analysis_data)
  default_vec <- analysis_data[[default_col]]

  if (is.null(user_values)) {
    return(default_vec)
  }

  if (is.numeric(user_values)) {
    if (length(user_values) != n) {
      stop("resolve_internal_series(): vector length ", length(user_values),
           " does not match nrow(analysis_data) = ", n)
    }
    return(user_values)
  }

  if (is.data.frame(user_values)) {
    val_col <- setdiff(colnames(user_values), "company_id")
    if (!"company_id" %in% colnames(user_values) || length(val_col) == 0) {
      stop("resolve_internal_series(): dataframe must have 'company_id' and one value column.")
    }
    val_col <- val_col[1]
    out <- default_vec
    idx <- match(as.character(analysis_data$company_id),
                 as.character(user_values$company_id))
    out[!is.na(idx)] <- user_values[[val_col]][idx[!is.na(idx)]]
    return(out)
  }

  stop("resolve_internal_series(): user_values must be NULL, numeric vector, or data frame.")
}

# Internal — pure vector math for the three PD methods. Shiny-parity.
apply_pd_method <- function(internal, baseline, shock, method,
                            zscore_floor, zscore_cap) {
  switch(method,
    absolute = internal + (shock - baseline),
    relative = {
      change_pct <- ifelse(baseline != 0, (shock - baseline) / baseline, 0)
      internal * (1 + change_pct)
    },
    zscore = {
      clip <- function(x) pmin(pmax(x, zscore_floor), zscore_cap)
      z_internal <- stats::qnorm(clip(internal))
      z_baseline <- stats::qnorm(clip(baseline))
      z_shock    <- stats::qnorm(clip(shock))
      stats::pnorm(z_internal + z_shock - z_baseline)
    }
  )
}
```

- [ ] **Step 2: Run devtools::document() to regenerate NAMESPACE**

Run:
```bash
Rscript -e 'devtools::document()'
```
Expected: output includes `integrate_pd` added to NAMESPACE.

- [ ] **Step 3: Run test to verify it passes**

Run:
```bash
Rscript -e 'devtools::test(filter = "integrate-pd")'
```
Expected: `[ FAIL 0 | WARN 0 | SKIP 0 | PASS 1 ]`.

- [ ] **Step 4: Commit**

```bash
git add R/integrate.R NAMESPACE tests/testthat/test-integrate-pd.R
git commit -m "feat: integrate_pd absolute method with resolve/apply helpers"
```

---

## Task 6: Add failing test + implementation for relative method

**Files:**
- Modify: `tests/testthat/test-integrate-pd.R`

- [ ] **Step 1: Add the relative-method test**

Append to `tests/testthat/test-integrate-pd.R`:
```r
test_that("integrate_pd relative method scales internal PD by percent change", {
  df <- make_test_analysis_data()
  result <- integrate_pd(df, method = "relative")

  # Relative: adjusted = internal * (1 + pd_change_pct)
  # Row A: baseline=0, pd_change_pct=0, adjusted=internal=0
  # Row B: internal=0.02, change_pct=(0.06-0.02)/0.02=2.0, adjusted=0.02*3=0.06
  # Row C: internal=0.01, change_pct=0.5, adjusted=0.015
  expect_equal(result$portfolio$trisk_adjusted_pd, c(0.00, 0.06, 0.015))
})

test_that("integrate_pd relative method preserves internal when pd_baseline is 0", {
  # Documented Shiny-parity quirk: shock signal lost on zero-baseline rows
  df <- make_test_analysis_data()
  internal <- c(0.03, 0.03, 0.03)
  result <- integrate_pd(df, internal_pd = internal, method = "relative")

  # Row A baseline=0 => change_pct=0 => adjusted = internal = 0.03
  expect_equal(result$portfolio$trisk_adjusted_pd[1], 0.03)
  # Rows B, C still get the scaling
  expect_equal(result$portfolio$trisk_adjusted_pd[2], 0.03 * (1 + 2.0))
  expect_equal(result$portfolio$trisk_adjusted_pd[3], 0.03 * (1 + 0.5))
})
```

- [ ] **Step 2: Run — tests should already pass because apply_pd_method handles all three methods**

Run:
```bash
Rscript -e 'devtools::test(filter = "integrate-pd")'
```
Expected: `[ FAIL 0 | WARN 0 | SKIP 0 | PASS 3 ]`. If any fail, investigate before committing.

- [ ] **Step 3: Commit**

```bash
git add tests/testthat/test-integrate-pd.R
git commit -m "test: relative method math + zero-baseline quirk"
```

---

## Task 7: Add failing test + verify zscore method

**Files:**
- Modify: `tests/testthat/test-integrate-pd.R`

- [ ] **Step 1: Add zscore-method tests**

Append:
```r
test_that("integrate_pd zscore method uses Vasicek combination", {
  df <- make_test_analysis_data()
  internal <- c(0.01, 0.02, 0.01)
  result <- integrate_pd(df, internal_pd = internal, method = "zscore")

  # Manual computation for row B: baseline=0.02, shock=0.06, internal=0.02
  # z_int=qnorm(0.02), z_base=qnorm(0.02), z_shock=qnorm(0.06)
  # adjusted = pnorm(z_int + z_shock - z_base) = pnorm(z_shock) = 0.06
  expect_equal(result$portfolio$trisk_adjusted_pd[2], 0.06, tolerance = 1e-9)

  # All rows must be in [0, 1]
  expect_true(all(result$portfolio$trisk_adjusted_pd >= 0))
  expect_true(all(result$portfolio$trisk_adjusted_pd <= 1))
})

test_that("integrate_pd zscore clips pd_baseline = 0 to zscore_floor", {
  df <- make_test_analysis_data()
  result <- integrate_pd(df, method = "zscore", zscore_floor = 1e-4)

  # pd_baseline = 0 clips to 1e-4 -> qnorm stays finite
  expect_true(is.finite(result$portfolio$trisk_adjusted_pd[1]))
})
```

- [ ] **Step 2: Run**

Run:
```bash
Rscript -e 'devtools::test(filter = "integrate-pd")'
```
Expected: `[ FAIL 0 | WARN 0 | SKIP 0 | PASS 5 ]`.

- [ ] **Step 3: Commit**

```bash
git add tests/testthat/test-integrate-pd.R
git commit -m "test: zscore method math and floor clipping"
```

---

## Task 8: Add tests for internal_pd resolution modes

**Files:**
- Modify: `tests/testthat/test-integrate-pd.R`

- [ ] **Step 1: Append resolution tests**

```r
test_that("integrate_pd accepts numeric vector internal_pd", {
  df <- make_test_analysis_data()
  result <- integrate_pd(df, internal_pd = c(0.05, 0.05, 0.05), method = "absolute")
  expect_equal(result$portfolio$internal_pd, c(0.05, 0.05, 0.05))
})

test_that("integrate_pd accepts data frame internal_pd matched by company_id", {
  df <- make_test_analysis_data()
  pd_df <- tibble::tibble(company_id = c("B", "A"),
                          internal_pd = c(0.10, 0.20))
  result <- integrate_pd(df, internal_pd = pd_df, method = "absolute")

  # A matches 0.20, B matches 0.10, C unmatched -> fallback to pd_baseline (0.01)
  expect_equal(result$portfolio$internal_pd, c(0.20, 0.10, 0.01))
})

test_that("integrate_pd errors on length-mismatched vector", {
  df <- make_test_analysis_data()
  expect_error(
    integrate_pd(df, internal_pd = c(0.05, 0.05), method = "absolute"),
    "does not match nrow"
  )
})

test_that("integrate_pd errors on invalid method string", {
  df <- make_test_analysis_data()
  expect_error(integrate_pd(df, method = "zzz"))
})

test_that("integrate_pd errors when required columns missing", {
  df <- make_test_analysis_data()
  df$pd_baseline <- NULL
  expect_error(integrate_pd(df, method = "absolute"), "missing required columns")
})

test_that("integrate_pd errors on dataframe internal_pd without company_id", {
  df <- make_test_analysis_data()
  bad_df <- tibble::tibble(foo = c("A", "B", "C"), internal_pd = c(0.01, 0.02, 0.03))
  expect_error(integrate_pd(df, internal_pd = bad_df, method = "absolute"),
               "company_id")
})

test_that("integrate_pd errors when zscore_floor >= zscore_cap", {
  df <- make_test_analysis_data()
  expect_error(integrate_pd(df, method = "zscore",
                            zscore_floor = 0.5, zscore_cap = 0.4),
               "strictly less than")
})

test_that("integrate_pd errors when resolved internal_pd is all NA", {
  df <- make_test_analysis_data()
  expect_error(integrate_pd(df, internal_pd = c(NA_real_, NA_real_, NA_real_),
                            method = "absolute"),
               "all resolved internal PD values are NA")
})
```

- [ ] **Step 2: Run**

Run:
```bash
Rscript -e 'devtools::test(filter = "integrate-pd")'
```
Expected: `[ FAIL 0 | WARN 0 | SKIP 0 | PASS 13 ]`.

- [ ] **Step 3: Commit**

```bash
git add tests/testthat/test-integrate-pd.R
git commit -m "test: internal_pd resolution modes and argument validation"
```

---

## Task 9: Wire up portfolio_long output

**Files:**
- Modify: `R/integrate.R`
- Modify: `tests/testthat/test-integrate-pd.R`

- [ ] **Step 1: Add test for portfolio_long shape**

Append to test file:
```r
test_that("integrate_pd portfolio_long has correct shape and pd_type factor", {
  df <- make_test_analysis_data()
  result <- integrate_pd(df, method = "absolute")

  expect_s3_class(result$portfolio_long, "data.frame")
  # Four pd_types (internal, baseline, shock, trisk_adjusted) x 3 rows = 12
  expect_equal(nrow(result$portfolio_long), 12)
  expect_setequal(levels(result$portfolio_long$pd_type),
                  c("internal", "baseline", "shock", "trisk_adjusted"))
  expect_true("pd_value" %in% colnames(result$portfolio_long))
})
```

- [ ] **Step 2: Run — expect failure (portfolio_long is NULL)**

Run:
```bash
Rscript -e 'devtools::test(filter = "integrate-pd")'
```
Expected: 1 FAIL.

- [ ] **Step 3: Implement portfolio_long in integrate_pd()**

In `R/integrate.R`, replace `portfolio_long = NULL,` in the returned list with a call to a new internal helper. Insert before the final `list(...)`:

```r
  portfolio_long <- portfolio |>
    tidyr::pivot_longer(
      cols = dplyr::all_of(c("internal_pd", "pd_baseline", "pd_shock", "trisk_adjusted_pd")),
      names_to = "pd_type_raw",
      values_to = "pd_value"
    ) |>
    dplyr::mutate(
      pd_type = factor(
        dplyr::recode(.data$pd_type_raw,
          internal_pd       = "internal",
          pd_baseline       = "baseline",
          pd_shock          = "shock",
          trisk_adjusted_pd = "trisk_adjusted"
        ),
        levels = c("internal", "baseline", "shock", "trisk_adjusted")
      )
    ) |>
    dplyr::select(-"pd_type_raw")
```

Then replace:
```r
  list(
    portfolio = portfolio,
    portfolio_long = NULL,    # wired up in later task
    aggregate = NULL          # wired up in later task
  )
```
with:
```r
  list(
    portfolio = portfolio,
    portfolio_long = portfolio_long,
    aggregate = NULL          # wired up in later task
  )
```

- [ ] **Step 4: Run**

Run:
```bash
Rscript -e 'devtools::test(filter = "integrate-pd")'
```
Expected: `[ FAIL 0 | WARN 0 | SKIP 0 | PASS 14 ]`.

- [ ] **Step 5: Commit**

```bash
git add R/integrate.R tests/testthat/test-integrate-pd.R
git commit -m "feat: integrate_pd returns portfolio_long pivot-longer output"
```

---

## Task 10: Implement aggregate_pd_integration()

**Files:**
- Create: `tests/testthat/test-aggregate.R`
- Modify: `R/integrate.R`

- [ ] **Step 1: Write failing test**

Create `tests/testthat/test-aggregate.R`:
```r
test_that("aggregate_pd_integration returns EAD-weighted portfolio metrics", {
  df <- make_test_analysis_data()
  integrated <- integrate_pd(df, method = "absolute")
  agg <- aggregate_pd_integration(integrated$portfolio)

  expect_s3_class(agg, "data.frame")
  expect_equal(nrow(agg), 1)
  expect_true(all(c("total_exposure_usd",
                    "weighted_pd_internal",
                    "weighted_pd_baseline",
                    "weighted_pd_shock",
                    "weighted_pd_adjusted",
                    "weighted_pd_adjustment",
                    "weighted_pd_adjustment_pct") %in% colnames(agg)))

  # Total exposure = 100 + 200 + 300 = 600
  expect_equal(agg$total_exposure_usd, 600)

  # Weighted internal PD = (0*100 + 0.02*200 + 0.01*300) / 600 = 7/600
  expect_equal(agg$weighted_pd_internal, (0 * 100 + 0.02 * 200 + 0.01 * 300) / 600)

  # Weighted adjusted PD = (0.05*100 + 0.06*200 + 0.015*300) / 600 = 21.5/600
  expect_equal(agg$weighted_pd_adjusted, (0.05 * 100 + 0.06 * 200 + 0.015 * 300) / 600)
})

test_that("aggregate_pd_integration supports group_cols for sector rollup", {
  df <- make_test_analysis_data()
  integrated <- integrate_pd(df, method = "absolute")
  agg <- aggregate_pd_integration(integrated$portfolio, group_cols = "sector")

  expect_equal(nrow(agg), 2)  # Coal + Power
  expect_true("sector" %in% colnames(agg))
})

test_that("aggregate_pd_integration errors if required columns missing", {
  df <- make_test_analysis_data()
  expect_error(aggregate_pd_integration(df),  # raw df has no internal_pd
               "required columns")
})
```

- [ ] **Step 2: Run — expect failure**

Run:
```bash
Rscript -e 'devtools::test(filter = "aggregate")'
```
Expected: 3 FAIL ("could not find function 'aggregate_pd_integration'").

- [ ] **Step 3: Append function to R/integrate.R**

```r
#' Aggregate PD integration results to EAD-weighted portfolio level
#'
#' @param portfolio_df The `$portfolio` element from [integrate_pd()], containing
#'   `internal_pd`, `pd_baseline`, `pd_shock`, `trisk_adjusted_pd`,
#'   `exposure_value_usd`.
#' @param group_cols Character vector of columns to group by. NULL (default) produces
#'   a single-row portfolio total. Pass e.g. "sector" for a sector rollup.
#'
#' @return A one-row tibble (per group) with EAD-weighted PD metrics.
#' @export
aggregate_pd_integration <- function(portfolio_df, group_cols = NULL) {
  required <- c("internal_pd", "pd_baseline", "pd_shock",
                "trisk_adjusted_pd", "exposure_value_usd")
  missing_cols <- setdiff(required, colnames(portfolio_df))
  if (length(missing_cols) > 0) {
    stop("aggregate_pd_integration(): missing required columns: ",
         paste(missing_cols, collapse = ", "))
  }

  grouped <- if (is.null(group_cols)) {
    portfolio_df |> dplyr::mutate(.dummy = 1L) |> dplyr::group_by(.data$.dummy)
  } else {
    portfolio_df |> dplyr::group_by_at(group_cols)
  }

  agg <- grouped |>
    dplyr::summarise(
      total_exposure_usd     = sum(.data$exposure_value_usd, na.rm = TRUE),
      weighted_pd_internal   = sum(.data$internal_pd       * .data$exposure_value_usd, na.rm = TRUE) / .data$total_exposure_usd,
      weighted_pd_baseline   = sum(.data$pd_baseline       * .data$exposure_value_usd, na.rm = TRUE) / .data$total_exposure_usd,
      weighted_pd_shock      = sum(.data$pd_shock          * .data$exposure_value_usd, na.rm = TRUE) / .data$total_exposure_usd,
      weighted_pd_adjusted   = sum(.data$trisk_adjusted_pd * .data$exposure_value_usd, na.rm = TRUE) / .data$total_exposure_usd,
      .groups = "drop"
    ) |>
    dplyr::mutate(
      weighted_pd_adjustment     = .data$weighted_pd_adjusted - .data$weighted_pd_internal,
      weighted_pd_adjustment_pct = ifelse(.data$weighted_pd_internal != 0,
                                          .data$weighted_pd_adjustment / .data$weighted_pd_internal,
                                          NA_real_)
    )

  if (is.null(group_cols)) {
    agg <- agg |> dplyr::select(-dplyr::any_of(".dummy"))
  }

  tibble::as_tibble(agg)
}
```

Also update `integrate_pd()` to call this: replace `aggregate = NULL` in the final list with `aggregate = aggregate_pd_integration(portfolio)`.

- [ ] **Step 4: Document and run**

Run:
```bash
Rscript -e 'devtools::document()'
Rscript -e 'devtools::test(filter = "aggregate")'
Rscript -e 'devtools::test(filter = "integrate-pd")'
```
Expected: all green.

- [ ] **Step 5: Commit**

```bash
git add R/integrate.R tests/testthat/test-aggregate.R NAMESPACE
git commit -m "feat: aggregate_pd_integration with optional sector rollup"
```

---

## Task 11: Implement integrate_el() and aggregate_el_integration()

**Files:**
- Create: `tests/testthat/test-integrate-el.R`
- Modify: `R/integrate.R`
- Modify: `tests/testthat/test-aggregate.R`

- [ ] **Step 1: Write failing tests for integrate_el**

Create `tests/testthat/test-integrate-el.R`:
```r
test_that("integrate_el absolute method computes additive EL shift", {
  df <- make_test_analysis_data()
  result <- integrate_el(df, method = "absolute")

  expect_type(result, "list")
  expect_named(result, c("portfolio", "portfolio_long", "aggregate"))
  # Absolute: adjusted = internal + (shock - baseline)
  # internal defaults to expected_loss_baseline
  # Row A: internal=0, shock-baseline=2, adjusted=2
  # Row B: internal=1.6, shock-baseline=3.2, adjusted=4.8
  # Row C: internal=1.2, shock-baseline=0.6, adjusted=1.8
  expect_equal(result$portfolio$trisk_adjusted_el, c(2.0, 4.8, 1.8))
})

test_that("integrate_el relative method scales by percent change", {
  df <- make_test_analysis_data()
  internal <- c(0.5, 2.0, 1.0)
  result <- integrate_el(df, internal_el = internal, method = "relative")

  # Row A: el_base=0, pct=0, adjusted=internal=0.5
  # Row B: el_base=1.6, pct=(4.8-1.6)/1.6=2.0, adjusted=2.0*3=6.0
  # Row C: el_base=1.2, pct=(1.8-1.2)/1.2=0.5, adjusted=1.0*1.5=1.5
  expect_equal(result$portfolio$trisk_adjusted_el, c(0.5, 6.0, 1.5))
})

test_that("integrate_el errors on unknown method", {
  df <- make_test_analysis_data()
  expect_error(integrate_el(df, method = "zscore"))
})
```

- [ ] **Step 2: Run — expect failure**

Run:
```bash
Rscript -e 'devtools::test(filter = "integrate-el")'
```
Expected: FAIL.

- [ ] **Step 3: Append integrate_el + apply_el_method + aggregate_el_integration to R/integrate.R**

```r
#' Integrate TRISK EL shift into an internal EL estimate
#'
#' Applies one of two methods to translate the TRISK baseline-to-shock EL change
#' into the bank's own internal EL scale. Mirrors the Shiny EL integration logic.
#'
#' @param analysis_data Data frame from [run_trisk_on_portfolio()]; must contain
#'   columns `expected_loss_baseline`, `expected_loss_shock`.
#' @param internal_el Numeric vector of length `nrow(analysis_data)`, or a data
#'   frame with `company_id` + `internal_el` columns, or NULL (default) which
#'   uses `expected_loss_baseline`.
#' @param method One of "absolute", "relative". Default "absolute".
#'
#' @return List with `$portfolio`, `$portfolio_long`, `$aggregate`.
#' @export
integrate_el <- function(analysis_data,
                         internal_el = NULL,
                         method = c("absolute", "relative")) {
  method <- match.arg(method)

  required_cols <- c("expected_loss_baseline", "expected_loss_shock")
  missing_cols <- setdiff(required_cols, colnames(analysis_data))
  if (length(missing_cols) > 0) {
    stop("integrate_el(): missing required columns: ",
         paste(missing_cols, collapse = ", "))
  }

  internal_vec <- resolve_internal_series(analysis_data, internal_el,
                                          "expected_loss_baseline")

  el_baseline <- analysis_data$expected_loss_baseline
  el_shock <- analysis_data$expected_loss_shock
  el_change <- el_shock - el_baseline
  el_change_pct <- ifelse(el_baseline != 0, el_change / el_baseline, 0)

  adjusted <- apply_el_method(internal_vec, el_baseline, el_shock, method)

  portfolio <- analysis_data |>
    dplyr::mutate(
      internal_el        = internal_vec,
      el_change          = el_change,
      el_change_pct      = el_change_pct,
      trisk_adjusted_el  = adjusted,
      el_adjustment      = adjusted - internal_vec
    )

  portfolio_long <- portfolio |>
    tidyr::pivot_longer(
      cols = dplyr::all_of(c("internal_el", "expected_loss_baseline",
                             "expected_loss_shock", "trisk_adjusted_el")),
      names_to = "el_type_raw",
      values_to = "el_value"
    ) |>
    dplyr::mutate(
      el_type = factor(
        dplyr::recode(.data$el_type_raw,
          internal_el            = "internal",
          expected_loss_baseline = "baseline",
          expected_loss_shock    = "shock",
          trisk_adjusted_el      = "trisk_adjusted"
        ),
        levels = c("internal", "baseline", "shock", "trisk_adjusted")
      )
    ) |>
    dplyr::select(-"el_type_raw")

  list(
    portfolio = portfolio,
    portfolio_long = portfolio_long,
    aggregate = aggregate_el_integration(portfolio)
  )
}

apply_el_method <- function(internal, baseline, shock, method) {
  switch(method,
    absolute = internal + (shock - baseline),
    relative = {
      change_pct <- ifelse(baseline != 0, (shock - baseline) / baseline, 0)
      internal * (1 + change_pct)
    }
  )
}

#' Aggregate EL integration results to portfolio level
#'
#' @param portfolio_df The `$portfolio` element from [integrate_el()].
#' @param group_cols Character vector or NULL. NULL = portfolio total.
#' @return A one-row tibble (per group) with total ELs + `el_adjusted_bps`.
#' @export
aggregate_el_integration <- function(portfolio_df, group_cols = NULL) {
  required <- c("internal_el", "expected_loss_baseline", "expected_loss_shock",
                "trisk_adjusted_el", "exposure_value_usd")
  missing_cols <- setdiff(required, colnames(portfolio_df))
  if (length(missing_cols) > 0) {
    stop("aggregate_el_integration(): missing required columns: ",
         paste(missing_cols, collapse = ", "))
  }

  grouped <- if (is.null(group_cols)) {
    portfolio_df |> dplyr::mutate(.dummy = 1L) |> dplyr::group_by(.data$.dummy)
  } else {
    portfolio_df |> dplyr::group_by_at(group_cols)
  }

  agg <- grouped |>
    dplyr::summarise(
      total_exposure_usd = sum(.data$exposure_value_usd, na.rm = TRUE),
      total_el_internal  = sum(.data$internal_el, na.rm = TRUE),
      total_el_baseline  = sum(.data$expected_loss_baseline, na.rm = TRUE),
      total_el_shock     = sum(.data$expected_loss_shock, na.rm = TRUE),
      total_el_adjusted  = sum(.data$trisk_adjusted_el, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      total_el_adjustment = .data$total_el_adjusted - .data$total_el_internal,
      el_adjusted_bps     = ifelse(.data$total_exposure_usd > 0,
                                   abs(.data$total_el_adjusted) / .data$total_exposure_usd * 10000,
                                   NA_real_)
    )

  if (is.null(group_cols)) {
    agg <- agg |> dplyr::select(-dplyr::any_of(".dummy"))
  }

  tibble::as_tibble(agg)
}
```

- [ ] **Step 4: Add EL aggregate test**

Append to `tests/testthat/test-aggregate.R`:
```r
test_that("aggregate_el_integration sums correctly with bps", {
  df <- make_test_analysis_data()
  integrated <- integrate_el(df, method = "absolute")
  agg <- aggregate_el_integration(integrated$portfolio)

  expect_equal(agg$total_exposure_usd, 600)
  expect_equal(agg$total_el_internal, 0 + 1.6 + 1.2)
  expect_equal(agg$total_el_adjusted, 2.0 + 4.8 + 1.8)
  # bps = abs(8.6) / 600 * 10000 = 143.33...
  expect_equal(agg$el_adjusted_bps, abs(8.6) / 600 * 10000)
})
```

- [ ] **Step 5: Document and run**

Run:
```bash
Rscript -e 'devtools::document()'
Rscript -e 'devtools::test()'
```
Expected: all green across test-integrate-pd, test-integrate-el, test-aggregate.

- [ ] **Step 6: Commit**

```bash
git add R/integrate.R tests/testthat/test-integrate-el.R tests/testthat/test-aggregate.R NAMESPACE
git commit -m "feat: integrate_el and aggregate_el_integration"
```

---

## Task 12: Implement P1 — `pipeline_crispy_pd_integration_bars`

**Files:**
- Create: `tests/testthat/test-plots.R`
- Create: `R/plot_pd_integration.R`

- [ ] **Step 1: Write smoke test**

Create `tests/testthat/test-plots.R`:
```r
test_that("pipeline_crispy_pd_integration_bars returns a ggplot", {
  df <- make_test_analysis_data()
  integrated <- integrate_pd(df, method = "absolute")
  p <- pipeline_crispy_pd_integration_bars(integrated)
  expect_s3_class(p, "ggplot")
})
```

- [ ] **Step 2: Run — expect failure**

Run:
```bash
Rscript -e 'devtools::test(filter = "plots")'
```
Expected: FAIL.

- [ ] **Step 3: Create R/plot_pd_integration.R**

```r
#' PD Integration Bar Plot (4-bar grouped)
#'
#' For each sector facet, draws four bars: Internal PD (grey), TRISK Baseline
#' (green), TRISK Shock (red), TRISK-Adjusted PD (dark-red). Extends the
#' `mod_results_summary.R` PD-by-sector pattern from 2 bars to 4.
#'
#' @param integration_result Output of [integrate_pd()] (a list with
#'   `$portfolio_long`).
#' @param facet_var Column used for facets. Default "sector".
#' @return A ggplot2 object.
#' @export
pipeline_crispy_pd_integration_bars <- function(integration_result,
                                                facet_var = "sector") {
  plot_data <- prepare_for_pd_integration_plot(integration_result, facet_var)
  draw_pd_integration_plot(plot_data, facet_var)
}

prepare_for_pd_integration_plot <- function(integration_result, facet_var) {
  integration_result$portfolio_long |>
    dplyr::group_by_at(c(facet_var, "term", "pd_type")) |>
    dplyr::summarise(pd_value = stats::median(.data$pd_value, na.rm = TRUE),
                     .groups = "drop")
}

draw_pd_integration_plot <- function(plot_data, facet_var) {
  fill_palette <- c(
    internal       = TRISK_HEX_GREY,
    baseline       = TRISK_HEX_GREEN,
    shock          = TRISK_HEX_RED,
    trisk_adjusted = TRISK_HEX_ADJUSTED
  )

  ggplot2::ggplot(plot_data,
                  ggplot2::aes(x = as.factor(.data$term),
                               y = .data$pd_value,
                               fill = .data$pd_type)) +
    ggplot2::geom_bar(stat = "identity",
                      position = ggplot2::position_dodge()) +
    ggplot2::facet_grid(stats::as.formula(paste(facet_var, "~ ."))) +
    ggplot2::scale_fill_manual(values = fill_palette,
                               name = "PD Type") +
    ggplot2::scale_y_continuous(labels = scales::percent_format(scale = 100)) +
    TRISK_PLOT_THEME_FUNC() +
    ggplot2::labs(x = "Term", y = "PD",
                  title = "PD Integration: Baseline, Shock, Internal, Adjusted")
}
```

- [ ] **Step 4: Document and run**

Run:
```bash
Rscript -e 'devtools::document()'
Rscript -e 'devtools::test(filter = "plots")'
```
Expected: PASS.

- [ ] **Step 5: Commit**

```bash
git add R/plot_pd_integration.R tests/testthat/test-plots.R NAMESPACE
git commit -m "feat: pipeline_crispy_pd_integration_bars (P1)"
```

---

## Task 13: Implement P2 — `pipeline_crispy_el_adjustment_bars`

**Files:**
- Create: `R/plot_el_adjustment.R`
- Modify: `tests/testthat/test-plots.R`

- [ ] **Step 1: Append smoke test**

```r
test_that("pipeline_crispy_el_adjustment_bars returns a ggplot", {
  df <- make_test_analysis_data()
  integrated <- integrate_el(df, method = "absolute")
  p <- pipeline_crispy_el_adjustment_bars(integrated)
  expect_s3_class(p, "ggplot")
})
```

- [ ] **Step 2: Run — expect failure**

Run:
```bash
Rscript -e 'devtools::test(filter = "plots")'
```

- [ ] **Step 3: Create R/plot_el_adjustment.R**

```r
#' EL Adjustment Bar Plot (horizontal, sign-filled)
#'
#' ggplot port of `mod_integration.R:789-834`. Horizontal bars of EL adjustment
#' (Adjusted minus Internal) by sector, with `TRISK_HEX_RED` for negative
#' (risk worsens) and `STATUS_GREEN` for positive (risk improves).
#'
#' @param integration_result Output of [integrate_el()].
#' @param facet_var Column for aggregation. Default "sector".
#' @return A ggplot2 object.
#' @export
pipeline_crispy_el_adjustment_bars <- function(integration_result,
                                               facet_var = "sector") {
  plot_data <- prepare_for_el_adjustment_plot(integration_result, facet_var)
  draw_el_adjustment_plot(plot_data, facet_var)
}

prepare_for_el_adjustment_plot <- function(integration_result, facet_var) {
  integration_result$portfolio |>
    dplyr::group_by_at(facet_var) |>
    dplyr::summarise(el_adjustment = sum(.data$el_adjustment, na.rm = TRUE),
                     .groups = "drop") |>
    dplyr::mutate(sign = ifelse(.data$el_adjustment < 0, "worse", "better"))
}

draw_el_adjustment_plot <- function(plot_data, facet_var) {
  facet_sym <- rlang::sym(facet_var)

  ggplot2::ggplot(plot_data,
                  ggplot2::aes(x = stats::reorder(!!facet_sym, .data$el_adjustment),
                               y = .data$el_adjustment,
                               fill = .data$sign)) +
    ggplot2::geom_bar(stat = "identity") +
    ggplot2::coord_flip() +
    ggplot2::scale_fill_manual(values = c(worse = TRISK_HEX_RED,
                                          better = STATUS_GREEN),
                               guide = "none") +
    TRISK_PLOT_THEME_FUNC() +
    ggplot2::labs(x = "", y = "EL Adjustment (USD)",
                  title = "EL Adjustment by Sector")
}
```

- [ ] **Step 4: Document and run**

Run:
```bash
Rscript -e 'devtools::document()'
Rscript -e 'devtools::test(filter = "plots")'
```

- [ ] **Step 5: Commit**

```bash
git add R/plot_el_adjustment.R tests/testthat/test-plots.R NAMESPACE
git commit -m "feat: pipeline_crispy_el_adjustment_bars (P2)"
```

---

## Task 14: Implement P3a + P3b — KPI tables

**Files:**
- Create: `R/plot_integration_kpi_table.R`
- Modify: `tests/testthat/test-plots.R`

- [ ] **Step 1: Append smoke tests**

```r
test_that("pipeline_crispy_pd_kpi_table returns a knitr_kable", {
  df <- make_test_analysis_data()
  integrated <- integrate_pd(df, method = "absolute")
  tbl <- pipeline_crispy_pd_kpi_table(integrated$aggregate)
  expect_s3_class(tbl, "knitr_kable")
})

test_that("pipeline_crispy_el_kpi_table returns a knitr_kable", {
  df <- make_test_analysis_data()
  integrated <- integrate_el(df, method = "absolute")
  tbl <- pipeline_crispy_el_kpi_table(integrated$aggregate)
  expect_s3_class(tbl, "knitr_kable")
})
```

- [ ] **Step 2: Run — expect failure**

Run:
```bash
Rscript -e 'devtools::test(filter = "plots")'
```

- [ ] **Step 3: Create R/plot_integration_kpi_table.R**

```r
#' PD Integration KPI Table
#'
#' kableExtra-formatted one-row summary of the PD integration aggregate.
#' Ports the Shiny `valueBox` strip from `mod_integration.R:321-356`.
#'
#' @param pd_aggregate The `$aggregate` element from [integrate_pd()], or the
#'   output of [aggregate_pd_integration()].
#' @return A `knitr_kable` object.
#' @export
pipeline_crispy_pd_kpi_table <- function(pd_aggregate) {
  display <- tibble::tibble(
    `Total Exposure (USD)`            = format_big_number(pd_aggregate$total_exposure_usd),
    `Weighted Internal PD`            = format_pct(pd_aggregate$weighted_pd_internal),
    `Weighted Adjusted PD`            = format_pct(pd_aggregate$weighted_pd_adjusted),
    `Weighted PD Adjustment (pp)`     = format_pp(pd_aggregate$weighted_pd_adjustment),
    `Adjustment %`                    = format_pct(pd_aggregate$weighted_pd_adjustment_pct)
  )

  adjustment_color <- sign_color(pd_aggregate$weighted_pd_adjustment, positive_is = "red")
  display$`Weighted PD Adjustment (pp)` <- kableExtra::cell_spec(
    display$`Weighted PD Adjustment (pp)`, color = adjustment_color, bold = TRUE
  )

  display |>
    knitr::kable("html", escape = FALSE, align = "r") |>
    kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed"))
}

#' EL Integration KPI Table
#'
#' kableExtra-formatted one-row summary of the EL integration aggregate.
#' Ports `mod_integration.R:657-704` including the bps metric.
#'
#' @param el_aggregate The `$aggregate` element from [integrate_el()].
#' @return A `knitr_kable` object.
#' @export
pipeline_crispy_el_kpi_table <- function(el_aggregate) {
  display <- tibble::tibble(
    `Total Exposure (USD)` = format_big_number(el_aggregate$total_exposure_usd),
    `Total Internal EL`    = format_big_number(el_aggregate$total_el_internal),
    `Total Adjusted EL`    = format_big_number(el_aggregate$total_el_adjusted),
    `EL Adjustment`        = format_big_number(el_aggregate$total_el_adjustment),
    `Adjusted EL (bps)`    = format_bps(el_aggregate$el_adjusted_bps)
  )

  adjustment_color <- sign_color(el_aggregate$total_el_adjustment, positive_is = "green")
  display$`EL Adjustment` <- kableExtra::cell_spec(
    display$`EL Adjustment`, color = adjustment_color, bold = TRUE
  )

  display |>
    knitr::kable("html", escape = FALSE, align = "r") |>
    kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed"))
}

# Internal formatting helpers — declared here because they only serve the KPI tables.
format_big_number <- function(x) {
  if (is.null(x) || is.na(x)) return("-")
  if (abs(x) >= 1e9) return(sprintf("%.2fB", x / 1e9))
  if (abs(x) >= 1e6) return(sprintf("%.2fM", x / 1e6))
  if (abs(x) >= 1e3) return(sprintf("%.1fK", x / 1e3))
  sprintf("%.2f", x)
}

format_pct <- function(x) {
  if (is.null(x) || is.na(x)) return("-")
  sprintf("%.3f%%", x * 100)
}

format_pp <- function(x) {
  if (is.null(x) || is.na(x)) return("-")
  sprintf("%+.3f pp", x * 100)
}

format_bps <- function(x) {
  if (is.null(x) || is.na(x)) return("-")
  sprintf("%.1f bps", x)
}

# Return the color string to apply to a signed adjustment value.
# For PD: positive_is="red" means positive adjustments (PD got worse) render red.
# For EL: positive_is="green" means positive EL adjustments (less loss) render green.
sign_color <- function(x, positive_is = c("red", "green")) {
  positive_is <- match.arg(positive_is)
  if (is.null(x) || is.na(x) || abs(x) < 1e-12) return("#6c757d")  # grey neutral
  if (x > 0) {
    if (positive_is == "red") TRISK_HEX_RED else STATUS_GREEN
  } else {
    if (positive_is == "red") STATUS_GREEN else TRISK_HEX_RED
  }
}
```

- [ ] **Step 4: Document and run**

Run:
```bash
Rscript -e 'devtools::document()'
Rscript -e 'devtools::test(filter = "plots")'
```

- [ ] **Step 5: Commit**

```bash
git add R/plot_integration_kpi_table.R tests/testthat/test-plots.R NAMESPACE
git commit -m "feat: PD and EL KPI tables (P3a, P3b)"
```

---

## Task 15: Implement P4 — EL sector breakdown table

**Files:**
- Modify: `R/plot_integration_kpi_table.R` (keep all table helpers in one file — matches Task 14 grouping)
- Modify: `tests/testthat/test-plots.R`

- [ ] **Step 1: Append smoke test**

```r
test_that("pipeline_crispy_el_sector_breakdown_table returns a knitr_kable", {
  df <- make_test_analysis_data()
  integrated <- integrate_el(df, method = "absolute")
  tbl <- pipeline_crispy_el_sector_breakdown_table(integrated$portfolio)
  expect_s3_class(tbl, "knitr_kable")
})
```

- [ ] **Step 2: Run — expect failure**

Run:
```bash
Rscript -e 'devtools::test(filter = "plots")'
```

- [ ] **Step 3: Append function to R/plot_integration_kpi_table.R**

```r
#' EL Sector Breakdown Table
#'
#' Sector-level EL breakdown with direction arrows, exposure, internal vs
#' adjusted EL, delta, and EL/EAD in bps. Ports the Shiny collapsible breakdown
#' at `mod_integration.R:707-786` into a printable table.
#'
#' @param portfolio_df The `$portfolio` from [integrate_el()].
#' @param group_col Character column to group by. Default "sector".
#' @return A `knitr_kable` object.
#' @export
pipeline_crispy_el_sector_breakdown_table <- function(portfolio_df,
                                                      group_col = "sector") {
  if (!group_col %in% colnames(portfolio_df)) {
    stop("pipeline_crispy_el_sector_breakdown_table(): column '", group_col,
         "' not in portfolio_df")
  }

  summary <- portfolio_df |>
    dplyr::group_by_at(group_col) |>
    dplyr::summarise(
      Count            = dplyr::n(),
      Exposure         = sum(.data$exposure_value_usd, na.rm = TRUE),
      `Internal EL`    = sum(.data$internal_el, na.rm = TRUE),
      `Adjusted EL`    = sum(.data$trisk_adjusted_el, na.rm = TRUE),
      `EL Adjustment`  = sum(.data$el_adjustment, na.rm = TRUE),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      `EL_EAD_bps` = ifelse(.data$Exposure > 0,
                            abs(.data$`Adjusted EL`) / .data$Exposure * 10000,
                            NA_real_),
      Direction = dplyr::case_when(
        .data$`EL Adjustment` < -0.01 ~ "↑",    # up arrow: loss worse
        .data$`EL Adjustment` >  0.01 ~ "↓",    # down arrow: loss better
        TRUE ~ "—"                               # em dash: neutral
      )
    )

  display <- summary |>
    dplyr::transmute(
      !!rlang::sym(group_col) := .data[[group_col]],
      .data$Direction,
      Count = format(.data$Count),
      Exposure      = sapply(.data$Exposure,      format_big_number),
      `Internal EL` = sapply(.data$`Internal EL`, format_big_number),
      `Adjusted EL` = sapply(.data$`Adjusted EL`, format_big_number),
      `EL Adjustment` = sapply(.data$`EL Adjustment`, format_big_number),
      `EL/EAD (bps)`  = sapply(.data$EL_EAD_bps, format_bps)
    )

  display |>
    knitr::kable("html", escape = FALSE, align = "r") |>
    kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed"))
}
```

- [ ] **Step 4: Document and run**

Run:
```bash
Rscript -e 'devtools::document()'
Rscript -e 'devtools::test(filter = "plots")'
```

- [ ] **Step 5: Commit**

```bash
git add R/plot_integration_kpi_table.R tests/testthat/test-plots.R NAMESPACE
git commit -m "feat: EL sector breakdown table (P4)"
```

---

## Task 16: Implement N1 — PD method comparison plot

**Files:**
- Create: `R/plot_pd_method_comparison.R`
- Modify: `tests/testthat/test-plots.R`

- [ ] **Step 1: Append smoke test**

```r
test_that("pipeline_crispy_pd_method_comparison returns a ggplot", {
  df <- make_test_analysis_data()
  p <- pipeline_crispy_pd_method_comparison(df)
  expect_s3_class(p, "ggplot")
})
```

- [ ] **Step 2: Run — expect failure**

Run:
```bash
Rscript -e 'devtools::test(filter = "plots")'
```

- [ ] **Step 3: Create R/plot_pd_method_comparison.R**

```r
#' PD Integration Method Comparison Plot
#'
#' Runs all three PD integration methods on the same input and overlays
#' their EAD-weighted adjusted PDs per sector, so the user can see method
#' sensitivity at a glance. Inspired by the range-lollipop pattern in
#' `mod_results_scenarios.R:220-234`.
#'
#' Each sector shows:
#' - a segment from weighted_pd_internal to the maximum adjusted across methods
#' - three points (circle, triangle, square) for absolute / relative / zscore
#'
#' @param analysis_data Raw output of [run_trisk_on_portfolio()].
#' @param internal_pd Optional; forwarded to [integrate_pd()].
#' @param facet_var Column used for aggregation. Default "sector".
#' @return A ggplot2 object.
#' @export
pipeline_crispy_pd_method_comparison <- function(analysis_data,
                                                 internal_pd = NULL,
                                                 facet_var = "sector") {
  methods <- c("absolute", "relative", "zscore")

  per_method <- lapply(methods, function(m) {
    integrated <- integrate_pd(analysis_data,
                               internal_pd = internal_pd, method = m)
    agg <- aggregate_pd_integration(integrated$portfolio,
                                    group_cols = facet_var)
    agg |> dplyr::mutate(method = m)
  })
  plot_df <- dplyr::bind_rows(per_method)

  segment_df <- plot_df |>
    dplyr::group_by_at(facet_var) |>
    dplyr::summarise(
      internal = dplyr::first(.data$weighted_pd_internal),
      adjusted_max = max(.data$weighted_pd_adjusted, na.rm = TRUE),
      .groups = "drop"
    )

  facet_sym <- rlang::sym(facet_var)

  ggplot2::ggplot() +
    ggplot2::geom_segment(
      data = segment_df,
      ggplot2::aes(x = .data$internal, xend = .data$adjusted_max,
                   y = !!facet_sym, yend = !!facet_sym),
      color = TRISK_HEX_GREY, linewidth = 1
    ) +
    ggplot2::geom_point(
      data = plot_df,
      ggplot2::aes(x = .data$weighted_pd_adjusted,
                   y = !!facet_sym,
                   shape = .data$method,
                   color = .data$method),
      size = 3
    ) +
    ggplot2::geom_point(
      data = segment_df,
      ggplot2::aes(x = .data$internal, y = !!facet_sym),
      shape = 124, size = 5, color = "#1A1A1A"
    ) +
    ggplot2::scale_shape_manual(values = c(absolute = 16, relative = 17, zscore = 15)) +
    ggplot2::scale_color_manual(values = c(absolute = TRISK_HEX_ADJUSTED,
                                           relative = STATUS_GREEN,
                                           zscore   = TRISK_HEX_RED)) +
    ggplot2::scale_x_continuous(labels = scales::percent_format(scale = 100)) +
    TRISK_PLOT_THEME_FUNC() +
    ggplot2::labs(
      x = "EAD-weighted PD",
      y = "",
      color = "Method", shape = "Method",
      title = "PD Method Comparison (Internal → Adjusted)",
      subtitle = "Black tick = Internal PD; colored shapes = method-specific Adjusted PD"
    )
}
```

- [ ] **Step 4: Document and run**

Run:
```bash
Rscript -e 'devtools::document()'
Rscript -e 'devtools::test(filter = "plots")'
```

- [ ] **Step 5: Commit**

```bash
git add R/plot_pd_method_comparison.R tests/testthat/test-plots.R NAMESPACE
git commit -m "feat: pipeline_crispy_pd_method_comparison (N1)"
```

---

## Task 17: Manual review checkpoint — decide on N2 waterfall

**Not a code task — a gate.**

- [ ] **Step 1: Render N1 against bundled testdata**

Run:
```bash
mkdir -p specs/plans/artifacts
Rscript -e '
library(trisk.analysis)
assets <- read.csv(system.file("testdata", "assets_testdata.csv", package = "trisk.model"))
scen   <- read.csv(system.file("testdata", "scenarios_testdata.csv", package = "trisk.model"))
fin    <- read.csv(system.file("testdata", "financial_features_testdata.csv", package = "trisk.model"))
carb   <- read.csv(system.file("testdata", "ngfs_carbon_price_testdata.csv", package = "trisk.model"))
port   <- read.csv(system.file("testdata", "portfolio_ids_testdata.csv", package = "trisk.analysis"))
ad <- run_trisk_on_portfolio(assets, scen, fin, carb, port,
                             baseline_scenario = "NGFS2023GCAM_CP",
                             target_scenario   = "NGFS2023GCAM_NZ2050")
p <- pipeline_crispy_pd_method_comparison(ad)
ggplot2::ggsave("specs/plans/artifacts/n1_method_comparison.png",
                p, width = 8, height = 5, dpi = 120)
'
```

- [ ] **Step 2: Show the rendered PNG to the user and ask: "Does N1 make the method-sensitivity story clear? If yes, skip Task 18 (N2 waterfall). If no, proceed to Task 18."**

- [ ] **Step 3: If user chooses to skip N2, mark Task 18 done without executing. If proceeding, execute Task 18.**

---

## Task 18: (CONDITIONAL) Implement N2 — PD waterfall

**Only run if N1 review says waterfall adds value.**

**Files:**
- Create: `R/plot_pd_waterfall.R`
- Modify: `tests/testthat/test-plots.R`

- [ ] **Step 1: Append smoke test**

```r
test_that("pipeline_crispy_pd_waterfall returns a ggplot", {
  df <- make_test_analysis_data()
  integrated <- integrate_pd(df, method = "absolute")
  p <- pipeline_crispy_pd_waterfall(integrated)
  expect_s3_class(p, "ggplot")
})
```

- [ ] **Step 2: Run — expect failure**

Run:
```bash
Rscript -e 'devtools::test(filter = "plots")'
```

- [ ] **Step 3: Create R/plot_pd_waterfall.R**

```r
#' PD Waterfall Plot
#'
#' Per-sector waterfall: Internal PD bar -> signed delta bar -> Adjusted PD bar.
#' The signed delta fill uses TRISK_HEX_RED if the adjustment worsens risk and
#' STATUS_GREEN if it improves risk.
#'
#' @param integration_result Output of [integrate_pd()].
#' @param facet_var Column for aggregation. Default "sector".
#' @return A ggplot2 object.
#' @export
pipeline_crispy_pd_waterfall <- function(integration_result,
                                         facet_var = "sector") {
  agg <- aggregate_pd_integration(integration_result$portfolio,
                                  group_cols = facet_var)

  plot_df <- agg |>
    tidyr::pivot_longer(
      cols = c("weighted_pd_internal", "weighted_pd_adjustment", "weighted_pd_adjusted"),
      names_to = "stage_raw",
      values_to = "value"
    ) |>
    dplyr::mutate(
      stage = factor(dplyr::recode(.data$stage_raw,
                                   weighted_pd_internal   = "Internal",
                                   weighted_pd_adjustment = "Adjustment",
                                   weighted_pd_adjusted   = "Adjusted"),
                     levels = c("Internal", "Adjustment", "Adjusted")),
      sign_group = dplyr::case_when(
        .data$stage == "Adjustment" & .data$value > 0 ~ "worse",
        .data$stage == "Adjustment" & .data$value < 0 ~ "better",
        .data$stage == "Internal"                     ~ "internal",
        .data$stage == "Adjusted"                     ~ "adjusted",
        TRUE ~ "neutral"
      )
    )

  facet_sym <- rlang::sym(facet_var)

  ggplot2::ggplot(plot_df,
                  ggplot2::aes(x = .data$stage, y = .data$value,
                               fill = .data$sign_group)) +
    ggplot2::geom_bar(stat = "identity") +
    ggplot2::facet_wrap(stats::as.formula(paste("~", facet_var))) +
    ggplot2::scale_fill_manual(values = c(
      internal = TRISK_HEX_GREY,
      adjusted = TRISK_HEX_ADJUSTED,
      worse    = TRISK_HEX_RED,
      better   = STATUS_GREEN,
      neutral  = TRISK_HEX_GREY
    ), guide = "none") +
    ggplot2::scale_y_continuous(labels = scales::percent_format(scale = 100)) +
    TRISK_PLOT_THEME_FUNC() +
    ggplot2::labs(x = "", y = "EAD-weighted PD",
                  title = "PD Waterfall: Internal -> Adjustment -> Adjusted")
}
```

- [ ] **Step 4: Document and run**

Run:
```bash
Rscript -e 'devtools::document()'
Rscript -e 'devtools::test(filter = "plots")'
```

- [ ] **Step 5: Commit**

```bash
git add R/plot_pd_waterfall.R tests/testthat/test-plots.R NAMESPACE
git commit -m "feat: pipeline_crispy_pd_waterfall (N2)"
```

---

## Task 19: Write the workflow vignette

**Files:**
- Create: `vignettes/pd-el-integration.Rmd`

- [ ] **Step 1: Create the vignette**

Create `vignettes/pd-el-integration.Rmd`:

````markdown
---
title: "pd-el-integration"
output: rmarkdown::html_vignette
vignette: >
  %\VignetteIndexEntry{pd-el-integration}
  %\VignetteEngine{knitr::rmarkdown}
  %\VignetteEncoding{UTF-8}
---

```{r, include = FALSE}
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)
```

```{r setup}
library(trisk.analysis)
library(magrittr)
```

# PD and EL Integration

## 1. Setup

Load the bundled testdata shipped with `trisk.model` and `trisk.analysis`.

```{r}
assets_testdata    <- read.csv(system.file("testdata", "assets_testdata.csv",    package = "trisk.model"))
scenarios_testdata <- read.csv(system.file("testdata", "scenarios_testdata.csv", package = "trisk.model"))
fin_testdata       <- read.csv(system.file("testdata", "financial_features_testdata.csv", package = "trisk.model"))
carbon_testdata    <- read.csv(system.file("testdata", "ngfs_carbon_price_testdata.csv", package = "trisk.model"))
portfolio_testdata <- read.csv(system.file("testdata", "portfolio_ids_testdata.csv", package = "trisk.analysis"))
```

## 2. Run TRISK on the portfolio

```{r}
analysis_data <- run_trisk_on_portfolio(
  assets_data       = assets_testdata,
  scenarios_data    = scenarios_testdata,
  financial_data    = fin_testdata,
  carbon_data       = carbon_testdata,
  portfolio_data    = portfolio_testdata,
  baseline_scenario = "NGFS2023GCAM_CP",
  target_scenario   = "NGFS2023GCAM_NZ2050"
)
```

```{r echo=FALSE}
knitr::kable(head(analysis_data[, c("company_id", "sector", "technology", "term",
                                    "pd_baseline", "pd_shock",
                                    "expected_loss_baseline", "expected_loss_shock")])) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "100%", height = "300px")
```

## 3. Why integration matters

TRISK recomputes PD from a Merton structural credit model. That PD level is not
directly comparable to the internal PD your institution already uses — only the
change from baseline to shock carries meaning. Three integration methods
translate the TRISK shift into your internal PD scale.

## 4. Method 1 — Absolute

```{r}
result_abs <- integrate_pd(analysis_data, method = "absolute")
```

```{r echo=FALSE}
knitr::kable(head(result_abs$portfolio[, c("company_id", "sector", "internal_pd",
                                           "pd_baseline", "pd_shock",
                                           "trisk_adjusted_pd", "pd_adjustment")])) %>%
  kableExtra::kable_styling(bootstrap_options = c("striped", "hover", "condensed")) %>%
  kableExtra::scroll_box(width = "100%", height = "300px")
```

## 5. Method 2 — Relative

> **Note:** when `pd_baseline = 0` the relative method returns the internal PD
> unchanged — the shock signal is lost on zero-baseline rows. Use `absolute` or
> `zscore` if this matters.

```{r}
result_rel <- integrate_pd(analysis_data, method = "relative")
```

## 6. Method 3 — Z-score (Basel IRB)

The z-score method combines PDs in the normal-quantile space, preserving the
non-linear relationship at distribution tails. Recommended for Basel IRB-aligned
institutions.

```{r}
result_zs <- integrate_pd(analysis_data, method = "zscore")
```

## 7. Supplying your own internal PDs

Pass a vector (length = `nrow(analysis_data)`) or a data frame with
`company_id` and `internal_pd`. Unmatched rows fall back to `pd_baseline`.

```{r}
flat_internal <- rep(0.03, nrow(analysis_data))
result_custom <- integrate_pd(analysis_data,
                              internal_pd = flat_internal,
                              method      = "zscore")
```

## 8. Method comparison

```{r fig.width=7, fig.height=4}
pipeline_crispy_pd_method_comparison(analysis_data)
```

## 9. Integration charts

```{r fig.width=7, fig.height=4}
pipeline_crispy_pd_integration_bars(result_zs)
```

## 10. EL integration

```{r}
result_el <- integrate_el(analysis_data, method = "relative")
```

```{r fig.width=7, fig.height=4}
pipeline_crispy_el_adjustment_bars(result_el)
```

## 11. Portfolio-level KPIs

```{r}
pipeline_crispy_pd_kpi_table(result_zs$aggregate)
```

```{r}
pipeline_crispy_el_kpi_table(result_el$aggregate)
```

## 12. Sector breakdown

```{r}
pipeline_crispy_el_sector_breakdown_table(result_el$portfolio)
```
````

- [ ] **Step 2: Build the vignette**

Run:
```bash
Rscript -e 'devtools::build_vignettes()'
```
Expected: vignette builds without errors; HTML file appears in `doc/` or `inst/doc/`.

- [ ] **Step 3: Commit**

```bash
git add vignettes/pd-el-integration.Rmd
git commit -m "docs: add pd-el-integration workflow vignette"
```

---

## Task 20: Full verification pass

- [ ] **Step 1: Run full test suite**

Run:
```bash
Rscript -e 'devtools::test()'
```
Expected: `[ FAIL 0 | WARN 0 | SKIP 0 | PASS ≥18 ]` (more if N2 built).

- [ ] **Step 2: Run R CMD check**

Run:
```bash
Rscript -e 'devtools::check()'
```
Expected: `0 errors | 0 warnings | 0 notes` (or only notes pre-existing on `main`).

- [ ] **Step 3: Render the vignette to confirm final output**

Run:
```bash
Rscript -e 'rmarkdown::render("vignettes/pd-el-integration.Rmd")'
```
Open the rendered HTML and confirm the three tables and three plots display correctly with no errors.

- [ ] **Step 4: Final commit (if any changes from the check pass)**

```bash
git status
# If clean, no commit needed. If roxygen produced NAMESPACE diffs, commit them:
git add NAMESPACE man/
git commit -m "docs: regenerate roxygen man pages"
```

---

## Out of scope (tracked for later)

- **S3:** PD/EL visualization walkthrough vignette (separate plan)
- **S4:** Simplify/rewrite `sensitivity-analysis.Rmd` (separate plan)
- **Upstream bug:** `trisk.model::calculate_pd_change_overall()` hardcodes `term = 1:5` (separate trisk.model issue)
