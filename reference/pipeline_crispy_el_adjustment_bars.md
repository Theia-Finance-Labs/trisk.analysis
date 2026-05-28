# EL Adjustment Bar Plot (horizontal, sign-filled)

ggplot port of \`mod_integration.R:789-834\`. Horizontal bars of EL
adjustment (Adjusted minus Internal) by sector. Sign convention (with EL
stored as a positive magnitude): positive adjustment = more loss =
\`TRISK_HEX_RED\` (worse), negative adjustment = less loss =
\`STATUS_GREEN\` (better), near-zero adjustment (\|x\| \< epsilon) =
neutral grey. The adjustment is signed; the EL levels themselves are not
coloured here.

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
