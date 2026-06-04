# PD waterfall plot

Per-facet cumulative decomposition: an Internal anchor bar (0 to
internal PD), a signed Adjustment segment that bridges the Internal top
to the Adjusted top, and an Adjusted anchor bar (0 to adjusted PD). The
Adjustment segment fill flips on sign: \`TRISK_HEX_RED\` when the
adjustment worsens risk (positive delta), \`STATUS_GREEN\` when it
improves risk. Internal and Adjusted anchors use the neutral grey and
dark-red roles from the standard palette. The cumulative segment
construction is what makes this a true waterfall: reading left to right
traces internal + adjustment = adjusted geometrically.

## Usage

``` r
pipeline_trisk_pd_waterfall(integration_result, facet_var = "sector")
```

## Arguments

- integration_result:

  Output of \[integrate_pd()\] (a list with a \`\$portfolio\` data
  frame).

- facet_var:

  Column used for facet wrapping. Default \`"sector"\`.

## Value

A ggplot2 object.
