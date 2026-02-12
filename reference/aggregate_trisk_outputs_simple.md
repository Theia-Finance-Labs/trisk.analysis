# Aggregate TRISK outputs for simple portfolio analysis

Aggregate TRISK outputs for simple portfolio analysis

## Usage

``` r
aggregate_trisk_outputs_simple(npv_results, pd_results)
```

## Arguments

- npv_results:

  NPV results from
  [`trisk.model::run_trisk_model()`](https://rdrr.io/pkg/trisk.model/man/run_trisk_model.html).

- pd_results:

  PD results from
  [`trisk.model::run_trisk_model()`](https://rdrr.io/pkg/trisk.model/man/run_trisk_model.html).

## Value

TRISK outputs aggregated without asset/country dimensions.
