# Preprocess Data for Exposure and Value Loss Visualization

Transforms given dataset for visualizing changes in exposure and crispy
value losses, selecting only the relevant variables. This step ensures
that the visualization is focused and clear, aiding in the analysis of
financial risk and impact across sectors or categories.

## Usage

``` r
prepare_for_exposure_change_plot(
  analysis_data,
  x_var,
  y_exposure_var,
  y_value_loss_var
)
```

## Arguments

- analysis_data:

  Dataset including financial metrics for exposure and value loss.

- x_var:

  Category or sector variable.

- y_exposure_var:

  Exposure value metric.

- y_value_loss_var:

  Crispy value loss metric.

## Value

A simplified dataframe focusing on selected variables for visualization.
