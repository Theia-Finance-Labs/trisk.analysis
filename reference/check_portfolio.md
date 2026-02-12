# Check Portfolio and Match Company IDs

This function checks if the portfolio data contains all required columns
and performs a fuzzy match to assign company IDs based on company names.

## Usage

``` r
check_portfolio(portfolio_data)
```

## Arguments

- portfolio_data:

  Data frame containing portfolio information.

## Value

A data frame of portfolio data with matched company IDs.
