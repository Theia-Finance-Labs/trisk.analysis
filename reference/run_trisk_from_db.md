# Fetch Data from PostgreSQL and Run Transition Risk Aggregation

Connects to a PostgreSQL database, retrieves the required datasets, and
runs \[run_trisk_agg()\].

## Usage

``` r
run_trisk_from_db(baseline_scenario, target_scenario, conn = NULL, ...)
```

## Arguments

- baseline_scenario:

  A character string representing the baseline scenario.

- target_scenario:

  A character string representing the target scenario.

- conn:

  Optional open DBI connection. When \`NULL\` (default), a connection is
  built from the \`TRISK_DB\_\*\` environment variables and closed on
  exit.

- ...:

  Additional parameters passed to \[run_trisk_agg()\].

## Value

A list with \`npv_results\`, \`pd_results\`, and
\`company_trajectories\`.

## Details

Credentials are \*\*never\*\* hardcoded. Supply the connection one of
two ways:

- Pass an open DBI connection via \`conn\` (recommended — the caller
  owns secret management and connection lifetime); or

- Leave \`conn = NULL\` and set environment variables, which are read at
  call time: \`TRISK_DB_NAME\`, \`TRISK_DB_HOST\`, \`TRISK_DB_USER\`,
  \`TRISK_DB_PASSWORD\`, and optional \`TRISK_DB_PORT\` (default
  \`5432\`). Missing required variables raise an error before any
  connection attempt.

When \`conn = NULL\`, the connection opened here is closed on exit. A
caller-supplied \`conn\` is left open for the caller to manage.

The following datasets are fetched: assets (\`public_marts.assets\`),
scenarios (\`public_marts.scenarios\`), financial features
(\`public_marts.financial_features\`), and carbon prices
(\`public_marts.ngfs_carbon_prices\`).
