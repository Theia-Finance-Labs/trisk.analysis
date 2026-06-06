# Aggregate TRISK facts to a grouping (country-aggregate path)

AGG1: PD is aggregated with \`median()\` across the counterparties in
each group — a deliberate robust central-tendency choice for the
country/aggregate path, where group members are heterogeneous and a few
extreme Merton PDs would dominate an unweighted mean. It is \*\*not\*\*
exposure-weighted (exposure is not available at this stage — it is
joined afterwards in \`merge_portfolio()\`), so the aggregated PD is
representative, not portfolio-weighted; weight by exposure downstream if
a portfolio-weighted PD is required. NPV is summed.

## Usage

``` r
aggregate_facts_trisk(analysis_data, group_cols)
```

## Arguments

- analysis_data:

  analysis_data

- group_cols:

  group_cols
