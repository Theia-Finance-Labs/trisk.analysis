# Run TRISK Model on Simple Portfolio

Runs the TRISK model on a simple portfolio that has only `company_id`,
`company_name`, `exposure_value_usd`, `term`, and `loss_given_default`.
No `country_iso2` is required; companies are matched to assets by
`company_id` across all countries. Reuses the same TRISK run and join
logic as [`run_trisk_on_portfolio`](run_trisk_on_portfolio.md), with
join keys `company_id` and `term`.

## Usage

``` r
run_trisk_on_simple_portfolio(
  assets_data,
  scenarios_data,
  financial_data,
  carbon_data,
  portfolio_data,
  baseline_scenario,
  target_scenario,
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

  Data frame with columns `company_id`, `company_name`,
  `exposure_value_usd`, `term`, `loss_given_default` (see
  [`check_portfolio_simple`](check_portfolio_simple.md)).

- baseline_scenario:

  String specifying the name of the baseline scenario.

- target_scenario:

  String specifying the name of the shock scenario.

- ...:

  Additional arguments passed to
  [`run_trisk_model`](https://rdrr.io/pkg/trisk.model/man/run_trisk_model.html).

## Value

A named list with:

- `portfolio_results_tech_detail`: company/term/sector/technology-level
  details.

- `portfolio_results`: portfolio-level results re-aggregated to
  input-row shape.
