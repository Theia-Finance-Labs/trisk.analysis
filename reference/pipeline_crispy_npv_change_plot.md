# Visualize Sector-wise NPV Percentage Changes

Generates a plot to visualize net present value (NPV) percentage changes
across sectors, facilitating quick insights into sectors' performance
under varying conditions. This function streamlines the data preparation
and plotting process, focusing on key financial metrics for strategic
analysis.

## Usage

``` r
pipeline_crispy_npv_change_plot(
  analysis_data,
  x_var = "technology",
  y_var = "crispy_perc_value_change",
  granularity = c("sector", "technology")
)
```

## Arguments

- analysis_data:

  Dataframe containing sector-wise NPV changes and other financial
  metrics.

- x_var:

  Sector variable for categorization, defaulting to "ald_sector".

- y_var:

  NPV change variable, defaulting to "crispy_perc_value_change".

- granularity:

  Character vector specifying the grouping columns for aggregation.

## Value

A ggplot object illustrating the percentage change in NPV across
sectors, essential for financial and strategic planning.
