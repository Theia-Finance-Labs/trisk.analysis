# Data Preparation for Financial Risk Visualization

Prepares dataset for plotting by transforming financial risk data,
including expected losses and exposure values, into a format that allows
for aggregated analysis across specified segments. Essential for
highlighting financial vulnerabilities and focusing risk management
efforts.

## Usage

``` r
prepare_for_expected_loss_plot(analysis_data, facet_var)
```

## Arguments

- analysis_data:

  Dataset including detailed financial risk metrics, to be transformed
  for visualization.

- facet_var:

  Segmentation variable used to categorize and analyze financial risk
  across different divisions.

## Value

Dataframe optimized for visualizing financial risk, with aggregated
metrics for each segment.
