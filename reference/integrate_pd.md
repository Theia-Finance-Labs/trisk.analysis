# Integrate TRISK PD shift into an internal PD estimate

Applies one of three methods to translate the TRISK baseline-to-shock PD
change into the bank's own internal PD scale. Mirrors the logic in the
trisk.r.docker Shiny integration module.

## Usage

``` r
integrate_pd(
  analysis_data,
  internal_pd = NULL,
  method = c("zscore", "absolute", "relative"),
  zscore_floor = 1e-04,
  zscore_cap = 1 - 1e-04
)
```

## Arguments

- analysis_data:

  Data frame from \[run_trisk_on_portfolio()\]; must contain columns
  \`pd_baseline\`, \`pd_shock\`.

- internal_pd:

  Either (a) a numeric vector of length \`nrow(analysis_data)\`, (b) a
  data frame with \`company_id\` and \`internal_pd\` columns, or (c)
  NULL (default) in which case \`pd_baseline\` is used.

- method:

  One of "zscore", "absolute", "relative". Default "zscore" (Basel
  IRB-aligned; zero-safe via clipping; recommended for sparse portfolios
  where baseline PDs can underflow from Merton inputs).

- zscore_floor:

  Lower clip bound for PDs before \`qnorm()\` in the zscore method.
  Default 1e-4.

- zscore_cap:

  Upper clip bound. Default 1 - 1e-4.

## Value

A list with three elements:

- portfolio:

  \`analysis_data\` with columns added: \`internal_pd\`, \`pd_change\`,
  \`pd_change_pct\`, \`trisk_adjusted_pd\`, \`pd_adjustment\`.

- portfolio_long:

  Pivot-longer helper for plotting.

- aggregate:

  One-row tibble of EAD-weighted portfolio metrics.
