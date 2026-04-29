# Aggregate PD integration results to EAD-weighted portfolio level

Aggregate PD integration results to EAD-weighted portfolio level

## Usage

``` r
aggregate_pd_integration(portfolio_df, group_cols = NULL)
```

## Arguments

- portfolio_df:

  The \`\$portfolio\` element from \[integrate_pd()\], containing
  \`internal_pd\`, \`pd_baseline\`, \`pd_shock\`, \`trisk_adjusted_pd\`,
  \`exposure_value_usd\`.

- group_cols:

  Character vector of columns to group by. NULL (default) produces a
  single-row portfolio total. Pass e.g. "sector" for a sector rollup.

## Value

A one-row tibble (per group) with EAD-weighted PD metrics.
