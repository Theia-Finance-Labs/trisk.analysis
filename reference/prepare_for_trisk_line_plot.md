# Prepare Data for Risk Trajectory Line Plot

Prepares trajectory data for line plot visualization, calculating
production percentages of the maximum value for
"production_shock_scenario" only, and removing the last year of each
"run_id" group.

## Usage

``` r
prepare_for_trisk_line_plot(trajectories_data, facet_var, linecolor)
```

## Arguments

- trajectories_data:

  Dataset containing trajectory information across different scenarios.

- facet_var:

  Variable for faceting plots by business units.

- linecolor:

  Variable for coloring lines by sector.

## Value

A dataframe ready for plotting, with production percentages for
"production_shock_scenario" for visualization, excluding the last year
of each "run_id" group.
