# Aggregate simple portfolio tech details back to input-row shape

Aggregate simple portfolio tech details back to input-row shape

## Usage

``` r
aggregate_simple_portfolio_results(portfolio_results_detailed)
```

## Arguments

- portfolio_results_detailed:

  Detailed output from
  [`run_trisk_on_simple_portfolio()`](run_trisk_on_simple_portfolio.md)
  before dropping `exposure_value_usd`.

## Value

Portfolio output with one row per input portfolio row.
