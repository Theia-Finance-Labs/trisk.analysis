# Warn when portfolio terms fall outside the TRISK Merton grid (D1)

The term join silently drops portfolio rows whose contractual \`term\`
is not in the model's PD term grid (sized to the analysis horizon),
yielding NA PD/EL. This surfaces those rows by name instead.

## Usage

``` r
warn_terms_outside_grid(portfolio_data, pd_results)
```

## Arguments

- portfolio_data:

  Portfolio data frame with \`company_id\` and \`term\`.

- pd_results:

  PD results from the TRISK model (provides the term grid).

## Value

Invisibly, the dropped rows (\`company_id\`, \`term\`).
