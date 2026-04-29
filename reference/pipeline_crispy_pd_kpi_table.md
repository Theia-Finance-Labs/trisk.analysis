# PD Integration KPI Table

kableExtra-formatted one-row summary of the PD integration aggregate.
Ports the Shiny \`valueBox\` strip from \`mod_integration.R:321-356\`.

## Usage

``` r
pipeline_crispy_pd_kpi_table(pd_aggregate)
```

## Arguments

- pd_aggregate:

  The \`\$aggregate\` element from \[integrate_pd()\], or the output of
  \[aggregate_pd_integration()\].

## Value

A \`knitr_kable\` object.
