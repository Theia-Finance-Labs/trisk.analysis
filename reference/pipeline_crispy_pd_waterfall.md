# PD waterfall plot

Per-facet decomposition: Internal PD bar -\> signed Adjustment bar -\>
Adjusted PD bar. The Adjustment bar fill flips on sign:
\`TRISK_HEX_RED\` when the adjustment worsens risk (positive delta),
\`STATUS_GREEN\` when it improves risk. Internal and Adjusted bars use
the neutral grey and dark-red roles from the standard palette.

## Usage

``` r
pipeline_crispy_pd_waterfall(integration_result, facet_var = "sector")
```

## Arguments

- integration_result:

  Output of \[integrate_pd()\] (a list with a \`\$portfolio\` data
  frame).

- facet_var:

  Column used for facet wrapping. Default \`"sector"\`.

## Value

A ggplot2 object.
