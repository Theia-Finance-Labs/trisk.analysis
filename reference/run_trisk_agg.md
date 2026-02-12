# Run TRISK Model with Aggregated Results

This function performs the transition risk model calculations but
returns aggregated results, removing the \`country_iso2\` column.

## Usage

``` r
run_trisk_agg(
  assets_data,
  scenarios_data,
  financial_data,
  carbon_data,
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

- baseline_scenario:

  String specifying the name of the baseline scenario.

- target_scenario:

  String specifying the name of the shock scenario.

- ...:

  Additional arguments passed to
  [`run_trisk_model`](https://rdrr.io/pkg/trisk.model/man/run_trisk_model.html).

## Value

A list containing aggregated results with \`country_iso2\` removed: -
\`npv_results\`: Aggregated NPV results by \`company_id\`, \`sector\`,
and \`technology\`. - \`pd_results\`: Aggregated PD results by
\`company_id\`, \`sector\`, and \`term\`. - \`company_trajectories\`:
Aggregated company trajectories by \`company_id\`, \`sector\`, and
\`technology\`.
