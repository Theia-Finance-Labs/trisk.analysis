# Generate Plot of PD Values by Term and Scenario

Creates a bar plot to visualize the variation of PD values across
different terms, under baseline and shock scenarios, segmented by
business unit. Utilizes a color gradient to distinguish between PD value
magnitudes, facilitating a clear and intuitive comparison of risk
profiles.

## Usage

``` r
draw_pd_term_plot(data_pd_term, facet_var)
```

## Arguments

- data_pd_term:

  Prepared data for plotting, containing term-wise PD values and
  scenarios.

- facet_var:

  Variable used to segment data into different business units for
  faceted visualization.

## Value

A ggplot object depicting the comparative analysis of PD values by term
and scenario, crucial for evaluating financial risk and strategic
planning.
