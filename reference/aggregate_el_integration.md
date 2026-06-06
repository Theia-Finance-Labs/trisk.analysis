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

A one-row tibble (per group) with total ELs and two bps measures, both
as a loss rate over \*notional exposure\* (EL/EAD would be PD-in-bps,
not a loss rate): \`el_adjusted_bps\` — the adjusted EL \*level\* (total
expected-loss rate of the shocked book), and \`el_adjustment_bps\` — the
climate overlay (delta = adjusted - internal), the marginal transition
effect.
