# Aggregate EL integration results to portfolio level

Aggregate EL integration results to portfolio level

## Usage

``` r
aggregate_el_integration(portfolio_df, group_cols = NULL)
```

## Arguments

- portfolio_df:

  The \`\$portfolio\` element from \[integrate_el()\].

- group_cols:

  Character vector or NULL. NULL = portfolio total.

## Value

A one-row tibble (per group) with total ELs + \`el_adjusted_bps\`.
