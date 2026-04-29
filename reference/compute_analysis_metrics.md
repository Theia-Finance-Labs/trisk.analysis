# Compute Analysis Metrics

Adds derived financial metrics to a raw \`run_trisk_on_portfolio()\`
output: \`net_present_value_difference\`, \`crispy_perc_value_change\`,
\`crispy_value_loss\`, \`exposure_at_default\`, \`pd_difference\`,
\`expected_loss_baseline\`, \`expected_loss_shock\`,
\`expected_loss_difference\`. Call this before passing data to
\[integrate_el()\], which requires the EL columns.

## Usage

``` r
compute_analysis_metrics(analysis_data)
```

## Arguments

- analysis_data:

  Data frame produced by \[run_trisk_on_portfolio()\].

## Value

The input data frame with the derived metric columns appended.
