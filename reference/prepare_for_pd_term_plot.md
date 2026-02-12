# Prepare Data for PD Term Visualization

Prepares the aggregated crispy data for visualization, focusing on PD
values by term. It transforms the dataset to a long format suitable for
plotting, allowing for a comparative view of PD values under different
scenarios.

## Usage

``` r
prepare_for_pd_term_plot(analysis_data, facet_var)
```

## Arguments

- analysis_data:

  Dataset containing aggregated PD values across terms and scenarios.

- facet_var:

  Faceting variable representing sectors or business units for detailed
  comparative analysis.

## Value

A dataframe in long format, ready for plotting PD values by term and
scenario.
