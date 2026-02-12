# Visualize PD Values by Term and Business Unit

Orchestrates the creation of a plot visualizing the probability of
default (PD) values across different terms and sectors or business
units. This function facilitates an understanding of how PD values vary
by term under baseline and shock scenarios, enabling stakeholders to
assess risk exposure.

## Usage

``` r
pipeline_crispy_pd_term_plot(
  analysis_data,
  facet_var = "sector",
  granularity = c("sector", "term")
)
```

## Arguments

- analysis_data:

  Aggregated dataset containing PD values for various terms and
  scenarios across different sectors or business units.

- facet_var:

  The variable by which to facet the plot, typically representing
  different sectors or business units, defaulting to "ald_sector".

- granularity:

  Character vector specifying the grouping columns for aggregation.

## Value

A ggplot object showing PD values by term, differentiated by scenario,
across the specified business units, aiding in strategic risk
management.
