# Prepare Data for NPV Change Visualization

Transforms the analysis dataset for visualization, focusing on NPV
percentage changes. It ensures that the data is in the correct format
for the plotting function, enhancing clarity and focus in the visual
representation of NPV changes.

## Usage

``` r
prepare_for_crispy_npv_change_plot(analysis_data, x_var, y_var)
```

## Arguments

- analysis_data:

  Dataset including sector-wise financial metrics and NPV changes.

- x_var:

  Sector categorization variable.

- y_var:

  NPV change percentage variable.

## Value

A dataframe with unified sector categorization, ready for NPV change
visualization.
