# Run TRISK sensitivity analysis on multiple scenarios

This function performs a sensitivity analysis by running the TRISK model
on multiple scenarios. It takes a list of parameter sets and runs the
TRISK model for each set, returning a comprehensive set of results that
includes net present value (NPV), probability of default (PD), company
trajectories, and model parameters.

## Usage

``` r
run_trisk_sa(
  assets_data,
  scenarios_data,
  financial_data,
  carbon_data,
  run_params,
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

- run_params:

  A list of parameter sets where each set contains the required
  parameters for a single TRISK model run. Each parameter set must
  include \`scenario_geography\`, \`baseline_scenario\`,
  \`target_scenario\`, and \`shock_year\`. Find their definition and
  other Trisk parameters at
  [`run_trisk_model`](https://rdrr.io/pkg/trisk.model/man/run_trisk_model.html)

- ...:

  Additional arguments passed to
  [`get_filtered_assets_data`](get_filtered_assets_data.md)
  (\`country_iso2\`, \`sector\`, \`technology\`, and \`company_name\`).

## Value

A list of tibbles containing the combined results for all runs. The list
includes tibbles for NPV results (\`npv\`), PD results (\`pd\`), company
trajectories (\`trajectories\`), and model parameters (\`params\`).
