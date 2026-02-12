# Draw Line Plot for Risk Trajectories

Creates a line plot to depict the "production_shock_scenario" risk
trajectories as a percentage of the maximum value, offering a visual
comparison within business units and sectors.

## Usage

``` r
draw_trisk_line_plot(
  data_trisk_line_plot,
  x_var,
  facet_var,
  linecolor,
  y_in_percent
)
```

## Arguments

- data_trisk_line_plot:

  Prepared data for plotting, with production percentages.

- x_var:

  Time variable for the x-axis.

- facet_var:

  Variable for faceting plots by business units.

- linecolor:

  Variable for coloring lines by sector.

- y_in_percent:

  plots in percent or absolute

## Value

A ggplot object illustrating risk trajectories over time, aiding in the
analysis of production risk and scenario planning.
