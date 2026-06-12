# Technology mix by sector, on two bases (NPV value and exposure)

100 computed two ways: as a share of baseline NPV value, and as a share
of exposure (EAD). Technologies render as shades of the sector's base
colour (darkest = most carbon-intensive, via \[trisk_sector_shades()\]).
Showing both bases makes the allocation choice explicit: the
NPV-weighted and exposure-weighted mixes can differ materially, so a
single basis can mislead.

## Usage

``` r
pipeline_trisk_tech_mix(
  analysis_data,
  bases = c("% of NPV value", "% of exposure (EAD)")
)
```

## Arguments

- analysis_data:

  Tech-detail frame from a TRISK runner (e.g.
  \`run_trisk_on_simple_portfolio()\$portfolio_results_tech_detail\`).
  Must contain \`sector\`, \`technology\`,
  \`net_present_value_baseline\`, and an exposure column
  (\`exposure_at_default\` preferred, else \`exposure_value_usd\`).

- bases:

  Character vector selecting which bases to draw; default both.

## Value

A ggplot object.
