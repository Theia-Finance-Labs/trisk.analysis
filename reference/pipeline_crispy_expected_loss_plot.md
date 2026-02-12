# Financial Risk Visualization via Expected Loss and Exposure Plot

Generates a plot that visualizes financial risk by showcasing expected
losses and exposure across different segments. It preprocesses data for
visual representation and uses faceting to provide insights into risk
distribution across specified categories, aiding in targeted risk
mitigation strategies.

## Usage

``` r
pipeline_crispy_expected_loss_plot(
  analysis_data,
  facet_var = "sector",
  granularity = c("sector")
)
```

## Arguments

- analysis_data:

  Dataframe with financial exposure and expected loss data, segmented by
  various categories.

- facet_var:

  Categorical variable for segmenting the data, enabling detailed risk
  analysis across segments.

- granularity:

  Character vector specifying the grouping columns for aggregation.

## Value

A ggplot object displaying financial risks segmented by \`facet_var\`,
crucial for risk management decisions.
