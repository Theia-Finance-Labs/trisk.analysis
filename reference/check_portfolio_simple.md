# Check Simple Portfolio

Validates that the portfolio data has the columns required for a simple
portfolio: `company_id`, `company_name`, `exposure_value_usd`, `term`,
`loss_given_default`. No `country_iso2` is required.

## Usage

``` r
check_portfolio_simple(portfolio_data)
```

## Arguments

- portfolio_data:

  Data frame containing portfolio information.

## Value

The input `portfolio_data` (invisibly).
