# Generate Exposure Change and Value Loss Plot

Constructs the final plot visualizing sector/category-wise changes in
financial exposure and value losses, using a combination of bar and tile
geoms to represent data points and their positive/negative changes.
Faceting can be applied for more detailed analysis. This function
integrates aesthetic elements and scales to effectively communicate the
financial impact.

## Usage

``` r
draw_exposure_change_plot(
  data_exposure_change,
  x_var,
  y_exposure_var,
  y_value_loss_var,
  facet_var = NULL
)
```

## Arguments

- data_exposure_change:

  Prepared dataframe for plotting.

- x_var:

  Category or sector variable for the x-axis.

- y_exposure_var:

  Metric for exposure value.

- y_value_loss_var:

  Metric for crispy value loss.

- facet_var:

  Optional; variable to facet the plot by.

## Value

A ggplot object depicting exposure changes and value losses, crucial for
detailed financial impact analysis.
