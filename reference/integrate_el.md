# Integrate TRISK EL shift into an internal EL estimate

Applies one of three methods to translate the TRISK baseline-to-shock EL
change into the bank's own internal EL scale. "absolute" and "relative"
mirror the Shiny EL integration logic; "zscore" adds a Basel IRB-aligned
Vasicek recombination by transforming EL to an effective PD (\|EL\| /
(EAD \* LGD)), applying the z-score combination in normal-quantile
space, and converting back. The zscore method preserves the package's
negative-EL convention (loss as negative number) and requires
\`exposure_value_usd\` and \`loss_given_default\` columns in
\`analysis_data\`.

## Usage

``` r
integrate_el(
  analysis_data,
  internal_el = NULL,
  method = c("zscore", "absolute", "relative"),
  zscore_floor = 1e-04,
  zscore_cap = 1 - 1e-04
)
```

## Arguments

- analysis_data:

  Data frame from \[run_trisk_on_portfolio()\]; must contain columns
  \`expected_loss_baseline\`, \`expected_loss_shock\` (and for zscore,
  \`exposure_value_usd\`, \`loss_given_default\`).

- internal_el:

  Numeric vector of length \`nrow(analysis_data)\`, or a data frame with
  \`company_id\` + \`internal_el\` columns, or NULL (default) which uses
  \`expected_loss_baseline\`.

- method:

  One of "zscore", "absolute", "relative". Default "zscore".

- zscore_floor:

  Lower clip bound for effective PDs before \`qnorm()\`. Default 1e-4.

- zscore_cap:

  Upper clip bound. Default 1 - 1e-4.

## Value

List with \`\$portfolio\`, \`\$portfolio_long\`, \`\$aggregate\`.
