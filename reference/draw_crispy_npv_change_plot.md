# Construct NPV Change Visualization Plot

Creates the final visualization for NPV percentage changes across
sectors using a color gradient to represent increase, decrease, or no
change. This function applies a gradient scale to highlight variations
in NPV change, facilitating an intuitive understanding of financial
performance across sectors.

## Usage

``` r
draw_crispy_npv_change_plot(data_crispy_npv_change_plot, x_var, y_var)
```

## Arguments

- data_crispy_npv_change_plot:

  Prepared dataframe for plotting.

- x_var:

  Unified sector categorization variable.

- y_var:

  NPV change percentage variable.

## Value

A ggplot object depicting NPV changes across sectors, crucial for
assessing financial impact and strategic direction.
