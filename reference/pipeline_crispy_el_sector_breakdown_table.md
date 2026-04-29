# EL Sector Breakdown Table

Sector-level EL breakdown with direction arrows, exposure, internal vs
adjusted EL, delta, and EL/EAD in bps. Ports the Shiny collapsible
breakdown at \`mod_integration.R:707-786\` into a printable table.

## Usage

``` r
pipeline_crispy_el_sector_breakdown_table(portfolio_df, group_col = "sector")
```

## Arguments

- portfolio_df:

  The \`\$portfolio\` from \[integrate_el()\].

- group_col:

  Character column to group by. Default "sector".

## Value

A \`knitr_kable\` object.
