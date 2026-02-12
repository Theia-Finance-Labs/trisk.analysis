# Visualize Exposure and Value Loss Changes

Creates a visualization of exposure value changes alongside crispy value
losses for different sectors or categories. It allows for an adjustable
focus through faceting and customization of the exposure and loss
variables. This plot is vital for stakeholders to assess the impact of
various factors on sectoral financial stability and risk exposure.

## Usage

``` r
pipeline_crispy_exposure_change_plot(
  analysis_data,
  x_var = "technology",
  y_exposure_var = "exposure_value_usd",
  y_value_loss_var = "crispy_value_loss",
  facet_var = NULL,
  granularity = c("sector", "technology")
)
```

## Arguments

- analysis_data:

  Dataframe with sector/category-wise financial data.

- x_var:

  Variable on the x-axis, typically sector or category.

- y_exposure_var:

  Variable for exposure values to be visualized.

- y_value_loss_var:

  Variable for crispy value loss to be overlayed.

- facet_var:

  Optional; faceting variable to segment data further.

- granularity:

  Character vector specifying the grouping columns for aggregation.

## Value

A ggplot object that shows changes in exposure values and value losses,
aiding in risk evaluation and management.
