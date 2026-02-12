# Visualize Trajectory Risks Over Time by Business Unit and Sector

This function generates a line plot visualizing the trajectory of risks
over time for the "production_shock_scenario", segmented by business
units and differentiated by sectors.

## Usage

``` r
plot_multi_trajectories(
  trajectories_data,
  x_var = "year",
  facet_var = "technology",
  linecolor = "run_id",
  y_in_percent = TRUE
)
```

## Arguments

- trajectories_data:

  Dataframe containing yearly data on risk trajectories across different
  business units and sectors.

- x_var:

  The time variable, defaulting to "year".

- facet_var:

  The variable for faceting the plot by business units, defaulting to
  "ald_business_unit".

- linecolor:

  Variable determining line colors by sector, defaulting to
  "ald_sector".

- y_in_percent:

  plots in percent or absolute

## Value

A ggplot object displaying the trend of the "production_shock_scenario"
over time, providing insights into risk management and strategic
planning.
