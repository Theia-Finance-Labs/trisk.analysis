# EL Adjustment Bar Plot (horizontal, sign-filled)

ggplot port of \`mod_integration.R:789-834\`. Horizontal bars of EL
adjustment (Adjusted minus Internal) by sector, with \`TRISK_HEX_RED\`
for negative (risk worsens) and \`STATUS_GREEN\` for positive (risk
improves).

## Usage

``` r
pipeline_crispy_el_adjustment_bars(integration_result, facet_var = "sector")
```

## Arguments

- integration_result:

  Output of \[integrate_el()\].

- facet_var:

  Column for aggregation. Default "sector".

## Value

A ggplot2 object.
