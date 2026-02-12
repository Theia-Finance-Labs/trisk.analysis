# Fetch Data from PostgreSQL and Run Transition Risk Aggregation

This function connects to a PostgreSQL database, retrieves required
datasets, and runs the \`run_trisk_agg\` function to perform transition
risk aggregation.

## Usage

``` r
run_trisk_from_db(baseline_scenario, target_scenario, ...)
```

## Arguments

- baseline_scenario:

  A character string representing the baseline scenario.

- target_scenario:

  A character string representing the target scenario.

- ...:

  Additional parameters passed to the \`run_trisk_agg\` function.

## Value

A list containing the results of the \`run_trisk_agg\` function: -
\`npv_results\`: Net Present Value results. - \`pd_results\`:
Probability of Default results. - \`company_trajectories\`: Aggregated
company trajectories.

## Details

The database connection parameters are hardcoded within the function: -
\`dbname\`: "crispydb" - \`host\`: "localhost" - \`port\`: 5432 -
\`user\`: "crispydb_user" - \`password\`: "crispypassword"

The function fetches the following datasets from the database: -
\`assets_data\` (retrieved from the \`assets_data\` table) -
\`scenarios_data\` (retrieved from the \`scenarios_data\` table) -
\`financial_data\` (retrieved from the \`financial_data\` table) -
\`carbon_data\` (retrieved from the \`carbon_data\` table)

After retrieving the data, it passes them along with additional
parameters to the \`run_trisk_agg\` function and returns the results.
