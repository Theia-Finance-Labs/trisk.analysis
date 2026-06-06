# Run TRISK Model on Portfolio (technology-resolved)

Runs the TRISK model on a portfolio resolved to the
`(company, sector, technology, country)` grain, joining the portfolio to
TRISK asset outputs on `technology`. Use this for *technology-resolved*
analysis - e.g. exposure held against a specific technology line, or
NPV-per-technology views. For a standard company-level loan book, use
\[run_trisk_on_simple_portfolio()\], which takes company-level loans and
allocates each loan's exposure across the company's technologies by NPV
share.

Returns analysis results suitable for the package plotting helpers.

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
