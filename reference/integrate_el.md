# Integrate TRISK EL shift into an internal EL estimate

Applies one of three methods to translate the TRISK baseline-to-shock EL
change into the bank's own internal EL scale. "absolute" and "relative"
mirror the Shiny EL integration logic; "zscore" reuses the integrate_pd
probit recombination engine (\`apply_pd_method\`, a Merton-style
threshold recombination — not the Basel IRB / Vasicek capital formula)
by transforming EL to an effective PD (\|EL\| / (EAD \* LGD)), applying
the z-score combination in normal-quantile space, and converting back.
All three methods return EL as a positive magnitude (post 59571f3
package-wide convention). The zscore method needs the EL normalizer
EAD\*LGD: a \`lgd_weighted_exposure\` column, or
\`exposure_value_usd\` + \`loss_given_default\` to reconstruct it.

## Usage

``` r
integrate_el(
  analysis_data,
  internal_el = NULL,
  method = c("zscore", "absolute", "relative"),
  zscore_floor = ZSCORE_FLOOR_DEFAULT,
  zscore_cap = ZSCORE_CAP_DEFAULT
)
```

## Arguments

- analysis_data:

  Data frame from a TRISK runner (\[run_trisk_on_simple_portfolio()\] or
  \[run_trisk_on_portfolio()\]); must contain columns
  \`expected_loss_baseline\`, \`expected_loss_shock\`. The zscore method
  additionally needs the EL normalizer EAD\*LGD
  (\`lgd_weighted_exposure\`): it uses that column when present (the
  canonical contract, written by \[compute_analysis_metrics()\] and
  \[run_trisk_on_simple_portfolio()\]) and otherwise reconstructs it as
  \`exposure_value_usd \* loss_given_default\`.

- internal_el:

  Numeric vector of length \`nrow(analysis_data)\`, or a data frame with
  \`company_id\` (+ optional keys) and a value column, or NULL (default)
  which uses \`expected_loss_baseline\`. The PD embedded in an internal
  EL should be on a horizon comparable to the TRISK \`term\` (no
  conversion is applied here); see the horizon note in
  \[integrate_pd()\].

- method:

  One of "zscore", "absolute", "relative". Default "zscore".

- zscore_floor:

  Lower clip bound for effective PDs before \`qnorm()\`. Default 1e-4.

- zscore_cap:

  Upper clip bound. Default 1 - 1e-4.

## Value

List with \`\$portfolio\`, \`\$portfolio_long\`, \`\$aggregate\`.
