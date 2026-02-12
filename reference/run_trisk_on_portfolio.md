# Run TRISK Model on Portfolio

This function runs the TRISK model on a given portfolio, processing
various input data and returning analysis results. It's designed to be
the primary data processing function for generating plots.

## Usage

``` r
run_trisk_on_portfolio(
  assets_data,
  scenarios_data,
  financial_data,
  carbon_data,
  portfolio_data,
  baseline_scenario,
  target_scenario,
  threshold = 0.5,
  method = "lcs",
  ...
)
```

## Arguments

- assets_data:

  Data frame containing asset information.

- scenarios_data:

  Data frame containing scenario information.

- financial_data:

  Data frame containing financial information.

- carbon_data:

  Data frame containing carbon price information.

- portfolio_data:

  Data frame containing portfolio information.

- baseline_scenario:

  String specifying the name of the baseline scenario.

- target_scenario:

  String specifying the name of the shock scenario.

- threshold:

  max distance for validating a fuzzy match

- method:

  String specifying method to use for fuzzy matching. See help of
  stringdist::stringdistmatrix for possible values.

- ...:

  Additional arguments passed to
  [`run_trisk_model`](https://rdrr.io/pkg/trisk.model/man/run_trisk_model.html).

## Value

A data frame containing the processed and analyzed portfolio data.
