# Compute exposure shares from baseline NPV

Allocates `exposure_value_usd` to assets using each asset baseline NPV
share. It mirrors the Python logic: compute run-level shares, average
exposure share after dropping `run_id`, then re-scale so each original
portfolio row keeps its total exposure. Non-negative guard: negative
technology NPVs are clamped to 0 and a company whose total baseline NPV
is non-positive is split equally across its technologies (with a
warning), so allocated exposure stays non-negative and still reconciles
to the original loan totals.

## Usage

``` r
add_exposure_share_from_npv(portfolio_results)
```

## Arguments

- portfolio_results:

  Output of `run_trisk_on_simple_portfolio` before share allocation.

## Value

Input dataframe with an additional `exposure_value_usd_share` column.
