# Join TRISK Outputs to Portfolio

This function joins the TRISK model outputs (NPV and PD results) to the
portfolio data.

## Usage

``` r
join_trisk_outputs_to_portfolio(portfolio_data, npv_results, pd_results)
```

## Arguments

- portfolio_data:

  Data frame containing portfolio information.

- npv_results:

  Data frame containing NPV (Net Present Value) results from TRISK
  model.

- pd_results:

  Data frame containing PD (Probability of Default) results from TRISK
  model.

## Value

A data frame of portfolio data joined with TRISK model outputs.
