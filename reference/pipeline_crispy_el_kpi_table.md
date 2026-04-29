# EL Integration KPI Table

kableExtra-formatted one-row summary of the EL integration aggregate.
Ports \`mod_integration.R:657-704\` including the bps metric.

## Usage

``` r
pipeline_crispy_el_kpi_table(el_aggregate)
```

## Arguments

- el_aggregate:

  The \`\$aggregate\` element from \[integrate_el()\].

## Value

A \`knitr_kable\` object.
